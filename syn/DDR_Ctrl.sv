module DDR_Ctrl # 
(
    parameter longint C_S_AXI_ADDR_WIDTH = 64,
    parameter longint C_S_AXI_DATA_WIDTH = 64
) 
(
    input ui_clk,
    input ui_clk_sync_rst,

    input wire [C_S_AXI_ADDR_WIDTH-1 : 0] addr_mem,
    input wire [C_S_AXI_DATA_WIDTH-1 : 0] wdata_mem,
    output reg [C_S_AXI_DATA_WIDTH-1 : 0] rdata_mem,
    output reg valid_mem, 
    input wire wen_mem,
    input wire ren_mem,
    input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0] wmask_mem,

    output reg [26:0] app_addr,
    output reg [2:0] app_cmd,
    output reg app_en,
    output reg [127:0] app_wdf_data,
    output reg app_wdf_end,
    output reg [15:0] app_wdf_mask,
    output reg app_wdf_wren,
    input [127:0] app_rd_data,
    input app_rd_data_end,
    input app_rd_data_valid,
    input app_rdy,
    input app_wdf_rdy,
    input init_calib_complete,

    output [2:0] debug_ddrctrl_state,
    output debug_app_en,
    output debug_app_wdf_wren,
    output debug_app_rdy,
    output debug_app_wdf_rdy,
    output debug_app_rd_data_valid
);

    localparam READY=3'b000;
    localparam START=3'b001;
    localparam WAIT_READ=3'b010;
    localparam WAIT_WRITE=3'b011;
    localparam DO_READ=3'b100;
    localparam DO_WRITE=3'b101;
    localparam SKIP=3'b110;
    reg [31:0] skip_interval;
    reg [2:0] state;

    // reg app_rd_data_valid_tmp;
    // reg [127:0] app_rd_data_tmp;
    // always@(posedge ui_clk)begin
    //     if(ui_clk_sync_rst)begin
    //         app_rd_data_tmp<=128'b0;
    //         app_rd_data_valid_tmp<=1'b0;
    //     end else if(state==START)begin 
    //         app_rd_data_valid_tmp<=1'b0;
    //     end if(app_rd_data_valid)begin
    //         app_rd_data_tmp<=app_rd_data;
    //         app_rd_data_valid_tmp<=app_rd_data_valid;
    //     end
    // end

    always @(posedge ui_clk) begin
        if(ui_clk_sync_rst)begin
            state<=START;
            app_addr<=27'b0;
            app_cmd<=3'b1;
            app_en<=1'b0;
            app_wdf_end<=1'b0;
            app_wdf_data<=128'b0;
            app_wdf_mask<=16'b0;
            app_wdf_wren<=1'b0;
            rdata_mem<=64'b0;
            valid_mem<=1'b0;
            skip_interval<=32'b0;
        end else begin
        case(state)
            READY:
            begin
                if(~wen_mem&~ren_mem)begin
                    valid_mem<=1'b0;
                    state<=SKIP;
                    skip_interval<=32'b1;
                end
            end
            default:
            begin
                skip_interval<={skip_interval[30:0],1'b0};
                if(skip_interval==32'b0)state<=START;
            end
            START:
            begin
                if(wen_mem&init_calib_complete)begin
                    state<=WAIT_WRITE;
                    app_addr<={addr_mem[26:3],3'b0};
                    app_cmd<=3'b0;
                    app_wdf_data<={wdata_mem,wdata_mem};
                    app_wdf_end<=1'b1;
                    app_wdf_mask<=addr_mem[3]?
                        {~wmask_mem,8'hff}:
                        {8'hff,~wmask_mem};
                    app_wdf_wren<=1'b0;
                end else if(ren_mem&init_calib_complete&~app_rd_data_valid)begin
                    state<=WAIT_READ;
                    app_addr<={addr_mem[26:3],3'b0};
                    app_cmd<=3'b1;
                    app_wdf_data<=128'b0;
                    app_wdf_end<=1'b0;
                    app_wdf_mask<=16'h0000;
                    app_wdf_wren<=1'b0;
                end
            end
            WAIT_WRITE:
            begin
                if(app_rdy&app_wdf_rdy)begin
                    state<=DO_WRITE;
                    app_en<=1'b1;
                    app_wdf_wren<=1'b1;
                end
            end
            WAIT_READ:
            begin
                if(app_rdy)begin
                    state<=DO_READ;
                    app_en<=1'b1;
                end
            end
            DO_READ:
            begin
                if(app_rd_data_valid)begin
                    app_en<=1'b0;
                    state<=READY;
                    rdata_mem<=app_addr[3]?app_rd_data[127:64]:app_rd_data[63:0];
                    valid_mem<=1'b1;
                end
            end
            DO_WRITE:
            begin
                if(app_rdy&app_wdf_rdy)begin
                    app_en<=1'b0;
                    app_wdf_wren<=1'b0;
                    state<=READY;
                    valid_mem<=1'b1;
                end
            end
        endcase
        end
    end

    assign debug_ddrctrl_state=state;
    assign debug_app_en=app_en;
    assign debug_app_wdf_wren=app_wdf_wren;
    assign debug_app_rdy=app_rdy;
    assign debug_app_wdf_rdy=app_wdf_rdy;
    assign debug_app_rd_data_valid=app_rd_data_valid;
    
endmodule
