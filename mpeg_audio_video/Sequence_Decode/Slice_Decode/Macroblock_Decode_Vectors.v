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
module Macroblock_Decode_Vectors(
   resetn,
   clock,
   
   Start_I,
   Data_In_I,

   Shift_En_O,
   Valid_Code_O,
   Symbol_O,

   Coeff_Table_En_O,
   Coeff_Table_Addr_O,
   Coeff_Table_Data_I
);

input                resetn;
input                clock;

input                Start_I;
input                Data_In_I;

output               Shift_En_O;
output               Valid_Code_O;
output   [5:0]       Symbol_O;

output               Coeff_Table_En_O;
input    [15:0]      Coeff_Table_Data_I;
output   [9:0]       Coeff_Table_Addr_O;

wire     [9:0]       Table_Offset;
wire     [7:0]       Next_Table_Addr, Curr_Table_Data;
reg                  Valid_Code_reg;
reg 		[4:0]			Symbol_reg;
wire 						Valid_Code;

assign Valid_Code = Curr_Table_Data[7];
assign Coeff_Table_En_O = ~Valid_Code_O | Start_I;
assign Curr_Table_Data = (Data_In_I) ? 
   Coeff_Table_Data_I[15:8] : Coeff_Table_Data_I[7:0];
assign Next_Table_Addr = (Start_I) ? 8'h00 : Curr_Table_Data;
assign Table_Offset = `TABLE_B10_START;
assign Coeff_Table_Addr_O = Table_Offset + {2'b00,Next_Table_Addr};
assign Symbol_O = {(Data_In_I & (|Symbol_reg)),Symbol_reg}; // sign magnitude

always @(posedge clock or negedge resetn) begin
   if (~resetn) Valid_Code_reg <= 1'b1;
   else Valid_Code_reg <= (Valid_Code | Valid_Code_reg) & ~Start_I;
end

always @(posedge clock or negedge resetn) begin
	if (~resetn) Symbol_reg <= 6'h00;
	else if (Valid_Code) Symbol_reg <= Curr_Table_Data[4:0];
end

assign Shift_En_O = ~Valid_Code_reg;
assign Valid_Code_O = Valid_Code_reg & ~Start_I;

endmodule
