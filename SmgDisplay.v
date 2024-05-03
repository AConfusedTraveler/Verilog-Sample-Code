`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/08/04 12:18:51
// Design Name: 
// Module Name: smg_display(untested)
// Project Name: 
// Target Devices: 100MHz
// Tool Versions: 
// Description: 
// up to 20'd999999
// Dependencies: 
// 每1ms显示1位，则6ms显示一遍
// 当number超过999999时，warning为1并显示低位
// 由于走的是时序电路，因此显示有一定的滞后性，但是如果只是为了smg显示，则不会出问题
// 但是如果输入数据改变的太快，则可能会来不及显示
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 如果想要更高效的输出num[23:0]，则可以将第一个always块改为combinatianal logic circuit
// 这样则不会有显示延迟，但相应的会增大面积（循环判断是否减法）
// smg_display uut0(
//     .clk(clk),
//     .rst_n(rst_n),
//     .number_en(number_en),
//     .number(),
//     .an(an),
//     .sseg(sseg),
//     .warning(warning)
// );
//////////////////////////////////////////////////////////////////////////////////


module smg_display(
input clk,
input rst_n,
input number_en,//当number_en为1时，记录number
input [19:0] number,
output reg [5:0] an,
output reg [7:0] sseg,
output reg warning
    );
reg [19:0] number_r;
reg [23:0] num;
reg [3:0] num_an;
reg finish;
reg [19:0] count1;

//由于走的是时序电路，因此显示有一定的滞后性，但是如果只是为了smg显示，则不会出问题
//但是如果输入数据改变的太快，则可能会来不及显示
//输出十万位、万位、千位、百位、十位、个位每个位应该输出的数据num[23:0]
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
            number_r <= 0;
            num <= 0;
            warning <= 0;
            finish <= 0;  
    end
    else begin
        if(number_en == 1) begin
            number_r <= number;
            num <= 0;
            warning <= 0;
            finish <= 0;
        end
        if(~finish) begin
            if(number_r > 20'b1111_0100_0010_0011_1111) begin//20'd999999
                number_r <= number_r - 20'b1111_0100_0010_0100_0000;
                warning <= 1;
            end
            else begin
                if(number_r > 20'b0001_1000_0110_1001_1111) begin//20'd99999 < number_r <= 20'd999999
                    number_r <= number_r - 20'b1111_0100_0010_0100_0000;
                    num[23:20] <= num[23:20] + 4'b1;
                end
                else begin
                    if(number_r > 20'b0000_0010_0111_0000_1111) begin//20'd9999 < number_r <= 20'd99999
                        number_r <= number_r - 20'b0000_0010_0111_0001_0000;
                        num[19:16] <= num[19:16] + 4'b1;
                    end
                    else begin
                        if(number_r > 20'b0000_0000_0011_1110_0111) begin//20'd999 < number_r <= 20'd9999
                            number_r <= number_r - 20'b0000_0000_0011_1110_1000;
                            num[15:12] <= num[15:12] + 4'b1;
                        end
                        else begin
                            if(number_r > 20'b0000_0000_0000_0110_0011) begin//20'd99 < number_r <= 20'd999
                                number_r <= number_r - 20'b0000_0000_0000_0110_0100;
                                num[11:8] <= num[11:8] + 4'b1;
                            end
                            else begin
                                if(number_r > 20'b0000_0000_0000_0000_1001) begin//20'd9 < number_r <= 20'd99
                                    number_r <= number_r - 20'b0000_0000_0000_0000_1010;
                                    num[7:4] <= num[7:4] + 4'b1;
                                end
                                else begin
                                    num[3:0] <= number_r[3:0];//number_r <= 20'd9
                                    finish <= 1;
                                end
                            end
                        end
                    end
                end
            end
        end
        else begin
            number_r <= number_r;
            num <= num;
            warning <= warning;
            finish <= finish;
        end
    end
end

//每隔1ms改变一次输出的位数，6ms输出一遍
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        an <= 0;//全亮
        count1 <= 0;
        num_an <= 0;
    end
    else begin
        if(count1 == 20'd9_9999) begin//1ms
            an <= 6'b111110;
            num_an <= num[3:0];
            count1 <= count1 + 1;
        end
        else if(count1 == 20'd19_9999) begin
            an <= 6'b111101;
            num_an <= num[7:4];
            count1 <= count1 + 1;
        end
        else if(count1 == 20'd29_9999) begin
            an <= 6'b111011;
            num_an <= num[11:8];
            count1 <= count1 + 1;
        end
        else if(count1 == 20'd39_9999) begin
            an <= 6'b110111;
            num_an <= num[15:11];
            count1 <= count1 + 1;
        end
        else if(count1 == 20'd49_9999) begin
            an <= 6'b101111;
            num_an <= num[19:16];
            count1 <= count1 + 1;
        end
        else if(count1 == 20'd59_9999) begin
            an <= 6'b011111;
            num_an <= num[23:20];
            count1 <= 0;
        end
        else begin
            an <= an;
            num_an <= num_an;
            count1 <= count1 + 1;
        end
    end
end

//输出的数字对应的晶体管显示，低电平显示
always @(*) begin
    case(num_an)//千位的数字，用低四位来显示0~9，下面是这10个数字的段码
		4'b0000:
		    sseg <= 8'b1100_0000;
		4'b0001:
		    sseg <= 8'b1111_1001;
		4'b0010:
		    sseg <= 8'b1010_0100;				
		4'b0011:
	        sseg <= 8'b1011_0000;
		4'b0100:
		    sseg <= 8'b1001_1001;
		4'b0101:
			sseg <= 8'b1001_0010;			
		4'b0110:
		    sseg <= 8'b1000_0010;
		4'b0111:
	        sseg <= 8'b1111_1000;
		4'b1000:
	        sseg <= 8'b1000_0000;
		4'b1001:
			sseg <= 8'b1001_0000;
        default:
            sseg <= 8'b0000_0000;//当进入default时，全亮
	endcase
end

endmodule
