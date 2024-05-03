`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Li Zhenghao
// 
// Create Date: 2023/08/04 11:58:12
// Design Name: button_debouncing
// Module Name: button_debouncing(untested)
// Project Name: 
// Target Devices: 100MHz
// Tool Versions: 
// Description: 
// 本module包括三种按键响应方式分别对应的消抖，释放时、按下时、按下与释放之间
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module button_debouncing(
input clk,
input rst_n,
input key_in,
output flag_key
    );
    
reg key_scan;
reg [31:0] count_20ms;
//button decouncing(20ms扫描一次记录输入，相当于50Hz)
always @(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		count_20ms <= 32'd0;
		key_scan <= 1'b0;
	end
	else
	begin
		if(count_20ms == 32'd1_999_999)			//100M/50-1=1_999_999
		begin
			count_20ms <= 32'd0;
			key_scan <= key_in;
		end
		else
			count_20ms <= count_20ms + 32'd1;	
	end
end

reg key_scan_r;
//按键信号所存一个时钟节拍
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        key_scan_r <= 1'b0;
    else
	   key_scan_r <= key_scan;
end
	
assign flag_key = key_scan_r & (~key_scan);//按键释放时，输出1并保持一个时钟周期
//assign flag_key = (~key_scan_r) & key_scan;//按键按下时，输出1并保持一个时钟周期
//assign flag_key = key_scan;//按键按下后直至按键释放前，保持输出为1
    
endmodule
