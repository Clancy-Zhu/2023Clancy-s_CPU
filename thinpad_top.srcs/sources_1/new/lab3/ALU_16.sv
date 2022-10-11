`timescale 1ns / 1ps `default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/24 14:32:13
// Design Name: 
// Module Name: ALU_16
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


module ALU_16 (
    input  wire [15:0] A,
    input  wire [15:0] B,
    input  wire [ 3:0] op,
    output wire [15:0] Y
);

  typedef enum logic [3:0] {
    NONE,
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
  } state_t;
  logic [15:0] out;

  always_comb begin
    case (op)
      NONE: begin
        out = 16'b0;
      end
      ADD: begin
        out = A + B;
      end
      SUB: begin
        out = A - B;
      end
      AND: begin
        out = A & B;
      end
      OR: begin
        out = A | B;
      end
      XOR: begin
        out = A ^ B;
      end
      NOT: begin
        out = ~A;
      end
      SLL: begin
        out = A << (B % 16);
      end
      SRL: begin
        out = A >> (B % 16);
      end
      SRA: begin
        out = $signed(A) >>> (B % 16);
      end
      ROL: begin
        out = (A << (B % 16)) | (A >> (16 - (B % 16)));
      end
      default: begin
        out = 16'b0;
      end
    endcase
  end

  assign Y = out;
endmodule
