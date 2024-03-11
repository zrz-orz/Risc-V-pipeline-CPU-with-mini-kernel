`timescale 1ns / 1ps

// Copyright 2023 Sycuricon Group
// Author: Jinyan Xu (phantom@zju.edu.cn)

module VRAM (
    input  clk,
    input  wo_wmode,
    input  [12:0] wo_addr,
    input  [ 7:0] wo_wdata,
    input  [12:0] ro_addr,
    output [ 7:0] ro_rdata
);

    localparam FILE_PATH = "vram.hex";
    integer i;
    reg [7:0] mem [0:4799];
    
    initial begin
        $readmemh(FILE_PATH, mem);
    end

    always @(posedge clk) begin
        if (wo_wmode) begin
            mem[wo_addr] <= wo_wdata;
        end
    end

    assign ro_rdata = mem[ro_addr];
endmodule
