`timescale 1ns/1ps
module DSP48A1_tb();
parameter A0REG = 0 ;
parameter A1REG = 1 ;
parameter B0REG = 0 ;
parameter B1REG = 1 ;
parameter CREG = 1; 
parameter DREG = 1 ; 
parameter MREG = 1 ; 
parameter PREG = 1 ; 
parameter CARRYINREG = 1 ; 
parameter CARRYOUTREG = 1 ; 
parameter OPMODEREG = 1;
parameter CARRYINSEL = "OPMODE5" ;
parameter B_INPUT = "DIRECT" ;
parameter RSTTYPE = "SYNC" ; 
//Signals Declaration
reg [17:0] A, B, D;
reg [47:0] C, PCIN;
reg CLK, CARRYIN;
reg [7:0] OPMODE;
reg RSTA, RSTB, RSTM, RSTP, RSTC, RSTD, RSTCARRYIN, RSTOPMODE;
reg CEA, CEB, CEM, CEP, CEC, CED, CECARRYIN, CEOPMODE;
reg [17:0] BCIN;
wire [17:0] BCOUT;
wire [47:0] PCOUT, P;
wire [35:0] M;
wire CARRYOUT, CARRYOUTF;
//DUT INSTANTIATION
DSP48A1 #(.A0REG(A0REG),.A1REG(A1REG),.B0REG(B0REG),.B1REG(B1REG),.CREG(CREG),.DREG(DREG),.MREG(MREG),.PREG(PREG),.CARRYINREG(CARRYINREG),.CARRYOUTREG(CARRYOUTREG),
        .OPMODEREG(OPMODEREG),.CARRYINSEL(CARRYINSEL),.B_INPUT(B_INPUT),.RSTTYPE(RSTTYPE)) DUT (.A(A),.B(B),.D(D),.C(C),.CLK(CLK),.CARRYIN(CARRYIN),.OPMODE(OPMODE),
        .BCIN(BCIN),.RSTA(RSTA),.RSTB(RSTB),.RSTM(RSTM),.RSTP(RSTP),.RSTC(RSTC),.RSTD(RSTD),.RSTCARRYIN(RSTCARRYIN),.RSTOPMODE(RSTOPMODE),.CEA(CEA),.CEB(CEB),.CEM(CEM),
        .CEP(CEP),.CEC(CEC),.CED(CED),.CECARRYIN(CECARRYIN),.CEOPMODE(CEOPMODE),.PCIN(PCIN),.BCOUT(BCOUT),.PCOUT(PCOUT),.P(P),.M(M),.CARRYOUT(CARRYOUT),.CARRYOUTF(CARRYOUTF));
// Clock generation
initial begin
    CLK = 0;
    forever 
    #1 CLK = ~CLK; 
end

//Test Stimiulus Generator
initial begin
// Initialize and reset signals
    RSTA = 1; RSTB = 1; RSTM = 1; RSTP = 1; RSTC = 1; RSTD = 1; RSTCARRYIN = 1; RSTOPMODE = 1;
    CEA = 1; CEB = 1; CEM = 1; CEP = 1; CEC = 1; CED = 1; CECARRYIN = 1; CEOPMODE = 1;
    A = 0; B = 0; C = 0; D = 0; CARRYIN = 0; BCIN = 0; PCIN = 0;
    OPMODE = 8'b00000000;
    repeat(5) @(negedge CLK);

    // Release resets
    RSTA = 0; RSTB = 0; RSTM = 0; RSTP = 0; RSTC = 0; RSTD = 0; RSTCARRYIN = 0; RSTOPMODE = 0;

    // Test case 1: Basic addition
    A = 20; B = 50; C = 10; D = 100; CARRYIN = 0; BCIN = 5; PCIN = 40;
    OPMODE = 8'b01101111; //A + B + D + C
    repeat(5) @(negedge CLK);

    // Test case 2: Basic subtraction
    A = 80; B = 10; C = 10; D = 10; CARRYIN = 0;
    OPMODE = 8'b01010100; //A - B - D - C
    repeat(5) @(negedge CLK);

    // Test case 3: Multiplication with addition
    A = 15; B = 10; C = 100; D = 5; CARRYIN = 0;
    OPMODE = 8'b00101010; //A * B + D + C
    repeat(5) @(negedge CLK);

    // Test case 4: Accumulation with CARRYIN
    A = 10; B = 20; C = 50; D = 10; CARRYIN = 1;
    OPMODE = 8'b10001101; //A + B + D + CARRYIN
    repeat(5) @(negedge CLK);

    // Test case 5: Chained operations with different OPMODE
    A = 50; B = 25; C = 200; D = 10; CARRYIN = 0;
    OPMODE = 8'b01111111; // Some other complex operation
    repeat(5) @(negedge CLK);

    // Test case 6: Cascade input (BCIN) handling
    A = 60; B = 30; C = 100; D = 10; CARRYIN = 0; BCIN = 10;
    OPMODE = 8'b11000010; // Perform operation using BCIN
    repeat(5) @(negedge CLK);

    // Test case 7: Complex operation using all inputs
    A = 70; B = 40; C = 150; D = 20; CARRYIN = 1;
    OPMODE = 8'b10101010; // Another complex operation
    repeat(5) @(negedge CLK);

    // Test case 8: Another OPMODE setting with all inputs
    A = 80; B = 50; C = 175; D = 25; CARRYIN = 0;
    OPMODE = 8'b00011000; // Another operation mode
    repeat(5) @(negedge CLK);

    // Reset all signals and finish
    RSTA = 1; RSTB = 1; RSTM = 1; RSTP = 1; RSTC = 1; RSTD = 1; RSTCARRYIN = 1; RSTOPMODE = 1;
    CEA = 0; CEB = 0; CEM = 0; CEP = 0; CEC = 0; CED = 0; CECARRYIN = 0; CEOPMODE = 0;
    A = 0; B = 0; C = 0; D = 0; CARRYIN = 0; BCIN = 0; PCIN = 0; OPMODE = 8'b00000000;
    repeat(10) @(negedge CLK);

    $stop;
end
//Test Monitor & Results
initial begin
    $monitor("A=%d, B=%d, C=%d, D=%d, CARRYIN=%d ,PCIN=%d , OPMODE=%b, P=%d,BCOUT=%d ,M=%d ,CARRYOUT=%d", A, B, C, D,CARRYIN ,PCIN , OPMODE, P,BCOUT ,M , CARRYOUT);
end
endmodule
