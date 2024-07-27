/*
 *************************************************************************************************************************************************************
 * File Name     :  DSP48A1.v
 ************************************************************************************************************************************************************
 * Module Name   :  DSP48A1
 ************************************************************************************************************************************************************
 * Author        :  Khaled Ahmed Hamed Abdelaziz
 ************************************************************************************************************************************************************
 * Date          :  7 / 23 / 2024
 ************************************************************************************************************************************************************
 * Brief         :  The Spartan-6 family offers a high density of DSP48A1 slices, making it ideal for computationally intensive applications.
 					The DSP48A1 is an evolution of the DSP48A slice found in the Extended Spartan-3A FPGAs. 
 					This design supports a wide range of DSP algorithms with minimal use of general-purpose FPGA logic, resulting in low power consumption, 
 					high performance, and efficient device utilization.
					On initial inspection, the DSP48A1 slice features an 18-bit input pre-adder, followed by an 18 x 18 bit two's complement multiplier,
					and a 48-bit sign-extended adder/subtracter/accumulator. This structure is widely used in digital signal processing.
					Closer examination reveals several advanced features that enhance the functionality, versatility, and speed of this arithmetic block.
					The slice includes programmable pipelining of input operands, intermediate products, and accumulator outputs, which boosts throughput. 
					The 48-bit internal bus supports extensive aggregation of DSP slices. The C input port enables the creation of various 3-input mathematical functions,
					such as 3-input addition by cascading the pre-adder with the post-adder, and 2-input multiplication combined with a single addition. 
					The D input provides a second operand for the pre-adder, optimizing DSP48A1 slice usage in symmetric filters.
					By integrating these features, the DSP48A1 slice offers a powerful and flexible solution for implementing complex DSP functions with high efficiency.
 *************************************************************************************************************************************************************
 */
module DSP48A1 (A,B,D,C,CLK,CARRYIN,OPMODE,BCIN,RSTA,RSTB,RSTM,RSTP,RSTC,RSTD,RSTCARRYIN,RSTOPMODE,
	 			CEA,CEB,CEM,CEP,CEC,CED,CECARRYIN,CEOPMODE,PCIN,BCOUT,PCOUT,P,M,CARRYOUT,CARRYOUTF);
//Parameter (Attributes): 
parameter A0REG = 0 ;//0 : No Register
parameter A1REG = 1 ;//1 : Registerd
parameter B0REG = 0 ;
parameter B1REG = 1 ;
parameter CREG = 1; 
parameter DREG = 1 ; 
parameter MREG = 1 ; 
parameter PREG = 1 ; 
parameter CARRYINREG = 1 ; 
parameter CARRYOUTREG =1;
parameter OPMODEREG = 1;
parameter CARRYINSEL = "OPMODE5" ;// CARRYIN or OPMODE5 , Default: OPMODE5
parameter B_INPUT = "DIRECT" ; // DIRECT from B input or CASCADE from the previous DSP48A1 slice , Default: DIRECT, if neither MUX Out =0
parameter RSTTYPE = "SYNC" ; //ASYNC or SYNC , Default: SYNC
//Data Ports: 
input [17:0] A,B,D;
input [47:0] C;
output [35:0] M;
output [47:0] P;
input CARRYIN ;
output CARRYOUT, CARRYOUTF;
//Control Input Ports: 
input CLK;
input [7:0] OPMODE;
//Clock Enable Input Ports: 
input CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP;
//Reset Input Ports:
input RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP;
//Cascade Ports: 
output [17:0] BCOUT;
input [47:0] PCIN ;
output [47:0] PCOUT ;
input [17:0] BCIN ;
//Design
//First Level
wire [17:0] DREGOUT ;
BLOCK #(.WIDTH(18),.RSTTYPE(RSTTYPE)) DMUXREG (.D(D),.SEL(DREG),.CLK(CLK),.RST(RSTD),.CE(CED),.BLOCK_OUT(DREGOUT));

wire [17:0] B0MUXOUT ;
wire [17:0] B0REGOUT ;
assign B0MUXOUT = (B_INPUT == "DIRECT") ? B : (B_INPUT == "CASCADE")? BCIN : 0 ;
BLOCK #(.WIDTH(18),.RSTTYPE(RSTTYPE)) B0MUXREG (.D(B0MUXOUT),.SEL(B0REG),.CLK(CLK),.RST(RSTB),.CE(CEB),.BLOCK_OUT(B0REGOUT));

wire [17:0] A0REGOUT ;
BLOCK #(.WIDTH(18),.RSTTYPE(RSTTYPE)) A0MUXREG (.D(A),.SEL(A0REG),.CLK(CLK),.RST(RSTA),.CE(CEA),.BLOCK_OUT(A0REGOUT));

wire [47:0] CREGOUT ;
BLOCK #(.WIDTH(48),.RSTTYPE(RSTTYPE)) CMUXREG (.D(C),.SEL(CREG),.CLK(CLK),.RST(RSTC),.CE(CEC),.BLOCK_OUT(CREGOUT));

//Second Level 
wire [7:0] OPMODEREGOUT ;
BLOCK #(.WIDTH(8),.RSTTYPE(RSTTYPE)) OPMODEMUXREG (.D(OPMODE),.SEL(OPMODEREG),.CLK(CLK),.RST(RSTOPMODE),.CE(CEOPMODE),.BLOCK_OUT(OPMODEREGOUT));

wire [17:0] PREADDEROUT;
assign PREADDEROUT = (OPMODEREGOUT[6]) ? (DREGOUT - B0REGOUT) : (DREGOUT + B0REGOUT) ;

wire [17:0] PREMUXOUT ;
assign PREMUXOUT = (OPMODEREGOUT[4]) ? PREADDEROUT : B0REGOUT ;

//Third Level
wire [17:0] B1REGOUT ;
BLOCK #(.WIDTH(18),.RSTTYPE(RSTTYPE)) B1MUXREG (.D(PREMUXOUT),.SEL(B1REG),.CLK(CLK),.RST(RSTB),.CE(CEB),.BLOCK_OUT(B1REGOUT));

wire [17:0] A1REGOUT ;
BLOCK #(.WIDTH(18),.RSTTYPE(RSTTYPE)) A1MUXREG (.D(A0REGOUT),.SEL(A1REG),.CLK(CLK),.RST(RSTA),.CE(CEA),.BLOCK_OUT(A1REGOUT));

//Fourth Level 
assign BCOUT = B1REGOUT ;

wire [35:0] MULTIPLIEROUT ;
assign MULTIPLIEROUT = B1REGOUT * A1REGOUT ;

wire [35:0] MREGOUT;
BLOCK #(.WIDTH(36),.RSTTYPE(RSTTYPE)) MMUXREG (.D(MULTIPLIEROUT),.SEL(MREG),.CLK(CLK),.RST(RSTM),.CE(CEM),.BLOCK_OUT(MREGOUT));

generate
	genvar i;
	for(i = 0;i<36;i=i+1)
		buf(M[i],MREGOUT[i]); 
endgenerate

wire CARRYMUXOUT ;
assign CARRYMUXOUT = (CARRYINSEL == "OPMODE5") ? OPMODEREGOUT[5] : (CARRYINSEL == "CARRYIN") ? CARRYIN : 0 ;

wire CIN;
BLOCK #(.WIDTH(1),.RSTTYPE(RSTTYPE)) CYIMUXREG (.D(CARRYMUXOUT),.SEL(CARRYINREG),.CLK(CLK),.RST(RSTCARRYIN),.CE(CECARRYIN),.BLOCK_OUT(CIN));

//Fifth Level
wire [47:0] MUXXOUT;
wire [47:0] DABCONCAT ;
assign DABCONCAT = { D[11:0], A[17:0], B[17:0]} ;
assign MUXXOUT = (OPMODEREGOUT[1:0] ==0 ) ? 0 : (OPMODEREGOUT[1:0] ==1) ? MREGOUT : (OPMODEREGOUT[1:0] ==2) ? P : DABCONCAT ;

wire [47:0] MUXZOUT;
assign MUXZOUT = (OPMODEREGOUT[3:2] ==0 ) ? 0 : (OPMODEREGOUT[3:2] ==1) ? PCIN : (OPMODEREGOUT[3:2] ==2) ? P : CREGOUT ;

wire [47:0] POSTADDERSUM;
wire POSTADDERCOUT;
assign {POSTADDERCOUT,POSTADDERSUM} = (OPMODEREGOUT[7]) ? (MUXZOUT - (MUXXOUT + CIN)) : (MUXZOUT + MUXXOUT + CIN)  ;

BLOCK #(.WIDTH(1),.RSTTYPE(RSTTYPE)) CYOMUXREG (.D(POSTADDERCOUT),.SEL(CARRYOUTREG),.CLK(CLK),.RST(RSTCARRYIN),.CE(CECARRYIN),.BLOCK_OUT(CARRYOUT));
assign CARRYOUTF = CARRYOUT;

BLOCK #(.WIDTH(48),.RSTTYPE(RSTTYPE)) PMUXREG (.D(POSTADDERSUM),.SEL(PREG),.CLK(CLK),.RST(RSTP),.CE(CEP),.BLOCK_OUT(P));
assign PCOUT = P ;
endmodule