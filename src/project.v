// Tiny Tapeout 8-bit bus wrapper for the unchanged 32-bit ALU.
// uio_in[2:0] command; uio_in[4:3] byte index; ui_in[7:0] data.
// Commands: 0 WRITE_A, 1 WRITE_B, 2 WRITE_OP,
//           3 READ_RESULT, 4 READ_FLAGS, 7 IDLE.
`default_nettype none
module tt_um_pengfei_alu32 (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire ena,
    input  wire clk,
    input  wire rst_n
);
    localparam [2:0] WRITE_A = 3'd0;
    localparam [2:0] WRITE_B = 3'd1;
    localparam [2:0] WRITE_OP = 3'd2;
    localparam [2:0] READ_RESULT = 3'd3;
    localparam [2:0] READ_FLAGS = 3'd4;

    wire [2:0] cmd = uio_in[2:0];
    wire [1:0] byte_index = uio_in[4:3];
    reg [31:0] a_reg;
    reg [31:0] b_reg;
    reg [4:0] op_reg;
    wire [31:0] alu_result;
    wire zero;
    wire negative;

    // Four byte-wise writes form each 32-bit operand (little-endian).
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            a_reg  <= 32'd0;
            b_reg  <= 32'd0;
            op_reg <= 5'd0;
        end else if (ena) begin
            case (cmd)
                WRITE_A:  a_reg[byte_index*8 +: 8] <= ui_in;
                WRITE_B:  b_reg[byte_index*8 +: 8] <= ui_in;
                WRITE_OP: op_reg <= ui_in[4:0];
                default: ; // reads and IDLE never modify the operands
            endcase
        end
    end

    alu core (
        .ALUResult (alu_result),
        .Zero      (zero),
        .Negative  (negative),
        .A         (a_reg),
        .B         (b_reg),
        .ALUControl(op_reg)
    );

    // Four byte-wise result reads, or one flags read.
    // Reading never clocks any operand register.
    reg [7:0] read_data;
    always @* begin
        case (cmd)
            READ_RESULT: read_data = alu_result[byte_index*8 +: 8];
            READ_FLAGS:  read_data = {6'b0, negative, zero};
            default:     read_data = 8'b0;
        endcase
    end

    assign uo_out  = read_data;
    assign uio_out = 8'd0;
    assign uio_oe  = 8'd0; // all bidirectional pins used as inputs
    wire unused = &{uio_in[7:5], 1'b0};
endmodule
`default_nettype wire
