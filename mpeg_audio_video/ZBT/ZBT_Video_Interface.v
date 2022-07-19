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
module ZBT_Video_Interface(
   resetn,
	internal_clock_40,
	internal_clock_54,
   
   Bank_Select_I,
   
   Video_Address_40_I,
   Video_Data_40_O,

   Write_Address_54_I,
   Write_Data_54_I,
   Write_En_54_I,
   
   ZBT_Bank0_Address_O,
   ZBT_Bank0_Write_Data_O,
   ZBT_Bank0_Write_En_O,
   ZBT_Bank0_Read_Data_I,
   
   ZBT_Bank1_Address_O,
   ZBT_Bank1_Write_Data_O,
   ZBT_Bank1_Write_En_O,
   ZBT_Bank1_Read_Data_I
);

input                resetn;
input 					internal_clock_40;
input 					internal_clock_54;

input                Bank_Select_I;

input    [18:0]      Video_Address_40_I;
output   [31:0]      Video_Data_40_O;

input    [18:0]      Write_Address_54_I;
input    [31:0]      Write_Data_54_I;
input                Write_En_54_I;

output   [18:0]      ZBT_Bank0_Address_O;
output   [31:0]      ZBT_Bank0_Write_Data_O;
output               ZBT_Bank0_Write_En_O;
input    [31:0]      ZBT_Bank0_Read_Data_I;
   
output   [18:0]      ZBT_Bank1_Address_O;
output   [31:0]      ZBT_Bank1_Write_Data_O;
output               ZBT_Bank1_Write_En_O;
input    [31:0]      ZBT_Bank1_Read_Data_I;
   
// Bank_Select_I == 0 -> Write Bank 0,  Read Bank 1
// Bank_Select_I == 1 ->  Read Bank 0, Write Bank 1

reg		[18:0]      Write_Address_54;
reg		[31:0]      Write_Data_54;
reg 		[1:0]			Write_En_54_pipe;
reg 						Write_En_54;

reg		[18:0]      Write_Address_40;
reg		[31:0]      Write_Data_40;
reg 						Write_En_40;

always @(posedge internal_clock_54 or negedge resetn) begin
	if (~resetn) begin
		Write_Address_54 <= 19'h00000;
		Write_Data_54 <= 32'h00000000;
		Write_En_54_pipe <= 2'h0;
		Write_En_54 <= 1'b0;
	end else begin
		Write_En_54 <= (Write_En_54_pipe != 2'h0);
		Write_En_54_pipe <= {Write_En_54_I, Write_En_54_pipe[1]};
		if (Write_En_54_I) begin
			Write_Address_54 <= Write_Address_54_I;
			Write_Data_54 <= Write_Data_54_I;
		end
	end
end

always @(posedge internal_clock_40 or negedge resetn) begin
	if (~resetn) begin
		Write_Address_40 <= 19'h00000;
		Write_Data_40 <= 32'h00000000;
		Write_En_40 <= 1'b0;
	end else begin
		Write_Address_40 <= Write_Address_54;
		Write_Data_40 <= Write_Data_54;
		Write_En_40 <= Write_En_54;
	end
end

assign ZBT_Bank0_Address_O = (Bank_Select_I) ? 
   Video_Address_40_I : Write_Address_40;
assign ZBT_Bank1_Address_O = (Bank_Select_I) ? 
   Write_Address_40 : Video_Address_40_I;

assign ZBT_Bank0_Write_Data_O = Write_Data_40;
assign ZBT_Bank1_Write_Data_O = Write_Data_40;

assign ZBT_Bank0_Write_En_O = Write_En_40 & ~Bank_Select_I;
assign ZBT_Bank1_Write_En_O = Write_En_40 &  Bank_Select_I;

assign Video_Data_40_O = (Bank_Select_I) ? 
   ZBT_Bank0_Read_Data_I : ZBT_Bank1_Read_Data_I;

endmodule
