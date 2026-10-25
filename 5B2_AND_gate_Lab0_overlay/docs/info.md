# AND Gate Demo

## How it works

This project implements a two-input, one-output combinational AND gate using SKY130 standard-cell ASIC implementation. Input A is `ui_in[0]`, input B is `ui_in[1]`, and output Y is `uo_out[0]`. Y is `A & B`. The seven other dedicated output bits and all bidirectional output/enable bits are tied to 0. No clock or reset is needed.

Truth table:

| A | B | Y |
|---|---|---|
| 0 | 0 | 0 |
| 0 | 1 | 0 |
| 1 | 0 | 0 |
| 1 | 1 | 1 |

## How to test

Drive A and B using `ui_in[0]` and `ui_in[1]`, and read Y at `uo_out[0]`. For RTL simulation, the repository's Cocotb test first exercises all four truth-table combinations, then loops over all 256 values of the dedicated input bus while changing the unused bidirectional inputs. The same test should be executed on the post-synthesis/physical-design gate-level netlist using the template's `gl_test` action.

## External hardware

None. The project is an ASIC flow teaching demo and does not require fabrication or physical hardware testing.
