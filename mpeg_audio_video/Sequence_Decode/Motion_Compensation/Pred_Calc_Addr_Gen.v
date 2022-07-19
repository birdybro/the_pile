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
module Pred_Calc_Addr_Gen(
	Bank_Sel_Flag_I,
	Block_Counter_I,
	Row_Counter_I,
	Column_Counter_I,
	
	Write_Address_O,
	Retrieve_Address_O,
	Y_nCbCr_O
);

input 				Bank_Sel_Flag_I;
input 	[3:0]		Block_Counter_I;
input 	[3:0]		Row_Counter_I;
input		[1:0]		Column_Counter_I;
	
output reg [9:0]	Write_Address_O;
output 	[8:0]		Retrieve_Address_O;
output 				Y_nCbCr_O;

wire 		[1:0]		cc;
wire 		[3:0]		CbCr_row;

assign CbCr_row = Row_Counter_I;

assign cc = 
	(Block_Counter_I[3:2] == 2'h0) ? 2'h0 : 
	(Block_Counter_I[0]) ? 2'h2 : 2'h1;

assign Retrieve_Address_O = Y_nCbCr_O ? 
	{2'b00, Row_Counter_I[2:0], Block_Counter_I[0], Column_Counter_I} +
		{Row_Counter_I[3],6'h00} + {Block_Counter_I[1],6'h00} : 
	Column_Counter_I + (144 * cc) + 
		4 * CbCr_row;


always @(
	cc, Bank_Sel_Flag_I, Block_Counter_I, 
	Row_Counter_I, Column_Counter_I, CbCr_row
) begin
	Write_Address_O = 10'h000;
	case (cc)
		2'h0 : Write_Address_O = {
			Bank_Sel_Flag_I, 2'h0,
			Block_Counter_I[1:0], 
			Row_Counter_I[2:0],
			Column_Counter_I };  
		2'h1 : Write_Address_O = {
			Bank_Sel_Flag_I, 4'h4, 
			CbCr_row[2:0],	Column_Counter_I};
		2'h2 : Write_Address_O = {
			Bank_Sel_Flag_I, 4'h5, 
			CbCr_row[2:0],	Column_Counter_I};
	endcase				
end

assign Y_nCbCr_O = (cc == 2'h0);

endmodule
