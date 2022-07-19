// 
//  MAC_MPEG2_AV - MPEG-2 hardware implementation for Xilinx multimedia board 
//  Copyright (C) 2007 McMaster University
// 
//==============================================================================
// 
// This file is part of MAC_MPEG2_AV
// 
// MAC_MPEG2_AV is distributed in the hope that it will be useful for further 
// research, but WITHOUT ANY WARRANTY; without even the implied warranty of 
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. MAC_MPEG2_AV is free; you 
// can redistribute it and/or modify it provided that proper reference is provided 
// to the authors. See the documents included in the "doc" folder for further details.
//
//==============================================================================

`include "defines.v"
module Coeff_Buffer(
   clock,
   Address_A_I,
   Write_Enable_A_I,
   Data_A_I,
   Enable_B_I,
   Address_B_I,
   Data_B_O
);

input             clock;
input [`COEFF_BUFFER_ADDR_WIDTH-1:0] Address_A_I;
input             Write_Enable_A_I;
input    [31:0]   Data_A_I;
input             Enable_B_I;
input [`COEFF_BUFFER_ADDR_WIDTH-1:0] Address_B_I;
output   [31:0]   Data_B_O;

wire     [31:0]   Data_B;

wire 		[15:0] 	Bank0_Data;
wire 		[15:0] 	Bank1_Data;
wire 		[15:0] 	Bank2_Data;
wire 		[15:0] 	Bank3_Data;

wire              Write_Enable_A_I_bank0;
wire              Write_Enable_A_I_bank1;
wire              Write_Enable_A_I_bank2;
wire              Write_Enable_A_I_bank3;

wire              Enable_B_I_bank0;
wire              Enable_B_I_bank1;
wire              Enable_B_I_bank2;
wire              Enable_B_I_bank3;

wire [`COEFF_BUFFER_ADDR_WIDTH-11:0] Bank_select_A;
wire [`COEFF_BUFFER_ADDR_WIDTH-11:0] Bank_select_B;
reg  [`COEFF_BUFFER_ADDR_WIDTH-11:0] Bank_select_B_delay;

assign Data_B_O = Data_B;
assign Bank_select_A = Address_A_I[10];
assign Bank_select_B = Address_B_I[10];

assign Write_Enable_A_I_bank0 = Write_Enable_A_I & (Bank_select_A == 1'b0);
assign Write_Enable_A_I_bank1 = Write_Enable_A_I & (Bank_select_A == 1'b1);
assign Write_Enable_A_I_bank2 = Write_Enable_A_I & (Bank_select_A == 1'b0);
assign Write_Enable_A_I_bank3 = Write_Enable_A_I & (Bank_select_A == 1'b1);

assign Enable_B_I_bank0 = Enable_B_I & (Bank_select_B == 1'b0);
assign Enable_B_I_bank1 = Enable_B_I & (Bank_select_B == 1'b1);
assign Enable_B_I_bank2 = Enable_B_I & (Bank_select_B == 1'b0);
assign Enable_B_I_bank3 = Enable_B_I & (Bank_select_B == 1'b1);

always @(posedge clock) begin
	Bank_select_B_delay <= Bank_select_B;
end

assign Data_B = (Bank_select_B_delay == 1'b1) ? 
	{ Bank3_Data, Bank1_Data } : 
	{ Bank2_Data, Bank0_Data };

//						  Data[31:16] | Data[15:0]
//						 /////////////////////////
// Address[0] = 1  //	 B3  	  |	B1		//
// Address[0] = 0  //	 B2  	  |	B0		//
//						 /////////////////////////

RAMB16_S18_S18 Coeff_Buffer_RAM_bank3 (
   .DOA(),
   .DOB(Bank3_Data),
   .DOPA(),
   .DOPB(),
   .ADDRA(Address_A_I[9:0]),
   .ADDRB(Address_B_I[9:0]),
   .CLKA(clock),
   .CLKB(clock),
   .DIA(Data_A_I[31:16]),
   .DIB(16'h0000),
   .DIPA(2'b00),
   .DIPB(2'b00),
   .ENA(1'b1),
   .ENB(Enable_B_I_bank3),
   .SSRA(1'b0),
   .SSRB(1'b0),
   .WEA(Write_Enable_A_I_bank3),
   .WEB(1'b0)
);

RAMB16_S18_S18 Coeff_Buffer_RAM_bank2 (
   .DOA(),
   .DOB(Bank2_Data),
   .DOPA(),
   .DOPB(),
   .ADDRA(Address_A_I[9:0]),
   .ADDRB(Address_B_I[9:0]),
   .CLKA(clock),
   .CLKB(clock),
   .DIA(Data_A_I[31:16]),
   .DIB(16'h0000),
   .DIPA(2'b00),
   .DIPB(2'b00),
   .ENA(1'b1),
   .ENB(Enable_B_I_bank2),
   .SSRA(1'b0),
   .SSRB(1'b0),
   .WEA(Write_Enable_A_I_bank2),
   .WEB(1'b0)
);
  
RAMB16_S18_S18 Coeff_Buffer_RAM_bank1 (
   .DOA(),
   .DOB(Bank1_Data),
   .DOPA(),
   .DOPB(),
   .ADDRA(Address_A_I[9:0]),
   .ADDRB(Address_B_I[9:0]),
   .CLKA(clock),
   .CLKB(clock),
   .DIA(Data_A_I[15:0]),
   .DIB(16'h0000),
   .DIPA(2'b00),
   .DIPB(2'b00),
   .ENA(1'b1),
   .ENB(Enable_B_I_bank1),
   .SSRA(1'b0),
   .SSRB(1'b0),
   .WEA(Write_Enable_A_I_bank1),
   .WEB(1'b0)
);

RAMB16_S18_S18 Coeff_Buffer_RAM_bank0 (
   .DOA(),
   .DOB(Bank0_Data),
   .DOPA(),
   .DOPB(),
   .ADDRA(Address_A_I[9:0]),
   .ADDRB(Address_B_I[9:0]),
   .CLKA(clock),
   .CLKB(clock),
   .DIA(Data_A_I[15:0]),
   .DIB(16'h0000),
   .DIPA(2'b00),
   .DIPB(2'b00),
   .ENA(1'b1),
   .ENB(Enable_B_I_bank0),
   .SSRA(1'b0),
   .SSRB(1'b0),
   .WEA(Write_Enable_A_I_bank0),
   .WEB(1'b0)
);

endmodule
