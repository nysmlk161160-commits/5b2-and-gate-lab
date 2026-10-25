"""RTL and gate-level Cocotb regression for the Tiny Tapeout AND gate.
Works with the official template's Cocotb 2.1.0 and Icarus Verilog.
"""
import cocotb
from cocotb.triggers import Timer


@cocotb.test()
async def test_project(dut):
    """Test basic truth table, all 256 input-bus values, and fixed outputs."""
    dut.clk.value = 0
    dut.rst_n.value = 1
    dut.ena.value = 1
    dut.uio_in.value = 0
    dut.ui_in.value = 0
    await Timer(2, unit="ns")

    # First four vectors appear at the beginning of the waveform.
    for a, b in ((0, 0), (0, 1), (1, 0), (1, 1)):
        ui = a | (b << 1)
        dut.ui_in.value = ui
        await Timer(5, unit="ns")
        y = int(dut.uo_out.value) & 1
        expected = a & b
        assert y == expected, f"Truth table failed: A={a}, B={b}, Y={y}"
        dut._log.info("A=%d B=%d Y=%d -- PASS", a, b, y)

    # Also verify unused ui_in bits and uio_in do not alter the output.
    for ui in range(256):
        dut.ui_in.value = ui
        dut.uio_in.value = ui ^ 0xA5
        await Timer(5, unit="ns")
        expected = (ui & 1) & ((ui >> 1) & 1)
        got = int(dut.uo_out.value)
        assert got == expected, f"ui=0x{ui:02X}: got {got}, expected {expected}"
        assert int(dut.uio_out.value) == 0, "Unused bidirectional outputs not tied low"
        assert int(dut.uio_oe.value) == 0, "Bidirectional pins must be configured as inputs"

    dut._log.info("PASS: four truth-table cases and all 256 ui_in values")
