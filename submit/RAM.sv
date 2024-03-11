`timescale 1ns / 1ps

// Copyright 2023 Sycuricon Group
// Author: Jinyan Xu (phantom@zju.edu.cn)
module RAM #(
    parameter longint MEM_DEPTH = 4096,
    parameter FILE_PATH         = "testcase.hex"
) (
    input  clk,
    input  rstn,
    input  ren,
    input  wen,
    input  [$clog2(MEM_DEPTH)-4:0] rw_addr,
    input  [63:0] rw_wdata,
    input  [7:0] rw_wmask,
    output reg [63:0] rw_rdata,
    output valid
);

    integer i;
    (* ram_style = "block" *) reg [63:0] mem [0:(MEM_DEPTH/8-1)];
    
    initial begin
        $display("%s:%d",FILE_PATH,MEM_DEPTH);
        $readmemh(FILE_PATH, mem);
    end

    always @(posedge clk) begin
        if(rstn)begin
            if (wen) begin
                for(i = 0; i < 8; i = i+1) begin
                    if(rw_wmask[i]) begin
                        mem[rw_addr][i*8 +: 8] <= rw_wdata[i*8 +: 8];
                    end
                end
            end
            rw_rdata <= mem[rw_addr];
        end
    end

    reg state;
    always@(posedge clk)begin
        if(!rstn)state<=1'b0;
        else if(~wen&~ren)state<=1'b0;
        else if(state==1'b0)state<=1'b1;
        else state<=state>>1;
    end

    assign valid=state==1'b1;

    //如果要模拟延迟多个周期则,比如4�??
    
    // `define DELAY 1
    // reg [`DELAY:0] state;
    // always@(posedge clk)begin
    //     if(~rstn)state<={`DELAY'b0,1'b0};
    //     else if(~wen&~ren)state<={`DELAY'b0,1'b0};
    //     else if(state=={`DELAY'b0,1'b0})state<={1'b1,`DELAY'b0};
    //     else state<=state>>1;
    // end

    // assign valid=state=={1'b0,`DELAY'b1};
    
endmodule
