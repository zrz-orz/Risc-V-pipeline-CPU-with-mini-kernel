module Axi_lite_DDR_sim #
(
    parameter longint C_S_AXI_DATA_WIDTH	= 64,
    parameter longint C_S_AXI_ADDR_WIDTH	= 64,
    parameter longint MEM_DEPTH             = 64'h80000000,
    parameter FILE_PATH                     = "testcase.hex"
)
(   
    input clk_100mhz,
    input clk_200mhz,
    AXI_ift.Slave slave_ift,
    inout [15:0]  ddr2_dq,
	inout [1:0]	  ddr2_dqs_n,
	inout [1:0]	  ddr2_dqs_p,
	output [12:0] ddr2_addr,
	output [2:0]  ddr2_ba,
	output		  ddr2_ras_n,
	output		  ddr2_cas_n,
	output		  ddr2_we_n,
	output [0:0]  ddr2_ck_p,
	output [0:0]  ddr2_ck_n,
	output [0:0]  ddr2_cke,
	output [0:0]  ddr2_cs_n,
	output [1:0]  ddr2_dm,
	output [0:0]  ddr2_odt,

    output [2:0] debug_ddrctrl_state,
    output debug_app_en,
    output debug_app_wdf_wren,
    output debug_app_rdy,
    output debug_app_wdf_rdy,
    output debug_app_rd_data_valid,
    output wire [1:0] debug_axi_wstate,
    output wire [1:0] debug_axi_rstate,
    output wire debug_wen_mem,
    output wire debug_ren_mem,
    output wire debug_valid_mem,
    output [31:0] debug_visit_times
);

    Axi_lite_RAM #(
        .C_S_AXI_ADDR_WIDTH(C_S_AXI_ADDR_WIDTH),
        .C_S_AXI_DATA_WIDTH(C_S_AXI_DATA_WIDTH),
        .MEM_DEPTH(MEM_DEPTH),
        .FILE_PATH(FILE_PATH)
    ) axi_lite_ram (
        .slave_ift(slave_ift)
    );

    assign ddr2_dq=16'bz;
    assign ddr2_dqs_n=2'bz;
    assign ddr2_dqs_p=2'bz;
    assign ddr2_addr=13'b0;
    assign ddr2_ba=3'b0;
    assign ddr2_ras_n=1'b0;
    assign ddr2_cas_n=1'b0;
    assign ddr2_we_n=1'b0;
    assign ddr2_ck_p=1'b0;
    assign ddr2_ck_n=1'b0;
    assign ddr2_cke=1'b0;
    assign ddr2_cs_n=1'b0;
    assign ddr2_dm=2'b0;
    assign ddr2_odt=1'b0;

    assign debug_ddrctrl_state=3'b0;
    assign debug_app_en=1'b0;
    assign debug_app_wdf_wren=1'b0;
    assign debug_app_rdy=1'b0;
    assign debug_app_wdf_rdy=1'b0;
    assign debug_app_rd_data_valid=1'b0;
    assign debug_axi_wstate=2'b0;
    assign debug_axi_rstate=2'b0;
    assign debug_wen_mem=1'b0;
    assign debug_ren_mem=1'b0;
    assign debug_valid_mem=1'b0;
    assign debug_visit_times=32'b0;

endmodule