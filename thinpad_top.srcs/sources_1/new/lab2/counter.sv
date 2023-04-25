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
  // ʱ���븴λ�źţ�ÿ��ʱ��ģ�鶼�������
  input wire clk,
  input wire reset,

  // ���������ź�
  input wire trigger,

  // ��ǰ����ֵ
  output wire [3:0] count
);

// Actual logic goes here ...
reg [3:0] count_reg;

// ע���ʱ�������ź��б�
always_ff @ (posedge clk or posedge reset) begin
    if(reset)
        count_reg <= 4'd0;
    else if (trigger)  // ���Ӵ˴�
        if(count_reg != 4'hf)
            count_reg <= count_reg + 4'd1;  // ��ʱ���Լ������
end

assign count = count_reg;

endmodule