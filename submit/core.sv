// Define Segment
`define OP_R 3'd0
`define OP_I 3'd1
`define OP_S 3'd2
`define OP_B 3'd3
`define OP_U 3'd4
`define OP_J 3'd5
// End Define

`include "ExceptStruct.vh"
`include "CSRStruct.vh"
`include "RegStruct.vh"

module Core (
  input wire clk,                       /* 时钟 */ 
  input wire rstn,                      /* 重置信号 */ 
  output wire [63:0] pc,
  output wire [63:0] address,
  output wire we_mem,
  output wire [63:0] wdata_mem,
  output wire [7:0] wmask_mem,
  output wire re_mem,
  output wire if_request,
  input wire if_stall,
  input wire mem_stall,
  output wire switch_mode,
  input wire time_int,
  input wire [63:0] rdata_mem,
  input wire [31:0] inst,
  output wire cosim_valid,
  output wire [63:0] cosim_pc,          /* current pc */
  output wire [31:0] cosim_inst,        /* current instruction */
  output wire [ 7:0] cosim_rs1_id,      /* rs1 id */
  output wire [63:0] cosim_rs1_data,    /* rs1 data */
  output wire [ 7:0] cosim_rs2_id,      /* rs2 id */
  output wire [63:0] cosim_rs2_data,    /* rs2 data */
  output wire [63:0] cosim_alu,         /* alu out */
  output wire [63:0] cosim_mem_addr,    /* memory address */
  output wire [ 3:0] cosim_mem_we,      /* memory write enable */
  output wire [63:0] cosim_mem_wdata,   /* memory write data */
  output wire [63:0] cosim_mem_rdata,   /* memory read data */
  output wire [ 3:0] cosim_rd_we,       /* rd write enable */
  output wire [ 7:0] cosim_rd_id,       /* rd id */
  output wire [63:0] cosim_rd_data,     /* rd data */
  output wire [ 3:0] cosim_br_taken,    /* branch taken? */
  output wire [63:0] cosim_npc,
  output CSRStruct::CSRPack cosim_csr_info,
  output RegStruct::RegPack cosim_regs,
  output cosim_interrupt,
  output [63:0] cosim_cause
  );

  //ID stage
  reg [31:0] IF_ID_inst;
  reg [63:0] IF_ID_PC;
  reg IF_ID_valid;
  //EX stage
  reg [31:0] ID_EX_inst;
  reg [63:0] ID_EX_PC;
  reg [63:0] ID_EX_rs1_data;
  reg [63:0] ID_EX_rs2_data;
  reg [4:0] ID_EX_rs1_id;
  reg [4:0] ID_EX_rs2_id;
  reg [63:0] ID_EX_imm;
  reg [4:0] ID_EX_rd;
  reg [63:0] ID_EX_mem_addr;
  reg [21:0] ID_EX_decode;
  reg ID_EX_valid;
  reg ID_EX_csr_we;
  reg [1:0] ID_EX_trap;
  reg ID_EX_wb_src;
  //MEMstage
  reg [63:0] EX_MEM_mem_rdata;
  reg [63:0] EX_MEM_mem_wdata;
  reg EX_MEM_br_taken;
  reg [31:0] EX_MEM_inst;
  reg [63:0] EX_MEM_PC;
  reg [63:0] EX_MEM_alu_res;
  reg [4:0] EX_MEM_rd;
  reg [63:0] EX_MEM_imm;
  reg [63:0] EX_MEM_rs1_data;
  reg [63:0] EX_MEM_rs2_data;
  reg [21:0] EX_MEM_decode;
  reg [63:0] EX_MEM_mem_addr;
  reg [4:0] EX_MEM_rs1_id;
  reg [4:0] EX_MEM_rs2_id;
  reg EX_MEM_valid;
  reg EX_MEM_csr_we;
  reg [1:0] EX_MEM_trap;
  reg EX_MEM_wb_src;

  //WB stage
  reg [31:0] MEM_WB_inst;
  reg [63:0] MEM_WB_PC;
  reg [63:0] MEM_WB_rd_data;
  reg [4:0] MEM_WB_rd;
  reg [63:0] MEM_WB_alu_res;
  reg [63:0] MEM_WB_imm;
  reg [21:0] MEM_WB_decode;
  reg [63:0] MEM_WB_rs1_data;
  reg [63:0] MEM_WB_rs2_data;
  reg [63:0] MEM_WB_mem_rdata;
  reg [63:0] MEM_WB_mem_addr;
  reg MEM_WB_rw_wmode;
  reg [4:0] MEM_WB_rs1_id;
  reg [4:0] MEM_WB_rs2_id;
  reg [63:0] MEM_WB_mem_wdata;
  reg MEM_WB_valid;
  reg MEM_WB_csr_we;
  reg [1:0] MEM_WB_trap;
  reg MEM_WB_wb_src;
  
  wire [63:0] alu_res;
  wire stall_PC;
  wire stall_IFID;
  wire stall_IDEXE;
  wire stall_EXEMEM;
  wire stall_MEMWB;
  wire flush_IFID;
  wire flush_IDEXE;
  wire flush_EXEMEM;
  wire flush_MEMWB;
  wire jump;

  reg [63:0] PC;  
  wire [4:0] rs1_id;
  wire [63:0] rs1_data;
  wire [4:0] rs2_id;
  wire [63:0] rs2_data;
  wire [63:0] mem_addr;
  wire [63:0] mem_wdata;
  wire [63:0] mem_rdata;
  wire [4:0] rd_id;
  wire [63:0] rd_data;
  wire rd_we;
  wire br_taken;
  reg [63:0] npc;
  wire [21:0] decode;
  wire rw_wmode;
  wire [63:0] imm;
  wire [6:0] opcode;
  wire [2:0] optype;
  wire [2:0] funct3;
  wire [6:0] funct7;
  wire [1:0] priv;
  wire [63:0] pc_csr;
  wire [63:0] csr_val;
  wire wb_src;
  
  ExceptStruct::ExceptPack except_ifid;
  ExceptStruct::ExceptPack except_idex;
  ExceptStruct::ExceptPack except_exmem;
  ExceptStruct::ExceptPack except_memwb;

  wire except_happen_ifid;
  wire except_happen_idex;
  wire except_happen_exmem;
  wire except_happen_memwb;

  reg [63:0] ID_EX_csr_val;
  reg [63:0] EX_MEM_csr_val;
  reg [63:0] MEM_WB_csr_val;

  wire [1:0] wb_sel = MEM_WB_decode[4:3];
  initial begin
    PC = 64'b0;
    npc = 64'b0;
    IF_ID_inst = 0;
    IF_ID_PC = 0;
    ID_EX_PC = 0;
    ID_EX_inst = 0;
    EX_MEM_PC = 0;
    EX_MEM_inst = 0;
    MEM_WB_PC = 0;
    MEM_WB_inst = 0;
    ID_EX_decode = 0;
    EX_MEM_decode = 0;
    MEM_WB_decode = 0;
    ID_EX_valid = 0;
    IF_ID_valid = 0;
    EX_MEM_valid = 0;
    MEM_WB_valid = 0;
    except_ifid = '{except:1'b0,epc:64'b0,ecause:64'h0,etval:64'h0};
    except_idex = '{except:1'b0,epc:64'b0,ecause:64'h0,etval:64'h0};
    except_exmem = '{except:1'b0,epc:64'b0,ecause:64'h0,etval:64'h0};
    except_memwb = '{except:1'b0,epc:64'b0,ecause:64'h0,etval:64'h0};
  end

  always@(posedge clk or negedge rstn) begin
    if(rstn == 0) begin
      PC<=0;
      IF_ID_inst<=0;
      IF_ID_PC<=0;
      ID_EX_PC<=0;
      ID_EX_inst<=0;
      EX_MEM_PC<=0;
      EX_MEM_inst<=0;
      MEM_WB_PC<=0;
      MEM_WB_inst<=0;
      ID_EX_decode<=0;
      EX_MEM_decode<=0;
      MEM_WB_decode<=0;
      ID_EX_valid<=0;
      IF_ID_valid<=0;
      EX_MEM_valid<=0;  
      MEM_WB_valid<=0;
    end
    else begin
      // IF stage pc forward 
      if (stall_PC == 0 || EX_MEM_br_taken == 1 || switch_mode) begin
        PC<=npc;
      end
      // ID stage
      if (stall_IFID == 0 && flush_IFID == 0) begin
        IF_ID_inst<=inst;
        IF_ID_PC<=PC;
        IF_ID_valid<=1;
      end else if (flush_IFID == 1 & stall_IFID == 0) begin
        IF_ID_inst <= 0;
        IF_ID_PC <= 0;
        IF_ID_valid <= 0;
      end
      // EX stage
      if (flush_IDEXE != 1 && stall_IDEXE != 1) begin
        ID_EX_inst<=IF_ID_inst;
        ID_EX_PC<=IF_ID_PC;
        ID_EX_rs1_data<=rs1_data;
        ID_EX_rs2_data<=rs2_data;
        ID_EX_rs1_id<=rs1_id;
        ID_EX_rs2_id<=rs2_id;
        ID_EX_imm<=imm;
        ID_EX_rd<=rd_id;
        ID_EX_decode<=cosim_interrupt ? 0 : decode;
        ID_EX_valid<=IF_ID_valid;
        ID_EX_csr_we<=cosim_interrupt ? 0 : csr_write;
        ID_EX_trap<=trap;
        ID_EX_csr_val <= csr_val;
        ID_EX_wb_src <= wb_src;
      end else if (flush_IDEXE == 1 & stall_IDEXE == 0) begin
        ID_EX_decode <= 0;
        ID_EX_inst <= 0;
        ID_EX_csr_we <= 0;
        ID_EX_valid <= 0;
        ID_EX_trap <= 0;
        ID_EX_wb_src <= 0;
        //except_idex <= 0;
      end
      // MEM stage
      if (flush_EXEMEM != 1 && stall_EXEMEM != 1) begin
        EX_MEM_inst<=ID_EX_inst;
        EX_MEM_PC<=ID_EX_PC;
        EX_MEM_alu_res<=alu_res;
        EX_MEM_rd<=ID_EX_rd;
        EX_MEM_imm<=ID_EX_imm;
        EX_MEM_mem_addr<=mem_addr;
        EX_MEM_rs1_data<=ID_EX_rs1_data;
        EX_MEM_rs2_data<=ID_EX_rs2_data;
        EX_MEM_decode<=cosim_interrupt ? 0 : ID_EX_decode;
        EX_MEM_valid<=ID_EX_valid;
        EX_MEM_rs1_id<=ID_EX_rs1_id;
        EX_MEM_rs2_id<=ID_EX_rs2_id; 
        EX_MEM_br_taken<=br_taken;
        EX_MEM_mem_wdata<=mem_wdata;
        EX_MEM_csr_we <= cosim_interrupt ? 0 : ID_EX_csr_we;
        EX_MEM_trap <= ID_EX_trap;
        except_exmem <= except_idex;
        EX_MEM_csr_val <= ID_EX_csr_val;
        EX_MEM_wb_src <= ID_EX_wb_src;        
      end else if (flush_EXEMEM == 1 & stall_EXEMEM == 0) begin
        EX_MEM_decode<=0;
        EX_MEM_inst<=0;
        EX_MEM_valid<=0;
        EX_MEM_br_taken<=0;
        EX_MEM_csr_we<=0;
        EX_MEM_trap <= 0;
        EX_MEM_wb_src <= 0;      
        except_exmem <= '{except:1'b0,epc:64'b0,ecause:64'h0,etval:64'h0};
      end

      // WB stage
      if (flush_MEMWB == 0) begin
        MEM_WB_inst<=EX_MEM_inst;
        MEM_WB_PC<=EX_MEM_PC;
        MEM_WB_rd<=EX_MEM_rd;
        MEM_WB_alu_res<=EX_MEM_alu_res;
        MEM_WB_imm<=EX_MEM_imm;
        MEM_WB_rs1_data<=EX_MEM_rs1_data;
        MEM_WB_rs2_data<=EX_MEM_rs2_data;
        MEM_WB_decode<=cosim_interrupt ? 0 : EX_MEM_decode;
        MEM_WB_valid<=EX_MEM_valid;
        MEM_WB_rs1_id<=EX_MEM_rs1_id;
        MEM_WB_rs2_id<=EX_MEM_rs2_id;
        MEM_WB_mem_wdata<=mem_wdata;
        MEM_WB_mem_rdata<=mem_rdata >> (EX_MEM_mem_addr[2:0] * 8);
        MEM_WB_rw_wmode<=rw_wmode;
        MEM_WB_mem_addr<=EX_MEM_mem_addr;
        except_memwb <= except_exmem;
        MEM_WB_csr_we <= cosim_interrupt ? 0 : EX_MEM_csr_we;
        MEM_WB_csr_val <= EX_MEM_csr_val;
        MEM_WB_trap <= EX_MEM_trap;
        MEM_WB_wb_src <= EX_MEM_wb_src;
      end else if (stall_MEMWB == 0) begin
        MEM_WB_wb_src <= 0;
        MEM_WB_inst <= 0;
        MEM_WB_PC <= 0;
        MEM_WB_valid <= 0;
        MEM_WB_decode <= 0;
        MEM_WB_csr_we <= 0;
        MEM_WB_trap <= 0;
        except_memwb <= '{except:1'b0,epc:64'b0,ecause:64'h0,etval:64'h0};
      end
    end
  end
  assign jump = opcode == 7'b1100011 | opcode == 7'b1101111 | opcode == 7'b1100111 | 
                ID_EX_inst[6:0] == 7'b1100011 | ID_EX_inst[6:0] == 7'b1101111 | ID_EX_inst[6:0] == 7'b1100111
                | EX_MEM_inst[6:0] == 7'b1100011 | EX_MEM_inst[6:0] == 7'b1101111 | EX_MEM_inst[6:0] == 7'b1100111 |
                MEM_WB_inst[6:0] == 7'b1100111 | MEM_WB_inst[6:0] == 7'b1101111 | switch_mode; 
  wire [1:0] forwardingA, forwardingB;

  StallUnit stallunit(
    .IF_rs1(rs1_id),
    .IF_rs2(rs2_id),
    .ID_rs1(ID_EX_rs1_id),
    .ID_rs2(ID_EX_rs2_id),
    .EXE_rd(ID_EX_rd),
    .MEM_rd(EX_MEM_rd),
    .WB_rd(MEM_WB_rd),
    .EXE_we_reg(ID_EX_decode[21]),
    .MEM_we_reg(EX_MEM_decode[21]),
    .WB_we_reg(MEM_WB_decode[21]),
    .jump(jump),
    .stall_PC(stall_PC),
    .stall_IFID(stall_IFID),
    .stall_IDEXE(stall_IDEXE),
    .stall_EXEMEM(stall_EXEMEM),
    .stall_MEMWB(stall_MEMWB),
    .flush_IFID(flush_IFID),
    .flush_IDEXE(flush_IDEXE),
    .flush_EXEMEM(flush_EXEMEM),
    .flush_MEMWB(flush_MEMWB),
    .forwardingA(forwardingA),
    .forwardingB(forwardingB),
    .if_stall(if_stall),
    .mem_stall(mem_stall),
    .switch_mode(switch_mode),
    .except_happen(except_happen_idex),
    .interrupt(cosim_interrupt)
  );
  wire shit = 0;
  wire [2:0] MEM_WB_memdata_width;
  assign MEM_WB_memdata_width = MEM_WB_decode[2:0];
  assign rw_wmode = EX_MEM_decode[20];
  assign rd_data = MEM_WB_wb_src ? MEM_WB_csr_val : 
            (wb_sel == 2'b00 ? 0 :
            wb_sel == 2'b01 ? MEM_WB_alu_res :
            wb_sel == 2'b10 ? (MEM_WB_inst[6:0] == 7'b0000011 ? 
                      (MEM_WB_memdata_width == 3'b010 ? { {(64 - 32){MEM_WB_mem_rdata[31]}}, MEM_WB_mem_rdata[31:0] } :
                      MEM_WB_memdata_width == 3'b011 ? { {(64 - 16){MEM_WB_mem_rdata[15]}}, MEM_WB_mem_rdata[15:0] } :
                      MEM_WB_memdata_width == 3'b100 ? { {(64 - 8){MEM_WB_mem_rdata[7]}}, MEM_WB_mem_rdata[7:0] } :
                      MEM_WB_memdata_width == 3'b101 ? { 32'b0, MEM_WB_mem_rdata[31:0] } : 
                      MEM_WB_memdata_width == 3'b110 ? { 48'b0, MEM_WB_mem_rdata[15:0] } :
                      MEM_WB_memdata_width == 3'b111 ? { 56'b0, MEM_WB_mem_rdata[7:0] } :
                      MEM_WB_mem_rdata) : MEM_WB_mem_rdata) :
                      PC);
  wire [63:0] tmp_inst;
  wire [7:0] mem_mask;

  assign pc = PC;
  assign address = EX_MEM_mem_addr;
  assign we_mem = rw_wmode;
  assign wdata_mem = EX_MEM_mem_wdata;
  assign wmask_mem = mem_mask;
  assign re_mem = rstn & EX_MEM_inst[6:0] == 7'b0000011;
  assign if_request = rstn & ~jump;
  assign mem_rdata = rdata_mem;

  wire csr_write;
  wire [1:0] trap;
  
  Inst_Controller ctrl( 
    IF_ID_inst,
    decode,
    csr_write,
    trap,
    wb_src
  );
  reg sig;
  always @(negedge clk) begin
    if (stall_PC != 1 || jump || switch_mode) begin
      if (switch_mode) begin
        npc = pc_csr;
      end else if ((EX_MEM_decode[19] & EX_MEM_br_taken) == 1) begin
        sig = 1;
        npc = EX_MEM_alu_res;
      end else if ((MEM_WB_decode[19] & (MEM_WB_decode[11:9] == 3'b0)) == 1) begin
        npc = MEM_WB_alu_res;
        sig = 0;
      end else if (~jump) begin
        npc = PC + 64'b100;
        sig = 0;
      end
    end 
  end

  Inst_parser inst_parser(
    .inst (IF_ID_inst),
    ._opcode (opcode),
    ._funct3 (funct3),
    ._funct7 (funct7),
    ._rs1 (rs1_id),
    ._rs2 (rs2_id),
    ._rd (rd_id),
    ._optype (optype)
  );

  assign rd_we = MEM_WB_decode[21];

  Regs regs(
    .clk (clk),
    .rst (~rstn),
    .we  (rd_we),
    .read_addr_1 (rs1_id),
    .read_addr_2 (rs2_id),
    .write_addr (MEM_WB_rd),
    .write_data (rd_data),
    .read_data_1 (rs1_data),
    .read_data_2 (rs2_data),
    .cosim_regs (cosim_regs)
  );

  wire [63:0] alu_a, alu_b;
  wire [3:0] alu_op;
  assign alu_op = ID_EX_decode[15:12];

  wire [1:0] a_sel = ID_EX_decode[8:7];
  wire [1:0] b_sel = ID_EX_decode[6:5];

  wire [2:0] immgen_op = decode[18:16];

  assign imm =  immgen_op == 3'b000 ? 64'b0 : 
                immgen_op == 3'b001 ? {{(64 - 12){IF_ID_inst[31]}}, IF_ID_inst[31:20]} :
                immgen_op == 3'b010 ? {{(64 - 12){IF_ID_inst[31]}}, IF_ID_inst[31:25], IF_ID_inst[11:7]} :
                immgen_op == 3'b011 ? {{(64 - 13){IF_ID_inst[31]}}, IF_ID_inst[31], IF_ID_inst[7], IF_ID_inst[30:25], IF_ID_inst[11:8], 1'b0} :
                immgen_op == 3'b100 ? {{(64 - 32){IF_ID_inst[31]}}, IF_ID_inst[31:12], 12'b0} :
                immgen_op == 3'b110 ? {59'b0, IF_ID_inst[19:15]} :
                {{(64 - 21){IF_ID_inst[31]}}, IF_ID_inst[31], IF_ID_inst[19:12], IF_ID_inst[20], IF_ID_inst[30:21], 1'b0};

  wire [63:0] read_data1, read_data2;

  assign read_data1 = forwardingA == 2'b01 ? rd_data :
                    forwardingA == 2'b10 ? EX_MEM_alu_res : 
                    ID_EX_rs1_data;
  assign read_data2 = forwardingB == 2'b01 ? rd_data :
                    forwardingB == 2'b10 ? EX_MEM_alu_res :
                    ID_EX_rs2_data;

  assign alu_a =  a_sel == 2'b0 ? 0 :
                  a_sel == 2'b01 ? read_data1 :
                  a_sel == 2'b11 ? ID_EX_imm :
                  ID_EX_PC;
  assign alu_b =  b_sel == 2'b0 ? 0 :
                  b_sel == 2'b01 ? read_data2 :
                  b_sel == 2'b11 ? ID_EX_csr_val :
                  ID_EX_imm;
  
  ALU alu(
    .clk(clk),
    .a (alu_a),
    .b (alu_b),
    .alu_op (alu_op),
    .res (alu_res)
  );

  wire signed [63:0] srs1_data = read_data1;
  wire signed [63:0] srs2_data = read_data2;
  
  wire [2:0] bralu_op;
  assign bralu_op = ID_EX_decode[11:9];
  assign br_taken = bralu_op == 3'b000 ? 0 :
             bralu_op == 3'b001 ? (read_data1 == read_data2 ? 1 : 0) :
             bralu_op == 3'b010 ? (read_data1 != read_data2 ? 1 : 0) :
             bralu_op == 3'b011 ? (srs1_data < srs2_data ? 1 : 0) :
             bralu_op == 3'b100 ? (srs1_data >= srs2_data ? 1 : 0) :
             bralu_op == 3'b101 ? (read_data1 < read_data2 ? 1 : 0) :
             (read_data1 >= read_data2 ? 1 : 0);

  assign mem_addr = alu_res;
  assign mem_wdata = read_data2 << (mem_addr[2:0] * 8);

  wire [2:0] memdata_width = EX_MEM_decode[2:0];
  wire [7:0] r_mask = memdata_width == 3'b000 ? 8'b0 :
                    memdata_width == 3'b001 ? 8'hff :
                    memdata_width == 3'b010 ? 8'hf :
                    memdata_width == 3'b011 ? 8'h3 :
                    memdata_width == 3'b100 ? 8'b1 :
                    memdata_width == 3'b101 ? 8'hf :
                    memdata_width == 3'b110 ? 8'h3 :
                    8'b1;
  assign mem_mask = r_mask << EX_MEM_mem_addr[2:0];

  import ExceptStruct::*;
  wire rst=~rstn;

  wire [1:0] csr_ret = MEM_WB_trap == 2'b01 ? 2'b01 :
                       MEM_WB_trap == 2'b10 ? 2'b10 :
                       2'b00;
  CSRModule csrmodule(
      .clk(clk),
      .rst(rst),
      .csr_we_wb(MEM_WB_csr_we),
      .csr_addr_wb(MEM_WB_inst[31:20]),
      .csr_val_wb(MEM_WB_alu_res),
      .csr_addr_id(IF_ID_inst[31:20]),
      .csr_val_id(csr_val),
      .pc_wb(MEM_WB_PC),
      .valid_wb(MEM_WB_valid),
      .time_int(time_int),
      .csr_ret(csr_ret),
      .except_commit(except_memwb),
      .priv(priv),
      .switch_mode(switch_mode),
      .pc_csr(pc_csr),
      .cosim_interrupt(cosim_interrupt),
      .cosim_cause(cosim_cause),
      .cosim_csr_info(cosim_csr_info)
  );

  wire except_happen_id;

  IDExceptExamine exceptexam(
    .clk(clk),
    .rst(rst),
    .stall(stall_IDEXE),
    .flush(flush_IDEXE),

    .pc_id(IF_ID_PC),
    .priv(priv),
    .inst_id(IF_ID_inst),
    .valid_id(IF_ID_valid),
    
    .except_id(except_ifid),
    .except_exe(except_idex),
    .except_happen_id(except_happen_idex)
);
  
  assign cosim_pc = MEM_WB_PC;
  assign cosim_inst = MEM_WB_inst;
  assign cosim_rs1_id = {3'b0, MEM_WB_rs1_id};
  assign cosim_rs1_data = MEM_WB_rs1_data;
  assign cosim_rs2_id = {3'b0, rs2_id};
  assign cosim_rs2_data = MEM_WB_rs2_data;
  assign cosim_alu = MEM_WB_alu_res;
  assign cosim_mem_addr = MEM_WB_mem_addr;
  assign cosim_mem_we = {3'b0, MEM_WB_rw_wmode};
  assign cosim_mem_wdata = MEM_WB_mem_wdata;
  assign cosim_mem_rdata = mem_rdata;
  assign cosim_rd_we = {3'b0, MEM_WB_decode[21]};
  assign cosim_rd_id = {3'b0, MEM_WB_rd};
  assign cosim_rd_data = rd_data;
  assign cosim_br_taken = {3'b0, br_taken};
  assign cosim_npc = npc;
  assign cosim_valid = MEM_WB_valid & ~cosim_interrupt;
endmodule