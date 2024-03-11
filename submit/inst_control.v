// Define Segment
`define MATHr 7'b0110011
`define MATHi 7'b0010011
`define MATHWi 7'b0011011
`define MATHWr 7'b0111011
`define JALr  7'b1100111
`define JAL   7'b1101111
`define BRANCH 7'b1100011
`define LUI   7'b0110111
`define AUIPC 7'b0010111
`define SW    7'b0100011
`define LW    7'b0000011
`define CSR   7'b1110011

`define ALU_ADD 4'b0000
`define ALU_SUB 4'b0001
`define ALU_AND 4'b0010
`define ALU_OR 4'b0011
`define ALU_XOR 4'b0100
`define ALU_SLT 4'b0101
`define ALU_SLTU 4'b0110
`define ALU_SLL 4'b0111
`define ALU_SRL 4'b1000
`define ALU_SRA 4'b1001
`define ALU_ADDW 4'b1010
`define ALU_SUBW 4'b1011
`define ALU_SLLW 4'b1100
`define ALU_SRLW 4'b1101
`define ALU_SRAW 4'b1110
// End Define

module Inst_Controller (
    input [31:0] inst,
    output [21:0] decode,
    output reg csr_write,
    output reg [1:0] trap,
    output reg wb_src
);

    reg we_reg, npl_sel, we_mem;
    reg [1:0] alu_asel, alu_bsel, wb_sel;
    reg [3:0] alu_op;
    reg [2:0] immgen_op, bralu_op, memdata_width;

    wire [6:0] opcode = inst[6:0];
    wire [2:0] funct3 = inst[14:12];
    wire funct7_5 = inst[30];
    wire [4:0] rs1 = inst[19:15];
    initial begin
        we_mem = 0;
        we_reg = 0;
        npl_sel = 0;
        alu_asel = 0;
        alu_bsel = 0;
        wb_sel = 0;
        alu_op = 0;
        immgen_op = 0;
        bralu_op = 0;
        memdata_width = 0;
        csr_write = 0;
        trap = 0;
        wb_src = 0;
    end
    always @(*) begin
        case (opcode) 
            `MATHr: begin
                we_reg = 1;
                npl_sel = 0;
                we_mem = 0;
                immgen_op = 0;
                case (funct3)
                    3'b000: alu_op = funct7_5 == 0 ? `ALU_ADD : `ALU_SUB;
                    3'b001: alu_op = `ALU_SLL;
                    3'b010: alu_op = `ALU_SLT;
                    3'b011: alu_op = `ALU_SLTU;
                    3'b100: alu_op = `ALU_XOR;
                    3'b101: alu_op = funct7_5 == 0 ? `ALU_SRL : `ALU_SRA;
                    3'b110: alu_op = `ALU_OR;
                    3'b111: alu_op = `ALU_AND;
                    default: alu_op = 4'bx;
                endcase
                bralu_op = 0;
                alu_asel = 2'b01;
                alu_bsel = 2'b01;
                wb_sel = 2'b01;
                memdata_width = 3'b0;
            end
            `MATHi: begin
                we_reg = 1;
                npl_sel = 0;
                we_mem = 0;
                immgen_op = 3'b001;
                case (funct3)
                    3'b000: alu_op = `ALU_ADD;
                    3'b001: alu_op = `ALU_SLL;
                    3'b010: alu_op = `ALU_SLT;
                    3'b011: alu_op = `ALU_SLTU;
                    3'b100: alu_op = `ALU_XOR;
                    3'b101: alu_op = funct7_5 == 0 ? `ALU_SRL : `ALU_SRA;
                    3'b110: alu_op = `ALU_OR;
                    3'b111: alu_op = `ALU_AND;
                    default: alu_op = 4'bx;
                endcase
                bralu_op = 0;
                alu_asel = 2'b01;
                alu_bsel = 2'b10;
                wb_sel = 2'b01;
                memdata_width = 0;
            end
            `MATHWr: begin
                we_reg = 1;
                npl_sel = 0;
                we_mem = 0;
                immgen_op = 3'b000;
                case (funct3)
                    3'b000: alu_op = funct7_5 == 0 ? `ALU_ADDW : `ALU_SUBW;
                    3'b001: alu_op = `ALU_SLLW;
                    3'b101: alu_op = funct7_5 == 0 ? `ALU_SRLW : `ALU_SRAW;
                    default: alu_op = 4'bx;
                endcase
                bralu_op = 0;
                alu_asel = 2'b01;
                alu_bsel = 2'b01;
                wb_sel = 2'b01;
                memdata_width = 0;
            end
            `MATHWi: begin
                we_reg = 1;
                npl_sel = 0;
                we_mem = 0;
                immgen_op = 3'b001;
                case (funct3)
                    3'b000: alu_op = `ALU_ADDW;
                    3'b001: alu_op = `ALU_SLLW;
                    3'b101: alu_op = funct7_5 == 0 ? `ALU_SRLW : `ALU_SRAW;
                    default: alu_op = 4'bx;
                endcase
                bralu_op = 0;
                alu_asel = 2'b01;
                alu_bsel = 2'b10;
                wb_sel = 2'b01;
                memdata_width = 0;
            end
            `JALr: begin
                we_reg = 1;
                npl_sel = 1;
                we_mem = 0;
                immgen_op = 3'b001;
                alu_op = `ALU_ADD;
                bralu_op = 0;
                alu_asel = 2'b01;
                alu_bsel = 2'b10;
                wb_sel = 2'b11;
                memdata_width = 0;
            end
            `JAL: begin
                we_reg = 1;
                npl_sel = 1;
                we_mem = 0;
                immgen_op = 3'b101;
                alu_op = `ALU_ADD;
                bralu_op = 0;
                alu_asel = 2'b10;
                alu_bsel = 2'b10;
                wb_sel = 2'b11;
                memdata_width = 0;
            end
            `BRANCH: begin
                we_reg = 0;
                npl_sel = 1;
                we_mem = 0;
                immgen_op = 3'b011;
                alu_op = `ALU_ADD;
                case (funct3)
                    3'b000: bralu_op = 3'b001;
                    3'b001: bralu_op = 3'b010;
                    3'b100: bralu_op = 3'b011;
                    3'b101: bralu_op = 3'b100;
                    3'b110: bralu_op = 3'b101;
                    3'b111: bralu_op = 3'b110;
                    default: bralu_op = 3'bx;
                endcase
                alu_asel = 2'b10;
                alu_bsel = 2'b10;
                wb_sel = 2'b01;
                memdata_width = 0;
            end
            `LUI: begin
                we_reg = 1;
                npl_sel = 0;
                we_mem = 0;
                immgen_op = 3'b100;
                alu_op = `ALU_ADD;
                bralu_op = 0;
                alu_asel = 2'b00;
                alu_bsel = 2'b10;
                wb_sel = 2'b01;
                memdata_width = 0;
            end
            `AUIPC: begin
                we_reg = 1;
                npl_sel = 0;
                we_mem = 0;
                immgen_op = 3'b100;
                alu_op = `ALU_ADD;
                bralu_op = 0;
                alu_asel = 2'b10;
                alu_bsel = 2'b10;
                wb_sel = 2'b01;
                memdata_width = 0;
            end
            `SW: begin
                we_reg = 0;
                npl_sel = 0;
                we_mem = 1;
                immgen_op = 3'b010;
                alu_op = `ALU_ADD;
                bralu_op = 0;
                alu_asel = 2'b01;
                alu_bsel = 2'b10;
                wb_sel = 2'b00;
                memdata_width = funct3 == 3'b011 ? 3'b001 :
                                funct3 == 3'b010 ? 3'b010 :
                                funct3 == 3'b001 ? 3'b011 :
                                funct3 == 3'b000 ? 3'b100 :
                                3'bx;
            end
            `LW: begin
                we_reg = 1;
                npl_sel = 0;
                we_mem = 0;
                immgen_op = 3'b001;
                alu_op = `ALU_ADD;
                bralu_op = 0;
                alu_asel = 2'b01;
                alu_bsel = 2'b10;
                wb_sel = 2'b10;
                memdata_width = funct3 == 3'b000 ? 3'b100 :
                                funct3 == 3'b001 ? 3'b011 :
                                funct3 == 3'b010 ? 3'b010 :
                                funct3 == 3'b011 ? 3'b001 :
                                funct3 == 3'b100 ? 3'b111 :
                                funct3 == 3'b101 ? 3'b110 :
                                funct3 == 3'b110 ? 3'b101 :
                                3'bx;
            end
            `CSR: begin
                we_reg = 1;
                npl_sel = 0;
                we_mem = 0;
                immgen_op = 3'b110;
                case(funct3) 
                    3'b001: begin
                        alu_op = `ALU_ADD;
                        alu_asel = 2'b01;
                        alu_bsel = 2'b0;
                        wb_src = 1;
                        csr_write = rs1 == 5'b0 ? 0 : 1;
                    end
                    3'b010: begin
                        alu_op = `ALU_OR;
                        alu_asel = 2'b01;
                        alu_bsel = 2'b11;
                        wb_src = 1;
                        csr_write = rs1 == 5'b0 ? 0 : 1;
                    end
                    3'b011: begin
                        alu_op = `ALU_XOR;
                        alu_asel = 2'b01;
                        alu_bsel = 2'b11;
                        wb_src = 1;
                        csr_write = rs1 == 5'b0 ? 0 : 1;
                    end
                    3'b101: begin
                        alu_op = `ALU_ADD;
                        alu_asel = 2'b11;
                        wb_src = 1;
                        alu_bsel = 2'b0;
                        csr_write = rs1 == 5'b0 ? 0 : 1;
                    end
                    3'b110: begin
                        alu_op = `ALU_OR;
                        alu_asel = 2'b11;
                        wb_src = 1;
                        alu_bsel = 2'b11;
                        csr_write = rs1 == 5'b0 ? 0 : 1;
                    end
                    3'b111: begin
                        alu_op = `ALU_XOR;
                        alu_asel = 2'b11;
                        wb_src = 1;
                        alu_bsel = 2'b11;
                        csr_write = rs1 == 5'b0 ? 0 : 1;
                    end
                    3'b000: begin
                        case (inst[31:20]) 
                            12'b000000000000: begin
                                trap = 2'b11; 
                                //csr_read_addr = 12'h305;
                                csr_write = 1;
                            end
                            12'b001100000010: begin
                                trap = 2'b10;
                                //csr_read_addr = 12'h341;  
                                csr_write = 1;
                            end
                            12'b000100000010: begin
                                trap = 2'b01;
                                csr_write = 1;
                                //csr_read_addr = 12'h141;  
                            end
                            default: begin
                                trap = 2'b00;
                                //csr_read_addr = 12'h305;
                            end
                        endcase
                    end
                    default: begin
                        
                    end
                endcase
                bralu_op = 0;
                wb_sel = 2'b10;
                memdata_width = 3'b001;
            end
            default: begin
                we_mem = 0;
                we_reg = 0;
                npl_sel = 0;
                alu_asel = 0;
                alu_bsel = 0;
                wb_sel = 0;
                alu_op = 0;
                immgen_op = 0;
                bralu_op = 0;
                memdata_width = 0;
                csr_write = 0;
                trap = 0;
                wb_src = 0;
            end
        endcase
    end
    assign decode = { we_reg, we_mem, npl_sel, immgen_op, alu_op, bralu_op, alu_asel, alu_bsel, wb_sel, memdata_width };
endmodule