`timescale 1ns / 1ps
// Standalone SELF-CHECKING SystemVerilog TB. Not used by Cocotb Actions.
module alu_tb;
    logic clk = 1'b0;
    always #5 clk = ~clk;
    logic rst_n = 1'b0, ena = 1'b1;
    logic [7:0] ui_in = 8'h00, uio_in = 8'h07;
    wire [7:0] uo_out, uio_out, uio_oe;
    integer checked = 0;

    tt_um_pengfei_alu32 dut (
        .ui_in(ui_in), .uo_out(uo_out), .uio_in(uio_in),
        .uio_out(uio_out), .uio_oe(uio_oe),
        .ena(ena), .clk(clk), .rst_n(rst_n)
    );

    task automatic bus_cycle(input logic [2:0] cmd,
                             input logic [1:0] idx,
                             input logic [7:0] data_byte);
        @(negedge clk);
        uio_in = {3'b000, idx, cmd};
        ui_in = data_byte;
        @(posedge clk);
        #1;
    endtask

    task automatic write32(input logic [2:0] cmd, input logic [31:0] val);
        for (integer i = 0; i < 4; i = i + 1)
            bus_cycle(cmd, i[1:0], (val >> (8*i)) & 8'hFF);
    endtask

    task automatic check(input logic [31:0] a, input logic [31:0] b,
                         input logic [4:0] op);
        logic [31:0] expected, actual;
        logic [7:0] flags;
        write32(3'd0, a);
        write32(3'd1, b);
        bus_cycle(3'd2, 2'd0, {3'b000, op});
        case (op)
            5'b00010: expected = a + b;
            5'b01010: expected = a - b;
            5'b00111: expected = a | b;
            5'b00011: expected = a & b;
            5'b00000: expected = a << b[4:0];
            5'b10000: expected = a >> b[4:0];
            5'b01001: expected = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            default: expected = 32'd0;
        endcase
        actual = 32'd0;
        for (integer j=0; j<4; j=j+1) begin
            bus_cycle(3'd3, j[1:0], 8'd0);
            actual[j*8 +: 8] = uo_out;
        end
        bus_cycle(3'd4, 2'd0, 8'd0);
        flags = uo_out;
        if (actual !== expected || flags !== {6'd0, expected[31], (expected == 0)}) begin
            $display("FAIL A=%h B=%h op=%b actual=%h expected=%h flags=%h", a,b,op,actual,expected,flags);
            $fatal(1);
        end
        checked = checked + 1;
        $display("PASS %0d: A=%h B=%h op=%b result=%h flags=%h",checked,a,b,op,actual,flags);
    endtask

    initial begin
        $dumpfile("alu_tb.vcd");
        $dumpvars(0, alu_tb);
        repeat (3) @(posedge clk);
        @(negedge clk); rst_n = 1;
        check(32'd20, 32'd30, 5'b00010);
        check(32'hffffffff, 32'd1, 5'b00010);
        check(32'd3, 32'd7, 5'b01010);
        check(32'hABCDEF01, 32'h00FF00FF, 5'b00011);
        check(32'hABCDEF01, 32'h00FF00FF, 5'b00111);
        check(32'h00000001, 32'd31, 5'b00000);
        check(32'h80000000, 32'd31, 5'b10000);
        check(32'hffffffff, 32'd1, 5'b01001);
        check(32'd1, 32'hffffffff, 5'b01001);
        check(32'd0, 32'd0, 5'b11111);
        $display("ALL %0d STANDALONE SYSTEMVERILOG TESTS PASSED", checked);
        $finish;
    end
endmodule
