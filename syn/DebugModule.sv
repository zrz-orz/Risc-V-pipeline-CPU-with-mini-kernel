`include "DebugStruct.vh"
module DebugModule(
    input clk,
    input rstn,
    input [15:0] switch,
    input [4:0] btn_dbnc,
    input [63:0] cosim_pc,
    input cosim_valid,
    input [63:0] cosim_commit_num,
    output reg debug_flag,
    output debug_step,

    output DebugStruct::DebugPack debug_info
);

    reg [7:0] ebreak_valid;
    reg [63:0] ebreak_point [7:0];

    wire [2:0] break_index;
    wire [2:0] break_part_index;
    wire [7:0] break_value;
    wire debug_set;
    wire break_set;
    wire break_clear;

    DebugDecode debug_decode(
        .switch(switch),
        .btn_dbnc(btn_dbnc),
        .break_index(break_index),
        .break_part_index(break_part_index),
        .break_value(break_value),
        .debug_set(debug_set),
        .debug_step(debug_step),
        .break_set(break_set),
        .break_clear(break_clear)
    );
    
    integer i;
    always@(posedge clk)begin
        if(~rstn)begin
            for(i=0;i<=7;i=i+1)begin:break_init
                ebreak_valid[i]<=1'b0;
                ebreak_point[i]<=64'b0;
            end
        end else if(break_set)begin
            case(break_part_index)
                3'b000:ebreak_point[break_index][7:0]<=break_value;
                3'b001:ebreak_point[break_index][15:8]<=break_value;
                3'b010:ebreak_point[break_index][23:16]<=break_value;
                3'b011:ebreak_point[break_index][31:24]<=break_value;
                3'b100:ebreak_point[break_index][39:32]<=break_value;
                3'b101:ebreak_point[break_index][47:40]<=break_value;
                3'b110:ebreak_point[break_index][55:48]<=break_value;
                default:ebreak_point[break_index][63:56]<=break_value;
            endcase
            ebreak_valid[break_index]<=1'b1;
        end else if(break_clear)begin
            ebreak_point[break_index]<=64'b0;
            ebreak_valid[break_index]<=1'b0;
        end
    end
    
    wire [7:0] break_get;
    genvar i1;
    generate
        for(i1=0;i1<=7;i1=i1+1)begin
            assign break_get[i1]=cosim_valid&ebreak_valid[i1]&(cosim_pc==ebreak_point[i1]);
        end
    endgenerate

    reg [63:0] last_commit_num;
    always@(posedge clk)begin
        if(~rstn)last_commit_num<=64'b0;
        else last_commit_num<=cosim_commit_num;
    end

    wire break_happen=(|break_get)&(cosim_commit_num!=last_commit_num);

    reg old_debug_set;
    always@(posedge clk)begin
        if(~rstn)old_debug_set<=1'b0;
        else old_debug_set<=debug_set;
    end
    wire debug_set_negedge=old_debug_set&~debug_set;

    always@(posedge clk)begin
        if(~rstn)begin
            debug_flag<=1'b0;
        end else if(break_happen|debug_set==1'b1)begin
            debug_flag<=1'b1;
        end else if(debug_set_negedge)begin
            debug_flag<=1'b0;
        end
    end

    genvar i2;
    generate
        for(i2=0;i2<=7;i2=i2+1)begin:debug_bkp_assign
            assign debug_info.ebreak_point[i2]=ebreak_point[i2];
        end
    endgenerate
    assign debug_info.ebreak_valid={56'b0,ebreak_valid};
    assign debug_info.ebreak_get={56'b0,break_get};
    assign debug_info.ebreak_happen={63'b0,break_happen};
    assign debug_info.debug_btn={59'b0,btn_dbnc};
    
endmodule

module DebugDecode(
    input [15:0] switch,
    input [4:0] btn_dbnc,
    output [2:0] break_index,
    output [2:0] break_part_index,
    output [7:0] break_value,
    output debug_set,
    output debug_step,
    output break_set,
    output break_clear
);
    assign debug_set=switch[15];
    assign debug_step=btn_dbnc[0];

    assign break_part_index=switch[10:8];
    assign break_index=switch[13:11];
    assign break_value=switch[7:0];
    
    assign break_set=btn_dbnc[1];
    assign break_clear=btn_dbnc[2];
    
endmodule

