`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/05 21:13:00
// Design Name: 
// Module Name: counter_1s_100M(tested)
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
// counter_1s_100M uut3(
//     .clk(clk),
//     .rst_n(rst_n),
//     .start(),
//     .hold_1s()
// );
//////////////////////////////////////////////////////////////////////////////////


module counter_1s_100M(
input clk,
input rst_n,
input start,
output reg hold_1s
    );
reg [26:0] counter_1s;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        counter_1s <= 0;
        hold_1s <= 0;
    end
    else begin
        if(start | hold_1s) begin
            if(counter_1s == 27'd99_999_999) begin//100Mhz,1s
                counter_1s <= 0;
                hold_1s <= 0;
            end
            else begin
                counter_1s <= counter_1s + 1;
                hold_1s <= 1;
            end
        end
        else begin
            counter_1s <= counter_1s;
            hold_1s <= hold_1s;
        end
    end
end

endmodule
