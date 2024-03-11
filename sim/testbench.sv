`timescale 1ns / 10ps

// Copyright 2023 Sycuricon Group
// Author: Jinyan Xu (phantom@zju.edu.cn)
`include "CSRStruct.vh"
`include "RegStruct.vh"
module Testbench;

	reg clk=1'b0;
	reg rstn=1'b0;

	initial begin
		#20;
		rstn=1'b1;
	end
	always begin
		#5;
		clk=~clk;
	end

	wire [63:0] cosim_pc;
    wire [31:0] cosim_inst;
    wire [ 7:0] cosim_rs1_id;
    wire [63:0] cosim_rs1_data;
    wire [ 7:0] cosim_rs2_id;
    wire [63:0] cosim_rs2_data;
    wire [63:0] cosim_alu;
    wire [63:0] cosim_mem_addr;
    wire [ 3:0] cosim_mem_we;
    wire [63:0] cosim_mem_wdata;
    wire [63:0] cosim_mem_rdata;
    wire [ 3:0] cosim_rd_we;
    wire [ 7:0] cosim_rd_id;
    wire [63:0] cosim_rd_data;
    wire [ 3:0] cosim_br_taken;
	wire [63:0] cosim_npc;
	CSRStruct::CSRPack cosim_csr_info;
	RegStruct::RegPack cosim_regs;
	wire [63:0] cosim_disp;
	wire [63:0] cosim_mtime;
	wire [63:0] cosim_mtimecmp;

	wire cosim_valid;
	wire cosim_mmio_store;
    wire [63:0] cosim_mmio_len;
    wire [63:0] cosim_mmio_val;
	wire [63:0] cosim_mmio_addr;
	wire cosim_interrupt;
	wire [63:0] cosim_cause;

    PipelineCPU dut (   
        .clk(clk),
	    .rstn(rstn),
		.clk_100mhz(1'b0),
		.clk_200mhz(1'b0),
		.ddr2_cs_n(),
		.ddr2_addr(),
		.ddr2_ba(),
		.ddr2_we_n(),
		.ddr2_ras_n(),
		.ddr2_cas_n(),
		.ddr2_ck_n(),
		.ddr2_ck_p(),
		.ddr2_cke(),
		.ddr2_dq(),
		.ddr2_dqs_n(),
		.ddr2_dqs_p(),
		.ddr2_dm(),
		.ddr2_odt(),

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

		.cosim_disp(cosim_disp),
		.cosim_mtime(cosim_mtime),
		.cosim_mtimecmp(cosim_mtimecmp),

		.cosim_valid(cosim_valid),
		.cosim_mmio_store(cosim_mmio_store),
        .cosim_mmio_len(cosim_mmio_len),
        .cosim_mmio_val(cosim_mmio_val),
        .cosim_mmio_addr(cosim_mmio_addr),
		.cosim_interrupt(cosim_interrupt),
        .cosim_cause(cosim_cause),

		.debug_ddrctrl_state(),
        .debug_app_en(),
        .debug_app_wdf_wren(),
        .debug_app_rdy(),
        .debug_app_wdf_rdy(),
        .debug_app_rd_data_valid(),
        .debug_axi_wstate(),
        .debug_axi_rstate(),
        .debug_wen_mem(),
        .debug_ren_mem(),
        .debug_valid_mem(),
		.debug_visit_times()
	);

	`ifdef VERILATE
		wire error;
		cj_comsimulation difftest (   
			.clk(clk),
			.rstn(rstn),
			.cosim_valid(cosim_valid),
			.cosim_pc(cosim_pc),
			.cosim_inst(cosim_inst),
			.cosim_we(cosim_rd_we[0]),
			.cosim_rd(cosim_rd_id[4:0]),
			.cosim_wdate(cosim_rd_data),
			.cosim_mmio_store(cosim_mmio_store),
			.cosim_mmio_len(cosim_mmio_len),
			.cosim_mmio_val(cosim_mmio_val),
			.cosim_mmio_addr(cosim_mmio_addr),
			.cosim_interrupt(cosim_interrupt),
        	.cosim_cause(cosim_cause),
			.error(error)
		);

		initial begin
			$dumpfile({`TOP_DIR,"/Testbench.vcd"});
			$dumpvars(0,dut);
			$dumpon;
		end

		reg [31:0] cnt=32'b0;
		reg [31:0] max_cycles=32'd4000000;
		always@(negedge clk)begin
			cnt<=cnt+32'b1;
			if(error)begin
				$display("[CJ] something error");
				$dumpoff;
				$finish;
			end else if(cnt==max_cycles)begin
				$display("[CJ] no simulation time");
				$dumpoff;
				$finish;
			end
		end
	`endif
endmodule

