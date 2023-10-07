`timescale 1ns / 1ps `default_nettype none

module cpu #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input wire clk_i,
    input wire rst_i,
    input wire [31:0] dip_sw,
    // wishbone master
    output reg wb_cyc_o,
    output reg wb_stb_o,
    input wire wb_ack_i,
    output reg [ADDR_WIDTH-1:0] wb_adr_o,
    output reg [DATA_WIDTH-1:0] wb_dat_o,
    input wire [DATA_WIDTH-1:0] wb_dat_i,
    output reg [DATA_WIDTH/8-1:0] wb_sel_o,
    output reg wb_we_o
);
  /* =========== Wishbone Master Arbiter begin ============ */
  // cpu_if_master
  logic [31:0] cpu_if_master_addr_o;
  logic [31:0] cpu_if_master_data_o;
  logic [31:0] cpu_if_master_data_i;
  logic [3:0] cpu_if_master_sel_o;
  logic cpu_if_master_cyc_o;
  logic cpu_if_master_stb_o;
  logic cpu_if_master_we_o;
  logic cpu_if_master_ack_i;

  // cpu_mem_master
  logic [31:0] cpu_mem_master_addr_o;
  logic [31:0] cpu_mem_master_data_o;
  logic [31:0] cpu_mem_master_data_i;
  logic [3:0] cpu_mem_master_sel_o;
  logic cpu_mem_master_cyc_o;
  logic cpu_mem_master_stb_o;
  logic cpu_mem_master_we_o;
  logic cpu_mem_master_ack_i;

  wb_arbiter_2 #(
      .DATA_WIDTH(ADDR_WIDTH),
      .ADDR_WIDTH(DATA_WIDTH),
      .ARB_TYPE_ROUND_ROBIN(0),
      .ARB_LSB_HIGH_PRIORITY(1)
  ) u_wb_arbiter_2 (
      .clk(clk_i),
      .rst(rst_i),
      .wbm0_adr_i(cpu_if_master_addr_o),
      .wbm0_dat_i(cpu_if_master_data_o),
      .wbm0_dat_o(cpu_if_master_data_i),
      .wbm0_we_i(cpu_if_master_we_o),
      .wbm0_sel_i(cpu_if_master_sel_o),
      .wbm0_stb_i(cpu_if_master_stb_o),
      .wbm0_ack_o(cpu_if_master_ack_i),
      .wbm0_err_o(),
      .wbm0_rty_o(),
      .wbm0_cyc_i(cpu_if_master_cyc_o),
      .wbm1_adr_i(cpu_mem_master_addr_o),
      .wbm1_dat_i(cpu_mem_master_data_o),
      .wbm1_dat_o(cpu_mem_master_data_i),
      .wbm1_we_i(cpu_mem_master_we_o),
      .wbm1_sel_i(cpu_mem_master_sel_o),
      .wbm1_stb_i(cpu_mem_master_stb_o),
      .wbm1_ack_o(cpu_mem_master_ack_i),
      .wbm1_err_o(),
      .wbm1_rty_o(),
      .wbm1_cyc_i(cpu_mem_master_cyc_o),
      .wbs_adr_o(wb_adr_o),
      .wbs_dat_i(wb_dat_i),
      .wbs_dat_o(wb_dat_o),
      .wbs_we_o(wb_we_o),
      .wbs_sel_o(wb_sel_o),
      .wbs_stb_o(wb_stb_o),
      .wbs_ack_i(wb_ack_i),
      .wbs_err_i(0),
      .wbs_rty_i(0),
      .wbs_cyc_o(wb_cyc_o)
  );
  /* =========== Wishbone Master Arbiter end ============ */

  /* =========== Hazard Controller begin ============ */
  logic if_flush_o;
  logic id_flush_o;
  logic ex_flush_o;
  logic mem_flush_o;
  logic wb_flush_o;
  logic if_stall_o;
  logic id_stall_o;
  logic ex_stall_o;
  logic mem_stall_o;
  logic wb_stall_o;
  wire  _if_flush_i;
  wire  if_id_flush_i;
  wire  id_ex_flush_i;
  wire  ex_mem_flush_i;
  wire  mem_wb_flush_i;
  wire  _if_stall_i;
  wire  if_id_stall_i;
  wire  id_ex_stall_i;
  wire  ex_mem_stall_i;
  wire  mem_wb_stall_i;
  assign if_flush_o  = 0;
  assign id_flush_o  = 0;
  assign mem_flush_o = 0;
  assign wb_flush_o  = 0;
  assign if_stall_o  = 0;
  assign ex_stall_o  = 0;
  assign mem_stall_o = 0;
  assign wb_stall_o  = 0;
  hazard_controller u_hazard_controller (
      .if_flush_i    (if_flush_o),
      .id_flush_i    (id_flush_o),
      .ex_flush_i    (ex_flush_o),
      .mem_flush_i   (mem_flush_o),
      .wb_flush_i    (wb_flush_o),
      .if_stall_i    (if_stall_o),
      .id_stall_i    (id_stall_o),
      .ex_stall_i    (ex_stall_o),
      .mem_stall_i   (mem_stall_o),
      .wb_stall_i    (wb_stall_o),
      ._if_flush_o   (_if_flush_i),
      .if_id_flush_o (if_id_flush_i),
      .id_ex_flush_o (id_ex_flush_i),
      .ex_mem_flush_o(ex_mem_flush_i),
      .mem_wb_flush_o(mem_wb_flush_i),
      ._if_stall_o   (_if_stall_i),
      .if_id_stall_o (if_id_stall_i),
      .id_ex_stall_o (id_ex_stall_i),
      .ex_mem_stall_o(ex_mem_stall_i),
      .mem_wb_stall_o(mem_wb_stall_i)
  );
  /* =========== Hazard Controller end ============ */
  logic [ 4:0] rf_raddr_a;
  logic [31:0] rf_rdata_a;
  logic [ 4:0] rf_raddr_b;
  logic [31:0] rf_rdata_b;
  logic [ 4:0] rf_waddr;
  logic [31:0] rf_wdata;
  logic        rf_we;

  RegFile_32 u_reg_file (
      .clk(clk_i),
      .reset(rst_i),
      .waddr(rf_waddr),
      .wdata(rf_wdata),
      .we(rf_we),
      .raddr_a(rf_raddr_a),
      .rdata_a(rf_rdata_a),
      .raddr_b(rf_raddr_b),
      .rdata_b(rf_rdata_b)
  );
  typedef enum logic [3:0] {
    NULL,
    ADD,
    SUB,
    AND,
    OR,
    XOR,
    NOT,
    SLL,
    SRL,
    SRA,
    ROL
  } opcode_t;
  logic    [31:0] alu_a;
  logic    [31:0] alu_b;
  logic    [31:0] alu_y;
  opcode_t        alu_op;
  ALU_32 u_alu (
      .A (alu_a),
      .B (alu_b),
      .Y (alu_y),
      .op(alu_op)
  );
  typedef enum logic [1:0] {
    STATE_READ_ACTION,
    STATE_READ_DONE,
    STATE_READ_IDLE
  } mem_read_state_t;

  /* =========== Pipeline begin ============ */

  // Pipeline control signals
  logic pipeline_stall;
  assign pipeline_stall = cpu_if_master_stb_o | cpu_mem_master_stb_o;

  // IF stage
  logic [31:0] if_pc, if_instr;

  // IF/ID pipeline register
  logic [31:0] if_id_pc, if_id_instr;

  // ID stage
  logic [31:0] id_src1_rf_data, id_src2_rf_data;
  logic [31:0] id_imm;
  opcode_t id_opcode;
  logic id_branch, id_use_reg2, id_memread, id_memwrite, id_rfwrite;
  logic [4:0] id_rf_waddr;
  logic [3:0] id_op_len;

  // ID/EX pipeline register
  logic [31:0] id_ex_pc, id_ex_instr, id_ex_src1_rf_data, id_ex_src2_rf_data, id_ex_imm;
  opcode_t id_ex_opcode;
  logic id_ex_branch, id_ex_usereg2, id_ex_memread, id_ex_memwrite, id_ex_rfwrite;
  logic [4:0] id_ex_rf_waddr;
  logic [3:0] id_ex_op_len;

  // EX stage
  logic ex_beq;
  logic [31:0] ex_alu_res;

  // EX/MEM pipeline register
  logic [31:0] ex_mem_pc, ex_mem_instr, ex_mem_alu_res, ex_mem_mem_wdata;
  logic ex_mem_memread, ex_mem_memwrite, ex_mem_rfwrite;
  logic [4:0] ex_mem_rf_waddr;
  logic [3:0] ex_mem_op_len;

  // MEM stage
  logic [31:0] mem_mem_rdata, mem_rf_wdata;

  // MEM/WB pipeline register
  logic [31:0] mem_wb_pc, mem_wb_instr;
  logic mem_wb_rfwrite;
  logic [31:0] mem_wb_rf_wdata;
  logic [4:0] mem_wb_rf_waddr;

  // PC controller
  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      if_pc <= 32'h80000000;  // the start address of the program
      if_id_instr <= 32'h00000013;  // nop
      id_ex_instr <= 32'h00000013;  // nop
      ex_mem_instr <= 32'h00000013;  // nop
      mem_wb_instr <= 32'h00000013;  // nop
      id_ex_memread <= 0;
      id_ex_memwrite <= 0;
      id_ex_rfwrite <= 0;
      id_ex_branch <= 0;
      ex_mem_memread <= 0;
      ex_mem_memwrite <= 0;
      ex_mem_rfwrite <= 0;
      mem_wb_rfwrite <= 0;
      id_ex_op_len <= 4'hf;
      ex_mem_op_len <= 4'hf;

    end else begin
      if (!pipeline_stall) begin
        // PC update
        if (_if_stall_i) begin
          if_pc <= if_pc;
        end else if (_if_flush_i) begin
          if_pc <= id_ex_pc + id_ex_imm;
        end else begin
          if_pc <= if_pc + 4;
        end
        // IF/ID pipeline register update
        if (if_id_stall_i) begin
          if_id_instr <= if_id_instr;
        end else if (if_id_flush_i) begin
          if_id_instr <= 32'h00000013;  // nop
        end else begin
          if_id_instr <= if_instr;
          if_id_pc <= if_pc;
        end
        // ID/EX pipeline register update
        if (id_ex_stall_i) begin
          id_ex_instr <= id_ex_instr;
        end else if (id_ex_flush_i) begin
          id_ex_instr <= 32'h00000013;  // nop
          id_ex_branch <= 0;
          id_ex_memread <= 0;
          id_ex_memwrite <= 0;
          id_ex_rfwrite <= 0;
        end else begin
          id_ex_instr <= if_id_instr;
          id_ex_pc <= if_id_pc;
          id_ex_src1_rf_data <= id_src1_rf_data;
          id_ex_src2_rf_data <= id_src2_rf_data;
          id_ex_imm <= id_imm;
          id_ex_opcode <= id_opcode;
          id_ex_branch <= id_branch;
          id_ex_usereg2 <= id_use_reg2;
          id_ex_memread <= id_memread;
          id_ex_memwrite <= id_memwrite;
          id_ex_rfwrite <= id_rfwrite;
          id_ex_rf_waddr <= id_rf_waddr;
          id_ex_op_len <= id_op_len;
        end
        // EX/MEM pipeline register update
        if (ex_mem_stall_i) begin
          ex_mem_instr <= ex_mem_instr;
        end else if (ex_mem_flush_i) begin
          ex_mem_instr <= 32'h00000013;  // nop
          ex_mem_memread <= 0;
          ex_mem_memwrite <= 0;
          ex_mem_rfwrite <= 0;
        end else begin
          ex_mem_instr <= id_ex_instr;
          ex_mem_pc <= id_ex_pc;
          ex_mem_alu_res <= ex_alu_res;
          ex_mem_mem_wdata <= id_ex_src2_rf_data;
          ex_mem_memread <= id_ex_memread;
          ex_mem_memwrite <= id_ex_memwrite;
          ex_mem_rfwrite <= id_ex_rfwrite;
          ex_mem_rf_waddr <= id_ex_rf_waddr;
          ex_mem_op_len <= id_ex_op_len;
        end
        // MEM/WB pipeline register update
        if (mem_wb_stall_i) begin
          mem_wb_instr <= mem_wb_instr;
        end else if (mem_wb_flush_i) begin
          mem_wb_instr   <= 32'h00000013;  // nop
          mem_wb_rfwrite <= 0;
        end else begin
          mem_wb_instr <= ex_mem_instr;
          mem_wb_pc <= ex_mem_pc;
          mem_wb_rfwrite <= ex_mem_rfwrite;
          mem_wb_rf_waddr <= ex_mem_rf_waddr;
          mem_wb_rf_wdata <= mem_rf_wdata;
        end
      end
    end
  end
  assign ex_flush_o = ex_beq;

  /* =============== Pipeline end =============== */

  /* =============== IF stage =============== */
  mem_read_state_t if_read_state;
  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      if_read_state <= STATE_READ_ACTION;
    end else begin
      case (if_read_state)
        STATE_READ_ACTION: begin
          if (cpu_if_master_ack_i) begin
            if_read_state <= STATE_READ_DONE;
            if_instr <= cpu_if_master_data_i;
          end
        end
        STATE_READ_DONE: begin
          if (!pipeline_stall) if_read_state <= STATE_READ_ACTION;
        end
      endcase
    end
  end
  assign cpu_if_master_addr_o = if_pc;
  assign cpu_if_master_we_o   = 0;  // instruction memory is read-only
  assign cpu_if_master_sel_o  = 4'hf;  // instruction memory is read-only
  assign cpu_if_master_stb_o  = if_read_state == STATE_READ_ACTION;
  assign cpu_if_master_cyc_o  = if_read_state == STATE_READ_ACTION;

  /* =============== ID stage =============== */
  typedef enum logic [7:0] {
    INST_ERR,
    INST_LUI,
    INST_BEQ,
    INST_LB,
    INST_SB,
    INST_SW,
    INST_ADDI,
    INST_ANDI,
    INST_ADD,
    INST_XOR
  } inst_type;  // instruction type, add more types when needed
  inst_type id_inst_type;
  logic [11:0] I_imm;
  logic [11:0] S_imm;
  logic [12:0] B_imm;
  logic [31:0] U_imm;
  logic [20:0] J_imm;
  logic [4:0] id_rs1_addr;
  logic [4:0] id_rs2_addr;
  logic [4:0] id_rd_addr;
  logic [2:0] funct3;
  logic [6:0] funct7;
  logic [6:0] opcode;

  assign rf_raddr_a = id_rs1_addr;
  assign rf_raddr_b = id_rs2_addr;
  assign id_src1_rf_data = rf_rdata_a;
  assign id_src2_rf_data = rf_rdata_b;
  assign I_imm = if_id_instr[31:20];
  assign S_imm = {if_id_instr[31:25], if_id_instr[11:7]};
  assign B_imm = {if_id_instr[31], if_id_instr[7], if_id_instr[30:25], if_id_instr[11:8], 1'b0};
  assign U_imm = {if_id_instr[31:12], 12'h0};
  assign J_imm = {if_id_instr[31], if_id_instr[19:12], if_id_instr[20], if_id_instr[30:21], 1'b0};

  always_comb begin
    id_rs1_addr = if_id_instr[19:15];
    id_rs2_addr = if_id_instr[24:20];
    id_rd_addr = if_id_instr[11:7];
    funct3 = if_id_instr[14:12];
    funct7 = if_id_instr[31:25];
    opcode = if_id_instr[6:0];

    case (opcode)
      7'b0110111: id_inst_type = INST_LUI;
      7'b1100011: id_inst_type = INST_BEQ;
      7'b0000011: id_inst_type = INST_LB;
      7'b0100011: begin
        case (funct3)
          3'b000:  id_inst_type = INST_SB;
          3'b010:  id_inst_type = INST_SW;
          default: id_inst_type = INST_ERR;
        endcase
      end
      7'b0010011: begin
        case (funct3)
          3'b000:  id_inst_type = INST_ADDI;
          3'b111:  id_inst_type = INST_ANDI;
          default: id_inst_type = INST_ERR;
        endcase
      end
      7'b0110011: begin
        case (funct3)
          3'b000: begin
            if (funct7 == 7'b0000000) begin
              id_inst_type = INST_ADD;
            end else begin
              id_inst_type = INST_ERR;
            end
          end
          3'b100: id_inst_type = INST_XOR;
        endcase
      end
      default: id_inst_type = INST_ERR;
    endcase

    case (id_inst_type)
      INST_LUI: begin
        id_op_len = 4'b1111;
        id_rs1_addr = 5'h0;
        id_memwrite = 0;
        id_rfwrite = 1;
        id_memread = 0;
        id_use_reg2 = 0;
        id_opcode = ADD;
        id_imm = U_imm;
        id_rf_waddr = id_rd_addr;
        id_branch = 0;
      end
      INST_BEQ: begin
        id_op_len   = 4'b1111;
        id_memwrite = 0;
        id_rfwrite  = 0;
        id_memread  = 0;
        id_use_reg2 = 1;
        id_opcode   = XOR;
        id_imm      = {{19{B_imm[12]}}, B_imm};
        id_rf_waddr = 5'h0;
        id_branch   = 1;
      end
      INST_LB: begin
        id_op_len   = 4'b0001;
        id_memwrite = 0;
        id_rfwrite  = 1;
        id_memread  = 1;
        id_use_reg2 = 0;
        id_opcode   = ADD;
        id_imm      = {{20{I_imm[11]}}, I_imm};
        id_rf_waddr = id_rd_addr;
        id_branch   = 0;
      end
      INST_SB: begin
        id_op_len   = 4'b0001;
        id_memwrite = 1;
        id_rfwrite  = 0;
        id_memread  = 0;
        id_use_reg2 = 0;
        id_opcode   = ADD;
        id_imm      = {{20{S_imm[11]}}, S_imm};
        id_rf_waddr = 5'h0;
        id_branch   = 0;
      end
      INST_SW: begin
        id_op_len   = 4'b1111;
        id_memwrite = 1;
        id_rfwrite  = 0;
        id_memread  = 0;
        id_use_reg2 = 0;
        id_opcode   = ADD;
        id_imm      = {{20{S_imm[11]}}, S_imm};
        id_rf_waddr = 5'h0;
        id_branch   = 0;
      end
      INST_ADDI: begin
        id_op_len   = 4'b1111;
        id_memwrite = 0;
        id_rfwrite  = 1;
        id_memread  = 0;
        id_use_reg2 = 0;
        id_opcode   = ADD;
        id_imm      = {{20{I_imm[11]}}, I_imm};
        id_rf_waddr = id_rd_addr;
        id_branch   = 0;
      end
      INST_ANDI: begin
        id_op_len   = 4'b1111;
        id_memwrite = 0;
        id_rfwrite  = 1;
        id_memread  = 0;
        id_use_reg2 = 0;
        id_opcode   = AND;
        id_imm      = {{20{I_imm[11]}}, I_imm};
        id_rf_waddr = id_rd_addr;
        id_branch   = 0;
      end
      INST_ADD: begin
        id_op_len   = 4'b1111;
        id_memwrite = 0;
        id_rfwrite  = 1;
        id_memread  = 0;
        id_use_reg2 = 1;
        id_opcode   = ADD;
        id_imm      = 0;
        id_rf_waddr = id_rd_addr;
        id_branch   = 0;
      end
      INST_XOR: begin
        id_op_len   = 4'b1111;
        id_memwrite = 0;
        id_rfwrite  = 1;
        id_memread  = 0;
        id_use_reg2 = 1;
        id_opcode   = XOR;
        id_imm      = 0;
        id_rf_waddr = id_rd_addr;
        id_branch   = 0;
      end
      default: begin
        id_op_len   = 4'b1111;
        id_memwrite = 0;
        id_rfwrite  = 0;
        id_memread  = 0;
        id_use_reg2 = 0;
        id_opcode   = NULL;
        id_imm      = 0;
        id_rf_waddr = 5'h0;
        id_branch   = 0;
      end
    endcase
  end

  always_comb begin
    if(id_ex_rfwrite && (id_rs1_addr == id_ex_rf_waddr || id_rs2_addr == id_ex_rf_waddr)
    || ex_mem_rfwrite && (id_rs1_addr == ex_mem_rf_waddr || id_rs2_addr == ex_mem_rf_waddr)
    || mem_wb_rfwrite && (id_rs1_addr == mem_wb_rf_waddr || id_rs2_addr == mem_wb_rf_waddr))
      id_stall_o = 1;
    else id_stall_o = 0;
  end

  /* =========== EX stage =========== */
  assign alu_op = id_ex_opcode;
  assign alu_a = id_ex_src1_rf_data;
  assign alu_b = id_ex_usereg2 ? id_ex_src2_rf_data : id_ex_imm;
  assign ex_alu_res = alu_y;
  assign ex_beq = id_ex_branch && (alu_y == 0);  // branch if equal

  /* =========== MEM stage =========== */
  typedef enum logic [2:0] {
    IDLE,
    READ,
    WRITE,
    DONE
  } mem_read_write_state_t;
  mem_read_write_state_t mem_read_write_state;

  always_ff @(posedge clk_i) begin
    if (rst_i) mem_read_write_state <= IDLE;
    else
      case (mem_read_write_state)
        IDLE: begin
          if (ex_mem_memread) mem_read_write_state <= READ;
          else if (ex_mem_memwrite) mem_read_write_state <= WRITE;
          else mem_read_write_state <= DONE;
        end
        READ: begin
          if (cpu_mem_master_ack_i) begin
            mem_read_write_state <= DONE;
            mem_mem_rdata <= cpu_mem_master_data_i;
          end
        end
        WRITE: begin
          if (cpu_mem_master_ack_i) begin
            mem_read_write_state <= DONE;
          end
        end
        DONE: begin
          if (!pipeline_stall) mem_read_write_state <= IDLE;
        end
      endcase
  end

  logic [31:0] mem_rf_wdata_origin;
  always_comb begin
    mem_rf_wdata_origin = ex_mem_memread ? mem_mem_rdata : ex_mem_alu_res;
    mem_rf_wdata = mem_rf_wdata_origin;
    cpu_mem_master_addr_o = ex_mem_alu_res;
    cpu_mem_master_we_o = ex_mem_memwrite && mem_read_write_state != DONE;
    cpu_mem_master_sel_o = 4'b1111;  // default store 4 bytes
    cpu_mem_master_data_o = ex_mem_mem_wdata;  // default store 4 bytes
    cpu_mem_master_cyc_o = mem_read_write_state == READ || mem_read_write_state == WRITE;
    cpu_mem_master_stb_o = mem_read_write_state == READ || mem_read_write_state == WRITE;

    if (ex_mem_memread || ex_mem_memwrite) begin
      case (ex_mem_op_len)
        // read or write 1 byte
        4'b0001: begin
          case (cpu_mem_master_addr_o[1:0])
            2'b00: begin
              cpu_mem_master_sel_o = 4'b0001;
              mem_rf_wdata = {24'b0, mem_rf_wdata_origin[7:0]};
              cpu_mem_master_data_o = {24'b0, ex_mem_mem_wdata[7:0]};
            end
            2'b01: begin
              cpu_mem_master_sel_o = 4'b0010;
              mem_rf_wdata = {24'b0, mem_rf_wdata_origin[15:8]};
              cpu_mem_master_data_o = {16'b0, ex_mem_mem_wdata[7:0], 8'b0};
            end
            2'b10: begin
              cpu_mem_master_sel_o = 4'b0100;
              mem_rf_wdata = {24'b0, mem_rf_wdata_origin[23:16]};
              cpu_mem_master_data_o = {8'b0, ex_mem_mem_wdata[7:0], 16'b0};
            end
            2'b11: begin
              cpu_mem_master_sel_o = 4'b1000;
              mem_rf_wdata = {24'b0, mem_rf_wdata_origin[31:24]};
              cpu_mem_master_data_o = {ex_mem_mem_wdata[7:0], 24'b0};
            end
          endcase
        end
        // default: 32-bit read or write
        4'b1111: ;
      endcase
    end
  end

  /* =========== WB stage =========== */
  assign rf_we = mem_wb_rfwrite;
  assign rf_waddr = mem_wb_rf_waddr;
  assign rf_wdata = mem_wb_rf_wdata;

endmodule
