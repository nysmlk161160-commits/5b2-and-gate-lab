// Tiny Tapeout SKY130 - combinational AND gate (teaching demonstration)
// SPDX-License-Identifier: Apache-2.0
`default_nettype none
module tt_um_and_demo (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);
    wire a = ui_in[0];
    wire b = ui_in[1];
    wire y = a & b;

    // Tie every unused output to a known value, as required by the template.
    assign uo_out  = {7'b0000000, y};
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;  // All bidirectional pins are inputs.

    // Explicitly acknowledge unused inputs to help keep lint logs clean.
    wire _unused = &{ena, clk, rst_n, ui_in[7:2], uio_in, 1'b0};
endmodule
`default_nettype wire
