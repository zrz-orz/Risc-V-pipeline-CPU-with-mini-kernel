`include "Define.vh"
`include "MMIOStruct.vh"

module Displayer(
    input clk,
    input rstn,
    input [63:0] address_i,
    input [63:0] indata_i,
    input wen_i,
    input ren_i,
    input [7:0] mask_i,
    output valid_o,
    output [63:0] outdata_o,
    output [63:0] display_o,
    output MMIOStruct::MMIOPack cosim_mmio
);

    import MMIOStruct::MMIOPack;

    wire is_display=wen_i&(address_i==`DISP_BASE);

    integer i;
    reg [7:0] disp [7:0];
    reg busy;
    reg [23:0] cnt;
    always@(posedge clk)begin
        if(!rstn)begin
            for(i=0;i<=7;i=i+1)begin
                disp[i]<=8'hf;
            end
        end else if(is_display&~busy)begin
            for(i=0;i<=6;i=i+1)begin
                disp[i+1]<=disp[i];
            end
            disp[0]<=indata_i[7:0];
            `ifdef VERILATE
                $display("%c",indata_i[7:0]);
            `endif
        end
    end

    always@(posedge clk)begin
        if(~rstn)begin
            busy<=1'b0;
            cnt<=24'b0;
        end 
        `ifndef VERILATE
        /*
         else if(wen_i&~busy)begin
             busy<=1'b1;
             cnt<=24'hffffff;
         end else if(cnt==24'b0)begin
             busy<=1'b0;
         end else if(busy==1'b1)begin
             cnt<=cnt-24'b1;
         end
         */
        `endif
    end

    genvar i1;
    generate
        for(i1=0;i1<=7;i1=i1+1)begin:loop_i1
            assign display_o[i1*8 +: 8]=disp[i1];
        end
    endgenerate
    assign outdata_o=ren_i?{busy,63'b0}:64'b0;
    
    assign valid_o=1'b1;

    assign cosim_mmio.store=ren_i;
    assign cosim_mmio.addr=address_i;
    assign cosim_mmio.len=64'd8;
    assign cosim_mmio.val=outdata_o;
endmodule