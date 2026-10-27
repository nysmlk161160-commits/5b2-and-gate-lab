"""Cocotb tests run by Tiny Tapeout GitHub Actions (RTL and gate-level)."""
import random
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import RisingEdge, FallingEdge, ClockCycles, Timer

WRITE_A, WRITE_B, WRITE_OP, READ_RESULT, READ_FLAGS, IDLE = 0, 1, 2, 3, 4, 7
MASK = 0xFFFFFFFF


def signed32(x):
    x &= MASK
    return x if x < 0x80000000 else x - 0x100000000


def golden(a, b, op):
    a, b = a & MASK, b & MASK
    sh = b & 31
    if op == 0b00010: result = a + b
    elif op == 0b01010: result = a - b
    elif op == 0b00111: result = a | b
    elif op == 0b00011: result = a & b
    elif op == 0b00000: result = a << sh
    elif op == 0b10000: result = a >> sh
    elif op == 0b01001: result = int(signed32(a) < signed32(b))
    else: result = 0
    return result & MASK


async def cycle(dut, cmd, idx=0, data=0):
    await FallingEdge(dut.clk)
    dut.uio_in.value = (idx << 3) | cmd
    dut.ui_in.value = data & 0xFF
    await RisingEdge(dut.clk)
    # Plenty of settle time for optional gate-level unit-delay simulation.
    await Timer(40, unit="ns")


async def write32(dut, cmd, val):
    for i in range(4):
        await cycle(dut, cmd, i, (val >> (i * 8)) & 0xFF)


async def check_alu(dut, a, b, op):
    await write32(dut, WRITE_A, a)
    await write32(dut, WRITE_B, b)
    await cycle(dut, WRITE_OP, 0, op)
    got = 0
    for i in range(4):
        await cycle(dut, READ_RESULT, i)
        got |= int(dut.uo_out.value) << (8 * i)
    await cycle(dut, READ_FLAGS)
    flags = int(dut.uo_out.value)
    expected = golden(a, b, op)
    assert got == expected, (
        f"A={a:08x} B={b:08x} OP={op:05b}: "
        f"got={got:08x} expected={expected:08x}"
    )
    assert flags == (((expected >> 31) & 1) << 1 | int(expected == 0)), (
        f"Flags incorrect: got={flags:02x}, result={expected:08x}"
    )
    assert int(dut.uio_oe.value) == 0
    assert int(dut.uio_out.value) == 0


@cocotb.test()
async def alu_functional_test(dut):
    dut.clk.value = 0
    dut.rst_n.value = 0
    dut.ena.value = 1
    dut.ui_in.value = 0
    dut.uio_in.value = IDLE
    cocotb.start_soon(Clock(dut.clk, 100, unit="ns").start())
    await ClockCycles(dut.clk, 3)
    await FallingEdge(dut.clk)
    dut.rst_n.value = 1

    cases = [
        (0, 0, 0b00010),
        (0x12345678, 0x01020304, 0b00010),
        (0xFFFFFFFF, 1, 0b00010),
        (3, 7, 0b01010),
        (0x80000000, 1, 0b01010),
        (0xABCD1234, 0x0F0F0F0F, 0b00111),
        (0xABCD1234, 0x0F0F0F0F, 0b00011),
        (1, 31, 0b00000),
        (0x80000000, 31, 0b10000),
        (0xFFFFFFFF, 1, 0b01001),
        (1, 0xFFFFFFFF, 0b01001),
        (0, 0, 0b01001),
        (0x12345678, 0x9ABCDEF0, 0b11111),
    ]
    rng = random.Random(2026)
    for op in (0b00010, 0b01010, 0b00111, 0b00011, 0, 0b10000, 0b01001):
        for _ in range(4):
            cases.append((rng.getrandbits(32), rng.getrandbits(32), op))
    for a, b, op in cases:
        await check_alu(dut, a, b, op)
    dut._log.info("PASS: %d directed and random ALU vectors", len(cases))
