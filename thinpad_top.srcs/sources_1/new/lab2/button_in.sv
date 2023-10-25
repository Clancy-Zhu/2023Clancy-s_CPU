`timescale 1ns / 1ps `default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/19 15:48:57
// Design Name: 
// Module Name: button_in
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


module button_in (
    input  wire clk,
    input  wire reset,
    input  wire btn,
    output wire trigger
);

  logic last_btn, last_last_btn;
  logic trig;
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      last_btn <= 0;
      trig <= 0;
    end else begin
      if (btn && !last_btn) trig <= 1'b1;
      else trig <= 1'b0;
      last_btn <= btn;
    end
  end

  assign trigger = trig;
endmodule
