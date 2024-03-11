module Axi_lite_RAM #
(
    parameter longint C_S_AXI_DATA_WIDTH	= 64,
    parameter longint C_S_AXI_ADDR_WIDTH	= 64,
    parameter longint MEM_DEPTH             = 4096,
    parameter FILE_PATH                     = "testcase.hex"
)
(   
    AXI_ift.Slave slave_ift
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

    RAM #(
        .MEM_DEPTH(MEM_DEPTH),
        .FILE_PATH(FILE_PATH)
    ) ram(
        .clk(slave_ift.clk),
        .rstn(slave_ift.rstn),
        .ren(ren_mem),
        .wen(wen_mem),
        .rw_addr(addr_mem[$clog2(MEM_DEPTH)-1:3]),
        .rw_wdata(wdata_mem),
        .rw_wmask(wmask_mem),
        .rw_rdata(rdata_mem),
        .valid(valid_mem)
    );

endmodule