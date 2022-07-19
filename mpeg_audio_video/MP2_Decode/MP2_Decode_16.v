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
output 	[4:0]		Shift_En_O;

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

reg 					Header_start, DBS_start, BDD_start, Synth_start;
wire 					Header_done, DBS_done, BDD_done, Synth_done;
wire 		[1:0]		Header_shift;
wire 				 	DBS_shift;
wire 					BDD_shift;

wire 		[4:0] 	alloc_index_i, DBS_alloc_index_i, BDD_alloc_index_i;
wire 		[3:0] 	alloc_index_j, DBS_alloc_index_j, BDD_alloc_index_j;
wire 		[3:0] 	alloc_steps_MSB;
wire 		[15:0] 	alloc_steps;
wire 		[4:0] 	alloc_bits;
wire 		[2:0] 	alloc_group;
wire 		[4:0] 	alloc_quant;
wire 					alloc_ROM_en;
wire 		[9:0]		alloc_ROM_addr;
wire 		[15:0]	alloc_ROM_data;

wire 					const_ROM_en;
wire 		[9:0]		const_ROM_address;
wire 		[15:0]	const_ROM_data;
wire 		[9:0]		sample_RAM_address;
wire 		[15:0]	sample_RAM_read_data;
wire 					sample_RAM_wen;
wire 		[15:0]	sample_RAM_write_data;

wire 		[15:0]	DBS_table_data, BDD_table_data;
wire 					DBS_ROM_en, BDD_ROM_en, Synth_ROM_en;
wire 		[9:0]		DBS_ROM_address, BDD_ROM_address, Synth_ROM_address;
wire 		[9:0]		DBS_RAM_address, BDD_RAM_address, Synth_RAM_address;
wire 					DBS_RAM_wen, BDD_RAM_wen;
wire 		[15:0]	DBS_RAM_write_data, BDD_RAM_write_data;

wire 		[17:0] 	BDD_Mult_OP_0, BDD_Mult_OP_1;
wire 		[17:0] 	Synth_Mult_OP_0, Synth_Mult_OP_1;
wire 		[17:0] 	Mult_OP_0, Mult_OP_1;
wire 		[35:0] 	Mult_Result;
wire 		[31:0] 	Synth_data;
wire 		[4:0]		Synth_address;

wire 		[2:0] 	table_num;
wire		[4:0] 	JS_bound;
wire  	[4:0] 	SB_limit;
reg  		[3:0] 	Scale_block;
reg 		[2:0] 	Synth_counter;
reg 					Sample_DP_full;

reg 		[2:0] 	state;

assign Shift_En_O[4:2] = 3'h0;
assign Shift_En_O[1] = Header_shift[1];
assign Shift_En_O[0] = 
	(state == `MP2_DECODE_HEADER) ? Header_shift[0] : 
	(state == `MP2_DECODE_SCALE) ? DBS_shift : BDD_shift;
		
assign alloc_index_i = (state == `MP2_DECODE_SCALE) ? DBS_alloc_index_i : BDD_alloc_index_i;
assign alloc_index_j = (state == `MP2_DECODE_SCALE) ? DBS_alloc_index_j : BDD_alloc_index_j;

assign JS_bound = SB_limit;

assign Decode_Done_O = (state == `MP2_DECODE_IDLE);

always @(posedge audio_decoder_clock or negedge resetn) begin
	if (~resetn) begin
		state <= `MP2_DECODE_IDLE;
		Header_start <= 1'b0;
		DBS_start <= 1'b0;
		BDD_start <= 1'b0;
		Synth_start <= 1'b0;
		Scale_block <= 4'h0;
		Synth_counter <= 3'h0;
		Header_found <= 1'b0;
	end else begin
		case (state) 
			`MP2_DECODE_IDLE : begin
					if (Decode_Start_I) begin
						state <= `MP2_DECODE_HEADER;
						Header_start <= 1'b1;
					end
				end
			`MP2_DECODE_HEADER : begin
					Header_start <= 1'b0;
					if (Header_done & ~Header_start) begin
						Header_found <= 1'b1;
						state <= `MP2_DECODE_SCALE;
						DBS_start <= 1'b1;			
					end
				end
			`MP2_DECODE_SCALE : begin
					DBS_start <= 1'b0;
					if (DBS_done & ~DBS_start) begin
						state <= `MP2_DECODE_BUFFER;
						BDD_start <= 1'b1;
						Scale_block <= 4'h0;
					end
				end
			`MP2_DECODE_BUFFER : begin
					BDD_start <= 1'b0;
					if (BDD_done & ~BDD_start) begin
						state <= `MP2_DECODE_CHECK_FILL;
						Synth_counter <= 3'h0;
					end
				end
			`MP2_DECODE_CHECK_FILL : begin
					if (~Sample_DP_full) begin
						state <= `MP2_DECODE_SYNTH;
						Synth_start <= 1'b1;
					end
				end
			`MP2_DECODE_SYNTH : begin
					Synth_start <= 1'b0;
					if (Synth_done & ~Synth_start) begin
						if (Synth_counter == 3'h5) begin
							if (Scale_block == 4'd11) begin
								state <= `MP2_DECODE_HEADER;
								Header_start <= 1'b1;
							end
							else begin
								Scale_block <= Scale_block + 1;
								BDD_start <= 1'b1;
								state <= `MP2_DECODE_BUFFER;
							end
						end else begin
							Synth_counter <= Synth_counter + 1;
							state <= `MP2_DECODE_CHECK_FILL;
						end
					end					
				end
		endcase
	end
end

Decode_Header Decode_Header_unit (
	.clock(audio_decoder_clock),
	.resetn(resetn),
	.Header_Start_I(Header_start),
	.Header_Done_O(Header_done),
	.Sample_Freq_O(),
	.Format_Check_O(),
	.Table_O(table_num),
	.Bitstream_Byte_Allign_I(Bitstream_Byte_Allign_I),
	.Bitstream_Data_I(Bitstream_Data_I),
	.Shift_En_O(Header_shift)
);

Decode_Bitalloc_Scale Decode_Bitalloc_Scale_unit (
	.clock(audio_decoder_clock), 
	.resetn(resetn),	
	.Bitalloc_Start_I(DBS_start),
	.Scale_Done_O(DBS_done),
	.JS_Bound_I(JS_bound),
	.SB_Limit_I(SB_limit),
	.Bitstream_Data_I(Bitstream_Data_I),
	.Shift_Busy_I(Shift_Busy_I),
	.Shift_En_O(DBS_shift),	
	.Alloc_index_i_O(DBS_alloc_index_i),
	.Alloc_index_j_O(DBS_alloc_index_j),
	.Alloc_bits_I(alloc_bits),
	.Table_Enable_I(alloc_ROM_en),
	.Table_Address_I(alloc_ROM_addr),
	.Table_Data_O(DBS_table_data),
	.ROM_Enable_O(DBS_ROM_en),
	.ROM_Address_O(DBS_ROM_address),
	.ROM_Data_I(const_ROM_data),
	.RAM_Address_O(DBS_RAM_address),
	.RAM_Data_I(sample_RAM_read_data),
	.RAM_Wen_O(DBS_RAM_wen),
	.RAM_Data_O(DBS_RAM_write_data)
);

assign alloc_ROM_data = (state == `MP2_DECODE_SCALE) ? DBS_table_data : BDD_table_data;
Bitalloc_Table Alloc_Table(
	.clock(audio_decoder_clock),
	.resetn(resetn), 	
	.Shift_Busy_I(Shift_Busy_I),
	.Table_I(table_num), 
	.index_i_I(alloc_index_i),
	.index_j_I(alloc_index_j),	
	.SB_Limit_O(SB_limit),
	.steps_MSB_O(alloc_steps_MSB),
	.steps_O(alloc_steps),
	.bits_O(alloc_bits),
	.group_O(alloc_group),
	.quant_O(alloc_quant),
	.Table_En_O(alloc_ROM_en),
   .Table_Address_O(alloc_ROM_addr),
   .Table_Data_I(alloc_ROM_data)
);

assign const_ROM_en = 
	(state == `MP2_DECODE_SCALE) ? DBS_ROM_en : 
	(state == `MP2_DECODE_BUFFER) ? BDD_ROM_en :
		Synth_ROM_en;
assign const_ROM_address = 
	(state == `MP2_DECODE_SCALE) ? DBS_ROM_address : 
	(state == `MP2_DECODE_BUFFER) ? BDD_ROM_address :
		Synth_ROM_address;
assign sample_RAM_address = 
	(state == `MP2_DECODE_SCALE) ? DBS_RAM_address : 
	(state == `MP2_DECODE_BUFFER) ? BDD_RAM_address :
		Synth_RAM_address;
assign sample_RAM_wen = (state == `MP2_DECODE_SCALE) ? 
	DBS_RAM_wen : BDD_RAM_wen;
assign sample_RAM_write_data = (state == `MP2_DECODE_SCALE) ? 
	DBS_RAM_write_data : BDD_RAM_write_data;
		
Const_ROM_Sample_RAM Internal_Buffer(
	.clock(audio_decoder_clock),
	.ROM_Enable_I(const_ROM_en),
	.ROM_Address_I(const_ROM_address),
	.ROM_Data_O(const_ROM_data),
	.RAM_Address_I(sample_RAM_address),
	.RAM_Data_O(sample_RAM_read_data),
	.RAM_Wen_I(sample_RAM_wen),
	.RAM_Data_I(sample_RAM_write_data)
);

Buffer_Deq_Denorm Buffer_Deq_Denorm_unit(
	.clock(audio_decoder_clock),
	.resetn(resetn),
	.Buffer_Start_I(BDD_start),
	.Denorm_Done_O(BDD_done),
	.JS_Bound_I(JS_bound),
	.SB_Limit_I(SB_limit),
	.Scale_Block_I(Scale_block),
	.Bitstream_Data_I(Bitstream_Data_I),
	.Shift_Busy_I(Shift_Busy_I),
	.Shift_En_O(BDD_shift),
	.Alloc_index_i_O(BDD_alloc_index_i),
	.Alloc_index_j_O(BDD_alloc_index_j),
	.Alloc_steps_MSB_I(alloc_steps_MSB),
	.Alloc_steps_I(alloc_steps),
	.Alloc_bits_I(alloc_bits),
	.Alloc_group_I(alloc_group),
	.Alloc_quant_I(alloc_quant),
	.Table_Enable_I(alloc_ROM_en),
	.Table_Address_I(alloc_ROM_addr),
	.Table_Data_O(BDD_table_data),
	.ROM_Enable_O(BDD_ROM_en),
	.ROM_Address_O(BDD_ROM_address),
	.ROM_Data_I(const_ROM_data),
	.RAM_Address_O(BDD_RAM_address),
	.RAM_Data_I(sample_RAM_read_data),
	.RAM_Wen_O(BDD_RAM_wen),
	.RAM_Data_O(BDD_RAM_write_data),
	.Mult_OP_0_O(BDD_Mult_OP_0),
	.Mult_OP_1_O(BDD_Mult_OP_1),
	.Mult_Result_I(Mult_Result)
);

wire 	[15:0]	Sample_data;
wire 				Sample_wen;
SubBandSynthesis SubBandSynthesis_unit(
	.clock(audio_decoder_clock),
	.resetn(resetn),
	.Start_Subband_I(Synth_start),
	.Done_Subband_O(Synth_done),
	.ROM_Enable_O(Synth_ROM_en),
	.ROM_Address_O(Synth_ROM_address),
	.ROM_Data_I(const_ROM_data),
	.RAM_Address_O(Synth_RAM_address),
	.RAM_Data_I(sample_RAM_read_data),
	.Sample_Data_O(Sample_data),
	.Sample_Write_En_O(Sample_wen),
	.Subblock_I(Synth_counter[2:1]),
	.Channel_I(Synth_counter[0]),
	.Mult_OP_0_O(Synth_Mult_OP_0),
	.Mult_OP_1_O(Synth_Mult_OP_1),
	.Mult_Result_I(Mult_Result)	
);

assign Mult_OP_0 = (state == `MP2_DECODE_SYNTH) ? Synth_Mult_OP_0 : BDD_Mult_OP_0;
assign Mult_OP_1 = (state == `MP2_DECODE_SYNTH) ? Synth_Mult_OP_1 : BDD_Mult_OP_1;

MULT18X18 Fixed_point_multiplier(.A(Mult_OP_0), .B(Mult_OP_1), .P(Mult_Result));

wire 				audio_bit_clock;

reg 	[10:0]	sample_counter;
wire 	[9:0]		Sample_address;

wire 	[8:0]		PCM_read_address;
wire 	[31:0]	PCM_read_data;
wire 	[15:0]	CH0_PCM_read_data, CH1_PCM_read_data;

reg 				initial_fill;
reg 				write_seg, read_seg, read_seg_12;

IBUFG AUD_FB_BUF(.O(audio_bit_clock), .I(AC97_BIT_CLOCK_I));

// Output sample DPRAMs
assign Sample_address = {
	sample_counter[9:6],
	sample_counter[4:0],
	sample_counter[5] };

RAMB16_S18_S36 PCM_RAM (
	.DOA(),
	.DOPA(),
	.ADDRA(Sample_address),
	.CLKA(audio_decoder_clock),
	.DIA(Sample_data),
	.DIPA(2'b00),
	.ENA(Sample_wen),
	.SSRA(1'b0),
	.WEA(Sample_wen),
	.DOB(PCM_read_data),
	.DOPB(),
	.ADDRB(PCM_read_address),
	.CLKB(audio_bit_clock),
	.DIB(32'h00000000),
	.DIPB(4'b0000),
	.ENB(1'b1),
	.SSRB(1'b0),
	.WEB(1'b0)
);
assign CH0_PCM_read_data = (initial_fill) ? PCM_read_data[15:0] : 16'h0000;
assign CH1_PCM_read_data = (initial_fill) ? PCM_read_data[31:16] : 16'h0000;

reg Audio_sync_adv;
always @(posedge audio_bit_clock or negedge resetn) begin
	if (~resetn) Audio_sync_adv <= 1'b0;
	else Audio_sync_adv <= Audio_Sync_I;
end

// instantiate the AC97 audio controller
ac97_ctr ac97_module (
	.BIT_CLOCK_I(audio_bit_clock),
	.SAMPLE_FREQUENCY_I(SAMPLE_FREQUENCY_I),
	.AC97_RESETN_I(AC97_RESETN_I),
	.SOURCE_SELECT_I(SOURCE_SELECT_I),
	.AC97_SYNCH_O(AC97_SYNCH_O),
	.AC97_DATA_IN_I(AC97_DATA_IN_I),
	.AC97_DATA_OUT_O(AC97_DATA_OUT_O),
	.AC97_BEEP_TONE_O(AC97_BEEP_TONE_O),
	.PCM_READ_ADVANCE_EN_I(initial_fill & Audio_sync_adv),
	.PCM_READ_ADDRESS_O(PCM_read_address),
	.CH0_PCM_DATA_I(CH0_PCM_read_data),
	.CH1_PCM_DATA_I(CH1_PCM_read_data),
	.STARTUP_O(STARTUP_O)
); 	
	
assign Audio_Sync_O = 1'b1; //initial_fill; 
always @(posedge audio_decoder_clock or negedge resetn) begin
	if (~resetn) begin
		initial_fill <= 1'b0;
		read_seg <= 1'b0;
		write_seg <= 1'b0;
		sample_counter <= 11'h000;
		Sample_DP_full <= 1'b0;
	end else begin
		read_seg <= read_seg_12;
		if (Sample_address[0]) write_seg <= Sample_address[9];
		if (Sample_wen)
			sample_counter <= sample_counter + 1;
		if (
			Sample_wen &
			(Sample_address[8:0] == 9'h1FF)
		) Sample_DP_full <= 1'b1;
		if ((read_seg == write_seg) | ~initial_fill) 
			Sample_DP_full <= 1'b0;
		if ((Sample_address == 10'h3FF) & Sample_wen) begin 	//
			initial_fill <= 1'b1;										//
			Sample_DP_full <= 1'b1;
		end
	end
end

always @(posedge audio_bit_clock or negedge resetn) begin
	if (~resetn) read_seg_12 <= 1'b0;
	else read_seg_12 <= PCM_read_address[8];
end

endmodule
