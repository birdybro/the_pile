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
module MP2_Decode_16(
	resetn,
	audio_decoder_clock,

	Decode_Start_I,
	Decode_Done_O,

	Bitstream_Byte_Allign_I,
	Bitstream_Data_I,
	Shift_Busy_I,
	Shift_En_O,

	AC97_RESETN_I,
	AC97_BIT_CLOCK_I,
	SAMPLE_FREQUENCY_I,
	SOURCE_SELECT_I,
	AC97_SYNCH_O,
	AC97_DATA_IN_I,
	AC97_DATA_OUT_O,
	AC97_BEEP_TONE_O,
	STARTUP_O,
Header_found,
	Audio_Sync_I,
	Audio_Sync_O
);
output reg Header_found;

input 				resetn;
input 				audio_decoder_clock;

input 				Decode_Start_I;
output 				Decode_Done_O;

input 				Bitstream_Byte_Allign_I;
input 	[15:0]	Bitstream_Data_I;
input 				Shift_Busy_I;
output reg [4:0]	Shift_En_O;

input 				AC97_RESETN_I;
input 				AC97_BIT_CLOCK_I;
input 	[1:0] 	SAMPLE_FREQUENCY_I;
input 				SOURCE_SELECT_I;
output 				AC97_SYNCH_O;
input 				AC97_DATA_IN_I;
output 				AC97_DATA_OUT_O;
output 				AC97_BEEP_TONE_O;
output 				STARTUP_O;

input 				Audio_Sync_I;
output 				Audio_Sync_O;

reg active, shift1, shift8;
wire frame_start;
integer counter;

assign Decode_Done_O = 1'b1;
assign Shift_En_O[4:2] = 3'h0;
assign Shift_En_O[1] = Audio_Sync_I & shift8;
assign Shift_En_O[0] = Audio_Sync_I & shift1 & ~frame_start;
assign AC97_SYNCH_O = 1'b0;
assign AC97_DATA_OUT_O = 1'b0;
assign AC97_BEEP_TONE_O = 1'b0;
assign STARTUP_O = 1'b1;
assign Audio_Sync_O = 1'b1;

assign frame_start = Bitstream_Byte_Allign_I & (Bitstream_Data_I == 16'hFFFD);

always @(negedge resetn) if (~resetn) Header_found <= 1'b0;

always @(posedge audio_decoder_clock or negedge resetn) begin
	if (~resetn) active <= 1'b0;
	else active <= Decode_Start_I;
end

initial begin
	counter = 0; shift1 = 1'b0; shift8 = 1'b0;
	@(posedge active);
	while (1) begin
		counter = 0;
		shift8 = 1'b1; 
		counter = counter + 1; @(posedge audio_decoder_clock); 
		shift1 = 1'b1; shift8 = 1'b0; 
		counter = counter + 1; @(posedge audio_decoder_clock);
		if (Audio_Sync_I)
			while (~frame_start) begin
				counter = counter + 1; @(posedge audio_decoder_clock);
			end
		shift1 = 1'b0;
		while (counter < 648000) begin
			counter = counter + 1; @(posedge audio_decoder_clock);
		end
	end
end	

endmodule
