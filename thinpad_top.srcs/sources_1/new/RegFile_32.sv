`timescale 1ns / 1ps `default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/24 14:44:10
// Design Name: 
// Module Name: RegFile_32
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


module RegFile_32 (
    input wire clk,
    input wire reset,

    input wire [4:0] waddr,
    input wire [31:0] wdata,
    input wire we,
    input wire [4:0] raddr_a,
    output reg [31:0] rdata_a,
    input wire [4:0] raddr_b,
    output reg [31:0] rdata_b
);
  reg [31:0] regs[0:31];

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      rdata_a <= 0;
      rdata_b <= 0;

      for (int i = 0; i < 32; i = i + 1) begin
        regs[i] <= 0;
      end

    end else begin
      if (we && waddr) regs[waddr] <= wdata;
      rdata_a <= regs[raddr_a];
      rdata_b <= regs[raddr_b];
    end
  end
endmodule
