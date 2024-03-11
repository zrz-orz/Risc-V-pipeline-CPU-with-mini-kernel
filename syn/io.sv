`timescale 1ns / 1ps

// Copyright 2023 Sycuricon Group
// Author: Jinyan Xu (phantom@zju.edu.cn)
`include "CSRStruct.vh"
`include "DebugStruct.vh"
`include "RegStruct.vh"
module IO (
    input  wire        clk,
    input  wire        rstn,

    // to cpu
    output wire        clk_core,
    
    // to gpio
    input  wire [15:0] switch,
    input  wire [ 4:0] btn,
    output wire [ 7:0] cs,
    output wire [ 7:0] an,
    output wire [ 3:0] vga_r,
    output wire [ 3:0] vga_g,
    output wire [ 3:0] vga_b,
    output wire        vga_hs,
    output wire        vga_vs,
    
    // debug
    input wire  cosim_valid,
    input wire  [63:0] cosim_pc,
    input wire  [63:0] cosim_inst,
    input wire  [63:0] cosim_rs1_id,
    input wire  [63:0] cosim_rs1,
    input wire  [63:0] cosim_rs2_id,
    input wire  [63:0] cosim_rs2,
    input wire  [63:0] cosim_alu,
    input wire  [63:0] cosim_mem_addr,
    input wire  [63:0] cosim_mem_we,
    input wire  [63:0] cosim_mem_wdata,
    input wire  [63:0] cosim_mem_rdata,
    input wire  [63:0] cosim_rd_id,
    input wire  [63:0] cosim_rd_we,
    input wire  [63:0] cosim_rd,
    input wire  [63:0] cosim_br_taken,
    input wire  [63:0] cosim_npc,

    input CSRStruct::CSRPack cosim_csr_info,
    input RegStruct::RegPack cosim_regs,

    input [63:0] cosim_disp,
    input [63:0] cosim_commit_num,
    input [63:0] cosim_ddr_visit_times,
    input [63:0] cosim_mtime,
    input [63:0] cosim_mtimecmp
);

    wire [31:0] clk_div;
    Divider div(clk, clk_div);

    wire [4:0] btn_dbnc;
    Debouncer bd4(clk_div[10], btn[4], btn_dbnc[4]);
    Debouncer bd3(clk_div[10], btn[3], btn_dbnc[3]);
    Debouncer bd2(clk_div[10], btn[2], btn_dbnc[2]);
    Debouncer bd1(clk_div[10], btn[1], btn_dbnc[1]);
    Debouncer bd0(clk_div[10], btn[0], btn_dbnc[0]);

    wire debug_flag;
    wire debug_step;
    DebugStruct::DebugPack debug_info;
    DebugModule dm(
        .clk(clk),
        .rstn(rstn),
        .switch(switch),
        .btn_dbnc(btn_dbnc),
        .cosim_pc(cosim_pc),
        .cosim_valid(cosim_valid),
        .cosim_commit_num(cosim_commit_num),
        .debug_flag(debug_flag),
        .debug_step(debug_step),
        .debug_info(debug_info)
    );

    assign clk_core = debug_flag & rstn ? debug_step : clk_div[2];

    reg [63:0] debug_pc;
    reg [63:0] debug_inst;
    reg [63:0] debug_rs1_id;
    reg [63:0] debug_rs1;
    reg [63:0] debug_rs2_id;
    reg [63:0] debug_rs2;
    reg [63:0] debug_alu;
    reg [63:0] debug_mem_addr;
    reg [63:0] debug_mem_we;
    reg [63:0] debug_mem_wdata;
    reg [63:0] debug_mem_rdata;
    reg [63:0] debug_rd_id;
    reg [63:0] debug_rd_we;
    reg [63:0] debug_rd;
    reg [63:0] debug_br_taken;
    reg [63:0] debug_npc;
    CSRStruct::CSRPack debug_csr_info;
    RegStruct::RegPack debug_regs;
    // reg [63:0] debug_disp;
    // reg [63:0] debug_commit_num;
    // reg [63:0] debug_ddr_visit_times;
    
    always@(posedge clk)begin
        if (cosim_valid) begin
            debug_pc        <= cosim_pc;
            debug_inst      <= cosim_inst;
            debug_rs1_id    <= cosim_rs1_id;
            debug_rs1       <= cosim_rs1;
            debug_rs2_id    <= cosim_rs2_id;
            debug_rs2       <= cosim_rs2;
            debug_alu       <= cosim_alu;
            debug_mem_addr  <= cosim_mem_addr;
            debug_mem_we    <= cosim_mem_we;
            debug_mem_wdata <= cosim_mem_wdata;
            debug_mem_rdata <= cosim_mem_rdata;
            debug_rd_id     <= cosim_rd_id;
            debug_rd_we     <= cosim_rd_we;
            debug_rd        <= cosim_rd;
            debug_br_taken  <= cosim_br_taken;
            debug_npc       <= cosim_npc;
            debug_csr_info  <= cosim_csr_info;
            debug_regs      <= cosim_regs;
            // debug_disp      <= cosim_disp;
            // debug_commit_num<= cosim_commit_num;
            // debug_ddr_visit_times <= cosim_ddr_visit_times;
        end
    end

    reg [63:0] data_src;
    always @ (*) begin
        case (switch[7:0])
            //core 00000000-00011111
            8'b00000000: data_src = debug_pc;
            8'b00000001: data_src = debug_inst;
            8'b00000010: data_src = debug_rs1_id;
            8'b00000011: data_src = debug_rs1;
            8'b00000100: data_src = debug_rs2_id;
            8'b00000101: data_src = debug_rs2;
            8'b00000110: data_src = debug_alu;
            8'b00000111: data_src = debug_mem_addr;
            8'b00001000: data_src = debug_mem_we;
            8'b00001001: data_src = debug_mem_wdata;
            8'b00001010: data_src = debug_mem_rdata;
            8'b00001011: data_src = debug_rd_id;
            8'b00001100: data_src = debug_rd_we;
            8'b00001101: data_src = debug_rd;
            8'b00001110: data_src = debug_br_taken;
            8'b00001111: data_src = debug_npc;
            //csr 00100000-00111111
            8'b00100000: data_src = debug_csr_info.sstatus;
            8'b00100001: data_src = debug_csr_info.sie;
            8'b00100010: data_src = debug_csr_info.stvec;
            8'b00100011: data_src = debug_csr_info.sscratch;
            8'b00100100: data_src = debug_csr_info.sepc;
            8'b00100101: data_src = debug_csr_info.scause;
            8'b00100110: data_src = debug_csr_info.stval;
            8'b00100111: data_src = debug_csr_info.sip;
            8'b00101000: data_src = debug_csr_info.mstatus;
            8'b00101001: data_src = debug_csr_info.mie;
            8'b00101010: data_src = debug_csr_info.mtvec;
            8'b00101011: data_src = debug_csr_info.mscratch;
            8'b00101100: data_src = debug_csr_info.mepc;
            8'b00101101: data_src = debug_csr_info.mcause;
            8'b00101110: data_src = debug_csr_info.mtval;
            8'b00101111: data_src = debug_csr_info.mip;
            8'b00110000: data_src = debug_csr_info.medeleg;
            8'b00110001: data_src = debug_csr_info.mideleg;
            8'b00110010: data_src = debug_csr_info.priv;
            8'b00110011: data_src = debug_csr_info.switch_mode;
            8'b00110100: data_src = debug_csr_info.pc_csr;
            8'b00110101: data_src = debug_csr_info.cosim_epc;
            8'b00110110: data_src = debug_csr_info.cosim_cause;
            8'b00110111: data_src = debug_csr_info.cosim_tval;
            8'b00111000: data_src = debug_csr_info.csr_ret;
            //hard 01000000 - 01011111
            8'b01000000: data_src = cosim_disp;
            8'b01000001: data_src = cosim_commit_num;
            8'b01000010: data_src = cosim_ddr_visit_times;
            8'b01000011: data_src = cosim_mtime;
            8'b01000100: data_src = cosim_mtimecmp;
            //debug 01100000 - 01111111
            8'b01100000: data_src = debug_info.ebreak_point[0];
            8'b01100001: data_src = debug_info.ebreak_point[1];
            8'b01100010: data_src = debug_info.ebreak_point[2];
            8'b01100011: data_src = debug_info.ebreak_point[3];
            8'b01100100: data_src = debug_info.ebreak_point[4];
            8'b01100101: data_src = debug_info.ebreak_point[5];
            8'b01100110: data_src = debug_info.ebreak_point[6];
            8'b01100111: data_src = debug_info.ebreak_point[7];
            8'b01101000: data_src = debug_info.ebreak_valid;
            8'b01101001: data_src = debug_info.ebreak_get;
            8'b01101010: data_src = debug_info.ebreak_happen;
            8'b01101011: data_src = debug_info.debug_btn;
            //regs 10000000 - 10011111
            8'b10000000: data_src = debug_regs.regs[0];
            8'b10000001: data_src = debug_regs.regs[1];
            8'b10000010: data_src = debug_regs.regs[2];
            8'b10000011: data_src = debug_regs.regs[3];
            8'b10000100: data_src = debug_regs.regs[4];
            8'b10000101: data_src = debug_regs.regs[5];
            8'b10000110: data_src = debug_regs.regs[6];
            8'b10000111: data_src = debug_regs.regs[7];
            8'b10001000: data_src = debug_regs.regs[8];
            8'b10001001: data_src = debug_regs.regs[9];
            8'b10001010: data_src = debug_regs.regs[10];
            8'b10001011: data_src = debug_regs.regs[11];
            8'b10001100: data_src = debug_regs.regs[12];
            8'b10001101: data_src = debug_regs.regs[13];
            8'b10001110: data_src = debug_regs.regs[14];
            8'b10001111: data_src = debug_regs.regs[15];
            8'b10010000: data_src = debug_regs.regs[16];
            8'b10010001: data_src = debug_regs.regs[17];
            8'b10010010: data_src = debug_regs.regs[18];
            8'b10010011: data_src = debug_regs.regs[19];
            8'b10010100: data_src = debug_regs.regs[20];
            8'b10010101: data_src = debug_regs.regs[21];
            8'b10010110: data_src = debug_regs.regs[22];
            8'b10010111: data_src = debug_regs.regs[23];
            8'b10011000: data_src = debug_regs.regs[24];
            8'b10011001: data_src = debug_regs.regs[25];
            8'b10011010: data_src = debug_regs.regs[26];
            8'b10011011: data_src = debug_regs.regs[27];
            8'b10011100: data_src = debug_regs.regs[28];
            8'b10011101: data_src = debug_regs.regs[29];
            8'b10011110: data_src = debug_regs.regs[30];
            8'b10011111: data_src = debug_regs.regs[31];
            default: data_src = 64'b0;
        endcase
    end
    wire [31:0] choose_data_src=switch[14]?data_src[63:32]:data_src[31:0];

    SevSegment_Display seg (
        .clk(clk_div[10]),
        .rstn(rstn),
        .hex(choose_data_src[31:0]),
        .CS(cs),
        .AN(an)
    );

    wire [12:0] vram_addr;
    wire  [7:0] vram_data;
    wire  [8:0] row_addr;
    wire  [9:0] col_addr;
    wire  [5:0] char_row = row_addr[8:3]; // char row
    wire  [2:0] font_row = row_addr[2:0]; // font row
    wire  [6:0] char_col = col_addr[9:3]; // char col
    wire  [2:0] font_col = col_addr[2:0]; // font col
    wire [12:0] font_addr = {vram_data, font_row, font_col};
    wire        font_dot;
    wire        verbose_pixel;
    wire [11:0] vga_pixel = font_dot & verbose_pixel ? 12'hfff : 12'h000;
    wire [ 3:0] vga_r_font;
    wire [ 3:0] vga_g_font;
    wire [ 3:0] vga_b_font;

    assign vga_r = vram_data[7] ? 0 : vga_r_font;
    assign vga_g = vram_data[7] ? 0 : vga_g_font;
    assign vga_b = vram_data[7] ? 1 : vga_b_font;
    
    // row_addr / 8 * 80 + col_addr / 8
    assign vram_addr = {char_row, 6'h0} + {char_row, 4'h0} + char_col;
    
    Font_Table ft(font_addr, font_dot);

    wire [7:0]  vram_wdata;
    wire        vram_wen;
    wire [12:0] vram_waddr;
    VRAM vram (
        .clk(clk),
        .wo_wmode(vram_wen),
        .wo_addr(vram_waddr),
        .wo_wdata(vram_wdata),
        .ro_addr(vram_addr),
        .ro_rdata(vram_data)
    );

    VGA_Controller vga (
        .clk(clk_div[2]),
        .rst(!rstn),
        .color(vga_pixel),
        .row_addr(row_addr),
        .col_addr(col_addr),
        .hsync(vga_hs),
        .vsync(vga_vs),
        .verbose(verbose_pixel),
        .red(vga_r_font),
        .green(vga_g_font),
        .blue(vga_b_font)
    );

    VGA_Debugger dump (
        .clk(clk),
        .vram_wen(vram_wen),
        .vram_waddr(vram_waddr),
        .vram_wdata(vram_wdata),
        .debug_pc(debug_pc),
        .debug_inst(debug_inst),
        .debug_rs1_id(debug_rs1_id),
        .debug_rs1(debug_rs1),
        .debug_rs2_id(debug_rs2_id),
        .debug_rs2(debug_rs2),
        .debug_alu(debug_alu),
        .debug_mem_addr(debug_mem_addr),
        .debug_mem_we(debug_mem_we),
        .debug_mem_wdata(debug_mem_wdata),
        .debug_mem_rdata(debug_mem_rdata),
        .debug_rd_id(debug_rd_id),
        .debug_rd_we(debug_rd_we),
        .debug_rd(debug_rd),
        .debug_br_taken(debug_br_taken),
        .debug_npc(debug_npc)
    );
endmodule

module Debouncer (
    input  wire  clk,
    input  wire  btn,
    output wire  btn_dbnc
);

    reg [7:0] shift = 0;

    always @ (posedge clk) begin
        shift <= {shift[6:0], btn};
    end

    assign btn_dbnc = &shift;
endmodule

module SevSegment_Display (
    input  wire        clk,
    input  wire        rstn,
    input  wire [31:0] hex, 
    output wire [ 7:0] CS,
    output wire [ 7:0] AN
);

    reg [7:0] an_state = 8'b11111110;
    reg [3:0] dec_in;

    always @ (posedge clk) begin
        if (rstn) begin
            an_state <= {an_state[6:0], an_state[7]};
        end else begin
            an_state <= 8'b11111110;
        end
    end

    SevSegment_Decoder dec(dec_in, CS);

    always @ (*) begin
        case (an_state)
            8'b11111110: begin dec_in = hex[ 3: 0]; end
            8'b11111101: begin dec_in = hex[ 7: 4]; end
            8'b11111011: begin dec_in = hex[11: 8]; end
            8'b11110111: begin dec_in = hex[15:12]; end
            8'b11101111: begin dec_in = hex[19:16]; end
            8'b11011111: begin dec_in = hex[23:20]; end
            8'b10111111: begin dec_in = hex[27:24]; end
            8'b01111111: begin dec_in = hex[31:28]; end
            default:     begin dec_in = 0; end
        endcase
    end

    assign AN = an_state;
endmodule

module SevSegment_Decoder (
    input  wire [3:0] hex,
    output reg [7:0] cs
);

    always @ (*) begin
        case (hex)
            4'h0: cs = 8'b11000000;
            4'h1: cs = 8'b11111001;
            4'h2: cs = 8'b10100100;
            4'h3: cs = 8'b10110000;
            4'h4: cs = 8'b10011001;
            4'h5: cs = 8'b10010010;
            4'h6: cs = 8'b10000010;
            4'h7: cs = 8'b11111000;
            4'h8: cs = 8'b10000000;
            4'h9: cs = 8'b10010000;
            4'ha: cs = 8'b10001000;
            4'hb: cs = 8'b10000011;
            4'hc: cs = 8'b11000110;
            4'hd: cs = 8'b10100001;
            4'he: cs = 8'b10000110;
            4'hf: cs = 8'b10001110;
        endcase
    end
endmodule

module Divider (
    input  wire clk,
    output wire [31:0] clk_50
);
    reg [31:0] cnt = 0;

    always @ (posedge clk) begin
        cnt <= cnt + 1;
    end
    assign clk_50 = cnt;

endmodule

module VGA_Controller (
    clk,
    rst,
    color,
    row_addr,
    col_addr,
    verbose,
    red,
    green,
    blue,
    hsync,
    vsync
);
    input     [11:0] color;                 // rrrr_gggg_bbbb
    input            clk;                   // 25MHz
    input            rst;
    output reg [8:0] row_addr;              // pixel ram row address, 480 (512)
    output reg [9:0] col_addr;              // pixel ram col address, 640 (1024)
    output reg [3:0] red,green,blue;        // red, green, blue colors, 4-bit for each
    output reg       verbose;               // verbose pixel
    output reg       hsync,vsync;           // horizontal and vertical synchronization
    
    // h_count: vga horizontal counter (0-799 pixels)
    reg [9:0] h_count;
    always @ (posedge clk) begin
        if (rst) begin
            h_count <= 10'h0;
        end else if (h_count == 10'd799) begin
            h_count <= 10'h0;
        end else begin 
            h_count <= h_count + 10'h1;
        end
    end
    
    // v_count: vga vertical counter (0-524 lines)
    reg [9:0] v_count;
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            v_count <= 10'h0;
        end else if (h_count == 10'd799) begin
            if (v_count == 10'd524) begin
                v_count <= 10'h0;
            end else begin
                v_count <= v_count + 10'h1;
            end
        end
    end
    
    // signals, will be latched for outputs
    wire  [9:0] row    =  v_count - 10'd35;       // pixel ram row address 
    wire  [9:0] col    =  h_count - 10'd143;      // pixel ram col address 
    wire        h_sync = (h_count > 10'd95);      //  96 -> 799
    wire        v_sync = (v_count > 10'd1);       //   2 -> 524
    wire        valid  = (h_count > 10'd142) &&   // 143 -> 782 =
                         (h_count < 10'd783) &&   //              640 pixels
                         (v_count > 10'd34)  &&   //  35 -> 514 =
                         (v_count < 10'd515);     //              480 lines
    
    // vga signals
    always @ (posedge clk) begin                    // posedge orginal
        row_addr <=  row[8:0];                      // pixel ram row address
        col_addr <=  col;                           // pixel ram col address
        verbose  <=  valid;                          // valid pixel
        hsync    <=  h_sync;                        // horizontal synch
        vsync    <=  v_sync;                        // vertical   synch
        red      <=  verbose ? color[11:8] : 'h0;     // 8-bit red
        green    <=  verbose ? color[ 7:4] : 'h0;     // 8-bit green
        blue     <=  verbose ? color[ 3:0] : 'h0;     // 8-bit blue
    end
endmodule

module VGA_Debugger (
    input wire         clk,
    output reg         vram_wen,
    output reg [12:0]  vram_waddr,
    output reg  [7:0]  vram_wdata,
    input wire  [63:0] debug_pc,
    input wire  [63:0] debug_inst,
    input wire  [63:0] debug_rs1_id,
    input wire  [63:0] debug_rs1,
    input wire  [63:0] debug_rs2_id,
    input wire  [63:0] debug_rs2,
    input wire  [63:0] debug_alu,
    input wire  [63:0] debug_mem_addr,
    input wire  [63:0] debug_mem_we,
    input wire  [63:0] debug_mem_wdata,
    input wire  [63:0] debug_mem_rdata,
    input wire  [63:0] debug_rd_id,
    input wire  [63:0] debug_rd_we,
    input wire  [63:0] debug_rd,
    input wire  [63:0] debug_br_taken,
    input wire  [63:0] debug_npc    
);

    reg [7:0] cnt = 0;
    reg [3:0] wdata_hex;

    always @* begin
        case (wdata_hex)
            4'h0: vram_wdata = 48;
            4'h1: vram_wdata = 49;
            4'h2: vram_wdata = 50;
            4'h3: vram_wdata = 51;
            4'h4: vram_wdata = 52;
            4'h5: vram_wdata = 53;
            4'h6: vram_wdata = 54;
            4'h7: vram_wdata = 55;
            4'h8: vram_wdata = 56;
            4'h9: vram_wdata = 57;
            4'ha: vram_wdata = 97;
            4'hb: vram_wdata = 98;
            4'hc: vram_wdata = 99;
            4'hd: vram_wdata = 100;
            4'he: vram_wdata = 101;
            4'hf: vram_wdata = 102;
        endcase
    end

    always @ (posedge clk) begin
        cnt <= cnt == 200 ? 0 : cnt + 1;
    end

    always @ (*) begin
        case (cnt)
              0: begin wdata_hex = debug_pc[63:60]; vram_waddr = 495; vram_wen = 1; end
              1: begin wdata_hex = debug_pc[59:56]; vram_waddr = 496; vram_wen = 1; end
              2: begin wdata_hex = debug_pc[55:52]; vram_waddr = 497; vram_wen = 1; end
              3: begin wdata_hex = debug_pc[51:48]; vram_waddr = 498; vram_wen = 1; end
              4: begin wdata_hex = debug_pc[47:44]; vram_waddr = 500; vram_wen = 1; end
              5: begin wdata_hex = debug_pc[43:40]; vram_waddr = 501; vram_wen = 1; end
              6: begin wdata_hex = debug_pc[39:36]; vram_waddr = 502; vram_wen = 1; end
              7: begin wdata_hex = debug_pc[35:32]; vram_waddr = 503; vram_wen = 1; end
              8: begin wdata_hex = debug_pc[31:28]; vram_waddr = 505; vram_wen = 1; end
              9: begin wdata_hex = debug_pc[27:24]; vram_waddr = 506; vram_wen = 1; end
             10: begin wdata_hex = debug_pc[23:20]; vram_waddr = 507; vram_wen = 1; end
             11: begin wdata_hex = debug_pc[19:16]; vram_waddr = 508; vram_wen = 1; end
             12: begin wdata_hex = debug_pc[15:12]; vram_waddr = 510; vram_wen = 1; end
             13: begin wdata_hex = debug_pc[11: 8]; vram_waddr = 511; vram_wen = 1; end
             14: begin wdata_hex = debug_pc[ 7: 4]; vram_waddr = 512; vram_wen = 1; end
             15: begin wdata_hex = debug_pc[ 3: 0]; vram_waddr = 513; vram_wen = 1; end
             16: begin wdata_hex = debug_inst[31:28]; vram_waddr = 655; vram_wen = 1; end
             17: begin wdata_hex = debug_inst[27:24]; vram_waddr = 656; vram_wen = 1; end
             18: begin wdata_hex = debug_inst[23:20]; vram_waddr = 657; vram_wen = 1; end
             19: begin wdata_hex = debug_inst[19:16]; vram_waddr = 658; vram_wen = 1; end
             20: begin wdata_hex = debug_inst[15:12]; vram_waddr = 660; vram_wen = 1; end
             21: begin wdata_hex = debug_inst[11: 8]; vram_waddr = 661; vram_wen = 1; end
             22: begin wdata_hex = debug_inst[ 7: 4]; vram_waddr = 662; vram_wen = 1; end
             23: begin wdata_hex = debug_inst[ 3: 0]; vram_waddr = 663; vram_wen = 1; end
             24: begin wdata_hex = debug_rs1_id[7:4]; vram_waddr = 808; vram_wen = 1; end
             25: begin wdata_hex = debug_rs1_id[3:0]; vram_waddr = 809; vram_wen = 1; end
             26: begin wdata_hex = debug_rs1[63:60]; vram_waddr = 815; vram_wen = 1; end
             27: begin wdata_hex = debug_rs1[59:56]; vram_waddr = 816; vram_wen = 1; end
             28: begin wdata_hex = debug_rs1[55:52]; vram_waddr = 817; vram_wen = 1; end
             29: begin wdata_hex = debug_rs1[51:48]; vram_waddr = 818; vram_wen = 1; end
             30: begin wdata_hex = debug_rs1[47:44]; vram_waddr = 820; vram_wen = 1; end
             31: begin wdata_hex = debug_rs1[43:40]; vram_waddr = 821; vram_wen = 1; end
             32: begin wdata_hex = debug_rs1[39:36]; vram_waddr = 822; vram_wen = 1; end
             33: begin wdata_hex = debug_rs1[35:32]; vram_waddr = 823; vram_wen = 1; end
             34: begin wdata_hex = debug_rs1[31:28]; vram_waddr = 825; vram_wen = 1; end
             35: begin wdata_hex = debug_rs1[27:24]; vram_waddr = 826; vram_wen = 1; end
             36: begin wdata_hex = debug_rs1[23:20]; vram_waddr = 827; vram_wen = 1; end
             37: begin wdata_hex = debug_rs1[19:16]; vram_waddr = 828; vram_wen = 1; end
             38: begin wdata_hex = debug_rs1[15:12]; vram_waddr = 830; vram_wen = 1; end
             39: begin wdata_hex = debug_rs1[11: 8]; vram_waddr = 831; vram_wen = 1; end
             40: begin wdata_hex = debug_rs1[ 7: 4]; vram_waddr = 832; vram_wen = 1; end
             41: begin wdata_hex = debug_rs1[ 3: 0]; vram_waddr = 833; vram_wen = 1; end
             42: begin wdata_hex = debug_rs2_id[7:4]; vram_waddr = 968; vram_wen = 1; end
             43: begin wdata_hex = debug_rs2_id[3:0]; vram_waddr = 969; vram_wen = 1; end
             44: begin wdata_hex = debug_rs2[63:60]; vram_waddr = 975; vram_wen = 1; end
             45: begin wdata_hex = debug_rs2[59:56]; vram_waddr = 976; vram_wen = 1; end
             46: begin wdata_hex = debug_rs2[55:52]; vram_waddr = 977; vram_wen = 1; end
             47: begin wdata_hex = debug_rs2[51:48]; vram_waddr = 978; vram_wen = 1; end
             48: begin wdata_hex = debug_rs2[47:44]; vram_waddr = 980; vram_wen = 1; end
             49: begin wdata_hex = debug_rs2[43:40]; vram_waddr = 981; vram_wen = 1; end
             50: begin wdata_hex = debug_rs2[39:36]; vram_waddr = 982; vram_wen = 1; end
             51: begin wdata_hex = debug_rs2[35:32]; vram_waddr = 983; vram_wen = 1; end
             52: begin wdata_hex = debug_rs2[31:28]; vram_waddr = 985; vram_wen = 1; end
             53: begin wdata_hex = debug_rs2[27:24]; vram_waddr = 986; vram_wen = 1; end
             54: begin wdata_hex = debug_rs2[23:20]; vram_waddr = 987; vram_wen = 1; end
             55: begin wdata_hex = debug_rs2[19:16]; vram_waddr = 988; vram_wen = 1; end
             56: begin wdata_hex = debug_rs2[15:12]; vram_waddr = 990; vram_wen = 1; end
             57: begin wdata_hex = debug_rs2[11: 8]; vram_waddr = 991; vram_wen = 1; end
             58: begin wdata_hex = debug_rs2[ 7: 4]; vram_waddr = 992; vram_wen = 1; end
             59: begin wdata_hex = debug_rs2[ 3: 0]; vram_waddr = 993; vram_wen = 1; end
             60: begin wdata_hex = debug_alu[63:60]; vram_waddr = 1135; vram_wen = 1; end
             61: begin wdata_hex = debug_alu[59:56]; vram_waddr = 1136; vram_wen = 1; end
             62: begin wdata_hex = debug_alu[55:52]; vram_waddr = 1137; vram_wen = 1; end
             63: begin wdata_hex = debug_alu[51:48]; vram_waddr = 1138; vram_wen = 1; end
             64: begin wdata_hex = debug_alu[47:44]; vram_waddr = 1140; vram_wen = 1; end
             65: begin wdata_hex = debug_alu[43:40]; vram_waddr = 1141; vram_wen = 1; end
             66: begin wdata_hex = debug_alu[39:36]; vram_waddr = 1142; vram_wen = 1; end
             67: begin wdata_hex = debug_alu[35:32]; vram_waddr = 1143; vram_wen = 1; end
             68: begin wdata_hex = debug_alu[31:28]; vram_waddr = 1145; vram_wen = 1; end
             69: begin wdata_hex = debug_alu[27:24]; vram_waddr = 1146; vram_wen = 1; end
             70: begin wdata_hex = debug_alu[23:20]; vram_waddr = 1147; vram_wen = 1; end
             71: begin wdata_hex = debug_alu[19:16]; vram_waddr = 1148; vram_wen = 1; end
             72: begin wdata_hex = debug_alu[15:12]; vram_waddr = 1150; vram_wen = 1; end
             73: begin wdata_hex = debug_alu[11: 8]; vram_waddr = 1151; vram_wen = 1; end
             74: begin wdata_hex = debug_alu[ 7: 4]; vram_waddr = 1152; vram_wen = 1; end
             75: begin wdata_hex = debug_alu[ 3: 0]; vram_waddr = 1153; vram_wen = 1; end
             76: begin wdata_hex = debug_mem_we[3:0]; vram_waddr = 1290; vram_wen = 1; end
             77: begin wdata_hex = debug_mem_addr[63:60]; vram_waddr = 1295; vram_wen = 1; end
             78: begin wdata_hex = debug_mem_addr[59:56]; vram_waddr = 1296; vram_wen = 1; end
             79: begin wdata_hex = debug_mem_addr[55:52]; vram_waddr = 1297; vram_wen = 1; end
             80: begin wdata_hex = debug_mem_addr[51:48]; vram_waddr = 1298; vram_wen = 1; end
             81: begin wdata_hex = debug_mem_addr[47:44]; vram_waddr = 1300; vram_wen = 1; end
             82: begin wdata_hex = debug_mem_addr[43:40]; vram_waddr = 1301; vram_wen = 1; end
             83: begin wdata_hex = debug_mem_addr[39:36]; vram_waddr = 1302; vram_wen = 1; end
             84: begin wdata_hex = debug_mem_addr[35:32]; vram_waddr = 1303; vram_wen = 1; end
             85: begin wdata_hex = debug_mem_addr[31:28]; vram_waddr = 1305; vram_wen = 1; end
             86: begin wdata_hex = debug_mem_addr[27:24]; vram_waddr = 1306; vram_wen = 1; end
             87: begin wdata_hex = debug_mem_addr[23:20]; vram_waddr = 1307; vram_wen = 1; end
             88: begin wdata_hex = debug_mem_addr[19:16]; vram_waddr = 1308; vram_wen = 1; end
             89: begin wdata_hex = debug_mem_addr[15:12]; vram_waddr = 1310; vram_wen = 1; end
             90: begin wdata_hex = debug_mem_addr[11: 8]; vram_waddr = 1311; vram_wen = 1; end
             91: begin wdata_hex = debug_mem_addr[ 7: 4]; vram_waddr = 1312; vram_wen = 1; end
             92: begin wdata_hex = debug_mem_addr[ 3: 0]; vram_waddr = 1313; vram_wen = 1; end
             93: begin wdata_hex = debug_mem_wdata[63:60]; vram_waddr = 1455; vram_wen = 1; end
             94: begin wdata_hex = debug_mem_wdata[59:56]; vram_waddr = 1456; vram_wen = 1; end
             95: begin wdata_hex = debug_mem_wdata[55:52]; vram_waddr = 1457; vram_wen = 1; end
             96: begin wdata_hex = debug_mem_wdata[51:48]; vram_waddr = 1458; vram_wen = 1; end
             97: begin wdata_hex = debug_mem_wdata[47:44]; vram_waddr = 1460; vram_wen = 1; end
             98: begin wdata_hex = debug_mem_wdata[43:40]; vram_waddr = 1461; vram_wen = 1; end
             99: begin wdata_hex = debug_mem_wdata[39:36]; vram_waddr = 1462; vram_wen = 1; end
            100: begin wdata_hex = debug_mem_wdata[35:32]; vram_waddr = 1463; vram_wen = 1; end
            101: begin wdata_hex = debug_mem_wdata[31:28]; vram_waddr = 1465; vram_wen = 1; end
            102: begin wdata_hex = debug_mem_wdata[27:24]; vram_waddr = 1466; vram_wen = 1; end
            103: begin wdata_hex = debug_mem_wdata[23:20]; vram_waddr = 1467; vram_wen = 1; end
            104: begin wdata_hex = debug_mem_wdata[19:16]; vram_waddr = 1468; vram_wen = 1; end
            105: begin wdata_hex = debug_mem_wdata[15:12]; vram_waddr = 1470; vram_wen = 1; end
            106: begin wdata_hex = debug_mem_wdata[11: 8]; vram_waddr = 1471; vram_wen = 1; end
            107: begin wdata_hex = debug_mem_wdata[ 7: 4]; vram_waddr = 1472; vram_wen = 1; end
            108: begin wdata_hex = debug_mem_wdata[ 3: 0]; vram_waddr = 1473; vram_wen = 1; end
            109: begin wdata_hex = debug_mem_rdata[63:60]; vram_waddr = 1615; vram_wen = 1; end
            110: begin wdata_hex = debug_mem_rdata[59:56]; vram_waddr = 1616; vram_wen = 1; end
            111: begin wdata_hex = debug_mem_rdata[55:52]; vram_waddr = 1617; vram_wen = 1; end
            112: begin wdata_hex = debug_mem_rdata[51:48]; vram_waddr = 1618; vram_wen = 1; end
            113: begin wdata_hex = debug_mem_rdata[47:44]; vram_waddr = 1620; vram_wen = 1; end
            114: begin wdata_hex = debug_mem_rdata[43:40]; vram_waddr = 1621; vram_wen = 1; end
            115: begin wdata_hex = debug_mem_rdata[39:36]; vram_waddr = 1622; vram_wen = 1; end
            116: begin wdata_hex = debug_mem_rdata[35:32]; vram_waddr = 1623; vram_wen = 1; end
            117: begin wdata_hex = debug_mem_rdata[31:28]; vram_waddr = 1625; vram_wen = 1; end
            118: begin wdata_hex = debug_mem_rdata[27:24]; vram_waddr = 1626; vram_wen = 1; end
            119: begin wdata_hex = debug_mem_rdata[23:20]; vram_waddr = 1627; vram_wen = 1; end
            120: begin wdata_hex = debug_mem_rdata[19:16]; vram_waddr = 1628; vram_wen = 1; end
            121: begin wdata_hex = debug_mem_rdata[15:12]; vram_waddr = 1630; vram_wen = 1; end
            122: begin wdata_hex = debug_mem_rdata[11: 8]; vram_waddr = 1631; vram_wen = 1; end
            123: begin wdata_hex = debug_mem_rdata[ 7: 4]; vram_waddr = 1632; vram_wen = 1; end
            124: begin wdata_hex = debug_mem_rdata[ 3: 0]; vram_waddr = 1633; vram_wen = 1; end
            125: begin wdata_hex = debug_rd_id[7:4]; vram_waddr = 1767; vram_wen = 1; end
            126: begin wdata_hex = debug_rd_id[3:0]; vram_waddr = 1768; vram_wen = 1; end
            127: begin wdata_hex = debug_rd_we[3:0]; vram_waddr = 1770; vram_wen = 1; end
            128: begin wdata_hex = debug_rd[63:60]; vram_waddr = 1775; vram_wen = 1; end
            129: begin wdata_hex = debug_rd[59:56]; vram_waddr = 1776; vram_wen = 1; end
            130: begin wdata_hex = debug_rd[55:52]; vram_waddr = 1777; vram_wen = 1; end
            131: begin wdata_hex = debug_rd[51:48]; vram_waddr = 1778; vram_wen = 1; end
            132: begin wdata_hex = debug_rd[47:44]; vram_waddr = 1780; vram_wen = 1; end
            133: begin wdata_hex = debug_rd[43:40]; vram_waddr = 1781; vram_wen = 1; end
            134: begin wdata_hex = debug_rd[39:36]; vram_waddr = 1782; vram_wen = 1; end
            135: begin wdata_hex = debug_rd[35:32]; vram_waddr = 1783; vram_wen = 1; end
            136: begin wdata_hex = debug_rd[31:28]; vram_waddr = 1785; vram_wen = 1; end
            137: begin wdata_hex = debug_rd[27:24]; vram_waddr = 1786; vram_wen = 1; end
            138: begin wdata_hex = debug_rd[23:20]; vram_waddr = 1787; vram_wen = 1; end
            139: begin wdata_hex = debug_rd[19:16]; vram_waddr = 1788; vram_wen = 1; end
            140: begin wdata_hex = debug_rd[15:12]; vram_waddr = 1790; vram_wen = 1; end
            141: begin wdata_hex = debug_rd[11: 8]; vram_waddr = 1791; vram_wen = 1; end
            142: begin wdata_hex = debug_rd[ 7: 4]; vram_waddr = 1792; vram_wen = 1; end
            143: begin wdata_hex = debug_rd[ 3: 0]; vram_waddr = 1793; vram_wen = 1; end
            144: begin wdata_hex = debug_br_taken[3:0]; vram_waddr = 1926; vram_wen = 1; end
            145: begin wdata_hex = debug_npc[63:60]; vram_waddr = 1935; vram_wen = 1; end
            146: begin wdata_hex = debug_npc[59:56]; vram_waddr = 1936; vram_wen = 1; end
            147: begin wdata_hex = debug_npc[55:52]; vram_waddr = 1937; vram_wen = 1; end
            148: begin wdata_hex = debug_npc[51:48]; vram_waddr = 1938; vram_wen = 1; end
            149: begin wdata_hex = debug_npc[47:44]; vram_waddr = 1940; vram_wen = 1; end
            150: begin wdata_hex = debug_npc[43:40]; vram_waddr = 1941; vram_wen = 1; end
            151: begin wdata_hex = debug_npc[39:36]; vram_waddr = 1942; vram_wen = 1; end
            152: begin wdata_hex = debug_npc[35:32]; vram_waddr = 1943; vram_wen = 1; end
            153: begin wdata_hex = debug_npc[31:28]; vram_waddr = 1945; vram_wen = 1; end
            154: begin wdata_hex = debug_npc[27:24]; vram_waddr = 1946; vram_wen = 1; end
            155: begin wdata_hex = debug_npc[23:20]; vram_waddr = 1947; vram_wen = 1; end
            156: begin wdata_hex = debug_npc[19:16]; vram_waddr = 1948; vram_wen = 1; end
            157: begin wdata_hex = debug_npc[15:12]; vram_waddr = 1950; vram_wen = 1; end
            158: begin wdata_hex = debug_npc[11: 8]; vram_waddr = 1951; vram_wen = 1; end
            159: begin wdata_hex = debug_npc[ 7: 4]; vram_waddr = 1952; vram_wen = 1; end
            160: begin wdata_hex = debug_npc[ 3: 0]; vram_waddr = 1953; vram_wen = 1; end
            default: begin wdata_hex = 0; vram_wen = 0; end       
        endcase
    end
endmodule