`timescale 1ns / 1ps `default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/22 15:44:09
// Design Name: 
// Module Name: controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module controller (
    input wire clk,
    input wire reset,

    // ���ӼĴ�����ģ����ź�
    output reg [4:0] rf_raddr_a,
    input wire [15:0] rf_rdata_a,
    output reg [4:0] rf_raddr_b,
    input wire [15:0] rf_rdata_b,
    output reg [4:0] rf_waddr,
    output reg [15:0] rf_wdata,
    output reg rf_we,

    // ���� ALU ģ����ź�
    output reg  [15:0] alu_a,
    output reg  [15:0] alu_b,
    output reg  [ 3:0] alu_op,
    input  wire [15:0] alu_y,

    // �����ź�
    input  wire        step,    // �û�����״̬����
    input  wire [31:0] dip_sw,  // 32 λ���뿪��״̬
    output reg  [15:0] leds
);

  logic [31:0] inst_reg;  // ָ��Ĵ���

  // ����߼�������ָ���еĳ��ò��֣���������Ч�� inst_reg ֵ
  logic is_rtype, is_itype, is_peek, is_poke;
  logic [15:0] imm;
  logic [4:0] rd, rs1, rs2;
  logic [3:0] opcode;

  always_comb begin
    is_rtype = (inst_reg[2:0] == 3'b001);
    is_itype = (inst_reg[2:0] == 3'b010);
    is_peek = is_itype && (inst_reg[6:3] == 4'b0010);
    is_poke = is_itype && (inst_reg[6:3] == 4'b0001);

    imm = inst_reg[31:16];
    rd = inst_reg[11:7];
    rs1 = inst_reg[19:15];
    rs2 = inst_reg[24:20];
    opcode = inst_reg[6:3];
  end

  // ʹ��ö�ٶ���״̬�б���������Ϊ logic [3:0]
  typedef enum logic [3:0] {
    ST_INIT,
    ST_DECODE,
    ST_CALC,
    ST_READ_REG,
    ST_WRITE_REG
  } state_t;

  // ״̬����ǰ״̬�Ĵ���
  state_t state;

  // ״̬���߼�
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      //��λ��������ź�
      rf_raddr_a <= 5'b0;
      rf_raddr_b <= 5'b0;
      rf_waddr <= 5'b0;
      rf_wdata <= 16'b0;
      rf_we <= 1'b0;
      alu_a <= 16'b0;
      alu_b <= 16'b0;
      alu_op <= 4'b0;
      leds <= 16'b0;
      state <= ST_INIT;
    end else begin
      case (state)

        ST_INIT: begin
          rf_we <= 1'b0;
          if (step) begin
            inst_reg <= dip_sw;
            state <= ST_DECODE;
          end
        end

        ST_DECODE: begin
          if (is_rtype) begin
            // �ѼĴ�����ַ�����Ĵ����ѣ���ȡ������
            rf_raddr_a <= rs1;
            rf_raddr_b <= rs2;
            state <= ST_CALC;

          end else if (is_peek) begin
            // �ӼĴ����Ѷ�ȡ����
            rf_raddr_a <= rd;
            rf_raddr_b <= 5'b0;
            state <= ST_READ_REG;

          end else if (is_poke) begin
            // ������д��Ĵ�����
            state <= ST_WRITE_REG;

          end else begin
            // δָ֪��ص���ʼ״̬
            state <= ST_INIT;
          end
        end

        ST_CALC: begin
          // �����ݽ��� ALU������ ALU ��ȡ���
          alu_a  <= rf_rdata_a;
          alu_b  <= rf_rdata_b;
          alu_op <= opcode;
          state  <= ST_WRITE_REG;
        end

        ST_WRITE_REG: begin
          // ���������Ĵ���
          rf_waddr <= rd;
          if (is_rtype) rf_wdata <= alu_y;
          else if (is_poke) rf_wdata <= imm;
          rf_we <= 1'b1;
          state <= ST_INIT;
        end

        ST_READ_REG: begin
          // �����ݴӼĴ����ж��������� leds
          leds  <= rf_rdata_a;
          state <= ST_INIT;
        end

        default: begin
          state <= ST_INIT;
        end
      endcase
    end
  end
endmodule
