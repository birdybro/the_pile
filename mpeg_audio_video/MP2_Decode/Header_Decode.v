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
module Decode_Header (
	clock,
	resetn,
	Header_Start_I,
	Header_Done_O,
	
	Sample_Freq_O,
	Format_Check_O,
	Table_O,
		
	Bitstream_Byte_Allign_I,
	Bitstream_Data_I,
	Shift_En_O
);

input 				clock;
input 				resetn;

input 				Header_Start_I;
output 				Header_Done_O;

output 	[1:0]		Sample_Freq_O;
output				Format_Check_O;
output reg [2:0]	Table_O;

input					Bitstream_Byte_Allign_I;
input 	[15:0]	Bitstream_Data_I;
output 	[1:0]		Shift_En_O;

reg 		[2:0]		state;

reg 					version;
reg 		[1:0]		layer;
reg 					error_protection;
reg 		[3:0]		bitrate_index;
reg 		[1:0]		sampling_frequency;
reg 					padding;
reg 					extension;
reg 		[1:0]		mode;
reg 		[1:0]		mode_ext;
reg 					copyright;
reg 					original;
reg 		[1:0]		emphasis;

assign Header_Done_O = (state == `MP2_HEADER_IDLE);

assign Shift_En_O = 
	(state == `MP2_HEADER_SYNC) ? 
(Bitstream_Byte_Allign_I & (Bitstream_Data_I[15:4] == 12'hFFF)) ? 2'b10 : 2'b01 :
	(
		(state == `MP2_HEADER_INFO) |
		(state == `MP2_HEADER_TEMP1) |
		(state == `MP2_HEADER_TEMP2)
	) ? 2'b10 : 2'b00;

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		state <= `MP2_HEADER_IDLE;
		version <= 1'b0;
		layer <= 2'h0;
		error_protection <= 1'b0;
		bitrate_index <= 4'h0;
		sampling_frequency <= 2'h0;
		padding <= 1'b0;
		extension <= 1'b0;
		mode <= 2'h0;
		mode_ext <= 2'h0;
		copyright <= 1'b0;
		original <= 1'b0;
		emphasis <= 2'h0;
	end else begin
		case (state)
			`MP2_HEADER_IDLE : begin
					if (Header_Start_I) begin
						state <= `MP2_HEADER_SYNC;
					end
				end
			`MP2_HEADER_SYNC : begin
					if (Bitstream_Byte_Allign_I & (Bitstream_Data_I[15:4] == 12'hFFF)) begin
						version <= Bitstream_Data_I[3];
						layer <= Bitstream_Data_I[2:1];
						error_protection <= Bitstream_Data_I[0];
						state <= `MP2_HEADER_TEMP1;
					end
				end
			`MP2_HEADER_TEMP1 : state <= `MP2_HEADER_INFO;				
			`MP2_HEADER_INFO : begin
					bitrate_index <= Bitstream_Data_I[15:12];
					sampling_frequency <= Bitstream_Data_I[11:10];
					padding <= Bitstream_Data_I[9];
					extension <= Bitstream_Data_I[8];
					mode <= Bitstream_Data_I[7:6];
					mode_ext <= Bitstream_Data_I[5:4];
					copyright <= Bitstream_Data_I[3];
					original <= Bitstream_Data_I[2];
					emphasis <= Bitstream_Data_I[1:0];
					state <= `MP2_HEADER_TEMP2;
				end
			`MP2_HEADER_TEMP2 : state <= `MP2_HEADER_IDLE;
		endcase
	end
end

assign Sample_Freq_O = sampling_frequency;

assign Format_Check_O = 
	(version == 1'b1) & 
	(layer == 2'h2) &
	(mode != 2'h3);
	
reg	 	[5:0] 	bitrate_code;
always @(bitrate_index) begin
	bitrate_code = 6'h00;
	case (bitrate_index[3:2])
		2'h0 : bitrate_code = {3'b000, |bitrate_index[1:0], bitrate_index[1], &bitrate_index[1:0]};
		2'h1 : bitrate_code = {3'b001, bitrate_index[1:0],   1'b0};
		2'h2 : bitrate_code = { 2'b01, bitrate_index[1:0],  2'b00};
		2'h3 : bitrate_code = {  1'b1, bitrate_index[1:0], 3'b000};
	endcase
end

always @(bitrate_code, sampling_frequency) begin
	Table_O = 3'h0;
	if ((bitrate_code >= 6'd7) && (
		(sampling_frequency == 2'h1) || 
		(bitrate_code <= 6'd10))
	) Table_O = 3'h0;
	else if ((sampling_frequency != 2'h1) && (bitrate_code <= 6'd12)) Table_O = 3'h1;
	else if ((sampling_frequency != 2'h2) && (bitrate_code <= 6'd6))  Table_O = 3'h2;
	else Table_O = 3'h3;
end

endmodule
