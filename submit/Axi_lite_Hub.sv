module Axi_lite_Hub #(
    parameter longint AXI_ADDR_WIDTH=64,
    parameter longint AXI_DATA_WIDTH=64,
    parameter longint MEM0_BEGIN=0,
    parameter longint MEM0_END=64'h1000,
    parameter longint MEM1_BEGIN=64'h10000,
    parameter longint MEM1_END=64'h14000,
    parameter longint MEM2_BEGIN=64'h80000000,
    parameter longint MEM2_END=64'h88000000
)(
    input clk,
    input rstn,
    AXI_ift.Slave master,
    AXI_ift.Master slave0,
    AXI_ift.Master slave1,
    AXI_ift.Master slave2
);

    AXI_ift #(
        .AXI_ADDR_WIDTH(64),
        .AXI_DATA_WIDTH(64)
    ) dummy_axi (
        .clk(clk),
        .rstn(rstn)
    );

    assign dummy_axi.Mw='{
        awaddr:0,
        awport:0,
        awvalid:0,
        wdata:0,
        wvalid:0,
        wstrb:0,
        bready:0
    };

    assign dummy_axi.Mr='{
        araddr:0,
        arport:0,
        arvalid:0,
        rready:0
    };

    assign dummy_axi.Sw='{
        awready:0,
        wready:0,
        bresp:0,
        bvalid:0
    };

    assign dummy_axi.Sr='{
        arready:0,
        rdata:0,
        rresp:0,
        rvalid:0
    };

    wire [AXI_ADDR_WIDTH-1:0] waddr=master.Mw.awaddr;
    wire wismem0=(waddr<MEM0_END);
    wire wismem1=(MEM1_BEGIN<=waddr)&(waddr<MEM1_END);
    wire wismem2=(MEM2_BEGIN<=waddr)&(waddr<MEM2_END);
    
    always@(*)begin
        case({wismem0,wismem1,wismem2})
            3'b100:master.Sw=slave0.Sw;
            3'b010:master.Sw=slave1.Sw;
            3'b001:master.Sw=slave2.Sw;
            default:master.Sw=dummy_axi.Sw;
        endcase
    end 

    assign slave0.Mw=wismem0?master.Mw:dummy_axi.Mw;
    assign slave1.Mw=wismem1?master.Mw:dummy_axi.Mw;
    assign slave2.Mw=wismem2?master.Mw:dummy_axi.Mw;

    wire [AXI_ADDR_WIDTH-1:0] raddr=master.Mr.araddr;
    wire rismem0=(raddr<MEM0_END);
    wire rismem1=(MEM1_BEGIN<=raddr)&(raddr<MEM1_END);
    wire rismem2=(MEM2_BEGIN<=raddr)&(raddr<MEM2_END);
    
    always@(*)begin
        case({rismem0,rismem1,rismem2})
            3'b100:master.Sr=slave0.Sr;
            3'b010:master.Sr=slave1.Sr;
            3'b001:master.Sr=slave2.Sr;
            default:master.Sr=dummy_axi.Sr;
        endcase
    end 

    assign slave0.Mr=rismem0?master.Mr:dummy_axi.Mr;
    assign slave1.Mr=rismem1?master.Mr:dummy_axi.Mr;
    assign slave2.Mr=rismem2?master.Mr:dummy_axi.Mr;
    
endmodule