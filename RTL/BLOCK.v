/*
 *************************************************************************************************************************************************************
 * File Name     :  BLOCK.V
 ************************************************************************************************************************************************************
 * Module Name   :  BLOCK
 ************************************************************************************************************************************************************
 * Author        :  Khaled Ahmed Hamed Abdelaziz
 ************************************************************************************************************************************************************
 * Date          :  7 / 23 / 2024
 ************************************************************************************************************************************************************
 * Brief         :  BLOCK Module represents the building block used in designing the DS48A1 slice
 *************************************************************************************************************************************************************
 */
module BLOCK (D,SEL,CLK,RST,CE,BLOCK_OUT);
parameter RSTTYPE = "SYNC";
parameter WIDTH = 18;//No. of bus bits
input SEL,CLK,RST,CE;
input [WIDTH-1:0] D;
reg [WIDTH-1:0] Q;//Intetnal signal not an output
output  [WIDTH-1:0] BLOCK_OUT;
generate
	if (RSTTYPE == "SYNC") begin
		always @(posedge CLK) begin
			if (RST) begin
				Q<=0;
			end
			else if (CE) begin
				Q<=D;
			end
		end
	end	
	else if (RSTTYPE == "ASYNC") begin
		always @(posedge CLK or posedge RST) begin
			if (RST) begin
				Q<=0;
			end
			else if (CE) begin
				Q<=D;
			end
		end
	end
endgenerate
assign BLOCK_OUT = (SEL)? Q : D ;
endmodule
