module StallUnit (
    input [4:0] IF_rs1,
    input [4:0] IF_rs2,
    input [4:0] ID_rs1,
    input [4:0] ID_rs2,
    input [4:0] EXE_rd,
    input [4:0] MEM_rd,
    input [4:0] WB_rd,
    input EXE_we_reg,
    input MEM_we_reg,
    input WB_we_reg,
    input jump,
    output wire stall_PC,
    output wire stall_IFID,
    output wire stall_IDEXE,
    output wire stall_EXEMEM,
    output wire stall_MEMWB,
    output wire flush_IFID,
    output wire flush_IDEXE,
    output wire flush_EXEMEM,
    output wire flush_MEMWB,
    output wire [1:0] forwardingA,
    output wire [1:0] forwardingB,
    input wire if_stall,
    input wire mem_stall,
    input wire switch_mode,
    input wire except_happen,
    input wire interrupt
);
    reg [1:0] ForwardingA, ForwardingB;

    always @(*) begin
        
        if (MEM_we_reg && (MEM_rd != 0) && MEM_rd == ID_rs1) ForwardingA = 2'b10;
        else ForwardingA = 0;

        if (MEM_we_reg && (MEM_rd != 0) && MEM_rd == ID_rs2) ForwardingB = 2'b10;
        else ForwardingB = 0;

        if (WB_we_reg && (WB_rd != 0) && WB_rd == ID_rs1 && 
        ~(MEM_we_reg && (MEM_rd != 0) && MEM_rd == ID_rs1)) ForwardingA = 2'b01;
        else ForwardingA = 0;

        if (WB_we_reg && (WB_rd != 0) && WB_rd == ID_rs2 && 
        ~(MEM_we_reg && (MEM_rd != 0) && MEM_rd == ID_rs2)) ForwardingB = 2'b01;
        else ForwardingB = 0;

    end

    assign stall_IFID = mem_stall | (EXE_we_reg & (IF_rs1 == EXE_rd | IF_rs2 == EXE_rd));
        
    assign stall_PC = if_stall | mem_stall | (EXE_we_reg & (IF_rs1 == EXE_rd | IF_rs2 == EXE_rd));
        
    assign flush_IDEXE = (EXE_we_reg & (IF_rs1 == EXE_rd | IF_rs2 == EXE_rd)) | switch_mode;

    assign flush_IFID = (~stall_IFID & jump) | if_stall | switch_mode | except_happen;

    assign stall_IDEXE = mem_stall;

    assign stall_EXEMEM = mem_stall;

    assign stall_MEMWB = 0;

    assign flush_EXEMEM = switch_mode;

    assign flush_MEMWB = mem_stall | switch_mode;

    assign forwardingA = ForwardingA;

    assign forwardingB = ForwardingB;

endmodule