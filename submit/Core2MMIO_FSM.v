module Core2MMIO_FSM (
    input wire clk,
    input wire rstn,
    input wire [63:0] address_cpu,
    input wire wen_cpu,
    input wire ren_cpu,
    input wire [63:0] wdata_cpu,
    input wire [7:0] wmask_cpu,
    output [63:0] rdata_cpu,
    output mem_stall,

    output wire [63:0] address_mem,
    output wire ren_mem,
    output wire wen_mem,
    output wire [7:0] wmask_mem,
    output wire [63:0] wdata_mem,
    input wire [63:0] rdata_mem,
    input wire valid_mem
);

    assign address_mem=address_cpu;
    assign wen_mem=wen_cpu;
    assign ren_mem=ren_cpu;
    assign wdata_mem=wdata_cpu;
    assign wmask_mem=wmask_cpu;
    assign rdata_cpu=rdata_mem;
    assign mem_stall=~valid_mem&(wen_cpu|ren_cpu);

endmodule