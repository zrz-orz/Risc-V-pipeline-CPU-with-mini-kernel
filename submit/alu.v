`define ALU_ADD 4'b0000
`define ALU_SUB 4'b0001
`define ALU_AND 4'b0010
`define ALU_OR 4'b0011
`define ALU_XOR 4'b0100
`define ALU_SLT 4'b0101
`define ALU_SLTU 4'b0110
`define ALU_SLL 4'b0111
`define ALU_SRL 4'b1000
`define ALU_SRA 4'b1001
`define ALU_ADDW 4'b1010
`define ALU_SUBW 4'b1011
`define ALU_SLLW 4'b1100
`define ALU_SRLW 4'b1101
`define ALU_SRAW 4'b1110

module ALU (
  input  clk,
  input  [63:0] a,
  input  [63:0] b,
  input  [3:0]  alu_op,
  output [63:0] res
);

  wire signed [63:0] sa = a;
  wire signed [63:0] sb = b;
  wire signed [31:0] la = a[31:0];
  wire signed [31:0] lb = b[31:0];
  wire [31:0] lau = a[31:0];
  wire [31:0] lbu = b[31:0];
  wire signed [31:0] lres;

  wire signed [63:0] shift = sa >>> sb[5:0];
  wire signed [31:0] lshift = la >>> lbu[4:0];
  
    assign lres = alu_op == `ALU_ADDW ? la + lb :
          alu_op == `ALU_SUBW ? la - lb :
          alu_op == `ALU_SLLW ? lau << lbu[4:0] :
          alu_op == `ALU_SRLW ? lau >> lbu[4:0] :
          alu_op == `ALU_SRAW ? lshift :
          0;
    assign res = alu_op == `ALU_ADD ? sa + sb : 
          alu_op == `ALU_SUB ? sa - sb :
          alu_op == `ALU_AND ? a & b :
          alu_op == `ALU_OR ? a | b :
          alu_op == `ALU_XOR ? a ^ b : 
          alu_op == `ALU_SLT ? (sa < sb ? 64'b1 : 64'b0) :
          alu_op == `ALU_SLTU ? (a < b ? 64'b1 : 64'b0) :
          alu_op == `ALU_SLL ? a << b[5:0] : 
          alu_op == `ALU_SRL ? a >> b[5:0] :
          alu_op == `ALU_SRA ? shift :
          alu_op >= `ALU_ADDW ? { {(64 - 32){lres[31]}}, lres } : 0;
  
endmodule

    
