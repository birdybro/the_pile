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
module ZBT_multiplier(operand_in, coefficient_in, a_out, b_out, c_out, d_out, sign_out);
	input [31:0]	operand_in;
	input [8:0]		coefficient_in;
	output [15:0]	a_out;
	output [15:0]	b_out;
	output [15:0]	c_out;
	output [15:0]	d_out;
	output			sign_out;
	
	assign sign_out = coefficient_in[8];
	
	wire [7:0]		a;
	wire [8:0]		a2;
	wire [9:0]		a4;
	wire [10:0]		a8;
	wire [11:0]		a16;
	wire [12:0]		a32;
	wire [13:0]		a64;
	wire [14:0]		a128;
	
	wire [15:0]		a_int1;
	wire [15:0]		a_int2;
	wire [15:0]		a_int3;
	wire [15:0]		a_int4;
	
	assign a = (coefficient_in[0]) ? operand_in[31:24] : 0;
	assign a2 = (coefficient_in[1]) ? operand_in[31:24] << 1 : 0;
	assign a4 = (coefficient_in[2]) ? operand_in[31:24] : 0;
	assign a8 = (coefficient_in[3]) ? operand_in[31:24] << 1 : 0;
	assign a16 = (coefficient_in[4]) ? operand_in[31:24] : 0;
	assign a32 = (coefficient_in[5]) ? operand_in[31:24] << 1 : 0;
	assign a64 = (coefficient_in[6]) ? operand_in[31:24] : 0;
	assign a128 = (coefficient_in[7]) ? operand_in[31:24] << 1 : 0;
	
	assign a_int1 = a + a2;
	assign a_int2 = (a4 + a8) << 2;
	assign a_int3 = a16 + a32;
	assign a_int4 = (a64 + a128) << 2;
	assign a_out = a_int1 + a_int2 + ((a_int3 + a_int4) << 4);
	
	wire [7:0]		b;
	wire [8:0]		b2;
	wire [9:0]		b4;
	wire [10:0]		b8;
	wire [11:0]		b16;
	wire [12:0]		b32;
	wire [13:0]		b64;
	wire [14:0]		b128;
	
	wire [15:0]		b_int1;
	wire [15:0]		b_int2;
	wire [15:0]		b_int3;
	wire [15:0]		b_int4;
	
	assign b = (coefficient_in[0]) ? operand_in[23:16] : 0;
	assign b2 = (coefficient_in[1]) ? operand_in[23:16] << 1 : 0;
	assign b4 = (coefficient_in[2]) ? operand_in[23:16] : 0;
	assign b8 = (coefficient_in[3]) ? operand_in[23:16] << 1 : 0;
	assign b16 = (coefficient_in[4]) ? operand_in[23:16] : 0;
	assign b32 = (coefficient_in[5]) ? operand_in[23:16] << 1 : 0;
	assign b64 = (coefficient_in[6]) ? operand_in[23:16] : 0;
	assign b128 = (coefficient_in[7]) ? operand_in[23:16] << 1 : 0;
	
	assign b_int1 = b + b2;
	assign b_int2 = (b4 + b8) << 2;
	assign b_int3 = b16 + b32;
	assign b_int4 = (b64 + b128) << 2;
	assign b_out = b_int1 + b_int2 + ((b_int3 + b_int4) << 4);

	wire [7:0]		c;
	wire [8:0]		c2;
	wire [9:0]		c4;
	wire [10:0]		c8;
	wire [11:0]		c16;
	wire [12:0]		c32;
	wire [13:0]		c64;
	wire [14:0]		c128;
	
	wire [15:0]		c_int1;
	wire [15:0]		c_int2;
	wire [15:0]		c_int3;
	wire [15:0]		c_int4;
	
	assign c = (coefficient_in[0]) ? operand_in[15:8] : 0;
	assign c2 = (coefficient_in[1]) ? operand_in[15:8] << 1 : 0;
	assign c4 = (coefficient_in[2]) ? operand_in[15:8] : 0;
	assign c8 = (coefficient_in[3]) ? operand_in[15:8] << 1 : 0;
	assign c16 = (coefficient_in[4]) ? operand_in[15:8] : 0;
	assign c32 = (coefficient_in[5]) ? operand_in[15:8] << 1 : 0;
	assign c64 = (coefficient_in[6]) ? operand_in[15:8] : 0;
	assign c128 = (coefficient_in[7]) ? operand_in[15:8] << 1 : 0;
	
	assign c_int1 = c + c2;
	assign c_int2 = (c4 + c8) << 2;
	assign c_int3 = c16 + c32;
	assign c_int4 = (c64 + c128) << 2;
	assign c_out = c_int1 + c_int2 + ((c_int3 + c_int4) << 4);

	wire [7:0]		d;
	wire [8:0]		d2;
	wire [9:0]		d4;
	wire [10:0]		d8;
	wire [11:0]		d16;
	wire [12:0]		d32;
	wire [13:0]		d64;
	wire [14:0]		d128;
	
	wire [15:0]		d_int1;
	wire [15:0]		d_int2;
	wire [15:0]		d_int3;
	wire [15:0]		d_int4;
	
	assign d = (coefficient_in[0]) ? operand_in[7:0] : 0;
	assign d2 = (coefficient_in[1]) ? operand_in[7:0] << 1 : 0;
	assign d4 = (coefficient_in[2]) ? operand_in[7:0] : 0;
	assign d8 = (coefficient_in[3]) ? operand_in[7:0] << 1 : 0;
	assign d16 = (coefficient_in[4]) ? operand_in[7:0] : 0;
	assign d32 = (coefficient_in[5]) ? operand_in[7:0] << 1 : 0;
	assign d64 = (coefficient_in[6]) ? operand_in[7:0] : 0;
	assign d128 = (coefficient_in[7]) ? operand_in[7:0] << 1 : 0;
	
	assign d_int1 = d + d2;
	assign d_int2 = (d4 + d8) << 2;
	assign d_int3 = d16 + d32;
	assign d_int4 = (d64 + d128) << 2;
	assign d_out = d_int1 + d_int2 + ((d_int3 + d_int4) << 4);
endmodule