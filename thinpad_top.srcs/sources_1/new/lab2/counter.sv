`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/04/19 15:17:04
// Design Name: 
// Module Name: counter
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


module counter (
  // 时钟与复位信号，每个时序模块都必须包含
  input wire clk,
  input wire reset,

  // 计数触发信号
  input wire trigger,

  // 当前计数值
  output wire [3:0] count
);

// Actual logic goes here ...
reg [3:0] count_reg;

// 注意此时的敏感信号列表
always_ff @ (posedge clk or posedge reset) begin
    if(reset)
        count_reg <= 4'd0;
    else if (trigger)  // 增加此处
        if(count_reg != 4'hf)
            count_reg <= count_reg + 4'd1;  // 暂时忽略计数溢出
end

assign count = count_reg;

endmodule