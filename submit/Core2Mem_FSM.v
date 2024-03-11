module Core2Mem_FSM (
    input wire clk,
    input wire rstn,
    input wire [63:0] pc,
    input wire if_request,
    input wire switch_mode,
    input wire [63:0] address_cpu,
    input wire wen_cpu,
    input wire ren_cpu,
    input wire [63:0] wdata_cpu,
    input wire [7:0] wmask_cpu,
    output [31:0] inst,
    output [63:0] rdata_cpu,
    output if_stall,
    output mem_stall,

    output reg [63:0] address_mem,
    output reg ren_mem,
    output reg wen_mem,
    output reg [7:0] wmask_mem,
    output reg [63:0] wdata_mem,
    input wire [63:0] rdata_mem,
    input wire valid_mem
);

    reg switch_flush;

    //assign if_stall=(state==INST)&~valid_mem|(state!=INST)&if_request|switch_flush;
    
    //实现代码
`define IDLEFSM 2'b00
`define INST 2'b01
`define DATA 2'b10

    reg [1:0] state;

    initial begin
        state = 0;
    end

    always @(posedge clk or negedge rstn) begin
        if (rstn == 0) begin
            state <= 0;
        end else begin
            case(state) 
                `IDLEFSM: begin
                    if (ren_cpu || wen_cpu) begin
                        state <= `DATA;
                        address_mem <= address_cpu;
                        ren_mem <= ren_cpu;
                        wen_mem <= wen_cpu;
                        wmask_mem <= wmask_cpu;
                        wdata_mem <= wdata_cpu;
                    end else if (if_request == 1) begin
                        state <= `INST;
                        address_mem <= pc;
                        ren_mem <= 1;
                        wen_mem <= 0;
                        wmask_mem <= pc[2] ? 8'hF0 : 8'h0F;
                        wdata_mem <= 0;
                    end else begin
                        state <= `IDLEFSM;
                    end
                end
                `INST: begin
                    if (valid_mem) begin 
                        state <= `IDLEFSM;
                        ren_mem <= 0;
                        wen_mem <= 0;
                        address_mem <= 0;
                        wmask_mem <= 0;
                        wdata_mem <= 0;
                    end else begin
                        state <= `INST;
                    end
                end
                `DATA: begin
                    if (valid_mem) begin
                        state <= `IDLEFSM;
                        ren_mem <= 0;
                        wen_mem <= 0;
                        address_mem <= 0;
                        wmask_mem <= 0;
                        wdata_mem <= 0;
                    end else begin
                        state <= `DATA;
                    end
                end
                default: begin
                    state <= `IDLEFSM;
                    ren_mem <= 0;
                    wen_mem <= 0;
                    address_mem <= 0;
                    wmask_mem <= 0;
                    wdata_mem <= 0;
                end
            endcase
        end
    end

    always @(posedge clk) begin
        if (~rstn) begin
            switch_flush <= 1'b0;
        end else if (state == `INST && ~valid_mem && switch_mode) begin
            switch_flush <= 1'b1;
        end else if (state == `INST && valid_mem) begin
            switch_flush <= 1'b0;
        end
    end

    assign if_stall = ((if_request | ren_cpu | wen_cpu) & (~valid_mem | state != 2'b01)) | switch_flush;
    assign mem_stall = (ren_cpu | wen_cpu) & (~valid_mem | state != 2'b10);
    assign inst = pc[2] ? rdata_mem[63:32] : rdata_mem[31:0];
    assign rdata_cpu = rdata_mem;
    
endmodule