`include"MMIOStruct.vh"
module Axi_lite_Uart #
(
    parameter longint C_S_AXI_DATA_WIDTH	= 64,
    parameter longint C_S_AXI_ADDR_WIDTH	= 64
)
(   
    AXI_ift.Slave slave_ift,
    output TxD,
    input RxD,
    output RTSn,
    input CTSn,
    output MMIOStruct::MMIOPack cosim_mmio
);

    wire async_resetn=slave_ift.rstn;
    wire clock=slave_ift.clk;
    wire [15:0] s_axi_awaddr;
    wire s_axi_awvalid;
    wire s_axi_awready;
    wire [31:0] s_axi_wdata;
    wire s_axi_wvalid;
    wire s_axi_wready;
    wire [1:0] s_axi_bresp;
    wire s_axi_bvalid;
    wire s_axi_bready;
    wire [15:0] s_axi_araddr;
    wire s_axi_arvalid;
    wire s_axi_arready;
    wire [31:0] s_axi_rdata;
    wire [1:0] s_axi_rresp;
    wire s_axi_rvalid;
    wire s_axi_rready;
    wire interrupt;

    Uart uart (
        .async_resetn(async_resetn),
        .clock(clock),
        .s_axi_awaddr(s_axi_awaddr),
        .s_axi_awvalid(s_axi_awvalid),
        .s_axi_awready(s_axi_awready),
        .s_axi_wdata(s_axi_wdata),
        .s_axi_wvalid(s_axi_wvalid),
        .s_axi_wready(s_axi_wready),
        .s_axi_bresp(s_axi_bresp),
        .s_axi_bvalid(s_axi_bvalid),
        .s_axi_bready(s_axi_bready),
        .s_axi_araddr(s_axi_araddr),
        .s_axi_arvalid(s_axi_arvalid),
        .s_axi_arready(s_axi_arready),
        .s_axi_rdata(s_axi_rdata),
        .s_axi_rresp(s_axi_rresp),
        .s_axi_rvalid(s_axi_rvalid),
        .s_axi_rready(s_axi_rready),
        .interrupt(interrupt),
        .TxD(TxD),
        .RxD(RxD),
        .RTSn(RTSn),
        .CTSn(CTSn)
    );

    assign s_axi_awaddr=slave_ift.Mw.awaddr[15:0];
    assign s_axi_awvalid=slave_ift.Mw.awvalid;
    assign slave_ift.Sw.awready=s_axi_awready;
    assign s_axi_wdata=slave_ift.Mw.wdata[31:0];
    assign s_axi_wvalid=slave_ift.Mw.wvalid;
    assign slave_ift.Sw.wready=s_axi_wready;
    assign slave_ift.Sw.bresp=s_axi_bresp;
    assign slave_ift.Sw.bvalid=s_axi_bvalid;
    assign s_axi_bready=slave_ift.Mw.bready;

    assign s_axi_araddr=slave_ift.Mr.araddr[15:0];
    assign s_axi_arvalid=slave_ift.Mr.arvalid;
    assign slave_ift.Sr.arready=s_axi_arready;
    assign slave_ift.Sr.rdata={32'b0,s_axi_rdata};
    assign slave_ift.Sr.rresp=s_axi_rresp;
    assign slave_ift.Sr.rvalid=s_axi_rvalid;
    assign s_axi_rready=slave_ift.Mr.rready;

    assign cosim_mmio.store=1'b0;
    assign cosim_mmio.addr=64'b0;
    assign cosim_mmio.len=64'b0;
    assign cosim_mmio.val=64'b0;

endmodule