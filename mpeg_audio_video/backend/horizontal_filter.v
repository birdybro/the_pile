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
module horizontal_filter(MPEG2_flag, im3, im2, im1, i, ip1, ip2, out_im1, out_i);
	input				MPEG2_flag;
	input [7:0]		im3;
	input [7:0] 	im2;
	input [7:0] 	im1;
	input [7:0]		i;
	input [7:0] 	ip1;
	input [7:0]		ip2;
	output [7:0]	out_im1;
	output [7:0]	out_i;

	///////////////////////////////////////////////////////////////////////////////
	// MULTIPLIER FOR IM3 AND IP2
	///////////////////////////////////////////////////////////////////////////////
	wire [10:0]		im3x5;
	wire [12:0]		im3xka;
	wire [11:0]		im3xkb;
	wire [10:0]		ip2x5;
	wire [12:0]		ip2xka;
	wire [11:0]		ip2xkb;

	assign im3x5 = im3 + (im3 << 2);
	assign im3xka = im3 + ((MPEG2_flag) ? (im3x5 << 2) : (im3x5 << 1));
	assign im3xkb = /*(MPEG2_flag) ? 0 :*/ im3x5;
	
	assign ip2x5 = ip2 + (ip2 << 2);
	assign ip2xka = ip2x5 + ((MPEG2_flag) ? (ip2 << 4) : 0);
	assign ip2xkb = /*(MPEG2_flag) ? 0 :*/ (ip2x5 << 1) + ip2;

	///////////////////////////////////////////////////////////////////////////////
	// MULTIPLIER FOR IM2 AND IP1
	///////////////////////////////////////////////////////////////////////////////
	wire [10:0]		im2x5;
	wire [13:0]		im2xka;
	wire [12:0]		im2xkb;
	wire [10:0]		ip1x5;
	wire [12:0]		ip1xka_intermediate;
	wire [13:0]		ip1xka;
	wire [13:0]		ip1xkb;

	assign im2x5 = im2 + (im2 << 2);
	assign im2xka = (im2 << 5) + ((MPEG2_flag) ? (im2x5 << 2) : im2x5);
	assign im2xkb = /*(MPEG2_flag) ? 0 :*/ (im2 << 4) + im2x5;
	
	assign ip1x5 = ip1 + (ip1 << 2);
	assign ip1xka_intermediate = (ip1 << 4) + ((MPEG2_flag) ? (ip1x5 << 1) : ip1x5); 
	assign ip1xka = (MPEG2_flag) ? (ip1xka_intermediate << 1) : ip1xka_intermediate;
	assign ip1xkb = /*(MPEG2_flag) ? 0 :*/ (ip1 << 5) + ip1x5; // times_37
	
	///////////////////////////////////////////////////////////////////////////////
	// MULTIPLIER FOR IM1 AND I
	///////////////////////////////////////////////////////////////////////////////
	
	wire [10:0]	im1x5;
	wire [12:0] im1x17;
	wire [15:0]	im1xka;
	wire [14:0]	im1xkb;
	
	assign im1x5 = im1 + (im1 << 2);
	assign im1x17 = im1 + (im1 << 4);
	assign im1xka = (MPEG2_flag) ? (im1x5 << 5) - im1 : (im1x5 << 5) + (im1x17 << 2);
	assign im1xkb = (im1x17 << 2) + (im1 << 1);
	
	wire [10:0]	ix5;
	wire [12:0]	ix17;
	wire [15:0] ixka;
	wire [15:0] ixkb;
	
	assign ix5 = i + (i << 2);
	assign ix17 = i + (i << 4);
	assign ixka = (MPEG2_flag) ? (ix5 << 5) - i : (ix17 << 2) + (i << 1);
	assign ixkb = (ix5 << 5) + (ix17 << 2);
	
	///////////////////////////////////////////////////////////////////////////////
	// FILTER
	///////////////////////////////////////////////////////////////////////////////

	wire [17:0] unclipped_out_im1;
	wire [17:0] unclipped_out_i;
	
	assign unclipped_out_im1 = (im3xka - im2xka) + (im1xka + ixka) + (ip2xka - ip1xka) + 128;
	assign unclipped_out_i = (im3xkb - im2xkb) + (im1xkb + ixkb) + (ip2xkb - ip1xkb) + 128;
	
	assign out_im1 = unclipped_out_im1[17] ? 0 : 
							(unclipped_out_im1[16]/* | unclipped_out_im1[15]*/) ? 255 : 
							(unclipped_out_im1 >> 8);
	assign out_i = (MPEG2_flag) ? i : 
							unclipped_out_i[17] ? 0 : 
							(unclipped_out_i[16]/* | unclipped_out_i[15]*/) ? 255 : 
							(unclipped_out_i >> 8);
endmodule
