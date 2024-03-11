`timescale 1ns / 1ps

// Copyright 2023 Sycuricon Group
// Author: Jinyan Xu (phantom@zju.edu.cn)
`include "CSRStruct.vh"
`include "RegStruct.vh"
module top (
    input wire         clk,
	input wire         rstn,
    input wire  [15:0] switch, 
    input wire  [ 4:0] btn,
    output wire [15:0] led,
    output wire [ 7:0] cs,
    output wire [ 7:0] an,
    output wire        vga_hs,
    output wire        vga_vs,
    output wire [ 3:0] vga_r,
    output wire [ 3:0] vga_g,
    output wire [ 3:0] vga_b,

    inout [15:0]		ddr2_dq,
	inout [1:0]			ddr2_dqs_n,
	inout [1:0]			ddr2_dqs_p,
	output [12:0]		ddr2_addr,
	output [2:0]		ddr2_ba,
	output				ddr2_ras_n,
	output				ddr2_cas_n,
	output				ddr2_we_n,
	output [0:0]		ddr2_ck_p,
	output [0:0]		ddr2_ck_n,
	output [0:0]		ddr2_cke,
	output [0:0]		ddr2_cs_n,
	output [1:0]		ddr2_dm,
	output [0:0]		ddr2_odt
);
    wire clk_core;
    wire cosim_mmio_store;
    wire [63:0] cosim_mmio_len;
    wire [63:0] cosim_mmio_val;
	wire [63:0] cosim_mmio_addr;
	wire cosim_interrupt;
	wire [63:0] cosim_cause;

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

    wire [2:0] debug_ddrctrl_state;
    wire debug_app_en;
    wire debug_app_wdf_wren;
    wire debug_app_rdy;
    wire debug_app_wdf_rdy;
    wire debug_app_rd_data_valid;
    wire [1:0] debug_axi_wstate;
    wire [1:0] debug_axi_rstate;
    wire debug_wen_mem;
    wire debug_ren_mem;
    wire debug_valid_mem;
    wire [31:0] debug_visit_times;

    assign led[2:0]=debug_ddrctrl_state;
    assign led[3]=debug_app_en;
    assign led[4]=debug_app_rdy;
    assign led[5]=debug_app_wdf_rdy;
    assign led[6]=debug_app_rd_data_valid;
    assign led[8:7]=debug_axi_rstate;
    assign led[10:9]=debug_axi_wstate;
    assign led[11]=debug_wen_mem;
    assign led[12]=debug_ren_mem;
    assign led[13]=debug_valid_mem;
    assign led[14]=debug_app_wdf_wren;
    assign led[15]=cosim_valid;

    wire clk_100mhz;
    wire clk_200mhz;
    clk_wiz_0 clk_div(
	   .clk_in1(clk),
	   .reset(~rstn),
       .locked(),
       .clk_out1(clk_200mhz),
       .clk_out2(clk_100mhz)	   
	);

    PipelineCPU dut (   
        .clk(clk_core),
	    .rstn(rstn),
        .clk_100mhz(clk_100mhz),
        .clk_200mhz(clk_200mhz),
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
        .cosim_disp(cosim_disp),
        .cosim_mtime(cosim_mtime),
        .cosim_mtimecmp(cosim_mtimecmp),
        
        .cosim_mmio_store(cosim_mmio_store),
        .cosim_mmio_len(cosim_mmio_len),
        .cosim_mmio_val(cosim_mmio_val),
        .cosim_mmio_addr(cosim_mmio_addr),
		.cosim_interrupt(cosim_interrupt),
        .cosim_cause(cosim_cause),

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
	
    reg old_clk_core;
    always@(posedge clk)begin
        if(~rstn)old_clk_core<=1'b0;
        else old_clk_core<=clk_core; 
    end
    wire clk_core_posedge=clk_core&~old_clk_core;

	reg [31:0] commit_num;
	always@(posedge clk)begin
	   if(~rstn)begin
	       commit_num<=32'b0;
	   end else if(clk_core_posedge&cosim_valid)begin
	       commit_num<=commit_num+32'b1;
	   end
	end
    
    IO io(
        .clk(clk),
        .rstn(rstn),
        .clk_core(clk_core),
        .switch(switch),
        .btn(btn),
        .cs(cs),
        .an(an),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b),
        .vga_hs(vga_hs),
        .vga_vs(vga_vs),
        .cosim_valid(cosim_valid),
        .cosim_pc(cosim_pc),
        .cosim_inst({32'b0,cosim_inst}),
        .cosim_rs1_id({56'b0,cosim_rs1_id}),
        .cosim_rs1(cosim_rs1_data),
        .cosim_rs2_id({56'b0,cosim_rs2_id}),
        .cosim_rs2(cosim_rs2_data),
        .cosim_alu(cosim_alu),
        .cosim_mem_addr(cosim_mem_addr),
        .cosim_mem_we({60'b0,cosim_mem_we}),
        .cosim_mem_wdata(cosim_mem_wdata),
        .cosim_mem_rdata(cosim_mem_rdata),
        .cosim_rd_id({56'b0,cosim_rd_id}),
        .cosim_rd_we({60'b0,cosim_rd_we}),
        .cosim_rd(cosim_rd_data),
        .cosim_br_taken({60'b0,cosim_br_taken}),
        .cosim_npc(cosim_npc),

        .cosim_csr_info(cosim_csr_info),
        .cosim_regs(cosim_regs),

        .cosim_disp(cosim_disp),
        .cosim_commit_num({32'b0,commit_num}),
        .cosim_ddr_visit_times({32'b0,debug_visit_times}),
        .cosim_mtime(cosim_mtime),
        .cosim_mtimecmp(cosim_mtimecmp)
    );

endmodule

