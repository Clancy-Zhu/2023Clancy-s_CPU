`timescale 1ns / 1ps `default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/24 14:44:10
// Design Name: 
// Module Name: RegFile
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


module RegFile (
    input wire clk,
    input wire reset,

    input wire [4:0] waddr,
    input wire [15:0] wdata,
    input wire we,
    input wire [4:0] raddr_a,
    output reg [15:0] rdata_a,
    input wire [4:0] raddr_b,
    output reg [15:0] rdata_b
);
  reg [15:0] regs[0:31];

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      regs[0]  <= 16'h0000;
      regs[1]  <= 16'h0000;
      regs[2]  <= 16'h0000;
      regs[3]  <= 16'h0000;
      regs[4]  <= 16'h0000;
      regs[5]  <= 16'h0000;
      regs[6]  <= 16'h0000;
      regs[7]  <= 16'h0000;
      regs[8]  <= 16'h0000;
      regs[9]  <= 16'h0000;
      regs[10] <= 16'h0000;
      regs[11] <= 16'h0000;
      regs[12] <= 16'h0000;
      regs[13] <= 16'h0000;
      regs[14] <= 16'h0000;
      regs[15] <= 16'h0000;
      regs[16] <= 16'h0000;
      regs[17] <= 16'h0000;
      regs[18] <= 16'h0000;
      regs[19] <= 16'h0000;
      regs[20] <= 16'h0000;
      regs[21] <= 16'h0000;
      regs[22] <= 16'h0000;
      regs[23] <= 16'h0000;
      regs[24] <= 16'h0000;
      regs[25] <= 16'h0000;
      regs[26] <= 16'h0000;
      regs[27] <= 16'h0000;
      regs[28] <= 16'h0000;
      regs[29] <= 16'h0000;
      regs[30] <= 16'h0000;
      regs[31] <= 16'h0000;

      rdata_a  <= 16'h0000;
      rdata_b  <= 16'h0000;
    end else begin
      if (we && (waddr != 0)) regs[waddr] <= wdata;
      rdata_a <= regs[raddr_a];
      rdata_b <= regs[raddr_b];
    end
  end
endmodule
