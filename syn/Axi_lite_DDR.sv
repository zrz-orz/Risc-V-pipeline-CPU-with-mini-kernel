module Axi_lite_DDR #
(
    parameter longint C_S_AXI_DATA_WIDTH	= 64,
    parameter longint C_S_AXI_ADDR_WIDTH	= 64,
    parameter longint MEM_DEPTH             = 64'd4096,
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
    output reg [31:0] debug_visit_times
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

        .debug_axi_wstate(debug_axi_wstate),
        .debug_axi_rstate(debug_axi_rstate),
        .debug_wen_mem(debug_wen_mem),
        .debug_ren_mem(debug_ren_mem),
        .debug_valid_mem(debug_valid_mem)
    );

    wire ui_clk;
    wire ui_clk_sync_rst;
    wire [26:0] app_addr;
    wire [2:0] app_cmd;
    wire app_en;
    wire [127:0] app_wdf_data;
    wire app_wdf_end;
    wire [15:0] app_wdf_mask;
    wire app_wdf_wren;
    wire [127:0] app_rd_data;
    wire app_rd_data_end;
    wire app_rd_data_valid;
    wire app_rdy;
    wire app_wdf_rdy;
    wire init_calib_complete;

    DDR_Ctrl # (
        .C_S_AXI_ADDR_WIDTH (C_S_AXI_ADDR_WIDTH),
        .C_S_AXI_DATA_WIDTH (C_S_AXI_DATA_WIDTH)
    ) ddr_ctrl (
        .ui_clk(ui_clk),
        .ui_clk_sync_rst(ui_clk_sync_rst),
        .addr_mem(addr_mem),
        .wdata_mem(wdata_mem),
        .rdata_mem(rdata_mem),
        .valid_mem(valid_mem),
        .wen_mem(wen_mem),
        .ren_mem(ren_mem),
        .wmask_mem(wmask_mem),
        .app_addr(app_addr),
        .app_cmd(app_cmd),
        .app_en(app_en),
        .app_wdf_data(app_wdf_data),
        .app_wdf_end(app_wdf_end),
        .app_wdf_mask(app_wdf_mask),
        .app_wdf_wren(app_wdf_wren),
        .app_rd_data(app_rd_data),
        .app_rd_data_end(app_rd_data_end),
        .app_rd_data_valid(app_rd_data_valid),
        .app_rdy(app_rdy),
        .app_wdf_rdy(app_wdf_rdy),
        .init_calib_complete(init_calib_complete),

        .debug_ddrctrl_state(debug_ddrctrl_state),
        .debug_app_en(debug_app_en),
        .debug_app_wdf_wren(debug_app_wdf_wren),
        .debug_app_rdy(debug_app_rdy),
        .debug_app_wdf_rdy(debug_app_wdf_rdy),
        .debug_app_rd_data_valid(debug_app_rd_data_valid)
    );

    mig_7series_0 u_my_ddr (
		// Memory interface ports
		.ddr2_cs_n					(ddr2_cs_n),
		.ddr2_addr					(ddr2_addr),
		.ddr2_ba					(ddr2_ba),
		.ddr2_we_n					(ddr2_we_n),
		.ddr2_ras_n					(ddr2_ras_n),
		.ddr2_cas_n					(ddr2_cas_n),
		.ddr2_ck_n					(ddr2_ck_n),
		.ddr2_ck_p					(ddr2_ck_p),
		.ddr2_cke					(ddr2_cke),
		.ddr2_dq					(ddr2_dq),
		.ddr2_dqs_n					(ddr2_dqs_n),
		.ddr2_dqs_p					(ddr2_dqs_p),
		.ddr2_dm					(ddr2_dm),
		.ddr2_odt					(ddr2_odt),
		// Application interface ports
		.app_addr					(app_addr),
		.app_cmd					(app_cmd),
		.app_en						(app_en),
		.app_wdf_rdy				(app_wdf_rdy),
		.app_wdf_data				(app_wdf_data),
		.app_wdf_end				(app_wdf_end),
		.app_wdf_wren				(app_wdf_wren),
		.app_wdf_mask				(app_wdf_mask),
		.app_rd_data				(app_rd_data),
		.app_rd_data_end			(app_rd_data_end),
		.app_rd_data_valid			(app_rd_data_valid),
		.app_rdy					(app_rdy),
		.app_sr_req					(1'b0),
        .app_sr_active              (),
		.app_ref_req				(1'b0),
        .app_ref_ack                (),
		.app_zq_req					(1'b0),
        .app_zq_ack                 (),
		.init_calib_complete		(init_calib_complete),
		.ui_clk                     (ui_clk),
		.ui_clk_sync_rst            (ui_clk_sync_rst),
		// System Clock Ports
		.sys_clk_i					(clk_100mhz),
		// Reference Clock Ports
		.clk_ref_i					(clk_200mhz),
		.sys_rst					(slave_ift.rstn)
	);
	
	reg old_en;
	always@(posedge slave_ift.clk)begin
	   if(~slave_ift.rstn)begin
	       old_en<=1'b0;
	   end else begin
	       old_en<=wen_mem|ren_mem;
	   end
	end
	
	reg [31:0] cnt;
	always@(posedge slave_ift.clk)begin
	   if(~slave_ift.rstn)begin
	       cnt<=32'b0;
	   end else if(old_en==1'b0&(wen_mem|ren_mem))begin
	       cnt<=cnt+32'b1;
	   end
	end
	assign debug_visit_times=cnt;
	
endmodule