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
module System_Parser(
	resetn,
	clock,
	audio_clock,
	
	Shift_8_En_O,
	System_Buffer_Empty_I,
	Bitstream_Data_I,

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
	
	Video_Empty_O,
	Video_Shift_1_En_I,
	Video_Shift_8_En_I,
	Video_Byte_Allign_O,
	Video_Data_O,
	
	Audio_Shift_En_I,
	Audio_Shift_Busy_O,
	Audio_Byte_Allign_O,
	Audio_Data_O,
	
	Reset_Address_I
,Buffer_Full_O
,debug
);
input [1:0] debug;
output reg Buffer_Full_O;

input                resetn;
input                clock;
input 					audio_clock;

output 					Shift_8_En_O;
input 					System_Buffer_Empty_I;
input 	[31:0] 		Bitstream_Data_I;

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

output 					Video_Empty_O;
input 					Video_Shift_1_En_I;
input 					Video_Shift_8_En_I;
output					Video_Byte_Allign_O;
output 	[31:0]		Video_Data_O;

input 	[4:0]			Audio_Shift_En_I;
output 					Audio_Shift_Busy_O;
output 					Audio_Byte_Allign_O;
output 	[15:0]		Audio_Data_O;

input 					Reset_Address_I;

reg 		[2:0]			parse_mode;		// [2] = reject/~accept 
												// [1] = system/~sequence 
												// [0] = audio/~video
reg		[2:0]			state;
reg 		[15:0] 		counter;
reg 		[15:0] 		parse_end;
reg 						shift_en;

wire 						start_code;
wire 						pack_start_code;
wire 						video_start_code;
wire 						audio_start_code;

wire 						video_write, audio_write;
wire 						video_full, audio_full;

assign Shift_8_En_O = 
	(state == `SYS_PARSE_PARSE) ? 
		(parse_mode[2]) ? ~(video_start_code | audio_start_code) : 
			(parse_mode[0]) ? audio_write : video_write : 
		shift_en;

assign start_code = (Bitstream_Data_I[31:8] == 24'h000001);
assign pack_start_code = start_code & (Bitstream_Data_I[7:0] == 8'hBA);
assign video_start_code = start_code & (Bitstream_Data_I[7:0] == 8'hE0);
assign audio_start_code = start_code & (Bitstream_Data_I[7:0] == 8'hC0);

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		parse_mode <= 3'h0;
		state <= `SYS_PARSE_IDLE;
		counter <= 16'h0000;
		parse_end <= 16'h0000;
		shift_en <= 1'b0;
	end else begin
		if ((state == `SYS_PARSE_IDLE) & ~System_Buffer_Empty_I) 
			state <= `SYS_PARSE_IDLE_2;
		if (
			pack_start_code |
			video_start_code | 
			audio_start_code
		) parse_mode[2:1] <= 2'b11;
		if (state == `SYS_PARSE_IDLE_2) begin
			if (counter == 16'd6) shift_en <= 1'b1;
			if (counter == 16'd14) shift_en <= 1'b0;
			if (counter == 16'd15) state <= `SYS_PARSE_PARSE;
			else counter <= counter + 1;
		end
		if (parse_mode[1]) begin
			case(state)
				`SYS_PARSE_PARSE : begin
						// scans for system start codes
						shift_en <= 1'b0;	
						if (~parse_mode[2])
							if (
								(counter == parse_end) & 
								((parse_mode[0]) ? audio_write : video_write)
							) begin
								parse_mode[2] <= 1'b1; 
								counter <= 16'h0000;
							end else if (Shift_8_En_O) counter <= counter + 1;
//						if (pack_start_code) state <= `SYS_PARSE_PACKET;
						if (video_start_code) begin
							state <= `SYS_PARSE_VIDEO;	
							counter <= 16'h0000;
							shift_en <= 1'b1;
						end
						if (audio_start_code) begin
							state <= `SYS_PARSE_AUDIO;
							counter <= 16'h0000;
							shift_en <= 1'b1;
						end
					end
//				`SYS_PARSE_PACKET : begin
//						counter <= counter + 1;
//						if (counter == 8'h7) state <= `SYS_PARSE_PARSE;
//					end
				`SYS_PARSE_VIDEO : begin
						counter <= counter + 1;
						if (counter == 16'd4) begin
							parse_end <= Bitstream_Data_I[31:16] + 16'd4;
							if (Bitstream_Data_I[15:14] != 2'b10) state <= `SYS_PARSE_PARSE;
						end
						if (counter == 16'd8) begin
							state <= `SYS_PARSE_VIDEO_HEADER;
							counter <= {counter[7:0] + Bitstream_Data_I[31:24], 
								Bitstream_Data_I[31:24]};
						end
					end
				`SYS_PARSE_VIDEO_HEADER : begin
						counter <= counter - 1;
						if (counter[7:0] == 8'd1) begin
							state <= `SYS_PARSE_PARSE;
							counter <= {8'h00, counter[15:8]};
							parse_mode[0] <= 1'b0;
							parse_mode[2] <= 1'b0;
							shift_en <= 1'b0;
						end
					end
				`SYS_PARSE_AUDIO : begin
						counter <= counter + 1;
						if (counter == 16'd4) begin
							parse_end <= Bitstream_Data_I[31:16] + 16'd4;
							if (Bitstream_Data_I[15:14] != 2'b10) state <= `SYS_PARSE_PARSE;
						end
						if (counter == 16'd8) begin
							state <= `SYS_PARSE_AUDIO_HEADER;
							counter <= {counter[7:0] + Bitstream_Data_I[31:24], 
								Bitstream_Data_I[31:24]};
						end
					end
				`SYS_PARSE_AUDIO_HEADER : begin
						counter <= counter - 1;
						if (counter[7:0] == 8'd1) begin
							state <= `SYS_PARSE_PARSE;
							counter <= {8'h00, counter[15:8]};
							parse_mode[0] <= 1'b1;
							parse_mode[2] <= 1'b0;
							shift_en <= 1'b0;
						end
					end
			endcase
		end
	end
end

assign video_write = 
	(state == `SYS_PARSE_PARSE) & ~System_Buffer_Empty_I &
	~parse_mode[2] & ~parse_mode[0] & ~video_full;
assign audio_write = 
	(state == `SYS_PARSE_PARSE) & ~System_Buffer_Empty_I &
	~parse_mode[2] &  parse_mode[0] & ~audio_full;

wire video_full_1, audio_full_1;
assign video_full = (debug[0]) ? (video_full_1) : 1'b0;
assign audio_full = (debug[1]) ? (audio_full_1) : 1'b0;

AV_Bitstream AV_External_Buffer(
	.resetn(resetn),
	.clock(clock),
	.audio_clock(audio_clock),
	.Reset_Address_I(Reset_Address_I),
	.Audio_Bitstream_Access_I(Audio_Bitstream_Access_I),
	.Audio_Bitstream_Address_O(Audio_Bitstream_Address_O),
	.Audio_Bitstream_Write_Data_O(Audio_Bitstream_Write_Data_O),
	.Audio_Bitstream_Write_En_O(Audio_Bitstream_Write_En_O),
	.Audio_Bitstream_Read_Data_I(Audio_Bitstream_Read_Data_I),
	.Video_Bitstream_Access_I(Video_Bitstream_Access_I), 
	.Video_Bitstream_Address_O(Video_Bitstream_Address_O),
	.Video_Bitstream_Write_Data_O(Video_Bitstream_Write_Data_O),
	.Video_Bitstream_Write_En_O(Video_Bitstream_Write_En_O),
	.Video_Bitstream_Read_Data_I(Video_Bitstream_Read_Data_I),
	.Video_Shift_1_En_I(Video_Shift_1_En_I),
	.Video_Shift_8_En_I(Video_Shift_8_En_I),
	.Video_Byte_Allign_O(Video_Byte_Allign_O),
	.Video_Data_O(Video_Data_O),
	.Video_Buffer_Write_I(video_write),
	.Video_Buffer_Full_O(video_full_1),
	.Video_Buffer_Empty_O(Video_Empty_O),
	.Video_Data_I(Bitstream_Data_I[31:24]),
	.Audio_Shift_En_I(Audio_Shift_En_I),
	.Audio_Shift_Busy_O(Audio_Shift_Busy_O),
	.Audio_Byte_Allign_O(Audio_Byte_Allign_O),
	.Audio_Data_O(Audio_Data_O),
	.Audio_Buffer_Write_I(audio_write),
	.Audio_Buffer_Full_O(audio_full_1),
	.Audio_Data_I(Bitstream_Data_I[31:24])
);

reg audio_full_reg, video_full_reg;
always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		audio_full_reg <= 1'b0;
		video_full_reg <= 1'b0;
		Buffer_Full_O <= 1'b0;
	end else begin
		audio_full_reg <= audio_full;
		video_full_reg <= video_full;
		Buffer_Full_O <= audio_full_reg | video_full_reg;
	end
end

endmodule
