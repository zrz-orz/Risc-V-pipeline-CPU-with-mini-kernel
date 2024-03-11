`include "Define.vh"
`include "MMIOStruct.vh"
module Timer(
    input clk,
    input rstn,
    input [63:0] address_i,
    input [63:0] indata_i,
    input wen_i,
    input ren_i,
    input [7:0] mask_i,
    output [63:0] outdata_o,
    output valid_o,
    output time_int_o,
    output MMIOStruct::MMIOPack cosim_mmio,
    output [63:0] cosim_mtime,
    output [63:0] cosim_mtimecmp
);

    import MMIOStruct::MMIOPack;

    wire is_mtime=address_i==`MTIME_BASE;
    wire is_mtimecmp=address_i==`MTIMECMP_BASE;

    reg [63:0] mtime;
    reg [63:0] mtimecmp;
    integer i;
    always@(posedge clk)begin
        if(~rstn)begin
            mtimecmp<=64'h0;
        end else if(wen_i&&is_mtimecmp)begin
            for(i=0;i<=7;i=i+1)begin
                if(mask_i[i])mtimecmp[i*8 +: 8]<=indata_i[i*8 +: 8];
            end
        end
    end

    always@(posedge clk)begin
        if(~rstn)begin
            mtime<=64'h0;
        end else begin
            mtime<=mtime+64'h1;
        end
    end
    
    wire is_mtime_r=is_mtime&ren_i;
    wire is_mtimecmp_r=is_mtimecmp&ren_i;
    assign outdata_o=is_mtime_r?mtime:is_mtimecmp_r?mtimecmp:64'b0;
    assign time_int_o=mtimecmp<mtime;
    assign valid_o=1'b1;

    assign cosim_mmio.store=ren_i;
    assign cosim_mmio.addr=address_i;
    assign cosim_mmio.len=64'd8;
    assign cosim_mmio.val=outdata_o;
    assign cosim_mtime=mtime;
    assign cosim_mtimecmp=mtimecmp;
endmodule