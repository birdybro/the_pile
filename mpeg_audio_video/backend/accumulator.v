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

`timescale 1ns / 1ps
`include "defines.v"
module accumulator(clk, resetn, line_state, data_mode, is_primary, is_topfield, write_first,
						 BRAM_operand, ZBT_operand,
						 done_a, done_b, done_c, done_d);

	input				clk;
	input				resetn;
	input [2:0]		line_state;
	input	[`IS_FOURTWOTWO:`IS_INTERLACED]
						data_mode;
	input				is_primary;
	input				is_topfield;
	input				write_first;
	input [15:0]	BRAM_operand;
	input [31:0]	ZBT_operand;
	output [7:0]	done_a;
	output [7:0]	done_b;
	output [7:0]	done_c;
	output [7:0]	done_d;
	
	reg [17:0]		channela;
	reg [17:0]		channelb;
	reg [17:0]		channelc;
	reg [17:0]		channeld;

	wire [15:0]		buffer_scaler_aout;
	wire [15:0]		buffer_scaler_bout;
	wire				buffer_scaler_signout;

	wire [15:0]		ZBT_scaler_aout;
	wire [15:0]		ZBT_scaler_bout;
	wire [15:0]		ZBT_scaler_cout;
	wire [15:0]		ZBT_scaler_dout;
	wire				ZBT_scaler_signout;
	
	////////////////////////////////////////////////////////////////////////////////////
	// PERFORM ACTUAL ACCUMULATION (MASK AND ADD SIGNALS)										 //
	////////////////////////////////////////////////////////////////////////////////////

	wire [17:0]		masked_channeld;
	assign masked_channeld = {channeld[17:8],((line_state == `S0) | (line_state == `S4)) ? 8'd128 : channeld[7:0]};

	wire [17:0]		intermediate_a;
	wire [17:0]		intermediate_b;
	wire [17:0]		intermediate_c;
	wire [17:0]		intermediate_d;
	
	assign intermediate_a = (ZBT_scaler_signout) ? channela - ZBT_scaler_aout : channela + ZBT_scaler_aout;
	assign intermediate_b = (ZBT_scaler_signout) ? channelb - ZBT_scaler_bout : channelb + ZBT_scaler_bout;
	assign intermediate_c = (ZBT_scaler_signout) ? channelc - ZBT_scaler_cout : channelc + ZBT_scaler_cout;
	assign intermediate_d = (ZBT_scaler_signout) ? masked_channeld - ZBT_scaler_dout : masked_channeld + ZBT_scaler_dout;

	wire even_ls;
	// in even states, channels a and b are scaled, in odd states channels c and d are scaled
	assign even_ls = (line_state == `S0) | (line_state == `S2) | (line_state == `S4) | (line_state == `S6);

	wire [17:0]		scaled_bchannela;
	wire [17:0]		scaled_bchannelb;

	assign scaled_bchannela = (even_ls) ? (buffer_scaler_signout) ? intermediate_a - buffer_scaler_aout 
																					  : intermediate_a + buffer_scaler_aout : 
													  (buffer_scaler_signout) ? intermediate_c - buffer_scaler_aout
																					  : intermediate_c + buffer_scaler_aout;

	assign scaled_bchannelb = (even_ls) ? (buffer_scaler_signout) ? intermediate_b - buffer_scaler_bout 
																					  : intermediate_b + buffer_scaler_bout : 
													  (buffer_scaler_signout) ? intermediate_d - buffer_scaler_bout
																					  : intermediate_d + buffer_scaler_bout;

	wire [17:0]		next_channela;
	wire [17:0]		next_channelb;
	wire [17:0]		next_channelc;
	wire [17:0]		next_channeld;

	assign next_channela = (even_ls) ? scaled_bchannela : intermediate_a;
	assign next_channelb = (even_ls) ? scaled_bchannelb : intermediate_b;
	assign next_channelc = (even_ls) ? intermediate_c : scaled_bchannela;
	assign next_channeld = (even_ls) ? intermediate_d : scaled_bchannelb;

	////////////////////////////////////////////////////////////////////////////////////
	// CLIP ACCUMULATOR FOR VERTICAL INTERPOLATION												 //
	////////////////////////////////////////////////////////////////////////////////////
	
	wire [7:0] clipped_d;
	
	assign done_a = next_channela[17] ? 0 : next_channela[16] ? 255 : (next_channela >> 8);
	assign done_b = next_channelb[17] ? 0 : next_channelb[16] ? 255 : (next_channelb >> 8);	
	assign done_c = next_channelc[17] ? 0 : next_channelc[16] ? 255 : (next_channelc >> 8);	
	assign clipped_d = next_channeld[17] ? 0 : next_channeld[16] ? 255 : (next_channeld >> 8);	
	assign done_d = channeld[7:0];

	////////////////////////////////////////////////////////////////////////////////////
	// ACCUMULATOR REGISTER CONTROL																	 //
	////////////////////////////////////////////////////////////////////////////////////

	always @(posedge clk or negedge resetn) begin
		if (~resetn) begin
			channela <= 18'd128;
			channelb <= 18'd128;
			channelc <= 18'd128;
			channeld <= 18'd128;
		end else begin
			if ((line_state == `S3) | (line_state == `S7)) begin
				channela <= 18'd128;
				channelb <= 18'd128;
				channelc <= 18'd128;
				channeld <= {10'd0,clipped_d};
			end else begin
				channela <= next_channela;
				channelb <= next_channelb;
				channelc <= next_channelc;
				channeld <= next_channeld;
			end
		end
	end

	////////////////////////////////////////////////////////////////////////////////////
	// GENERATE COEFFICIENTS AND PERFORM MULTIPLICATIONS										 //
	////////////////////////////////////////////////////////////////////////////////////

	wire [5:0]		buffer_scaler_coefficient;
	wire [8:0]		ZBT_scaler_coefficient;
	wire 				is_interlaced;
	assign is_interlaced = data_mode[`IS_INTERLACED];

	assign buffer_scaler_coefficient = data_mode[`IS_FOURTWOTWO] ? `BRAM_times_0 : 
												  // Row jm2
												  (write_first ? (`LS_26 | `LS_37) : (`LS_04 | `LS_15)) ? 
														(is_primary & is_interlaced & is_topfield) ? `BRAM_times_neg7 : 
														(~is_primary & is_interlaced & is_topfield) ? `BRAM_times_7 : 
														(is_primary & is_interlaced & ~is_topfield) ? `BRAM_times_neg24 :
														(~is_primary & is_interlaced & ~is_topfield) ? `BRAM_times_5 :
														(is_primary & ~is_interlaced) ? `BRAM_times_neg16 :
														/*(~is_primary & ~is_interlaced) ?*/ `BRAM_times_7 :
												  // Row 0
												  (write_first ? (`LS_04 | `LS_15) : (`LS_26 | `LS_37)) ? 
														(is_primary & is_interlaced & is_topfield) ? `BRAM_times_1 : 
														(~is_primary & is_interlaced & is_topfield) ? `BRAM_times_neg35 : 
														(is_primary & is_interlaced & ~is_topfield) ? `BRAM_times_4 :
														(~is_primary & is_interlaced & ~is_topfield) ? `BRAM_times_neg21 :
														(is_primary & ~is_interlaced) ? `BRAM_times_3 :
														/*(~is_primary & ~is_interlaced) ?*/ `BRAM_times_neg32 : 
													`BRAM_times_1;
	
	assign ZBT_scaler_coefficient = data_mode[`IS_FOURTWOTWO] ? `ZBT_times_64 : 
											  // Row 3
											  `LS_15 ? (is_primary & is_interlaced & is_topfield) ? `ZBT_times_248 : 
														  (~is_primary & is_interlaced & is_topfield) ? `ZBT_times_110 : 
														  (is_primary & is_interlaced & ~is_topfield) ? `ZBT_times_194 :
														  (~is_primary & is_interlaced & ~is_topfield) ? `ZBT_times_30 :
														  (is_primary & ~is_interlaced) ? `ZBT_times_227 :
														/*(~is_primary & ~is_interlaced) ?*/ `ZBT_times_67 :
											  // Row 5
											  `LS_37 ? (is_primary & is_interlaced & is_topfield) ? `ZBT_times_5 : 
														  (~is_primary & is_interlaced & is_topfield) ? `ZBT_times_4 : 
														  (is_primary & is_interlaced & ~is_topfield) ? `ZBT_times_7 :
														  (~is_primary & is_interlaced & ~is_topfield) ? `ZBT_times_1 :
														  (is_primary & ~is_interlaced) ? `ZBT_times_7 :
														/*(~is_primary & ~is_interlaced) ?*/ `ZBT_times_3 :
											  // Row 2
											  (write_first ? `LS_04 : `LS_26)
														? (is_primary & is_interlaced & is_topfield) ? `ZBT_times_30 : 
														  (~is_primary & is_interlaced & is_topfield) ? `ZBT_times_194 : 
														  (is_primary & is_interlaced & ~is_topfield) ? `ZBT_times_110 :
														  (~is_primary & is_interlaced & ~is_topfield) ? `ZBT_times_248 :
														  (is_primary & ~is_interlaced) ? `ZBT_times_67 :
														/*(~is_primary & ~is_interlaced) ?*/ `ZBT_times_227 :
											  // Row 4
											  (write_first ? `LS_26 : `LS_04)
														? (is_primary & is_interlaced & is_topfield) ? `ZBT_times_neg21 : 
														  (~is_primary & is_interlaced & is_topfield) ? `ZBT_times_neg24 : 
														  (is_primary & is_interlaced & ~is_topfield) ? `ZBT_times_neg35 :
														  (~is_primary & is_interlaced & ~is_topfield) ? `ZBT_times_neg7 :
														  (is_primary & ~is_interlaced) ? `ZBT_times_neg32 :
														/*(~is_primary & ~is_interlaced) ?*/ `ZBT_times_neg16 :
											  `ZBT_times_0;	
	
	BRAM_multiplier buffer_scaler (
		.operand_in(BRAM_operand),
		.coefficient_in(buffer_scaler_coefficient),
		.a_out(buffer_scaler_aout),
		.b_out(buffer_scaler_bout),
		.sign_out(buffer_scaler_signout));

	ZBT_multiplier ZBT_scaler (
		.operand_in(ZBT_operand),
		.coefficient_in(ZBT_scaler_coefficient),
		.a_out(ZBT_scaler_aout), 
		.b_out(ZBT_scaler_bout), 
		.c_out(ZBT_scaler_cout), 
		.d_out(ZBT_scaler_dout), 
		.sign_out(ZBT_scaler_signout));
endmodule
