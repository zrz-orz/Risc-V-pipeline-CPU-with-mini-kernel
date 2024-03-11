// Define Segment
`define OP_R 3'd0
`define OP_I 3'd1
`define OP_S 3'd2
`define OP_B 3'd3
`define OP_U 3'd4
`define OP_J 3'd5
// End Define



module Inst_parser (
    input [31:0] inst,
    output [6:0] _opcode,
    output [2:0] _funct3,
    output [6:0] _funct7,
    output [4:0] _rs1,
    output [4:0] _rs2,
    output [4:0] _rd,
    output [2:0] _optype
);

function [2:0] get_optype;
    input [6:0] opcode;
    begin
        case(opcode)
            7'b1100011: get_optype = `OP_B;
            7'b1101111: get_optype = `OP_J;
            7'b1100111: get_optype = `OP_I;
            7'b0110111: get_optype = `OP_U;
            7'b0000111: get_optype = `OP_I;
            7'b0100011: get_optype = `OP_S;
            7'b0010011: get_optype = `OP_I;
            7'b0110011: get_optype = `OP_R;
            7'b0000011: get_optype = `OP_I;
            7'b1110011: get_optype = `OP_I;
            default: get_optype = 3'b0;
        endcase
    end
endfunction

  wire [6:0] opcode = inst[6:0];
  wire [2:0] optype;
  assign optype = get_optype(opcode);
  wire [2:0] funct3;
  assign funct3 = 
                optype == `OP_R ||
                optype == `OP_I ||
                optype == `OP_S ||
                optype == `OP_B
                ? inst[14:12] : 3'b0;
  wire [6:0] funct7;
  assign funct7 = optype == `OP_R ? inst[31:25] : 7'b0;
  wire [4:0] rs1;
  assign rs1 = optype==`OP_R ||
                optype==`OP_I ||
                optype==`OP_S ||
                optype==`OP_B
                ? inst[19:15]
                : 5'b0;
  wire [4:0] rs2;
  assign rs2 = optype==`OP_R ||
                optype==`OP_S ||
                optype==`OP_B
                ? inst[24:20]
                : 5'b0;
  wire [4:0] rd;
  assign rd =  optype==`OP_R ||
                optype==`OP_I ||
                optype==`OP_U ||
                optype==`OP_J
                ? inst[11:7]
                : 5'b0;

  assign _opcode = opcode;
  assign _funct3 = funct3;
  assign _funct7 = funct7;
  assign _rs1 = rs1;
  assign _rs2 = rs2;
  assign _rd = rd;
  assign _optype = optype;
endmodule
