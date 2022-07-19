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
module Picture_Decode (
   resetn,
   clock,

   Start_Picture_Decode_I,
   Done_Picture_Decode_O,

   Data_In_I,
   Shift_1_En_O,
   Shift_8_En_O,
	Shift_Busy_I,
	Byte_Allign_I,
   Start_Code_I,
   Slice_Start_Code_I,
   Start_Code_Upcoming_I,

   Picture_Type_I,
 	Picture_Structure_I,
	Intra_VLC_Format_I,
	Frame_Pred_Frame_DCT_I,
	Concealment_Vectors_I,
	F_Codes_I,
	Intra_DC_Precision_I,
	Quant_Scale_Type_I,
	Alternate_Scan_I,
	Image_Horizontal_I,  
	Image_Vertical_I,
	Load_Seq_Intra_Quant_I,
	Load_Seq_NIntra_Quant_I,
	
   YUV_Data_O,
   YUV_Write_En_O,
   YUV_Start_O,

	Forward_Framestore_Address_O,
	Forward_Framestore_Data_I,
	Forward_Framestore_Busy_I,
	Forward_Framestore_Busy_O,
	Backward_Framestore_Address_O,
	Backward_Framestore_Data_I,
	Backward_Framestore_Busy_I,
	Backward_Framestore_Busy_O

,debug    
//,advance
);
//output [23:0] debug;
input [16:0] debug;
//input advance;
input                resetn;
input                clock;

input                Start_Picture_Decode_I;
output reg           Done_Picture_Decode_O;

input    [1:0]       Data_In_I;
output            	Shift_1_En_O;
output reg           Shift_8_En_O;
input						Shift_Busy_I;
input						Byte_Allign_I;
input                Start_Code_I;
input                Slice_Start_Code_I;
input                Start_Code_Upcoming_I;

input 	[1:0]		   Picture_Type_I;
input 	[1:0]		 	Picture_Structure_I;
input 					Intra_VLC_Format_I;
input 					Frame_Pred_Frame_DCT_I;
input 					Concealment_Vectors_I;
input 	[15:0]		F_Codes_I;
input 	[1:0]			Intra_DC_Precision_I;
input 					Quant_Scale_Type_I;
input 					Alternate_Scan_I;
input 	[11:0]		Image_Horizontal_I;  
input 	[11:0]		Image_Vertical_I;
input 					Load_Seq_Intra_Quant_I;
input 					Load_Seq_NIntra_Quant_I;

output   [7:0]       YUV_Data_O;
output               YUV_Write_En_O;
output 					YUV_Start_O;

output	[18:0]		Forward_Framestore_Address_O, Backward_Framestore_Address_O;
input 	[31:0]		Forward_Framestore_Data_I, Backward_Framestore_Data_I;
input 					Forward_Framestore_Busy_I, Backward_Framestore_Busy_I;
output 					Forward_Framestore_Busy_O, Backward_Framestore_Busy_O;

assign YUV_Data_O = 8'h00;
assign YUV_Write_En_O = 1'b0;
assign YUV_Start_O = 1'b0;

assign Forward_Framestore_Address_O = 19'd0;
assign Backward_Framestore_Address_O = 19'd0;

assign Forward_Framestore_Busy_O = 1'b0;
assign Backward_Framestore_Busy_O = 1'b0;

reg active;
always @(posedge clock or negedge resetn) begin
	if (~resetn) active <= 1'b0;
	else if (Start_Picture_Decode_I) active <= 1'b1;
	else active <= 1'b0;
end

//`define COUNTER_LIMIT 900000
`define COUNTER_LIMIT 48500
integer counter;
integer check1;
reg shift_1_reg;

initial begin
	active = 1'b0;
	counter = 0;
	Done_Picture_Decode_O = 1'b1;
	Shift_8_En_O = 1'b0;
	shift_1_reg = 1'b0;
end

always @(posedge active) begin
	Done_Picture_Decode_O = 1'b0; @(posedge clock);
	Shift_8_En_O = 1'b1;
	while (~Slice_Start_Code_I) @(posedge clock);
	Shift_8_En_O = 1'b0; @(posedge clock);
	while (Slice_Start_Code_I) begin
		counter = 0;
		Shift_8_En_O = 1'b1; @(posedge clock); 
		Shift_8_En_O = 1'b0; shift_1_reg = 1'b1; @(posedge clock); 
		while (~Start_Code_I) begin
			counter = counter + 1;
			if (Start_Code_I) shift_1_reg = 1'b0;
			@(posedge clock);
		end
		while (counter < `COUNTER_LIMIT) begin
			counter = counter + 1;
			@(posedge clock);
		end
	end	
	Done_Picture_Decode_O = 1'b1; @(posedge clock);
end

assign Shift_1_En_O = shift_1_reg & ~Start_Code_I;

endmodule
