`include "ExceptStruct.vh"
module IDExceptExamine(
    input clk,
    input rst,
    input stall,
    input flush,

    input [63:0] pc_id,
    input [1:0] priv,
    input [31:0] inst_id,
    input valid_id,
    
    input ExceptStruct::ExceptPack except_id,
    output ExceptStruct::ExceptPack except_exe,
    output except_happen_id
);
    
    import ExceptStruct::ExceptPack;
    ExceptPack except_new;
    ExceptPack except;

    InstExamine instexmaine(
        .PC_i(pc_id),
        .priv_i(priv),
        .inst_i(inst_id),
        .valid_i(valid_id),
        .except_o(except_new)
    );

    assign except=except_id.except?except_id:except_new;
    assign except_happen_id=except_new.except&~except_id.except;

    ExceptReg exceptreg(
        .clk(clk),
        .rst(rst),
        .stall(stall),
        .flush(flush),
        .except_i(except),
        .except_o(except_exe)
    );

endmodule 
