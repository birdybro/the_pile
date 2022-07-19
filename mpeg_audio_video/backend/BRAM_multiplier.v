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
module BRAM_multiplier(operand_in, coefficient_in, a_out, b_out, sign_out);
	input [15:0]	operand_in;
	input [5:0]		coefficient_in;
	output [15:0]	a_out;
	output [15:0]	b_out;
	output 			sign_out;

	// Split up input signal
	wire [7:0]		a_in;
	wire [7:0]		b_in;
	assign a_in = operand_in [15:8];
	assign b_in = operand_in [7:0];

	// Create intermediate shifts
	wire [8:0]		a2;
	wire [9:0]		a4;
	wire [10:0]		a8;
	wire [11:0]		a16;
	wire [12:0]		a32;
	assign a2 = a_in << 1;
	assign a4 = a_in << 2;
	assign a8 = a_in << 3;
	assign a16 = a_in << 4;
	assign a32 = a_in << 5;
	wire [8:0]		b2;
	wire [9:0]		b4;
	wire [10:0]		b8;
	wire [11:0]		b16;
	wire [12:0]		b32;
	assign b2 = b_in << 1;
	assign b4 = b_in << 2;
	assign b8 = b_in << 3;
	assign b16 = b_in << 4;
	assign b32 = b_in << 5;

	wire [11:0]		a_a;
	wire [12:0]		a_b;
	wire [7:0]		a_c;
	wire [11:0]		b_a;
	wire [12:0]		b_b;
	wire [7:0]		b_c;
	
	wire [13:0]		a_result_a;
	wire [14:0]		a_result_b;
	wire [13:0]		b_result_a;
	wire [14:0]		b_result_b;

	assign a_a = coefficient_in[4] ? a2 : coefficient_in[3] ? a16 : 0;
	assign a_b = (coefficient_in[2:1] == 2'b10) ? a4 
						: (coefficient_in[2:1] == 2'b01) ? a8 
						: (coefficient_in[2:1] == 2'b11) ? a32 : 0;
	assign a_c = coefficient_in[0] ? a_in : 0;
	assign b_a = coefficient_in[4] ? b2 : coefficient_in[3] ? b16 : 0;
	assign b_b = (coefficient_in[2:1] == 2'b10) ? b4 
						: (coefficient_in[2:1] == 2'b01) ? b8 
						: (coefficient_in[2:1] == 2'b11) ? b32 : 0;
	assign b_c = coefficient_in[0] ? b_in : 0;

	assign a_result_a = a_b + a_c;
	assign a_result_b = a_result_a + a_a;
	assign b_result_a = b_b + b_c;
	assign b_result_b = b_result_a + b_a;
	
	assign a_out = a_result_b;
	assign b_out = b_result_b;
	
	assign sign_out = coefficient_in[5];
endmodule
