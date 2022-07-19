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
module AV_Bitstream (
	resetn,
	clock,
	audio_clock,
	Reset_Address_I,

	Audio_Bitstream_Access_I,
	Audio_Bitstream_Address_O,
	Audio_Bitstream_Write_Data_O,
	Audio_Bitstream_Write_En_O,
	Audio_Bitstream_Read_Data_I,

	Video_Bitstream_Access_I, 
	Video_Bitstream_Address_O,
	Video_Bitstream_Write_Data_O,
	Video_Bitstream_Write_En_O,
	Video_Bitstream_Read_Data_I,

	Video_Shift_1_En_I,
	Video_Shift_8_En_I,
	Video_Byte_Allign_O,
	Video_Data_O,

	Video_Buffer_Write_I,
	Video_Buffer_Full_O,
	Video_Buffer_Empty_O,
	Video_Data_I,

	Audio_Shift_En_I,
	Audio_Shift_Busy_O,
	Audio_Byte_Allign_O,
	Audio_Data_O,

	Audio_Buffer_Write_I,
	Audio_Buffer_Full_O,
	Audio_Data_I
);

input 					resetn;
input 					clock;
input 					audio_clock;
input 					Reset_Address_I;

// Framestores
input 					Audio_Bitstream_Access_I;
output  	[18:0]		Audio_Bitstream_Address_O;
output 	[31:0]		Audio_Bitstream_Write_Data_O;
output  					Audio_Bitstream_Write_En_O;
input 	[31:0]		Audio_Bitstream_Read_Data_I;

input 					Video_Bitstream_Access_I;
output  	[18:0]		Video_Bitstream_Address_O;
output 	[31:0]		Video_Bitstream_Write_Data_O;
output  					Video_Bitstream_Write_En_O;
input 	[31:0]		Video_Bitstream_Read_Data_I;

// Video
input 					Video_Shift_1_En_I;
input 					Video_Shift_8_En_I;
output 					Video_Byte_Allign_O;
output 	[31:0]		Video_Data_O;

input 					Video_Buffer_Write_I;
output 					Video_Buffer_Full_O;
output 					Video_Buffer_Empty_O;
input 	[7:0]			Video_Data_I;

// Audio
input 	[4:0]			Audio_Shift_En_I;
output 					Audio_Shift_Busy_O;
output 					Audio_Byte_Allign_O;
output 	[15:0]		Audio_Data_O;

input 					Audio_Buffer_Write_I;
output 					Audio_Buffer_Full_O;
input 	[7:0]			Audio_Data_I;

Video_ZBT_Bitstream Video_Bitstream_unit(
	.resetn(resetn),
	.clock(clock),
	.Reset_Address_I(Reset_Address_I),
	.Buffer_Write_I(Video_Buffer_Write_I),
	.Buffer_Full_O(Video_Buffer_Full_O),
	.Video_Data_I(Video_Data_I),
   .Video_Shift_1_En_I(Video_Shift_1_En_I),
   .Video_Shift_8_En_I(Video_Shift_8_En_I),
	.Buffer_Empty_O(Video_Buffer_Empty_O),
	.Video_Data_O(Video_Data_O),
	.Video_Byte_Allign_O(Video_Byte_Allign_O),
	.ZBT_Access_I(Video_Bitstream_Access_I),
	.ZBT_Address_O(Video_Bitstream_Address_O),
	.ZBT_Write_Data_O(Video_Bitstream_Write_Data_O),
	.ZBT_Write_En_O(Video_Bitstream_Write_En_O),
	.ZBT_Read_Data_I(Video_Bitstream_Read_Data_I)
);

Audio_ZBT_Bitstream Audio_Bitstream_unit(
	.resetn(resetn),
	.clock(clock),
	.audio_clock(audio_clock),
	.Reset_Address_I(Reset_Address_I),
	.Buffer_Write_I(Audio_Buffer_Write_I),
	.Buffer_Full_O(Audio_Buffer_Full_O),
	.Audio_Data_I(Audio_Data_I),
	.Buffer_Empty_O(),
	.Audio_Shift_En_I(Audio_Shift_En_I),
	.Audio_Shift_Busy_O(Audio_Shift_Busy_O),
	.Audio_Byte_Allign_O(Audio_Byte_Allign_O),
	.Audio_Data_O(Audio_Data_O),	
	.ZBT_Access_I(Audio_Bitstream_Access_I),
	.ZBT_Address_O(Audio_Bitstream_Address_O),
	.ZBT_Write_Data_O(Audio_Bitstream_Write_Data_O),
	.ZBT_Write_En_O(Audio_Bitstream_Write_En_O),
	.ZBT_Read_Data_I(Audio_Bitstream_Read_Data_I)
);

endmodule
