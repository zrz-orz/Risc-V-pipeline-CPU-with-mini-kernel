`include "MMIOStruct.vh"
module Axi_lite_Displayer #
(
    parameter longint C_S_AXI_DATA_WIDTH	= 64,
    parameter longint C_S_AXI_ADDR_WIDTH	= 64
)
(   
    AXI_ift.Slave slave_ift,
    output [63:0] displayer,
    output MMIOStruct::MMIOPack cosim_mmio
);

    wire [C_S_AXI_ADDR_WIDTH-1 : 0] addr_mem;
    wire [C_S_AXI_DATA_WIDTH-1 : 0] wdata_mem;
    wire [C_S_AXI_DATA_WIDTH-1 : 0] rdata_mem;
    wire valid_mem;
    wire wen_mem;
    wire ren_mem;
    wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] wmask_mem;

    MemAxi_lite #(
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH)
    ) memaxi_lite (
        .slave_ift(slave_ift),
        .addr_mem(addr_mem),
        .wdata_mem(wdata_mem),
        .rdata_mem(rdata_mem),
        .ren_mem(ren_mem),
        .wen_mem(wen_mem),
        .wmask_mem(wmask_mem),
        .valid_mem(valid_mem),

        .debug_axi_wstate(),
        .debug_axi_rstate(),
        .debug_wen_mem(),
        .debug_ren_mem(),
        .debug_valid_mem()
    );

    Displayer disp(
        .clk(slave_ift.clk),
        .rstn(slave_ift.rstn),
        .address_i(addr_mem),
        .indata_i(wdata_mem),
        .ren_i(ren_mem),
        .wen_i(wen_mem),
        .mask_i(wmask_mem),
        .outdata_o(rdata_mem),
        .valid_o(valid_mem),
        .display_o(displayer),
        .cosim_mmio(cosim_mmio)
    );

endmodule