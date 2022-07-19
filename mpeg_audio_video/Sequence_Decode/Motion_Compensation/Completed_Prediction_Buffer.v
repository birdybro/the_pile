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
module Completed_Prediction_Buffer (
	clock,

	Write_En_A_I,
	Address_A_I,
	Data_A_I,

	Address_B_I,
	Data_B_O
);

input 				clock;

input 				Write_En_A_I;
input 	[9:0]		Address_A_I;
input 	[15:0]	Data_A_I;

input 	[10:0] 	Address_B_I;
output 	[7:0]		Data_B_O;

wire 					enable_A;

assign enable_A = ~(Write_En_A_I & (Address_B_I[10:1] == Address_A_I));

RAMB16_S9_S18 Buffer_RAM (
   .DOA(Data_B_O),
   .DOB(),
   .DOPA(),
   .DOPB(),
   .ADDRA(Address_B_I),
   .ADDRB(Address_A_I),
   .CLKA(clock),
   .CLKB(clock),
   .DIA(8'h00),
   .DIB(Data_A_I),
   .DIPA(1'b0),
   .DIPB(2'b00),
   .ENA(enable_A),
   .ENB(1'b1),
   .SSRA(1'b0),
   .SSRB(1'b0),
   .WEA(1'b0),
   .WEB(Write_En_A_I)
);

endmodule
