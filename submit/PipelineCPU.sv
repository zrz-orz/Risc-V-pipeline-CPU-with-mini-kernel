`include "Define.vh"
`include "MMIOStruct.vh"
`include "CSRStruct.vh"
`include "RegStruct.vh"
module PipelineCPU (
    input wire clk,                       /* 时钟 */ 
    input wire rstn,                      /* 重置信号 */ 
    input wire clk_100mhz,
    input wire clk_200mhz,
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
    output wire cosim_valid,
    output wire [63:0] cosim_pc,          /* current pc */
    output wire [31:0] cosim_inst,        /* current instruction */
    output wire [ 7:0] cosim_rs1_id,      /* rs1 id */
    output wire [63:0] cosim_rs1_data,    /* rs1 data */
    output wire [ 7:0] cosim_rs2_id,      /* rs2 id */
    output wire [63:0] cosim_rs2_data,    /* rs2 data */
    output wire [63:0] cosim_alu,         /* alu out */
    output wire [63:0] cosim_mem_addr,    /* memory address */
    output wire [ 3:0] cosim_mem_we,      /* memory write enable */
    output wire [63:0] cosim_mem_wdata,   /* memory write data */
    output wire [63:0] cosim_mem_rdata,   /* memory read data */
    output wire [ 3:0] cosim_rd_we,       /* rd write enable */
    output wire [ 7:0] cosim_rd_id,       /* rd id */
    output wire [63:0] cosim_rd_data,     /* rd data */
    output wire [ 3:0] cosim_br_taken,    /* branch taken? */
    output wire [63:0] cosim_npc,        /* next pc */
    output CSRStruct::CSRPack cosim_csr_info,
    output RegStruct::RegPack cosim_regs,

    output wire [63:0] cosim_disp,
    output [63:0] cosim_mtime,
    output [63:0] cosim_mtimecmp,

    output cosim_mmio_store,
    output [63:0] cosim_mmio_len,
    output [63:0] cosim_mmio_val,
    output [63:0] cosim_mmio_addr,
    output cosim_interrupt,
    output [63:0] cosim_cause,

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
    import MMIOStruct::MMIOPack;

    AXI_ift #(
        .AXI_ADDR_WIDTH(64),
        .AXI_DATA_WIDTH(64)    
    ) mem_axi_ift [3:0] (
        .clk(clk),
        .rstn(rstn)
    );

     AXI_ift #(
        .AXI_ADDR_WIDTH(64),
        .AXI_DATA_WIDTH(64)    
     ) mmio_axi_ift [3:0] (
        .clk(clk),
        .rstn(rstn)
    );

    wire time_int;
    Axi_lite_Core #(
        .C_M_AXI_ADDR_WIDTH(64),
        .C_M_AXI_DATA_WIDTH(64)
    ) axi_lite_core (
        .mem_ift(mem_axi_ift[0].Master),
        .mmio_ift(mmio_axi_ift[0].Master),
        .time_int(time_int),

        .cosim_valid(cosim_valid),
        .cosim_pc(cosim_pc),
	    .cosim_inst(cosim_inst),
	    .cosim_rs1_id(cosim_rs1_id),
	    .cosim_rs1_data(cosim_rs1_data),
	    .cosim_rs2_id(cosim_rs2_id),
	    .cosim_rs2_data(cosim_rs2_data),
	    .cosim_alu(cosim_alu),
	    .cosim_mem_addr(cosim_mem_addr),
	    .cosim_mem_we(cosim_mem_we),
	    .cosim_mem_wdata(cosim_mem_wdata),
	    .cosim_mem_rdata(cosim_mem_rdata),
	    .cosim_rd_we(cosim_rd_we),
	    .cosim_rd_id(cosim_rd_id),
	    .cosim_rd_data(cosim_rd_data),
	    .cosim_br_taken(cosim_br_taken),
	    .cosim_npc(cosim_npc),
        .cosim_csr_info(cosim_csr_info),
        .cosim_regs(cosim_regs),
        .cosim_interrupt(cosim_interrupt),
        .cosim_cause(cosim_cause)
    );

    Axi_lite_Hub #(
        .AXI_ADDR_WIDTH(64),
        .AXI_DATA_WIDTH(64),
        .MEM0_BEGIN(`ROM_BASE),
        .MEM0_END(`ROM_BASE+`ROM_LEN),
        .MEM1_BEGIN(`BUFFER_BASE),
        .MEM1_END(`BUFFER_BASE+`BUFFER_LEN),
        .MEM2_BEGIN(`MEM_BASE),
        .MEM2_END(`MEM_BASE+`MEM_LEN)
    ) mem_hub (
        .clk(clk),
        .rstn(rstn),
        .master(mem_axi_ift[0].Slave),
        .slave0(mem_axi_ift[1].Master),
        .slave1(mem_axi_ift[2].Master),
        .slave2(mem_axi_ift[3].Master)
    );

    `ifdef VERILATE
        localparam ROM_PATH = "rom.hex";
        `ifdef BOARD_SIM
            localparam BUFFER_PATH = "elf.hex";
            localparam KERNEL_PATH = "dummy.hex";
        `else
            localparam BUFFER_PATH = "dummy.hex";
            localparam KERNEL_PATH = "mini_sbi.hex";
        `endif
    `else 
        localparam ROM_PATH = "D:\\txt\\system2\\rom.hex";
        localparam BUFFER_PATH = "D:\\txt\\system2\\elf.hex";
        localparam KERNEL_PATH = "D:\\txt\\system2\\dummy.hex";
    `endif

    Axi_lite_RAM #(
        .C_S_AXI_ADDR_WIDTH(64),
        .C_S_AXI_DATA_WIDTH(64),
        .MEM_DEPTH(`ROM_LEN),
        .FILE_PATH(ROM_PATH)
    ) axi_lite_rom (
        .slave_ift(mem_axi_ift[1].Slave)
    );

    Axi_lite_RAM #(
        .C_S_AXI_ADDR_WIDTH(64),
        .C_S_AXI_DATA_WIDTH(64),
        .MEM_DEPTH(`BUFFER_LEN),
        .FILE_PATH(BUFFER_PATH)
    ) axi_lite_buffer (
        .slave_ift(mem_axi_ift[2].Slave)
    );

    Axi_lite_DDR #(
        .C_S_AXI_ADDR_WIDTH(64),
        .C_S_AXI_DATA_WIDTH(64),
        .MEM_DEPTH(`MEM_LEN),
        .FILE_PATH(KERNEL_PATH)
    ) axi_lite_kernel (
        .clk_100mhz(clk_100mhz),
        .clk_200mhz(clk_200mhz),
        .slave_ift(mem_axi_ift[3].Slave),
        // Memory interface ports
		.ddr2_cs_n(ddr2_cs_n),
		.ddr2_addr(ddr2_addr),
		.ddr2_ba(ddr2_ba),
		.ddr2_we_n(ddr2_we_n),
		.ddr2_ras_n(ddr2_ras_n),
		.ddr2_cas_n(ddr2_cas_n),
		.ddr2_ck_n(ddr2_ck_n),
		.ddr2_ck_p(ddr2_ck_p),
		.ddr2_cke(ddr2_cke),
		.ddr2_dq(ddr2_dq),
		.ddr2_dqs_n(ddr2_dqs_n),
		.ddr2_dqs_p(ddr2_dqs_p),
		.ddr2_dm(ddr2_dm),
		.ddr2_odt(ddr2_odt),

        .debug_ddrctrl_state(debug_ddrctrl_state),
        .debug_app_en(debug_app_en),
        .debug_app_wdf_wren(debug_app_wdf_wren),
        .debug_app_rdy(debug_app_rdy),
        .debug_app_wdf_rdy(debug_app_wdf_rdy),
        .debug_app_rd_data_valid(debug_app_rd_data_valid),
        .debug_axi_wstate(debug_axi_wstate),
        .debug_axi_rstate(debug_axi_rstate),
        .debug_wen_mem(debug_wen_mem),
        .debug_ren_mem(debug_ren_mem),
        .debug_valid_mem(debug_valid_mem),
        .debug_visit_times(debug_visit_times)
    );

    Axi_lite_Hub #(
        .AXI_ADDR_WIDTH(64),
        .AXI_DATA_WIDTH(64),
        .MEM0_BEGIN(`TIME_BASE),
        .MEM0_END(`TIME_BASE+`TIME_LEN),
        .MEM1_BEGIN(`DISP_BASE),
        .MEM1_END(`DISP_BASE+`DISP_LEN),
        .MEM2_BEGIN(`UART_BASE),
        .MEM2_END(`UART_BASE+`UART_LEN)
    ) mmio_hub (
        .clk(clk),
        .rstn(rstn),
        .master(mmio_axi_ift[0].Slave),
        .slave0(mmio_axi_ift[1].Master),
        .slave1(mmio_axi_ift[2].Master),
        .slave2(mmio_axi_ift[3].Master)
    );

    MMIOPack cosim_mmio_timer;
    Axi_lite_Timer #(
        .C_S_AXI_DATA_WIDTH(64),
        .C_S_AXI_ADDR_WIDTH(64)
    ) timer (   
        .slave_ift(mmio_axi_ift[1].Slave),
        .time_int(time_int),
        .cosim_mmio(cosim_mmio_timer),
        .cosim_mtime(cosim_mtime),
        .cosim_mtimecmp(cosim_mtimecmp)
    );

    MMIOPack cosim_mmio_disp;
    Axi_lite_Displayer #(
        .C_S_AXI_DATA_WIDTH(64),
        .C_S_AXI_ADDR_WIDTH(64)
    ) displayer (   
        .slave_ift(mmio_axi_ift[2].Slave),
        .displayer(cosim_disp),
        .cosim_mmio(cosim_mmio_disp)
    );

    MMIOPack cosim_mmio_uart;
    Axi_lite_Uart #(
        .C_S_AXI_DATA_WIDTH(64),
        .C_S_AXI_ADDR_WIDTH(64)
    ) uart (   
        .slave_ift(mmio_axi_ift[3].Slave),
        .TxD(),
        .RxD(),
        .RTSn(),
        .CTSn(),
        .cosim_mmio(cosim_mmio_uart)
    );

    MMIOPack cosim_mmio;
    Cosim_MMIO cosim_mmio_choose(
        .timer_mmio(cosim_mmio_timer),
        .disp_mmio(cosim_mmio_disp),
        .uart_mmio(cosim_mmio_uart),
        .cosim_mmio(cosim_mmio) 
    );
    assign cosim_mmio_store=cosim_mmio.store;
    assign cosim_mmio_len=cosim_mmio.len;
    assign cosim_mmio_val=cosim_mmio.val;
    assign cosim_mmio_addr=cosim_mmio.addr;

endmodule
