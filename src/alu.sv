// 5B2 ALU V0: original seven operations preserved.
module alu (
    output logic [31:0] ALUResult,
    output logic Zero,
    output logic Negative,
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [4:0] ALUControl
);
    always_comb begin
        case (ALUControl)
            5'b00010: ALUResult = A + B;
            5'b01010: ALUResult = A - B;
            5'b00111: ALUResult = A | B;
            5'b00011: ALUResult = A & B;
            5'b00000: ALUResult = A << B[4:0];
            5'b10000: ALUResult = A >> B[4:0];
            5'b01001: ALUResult = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
            default:  ALUResult = 32'd0;
        endcase
    end
    assign Zero     = (ALUResult == 32'd0);
    assign Negative = ALUResult[31];
endmodule
