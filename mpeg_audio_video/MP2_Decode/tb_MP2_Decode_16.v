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
module tb_MP2_Decode_16();
//`define PCM_VALIDATE 1
//`define TRACE 1

reg 						resetn;
reg 						clock, audio_bit_clock;

reg 						Audio_start;
wire 		[15:0]		Audio_data;
wire 						Audio_shift_busy;
wire 						Audio_byte_allign;
wire 		[4:0]			Audio_shift;

integer frame_counter;

wire audio_en_flag, video_en_flag;
assign audio_en_flag = 1'b1;
assign video_en_flag = 1'b0;

MP2_Decode_16 Audio_Decoder(
	.resetn(resetn),
	.audio_decoder_clock(clock),
	.Decode_Start_I(Audio_start),
	.Decode_Done_O(),
	.Bitstream_Byte_Allign_I(Audio_byte_allign),
	.Bitstream_Data_I(Audio_data),
	.Shift_Busy_I(Audio_shift_busy),
	.Shift_En_O(Audio_shift),
	.AC97_RESETN_I(resetn),
	.AC97_BIT_CLOCK_I(audio_bit_clock),
	.SAMPLE_FREQUENCY_I(2'b00),
	.SOURCE_SELECT_I(1'b0),
	.AC97_SYNCH_O(),
	.AC97_DATA_IN_I(1'b0),
	.AC97_DATA_OUT_O(),
	.AC97_BEEP_TONE_O(),
	.STARTUP_O(),
	.Header_found(),
	.Audio_Sync_I(1'b1),
	.Audio_Sync_O
);

tb_ETH_ZBT_emulator ETH_ZBT_emulator(
   .resetn(resetn),
   .clock(clock),
   .audio_clock(clock),
	.ZBT_Reset_I(1'b0),
	.ZBT_Initial_Fill_O(),
   .Video_Empty_O(),
   .Video_Shift_1_En_I(1'b0),
   .Video_Shift_8_En_I(1'b0),
   .Video_Shift_Busy_O(),
   .Video_Byte_Allign_O(),
   .Video_Bitstream_Data_O(),
   .Audio_Shift_En_I(Audio_shift),
	.Audio_Shift_Busy_O(Audio_shift_busy),
	.Audio_Byte_Allign_O(Audio_byte_allign),
   .Audio_Bitstream_Data_O(Audio_data)
,.debug({audio_en_flag,video_en_flag})
);

always begin #(0.5*`CLOCK_PERIOD) clock = ~clock; end
always begin #41.67 audio_bit_clock = ~audio_bit_clock; end

integer outfile;

initial begin 
	// set the time format
	$timeformat(-3, 2, " ms", 10);
	$write("Simulation started at %t\n\n", $realtime);

`ifdef PCM_VALIDATE `else
//	$write("Opening output file: tb_matrix.aiff.hex\n");
//	outfile = $fopen("tb_matrix.aiff.hex", "wb");

	// AIFF header
//	AIFF_header;
`endif
	// initialize signals
	clock = 1'b0; resetn = 1'b0; 
	audio_bit_clock = 1'b0;
	Audio_start = 1'b0;
	
	// master reset
	#(2*`CLOCK_PERIOD) resetn = 1'b1;	
	
	// Sequence decode start pulse
	wait(ETH_ZBT_emulator.ZBT_buffer_interface.In_Buffer_Full == 1'b1);
	#(10*`CLOCK_PERIOD) Audio_start = 1'b1;	
	$write("Sequence decode started at %t\n", $realtime);
	#(`CLOCK_PERIOD) Audio_start = 1'b0;

end

reg [15:0] samples [1:0][1023:0];
integer sample_count, left_count, right_count;
initial begin sample_count = 0; left_count = 0; right_count = 0; end

always @(posedge Audio_Decoder.Header_done) begin
	if (resetn) $write("Header Decoded, sample freq %d, format_check %b, Table %d\n", 
		Audio_Decoder.Decode_Header_unit.Sample_Freq_O,
		Audio_Decoder.Decode_Header_unit.Format_Check_O,
		Audio_Decoder.Decode_Header_unit.Table_O);
end

always @(posedge clock) begin
//	if (Audio_Decoder.Decode_Bitalloc_Scale_unit.RAM_Wen_O)
//		$write("DBS RAM write addr %d, data %x\n", 
//			Audio_Decoder.Decode_Bitalloc_Scale_unit.RAM_Address_O,
//			Audio_Decoder.Decode_Bitalloc_Scale_unit.RAM_Data_O);

//	if (Audio_Decoder.Buffer_Deq_Denorm_unit.RAM_Wen_O)
//		$write("BDD RAM write addr %d, data %x\n", 
//			Audio_Decoder.Buffer_Deq_Denorm_unit.RAM_Address_O,
//			Audio_Decoder.Buffer_Deq_Denorm_unit.RAM_Data_O);

//	if (
//		(Audio_Decoder.SubBandSynthesis_unit.window_write_en) //& 
////		(Audio_Decoder.Scale_block >= 4)
//	)
//		$write("window sample: %x\n", 
//			Audio_Decoder.SubBandSynthesis_unit.window_write_data);

//	if (Audio_Decoder.SubBandSynthesis_unit.Sample_Write_En_O)
//		$write("Completed sample: %x\n", 
//			Audio_Decoder.SubBandSynthesis_unit.Sample_Data_O);
end

/*
always @(posedge clock) begin
	if (Audio_Decoder.SubBandSynthesis_unit.Sample_Write_En_O) begin	
		if (~Audio_Decoder.Synth_counter[0]) begin 	// left sample
			samples[0][left_count] = Audio_Decoder.SubBandSynthesis_unit.Sample_Data_O;  
			left_count = left_count + 1;
		end else begin											// right sample
			samples[1][right_count] = Audio_Decoder.SubBandSynthesis_unit.Sample_Data_O;
			right_count = right_count + 1;
			if (right_count == 'd32) begin
`ifdef PCM_VALIDATE
				pcm_compare; 
`else
				$write("--- Dumping samples to file ---\n");
				for (right_count = 0; right_count < 32; right_count = right_count + 1) begin
					$fwrite(outfile, "%02h %02h %02h %02h ", 
						samples[0][right_count][15:8],
						samples[0][right_count][7:0],
						samples[1][right_count][15:8],
						samples[1][right_count][7:0]);
				end
`endif
				left_count = 0; right_count = 0;
			end
		end
	end
end
/**/

`ifdef TRACE
integer temp;
always @(posedge clock) begin //if (frame_counter == 8) begin
	if (Audio_Decoder.Header_start) $write("Starting header parse\n");	
	if (Audio_Decoder.Synth_start) $write("Starting subband synthesis\n");
	if (Audio_Decoder.SubBandSynthesis_unit.Sample_Write_En_O) begin	
		temp = {{16{Audio_Decoder.SubBandSynthesis_unit.Sample_Data_O[15]}},
			Audio_Decoder.SubBandSynthesis_unit.Sample_Data_O};
		$write("%x -> %d\n", 
			Audio_Decoder.SubBandSynthesis_unit.next_sum, temp);
	end
end

//always @(posedge clock) if (frame_counter == 8) begin
//	if (Audio_Decoder.BDD_sample_wen) $write("%x - %x\n", Audio_Decoder.BDD_sample_address, Audio_Decoder.BDD_sample_data);
//end

//always @(posedge clock) if (frame_counter == 8) begin
//	if (Audio_Decoder.Decode_Bitalloc_Scale_unit.bit_alloc_write_en) begin
////		$write("BA_WEN %x %x - ", 
////			Audio_Decoder.Decode_Bitalloc_Scale_unit.bit_alloc_address,
////			Audio_Decoder.Decode_Bitalloc_Scale_unit.bit_alloc_write_data);
//		if ((Audio_Decoder.Decode_Bitalloc_Scale_unit.state == `MP2_BITALLOC_DECODE) | (Audio_Decoder.Decode_Bitalloc_Scale_unit.state == `MP2_BITALLOC_FINISH)) begin
//			$write("i: %d, j: %d, addr: %x, data: %x\n", 
//				Audio_Decoder.Decode_Bitalloc_Scale_unit.bit_alloc_address[6:2], 
//				Audio_Decoder.Decode_Bitalloc_Scale_unit.bit_alloc_address[1], 
//				Audio_Decoder.Decode_Bitalloc_Scale_unit.bit_alloc_address, 
//				Audio_Decoder.Decode_Bitalloc_Scale_unit.bit_alloc_write_data);
//		end else if (Audio_Decoder.Decode_Bitalloc_Scale_unit.state == `MP2_SCALE_INDEX) begin
//			if (Audio_Decoder.Decode_Bitalloc_Scale_unit.counter[1:0] == 2'h1) 
//				$write("scale_index[%d][0..2][%d] = %x ", 
//					Audio_Decoder.Decode_Bitalloc_Scale_unit.bit_alloc_address[1], 
//					Audio_Decoder.Decode_Bitalloc_Scale_unit.bit_alloc_address[7:2],
//					Audio_Decoder.Decode_Bitalloc_Scale_unit.bit_alloc_write_data[7:0]);
//			else if (Audio_Decoder.Decode_Bitalloc_Scale_unit.counter[1:0] == 2'h3)
//				$write("%x %x\n", 
//					Audio_Decoder.Decode_Bitalloc_Scale_unit.bit_alloc_write_data[15:8],
//					Audio_Decoder.Decode_Bitalloc_Scale_unit.bit_alloc_write_data[7:0]);
//		end
//	end
//	if (Audio_Decoder.Decode_Bitalloc_Scale_unit.scfsi_write_en) begin
////		$write("SCFSI_WEN %x %x - ", 
////			Audio_Decoder.Decode_Bitalloc_Scale_unit.scfsi_address,
////			Audio_Decoder.Decode_Bitalloc_Scale_unit.scfsi_write_data);
//		$write("%x : %x %x %x %x %x %x %x %x\n", 
//			Audio_Decoder.Decode_Bitalloc_Scale_unit.scfsi_address,
//			Audio_Decoder.Decode_Bitalloc_Scale_unit.scfsi_write_data[15:14],
//			Audio_Decoder.Decode_Bitalloc_Scale_unit.scfsi_write_data[13:12],
//			Audio_Decoder.Decode_Bitalloc_Scale_unit.scfsi_write_data[11:10],
//			Audio_Decoder.Decode_Bitalloc_Scale_unit.scfsi_write_data[9:8],
//			Audio_Decoder.Decode_Bitalloc_Scale_unit.scfsi_write_data[7:6],
//			Audio_Decoder.Decode_Bitalloc_Scale_unit.scfsi_write_data[5:4],
//			Audio_Decoder.Decode_Bitalloc_Scale_unit.scfsi_write_data[3:2],
//			Audio_Decoder.Decode_Bitalloc_Scale_unit.scfsi_write_data[1:0]);
//	end
//end
`endif

`ifdef PCM_VALIDATE
integer ref_file;
integer mismatches;
//integer frame_counter;
integer scale_block_counter;
integer block_counter;
integer total_sample_counter;

initial begin 
	total_sample_counter = 0;
	frame_counter = -1;
	mismatches = 0;
	ref_file = $fopen("software/matrix_small_2_FIX16.pcm", "rb");
//	ref_file = $fopen("matrix_small_2.pcm", "rb");
end
	
always @(posedge clock) begin
	if (Audio_Decoder.Header_start) begin
		frame_counter = frame_counter + 1;
		$write("Frame %d start - %d mismatches\n", 
			frame_counter, mismatches);
		scale_block_counter = 0;
		block_counter = 0;
	end
end

task pcm_compare; 
	integer i;
	reg [15:0] ref_sample, abs_dif;
begin	
	for (i = 0; i < 32; i = i + 1) begin
		// left sample
		ref_sample[15:8] = $fgetc(ref_file);
		ref_sample[7:0] = $fgetc(ref_file);
		abs_dif = (samples[0][i] > ref_sample) ? 
			samples[0][i] - ref_sample : 
			ref_sample - samples[0][i]; 
		if (abs_dif != 0) mismatches = mismatches + 1;
		if (abs_dif > 2) 
			$write("mismatch on frame %d, scaleblock %d, block %d, sample %d L (%d) : got %x expect %x\n", 
				frame_counter, scale_block_counter, block_counter, 
				i, total_sample_counter, samples[0][i], ref_sample);
		total_sample_counter = total_sample_counter + 1;

		// right sample
		ref_sample[15:8] = $fgetc(ref_file);
		ref_sample[7:0] = $fgetc(ref_file);
		abs_dif = (samples[1][i] > ref_sample) ? 
			samples[1][i] - ref_sample : 
			ref_sample - samples[1][i]; 
		if (abs_dif != 0) mismatches = mismatches + 1;
		if (abs_dif > 2) 
			$write("mismatch on frame %d, scaleblock %d, block %d, sample %d R (%d) : got %x expect %x\n", 
				frame_counter, scale_block_counter, block_counter, 
				i, total_sample_counter, samples[1][i], ref_sample);
		total_sample_counter = total_sample_counter + 1;
	end

	if (block_counter == 2) begin
		scale_block_counter = scale_block_counter + 1;
		block_counter = 0;
	end else block_counter = block_counter + 1;
	
end endtask
`endif

task AIFF_header; begin
/*
	$fwrite(outfile, "%02h %02h %02h %02h %02h %02h %02h %02h ",
		8'h46, 8'h4f, 8'h52, 8'h4d, 8'h00, 8'h96, 8'h30, 8'h22);
	$fwrite(outfile, "%02h %02h %02h %02h %02h %02h %02h %02h\n",
		8'h41, 8'h49, 8'h46, 8'h46, 8'h43, 8'h4f, 8'h4d, 8'h4d); 
	$fwrite(outfile, "%02h %02h %02h %02h %02h %02h %02h %02h ",
		8'h00, 8'h00, 8'h00, 8'h12, 8'h00, 8'h02, 8'h00, 8'h25);
	$fwrite(outfile, "%02h %02h %02h %02h %02h %02h %02h %02h\n",
		8'h8c, 8'h00, 8'h00, 8'h10, 8'h40, 8'h0e, 8'hac, 8'h44);
	$fwrite(outfile, "%02h %02h %02h %02h %02h %02h %02h %02h ",
		8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h53, 8'h53); 
	$fwrite(outfile, "%02h %02h %02h %02h %02h %02h %02h %02h\n\n",
		8'h4e, 8'h44, 8'h00, 8'h96, 8'h30, 8'h08, 8'h00, 8'h00);
/**/
	$fwrite(outfile, "%02h %02h %02h %02h %02h %02h %02h %02h ",
		8'h46, 8'h4f, 8'h52, 8'h4d, 8'h00, 8'h6e, 8'h0a, 8'h22);
	$fwrite(outfile, "%02h %02h %02h %02h %02h %02h %02h %02h\n",
		8'h41, 8'h49, 8'h46, 8'h46, 8'h43, 8'h4f, 8'h4d, 8'h4d); 
	$fwrite(outfile, "%02h %02h %02h %02h %02h %02h %02h %02h ",
		8'h00, 8'h00, 8'h00, 8'h12, 8'h00, 8'h02, 8'h00, 8'h1b);
	$fwrite(outfile, "%02h %02h %02h %02h %02h %02h %02h %02h\n",
		8'h82, 8'h80, 8'h00, 8'h10, 8'h40, 8'h0e, 8'hbb, 8'h80);
	$fwrite(outfile, "%02h %02h %02h %02h %02h %02h %02h %02h ",
		8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h53, 8'h53); 
	$fwrite(outfile, "%02h %02h %02h %02h %02h %02h %02h %02h\n\n",
		8'h4e, 8'h44, 8'h00, 8'h6e, 8'h0a, 8'h08, 8'h00, 8'h00);
/**/
end endtask

endmodule
/*
module DP_model(
	clock,
	addr_A,
	addr_B,
	en_A,
	en_B,
	read_data_A,
	read_data_B,
	wen_A,
	wen_B,
	write_data_A,
	write_data_B
);

input 				clock;
input 	[9:0] 	addr_A;
input 	[9:0] 	addr_B;
input 				en_A;
input 				en_B;
output	[15:0] 	read_data_A;
output	[15:0] 	read_data_B;
input 				wen_A;
input 				wen_B;
input 	[15:0] 	write_data_A;
input 	[15:0] 	write_data_B;

reg		[15:0] 	read_data_A_reg;
reg		[15:0] 	read_data_B_reg;
reg 		[15:0]	memory	[1023:0];

reg 					en_A_dly, en_B_dly;
reg 		[15:0]	read_data_A_dly;
reg 		[15:0]	read_data_B_dly;

always @(posedge clock) begin
	read_data_A_reg <= memory[addr_A];
	if (wen_A) memory[addr_A] <= write_data_A;
	read_data_B_reg <= memory[addr_B];
	if (wen_B) memory[addr_B] <= write_data_B;
	
	en_A_dly <= en_A; en_B_dly <= en_B;
	if (en_A) read_data_A_dly <= read_data_A_reg; 
	if (en_B) read_data_B_dly <= read_data_B_reg; 
end

assign read_data_A = (en_A_dly) ? read_data_A_reg : read_data_A_dly;
assign read_data_B = (en_B_dly) ? read_data_B_reg : read_data_B_dly;

endmodule

module FXP_MULT(A, B, P);

input 	[31:0] 	A, B;
output 	[63:0]   P;

wire 		[30:0] 	A_abs, B_abs;
wire 		[17:0] 	AH, AL, BH, BL;
wire 		[35:0] 	AHBH, AHBL, ALBH, ALBL;

assign A_abs = A[31] ? -A : A;
assign B_abs = B[31] ? -B : B;

assign AH = {3'b000, A_abs[30:16]};
assign BH = {3'b000, B_abs[30:16]};
assign AL = {2'b00, A_abs[15:0]};
assign BL = {2'b00, B_abs[15:0]};
//assign AL = 18'h00000;
//assign BL = 18'h00000;

MULT18X18 fixed_point_mult_HH ( 
   .P(AHBH), .A(AH), .B(BH));

MULT18X18 fixed_point_mult_HL( 
   .P(AHBL), .A(AH), .B(BL));

MULT18X18 fixed_point_mult_LH ( 
   .P(ALBH), .A(AL), .B(BH));

MULT18X18 fixed_point_mult_LL( 
   .P(ALBL), .A(AL), .B(BL));

wire 		[63:0] 	P_long, P_sign;

assign P_long = 
	{AHBH[31:0], 32'h00000000} + 
	{16'h0000, AHBL[31:0], 16'h0000} + 
	{16'h0000, ALBH[31:0], 16'h0000} + 
	{32'h00000000, ALBL[31:0]};
assign P_sign = (A[31] ^ B[31]) ? -P_long : P_long;

assign P = P_sign; 
//assign P = (A[31] ^ B[31]) ? 
//	(P_sign | 64'h0000FFFFFFFFFFFF) : (P_sign & 64'hFFFF000000000000); 

endmodule
*/
