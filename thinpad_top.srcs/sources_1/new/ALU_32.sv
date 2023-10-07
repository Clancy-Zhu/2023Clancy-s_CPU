`timescale 1ns / 1ps `default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/24 14:32:13
// Design Name: 
// Module Name: ALU_32
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


module ALU_32 (
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [ 3:0] op,
    output wire [31:0] Y
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
  } state_t;
  logic [31:0] out;

  always_comb begin
    case (op)
      NULL: begin
        out = 32'b0;
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
        out = A << (B[4:0]);
      end
      SRL: begin
        out = A >> (B[4:0]);
      end
      SRA: begin
        out = $signed(A) >>> (B[4:0]);
      end
      ROL: begin
        out = {A << (B[4:0]), A >> (32 - B[4:0])};
      end
      default: begin
        out = 32'b0;
      end
    endcase
  end

  assign Y = out;
endmodule
