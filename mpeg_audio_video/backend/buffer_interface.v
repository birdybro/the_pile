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
module buffer_interface(clk, 
								resetn,
								line_state,

								vbuf_addr,
								vbuf_dataout,
								vbuf_we,

								ZBT_datain,
								
								ybuf_addr,
								ybuf_we,

								obuf_datain,
								hbuf_datain,
								hbuf_dataout,
//								obuf_we,
								
								y_out,
								cr_out,
								cb_out
								);
								
	input 			clk;
	input				resetn;
	input [2:0]		line_state;
		
	// virutal port for vertical interpolation
	input [10:0]	vbuf_addr;	// 10 specifies bank, 9:1 specifices addr, 0 specifies pair in addr
	output [15:0]	vbuf_dataout;
	input				vbuf_we;
	
	input [31:0]	ZBT_datain;

	// virtual port for y buffering
	input [9:0]		ybuf_addr;  // 8:2 specifies addr, 1:0 specifies element in addr
	input				ybuf_we;

	input [15:0]	obuf_datain;
	input [15:0]	hbuf_datain;
	output [15:0]	hbuf_dataout;

	output [7:0]	y_out;
	output [7:0]	cr_out;
	output [7:0]	cb_out;

	//////////////////////////////////////////////////////////////////////
	// Select output of vbuffer
	//////////////////////////////////////////////////////////////////////

	wire [31:0]		vbuf_dataouta;
	wire [31:0]		vbuf_dataoutb;
	reg				bank;
	reg				group;
	
	always @(posedge clk or negedge resetn) begin
		if (~resetn) begin
			bank <= 1'b0;
			group <= 1'b0;
		end else begin
			bank <= vbuf_addr[10];
			group <= vbuf_addr[0];
		end
	end
	
	assign vbuf_dataout = ({bank, group} == 2'b00) ? vbuf_dataouta[31:16] :
								 ({bank, group} == 2'b01) ? vbuf_dataouta[15:0] : 
								 ({bank, group} == 2'b10) ? vbuf_dataoutb[31:16] : 
							/*  ({bank, group} == 2'b11) ?*/ vbuf_dataoutb[15:0];

	//////////////////////////////////////////////////////////////////////
	// Reorder output from Output Buffer
	//////////////////////////////////////////////////////////////////////

	reg [7:0] output_reordera;
	reg [7:0] output_reorderb;
	reg [1:0] obuf_addr_mode;
	wire [15:0] obuf_dataout;
	
	wire [2:0] obuf_addr;
	assign obuf_addr = ((line_state == `S4) | (line_state == `S1)) ? 3'd0 : 
							 (line_state == `S6) ? 3'd2 : 
							 (obuf_addr_mode == 2'b00) ? 
								((line_state == `S3) | (line_state == `S5)) ? 3'd1 : 
								((line_state == `S0) | (line_state == `S2)) ? 3'd4 : 3'd3
						  : (obuf_addr_mode == 2'b01) ? 
								((line_state == `S3) | (line_state == `S5)) ? 3'd4 : 
								((line_state == `S0) | (line_state == `S2)) ? 3'd3 : 3'd1
						  :/*(obuf_addr_mode == 2'b10) ?*/
								((line_state == `S0) | (line_state == `S2)) ? 3'd1 : 
								((line_state == `S3) | (line_state == `S5)) ? 3'd3 : 3'd4;
	
	always @(posedge clk or negedge resetn) begin
		if (~resetn) begin
			obuf_addr_mode <= 2'd0;
		end else begin
			if (line_state == `S3) begin
				if (obuf_addr_mode == 2'b10) obuf_addr_mode <= 2'b00;
				else obuf_addr_mode <= obuf_addr_mode + 1;
			end
			
			if (`LS_26 | `LS_04) begin
				output_reordera <= obuf_dataout[15:8];
				output_reorderb <= obuf_dataout[7:0];
			end else begin
				output_reordera <= output_reorderb;
				output_reorderb <= obuf_dataout[7:0];
			end
		end
	end
	
	assign cr_out = ((line_state == `S0) | (line_state == `S2)) ? output_reorderb :
						 ((line_state == `S1) | (line_state == `S7)) ? obuf_dataout[15:8]
						 : output_reordera;
	assign cb_out = ((line_state == `S4) | (line_state == `S6)) ? output_reorderb : 
						 ((line_state == `S3) | (line_state == `S5)) ? obuf_dataout[15:8]
						 : output_reordera;
	
	//////////////////////////////////////////////////////////////////////
	// Instantiate BRAM for Output and CrCb bufffering
	//////////////////////////////////////////////////////////////////////
	
	RAMB16_S9_S36 a_buffer (
		// Y buffer read port
		.DOA		(y_out),
		.ADDRA	({1'b0,ybuf_addr[9:2],2'b11 - ybuf_addr[1:0]/*,3-ybuf_addr[1:0]*/}),
		.CLKA		(clk),
		.DIA		(8'h00),
		.ENA		(resetn),
		.WEA		(1'b0),
		.SSRA		(1'b0),
		.DIPA		(1'b0),

		// Vertical interpolation buffering and Y buffer write port
		.DOB		(vbuf_dataouta),
		.ADDRB	(vbuf_addr[9:1]),
		.CLKB		(clk),
		.DIB		(ZBT_datain),
		.ENB		(resetn),
		.WEB		((vbuf_we & ~vbuf_addr[10]) | ybuf_we),
		.SSRB		(1'b0),
		.DIPB		(4'h0)
	);

	// synthesis attribute WRITE_MODE_A of a_buffer is "READ_FIRST"
	// synthesis attribute WRITE_MODE_B of a_buffer is "READ_FIRST"
	
	// synthesis translate off
	defparam a_buffer.WRITE_MODE_A = "READ_FIRST";
	defparam a_buffer.WRITE_MODE_B = "READ_FIRST";
	// synthesis translate on
	
	//////////////////////////////////////////////////////////////////////
	// Instantiate BRAM for Vertical Interpolation and Output Buffering
	//////////////////////////////////////////////////////////////////////

	RAMB16_S36_S36 b_buffer (
		// Vertical interpolation buffering port
		.DOA		(vbuf_dataoutb),
		.ADDRA	(vbuf_addr[9:1]),
		.CLKA		(clk),
		.DIA		(ZBT_datain),
		.ENA		(resetn),
		.WEA		(vbuf_we & vbuf_addr[10]),
		.SSRA		(1'b0),
		.DIPA		(4'h0),
		
		// Output/Horizontal Interpolation Buffer Port
		.DOB		({obuf_dataout,hbuf_dataout}),
		.ADDRB	({6'h3f,obuf_addr}),
		.CLKB		(clk),
		.DIB		({obuf_datain,hbuf_datain}),
		.ENB		(resetn),
		.WEB		(1'b1),
		.SSRB		(1'b0),
		.DIPB		(4'h0)
	);
	
	// synthesis attribute WRITE_MODE_A of b_buffer is "READ_FIRST"
	// synthesis attribute WRITE_MODE_B of b_buffer is "READ_FIRST"
	
	// synthesis translate off
	defparam b_buffer.WRITE_MODE_A = "READ_FIRST";
	defparam b_buffer.WRITE_MODE_B = "READ_FIRST";
	// synthesis translate on
endmodule
