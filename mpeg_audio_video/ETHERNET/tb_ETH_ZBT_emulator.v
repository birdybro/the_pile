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
module tb_ETH_ZBT_emulator(
   resetn,
   clock,
	audio_clock,
	ZBT_Reset_I,
	ZBT_Initial_Fill_O,

   Video_Empty_O,
   Video_Shift_1_En_I,
   Video_Shift_8_En_I,
	Video_Shift_Busy_O,
	Video_Byte_Allign_O,
   Video_Bitstream_Data_O,

   Audio_Shift_En_I,
	Audio_Shift_Busy_O,
	Audio_Byte_Allign_O,
   Audio_Bitstream_Data_O
,debug   
);
input [1:0] debug;

input 					resetn;
input 					clock;
input 					audio_clock;

input 					ZBT_Reset_I;
output 					ZBT_Initial_Fill_O;

output 					Video_Empty_O;
input 					Video_Shift_1_En_I;
input 					Video_Shift_8_En_I;
output 					Video_Shift_Busy_O;
output 					Video_Byte_Allign_O;
output 	[31:0]      Video_Bitstream_Data_O;

input 	[4:0] 		Audio_Shift_En_I;
output 					Audio_Shift_Busy_O;
output 					Audio_Byte_Allign_O;
output 	[15:0]		Audio_Bitstream_Data_O;

integer i, file_pointer;
reg [7:0] file_byte;
reg [31:0] file_word;

task ZBT_open; begin
	$fclose(file_pointer);
	$write("Opening file %s for ZBT read\n", `ZBT_input_file);
	file_pointer = $fopen(`ZBT_input_file, "rb");
end endtask

task ZBT_fill_0; begin
	$write("Filling ZBT addresses 00000 - 3FFFF\n");
	for (i = 0; i < 262144; i = i + 1) begin
		file_byte = $fgetc(file_pointer); file_word[31:24] = file_byte;
		file_byte = $fgetc(file_pointer); file_word[23:16] = file_byte;
		file_byte = $fgetc(file_pointer); file_word[15:8] = file_byte;
		file_byte = $fgetc(file_pointer); file_word[7:0] = file_byte;
		ZBT_memory_bank.memory[i] = file_word;
	end
end endtask

task ZBT_fill_1; begin
	$write("Filling ZBT addresses 40000 - 7FFFF\n");
	for (i = 0; i < 262144; i = i + 1) begin
		file_byte = $fgetc(file_pointer); file_word[31:24] = file_byte;
		file_byte = $fgetc(file_pointer); file_word[23:16] = file_byte;
		file_byte = $fgetc(file_pointer); file_word[15:8] = file_byte;
		file_byte = $fgetc(file_pointer); file_word[7:0] = file_byte;
		ZBT_memory_bank.memory[i+262144] = file_word;
	end
end endtask

wire 		[18:0]		ZBT_address;
wire 		[31:0] 		ZBT_Data;

ZBT_model ZBT_memory_bank(
	.clock(clock),
	.Address(ZBT_address),
	.Read_data(ZBT_Data),
	.Write_data(32'h00000000),
	.Write_en(1'b0)
);

wire System_shift, System_empty;
wire [31:0] System_data;

ZBT_Bitstream ZBT_buffer_interface(
	.resetn(resetn),
	.clock(clock),
	.ZBT_Reset_Address_I(ZBT_Reset_I),
	.ZBT_Busy_I(1'b0),
	.ZBT_Address_O(ZBT_address),
	.ZBT_Data_I(ZBT_Data),
	.Shift_8_En_I(System_shift),
	.Buffer_Empty_O(System_empty),
	.Bitstream_Data_O(System_data)
);

wire 		 				Video_ZBT_write_en, Audio_ZBT_write_en;
wire 		[18:0]		Video_ZBT_address, Audio_ZBT_address;
wire 		[31:0] 		Video_ZBT_write_data, Audio_ZBT_write_data;
wire 		[31:0] 		Video_ZBT_read_data, Audio_ZBT_read_data;

ZBT_model ZBT_video_bank(
	.clock(clock),
	.Address(Video_ZBT_address),
	.Read_data(Video_ZBT_read_data),
	.Write_data(Video_ZBT_write_data),
	.Write_en(Video_ZBT_write_en)
);

ZBT_model ZBT_audio_bank(
	.clock(clock),
	.Address(Audio_ZBT_address),
	.Read_data(Audio_ZBT_read_data),
	.Write_data(Audio_ZBT_write_data),
	.Write_en(Audio_ZBT_write_en)
);

assign Video_Shift_Busy_O = 1'b0;
System_Parser System_Parser_unit(
	.resetn(resetn),
	.clock(clock),
	.audio_clock(audio_clock),	
	.Shift_8_En_O(System_shift),
	.System_Buffer_Empty_I(System_empty),
	.Bitstream_Data_I(System_data),
	.Audio_Bitstream_Access_I(1'b1),
	.Audio_Bitstream_Address_O(Audio_ZBT_address),
	.Audio_Bitstream_Write_Data_O(Audio_ZBT_write_data),
	.Audio_Bitstream_Write_En_O(Audio_ZBT_write_en),
	.Audio_Bitstream_Read_Data_I(Audio_ZBT_read_data),
	.Video_Bitstream_Access_I(1'b1), 
	.Video_Bitstream_Address_O(Video_ZBT_address),
	.Video_Bitstream_Write_Data_O(Video_ZBT_write_data),
	.Video_Bitstream_Write_En_O(Video_ZBT_write_en),
	.Video_Bitstream_Read_Data_I(Video_ZBT_read_data),	
	.Video_Empty_O(Video_Empty_O),
	.Video_Shift_1_En_I(Video_Shift_1_En_I),
	.Video_Shift_8_En_I(Video_Shift_8_En_I),
	.Video_Byte_Allign_O(Video_Byte_Allign_O),
	.Video_Data_O(Video_Bitstream_Data_O),
	.Audio_Shift_En_I(Audio_Shift_En_I),
	.Audio_Shift_Busy_O(Audio_Shift_Busy_O),
	.Audio_Byte_Allign_O(Audio_Byte_Allign_O),
	.Audio_Data_O(Audio_Bitstream_Data_O),
	.Reset_Address_I(ZBT_Reset_I)
,.Buffer_Full_O()
,.debug(debug)
);

reg 		[18:0]		last_address_read;
always @(posedge clock or negedge resetn) begin
	if (~resetn) last_address_read <= 19'h00000;
	else last_address_read <= ZBT_address;
end

always @(negedge resetn) begin
	$write("ETH_ZBT resetn detected\n");
	ZBT_open;
	ZBT_fill_0;
	ZBT_fill_1;
end

always @(posedge clock) begin
	if (ZBT_Reset_I) begin
		$write("ETH_ZBT ZBT_Reset_I detected\n");
		ZBT_open;
		ZBT_fill_0;
		ZBT_fill_1;
	end else if (
		(ZBT_address == 19'h40000) &
		(last_address_read != 19'h40000)
	) ZBT_fill_0;
	else if (
		(ZBT_address == 19'h00000) &
		(last_address_read != 19'h00000)
	) ZBT_fill_1;
end

endmodule

module ZBT_model(
	clock,
	Address,
	Read_data,
	Write_data,
	Write_en
);

input clock;
input [18:0] Address;
output reg [31:0] Read_data;
input [31:0] Write_data;
input Write_en;

reg [31:0] memory [524287:0];
reg [31:0] data_1, data_2, data_3;

always @(posedge clock) begin

	Read_data <= data_3;
	data_3 <= data_2;
	data_2 <= data_1;

	if (Write_en) begin
		memory[Address] <= Write_data;
		data_1 <= Write_data;
	end else data_1 <= memory[Address];	
end

endmodule
