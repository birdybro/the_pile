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
module backend(	clk, 
						resetn, 
						data_mode,
						ZBT_addr, 
						ZBT_datain, 
						R_out, 
						G_out, 
						B_out,
						
						pic_width,
						pic_height,
						
						CR_start,
						CB_start,
						
						h_synch_n,
						v_synch_n,
						blank_n,
						
						frame_advance);
	input clk;
	input resetn;
	input [2:0]		data_mode;
	
	output [18:0]	ZBT_addr;
	input [31:0]	ZBT_datain;
	
	output [7:0]	R_out;
	output [7:0]	G_out;
	output [7:0]	B_out;
	
	input [11:0]	pic_width;
	input [11:0]	pic_height;
	
	input [18:0]	CR_start;
	input [18:0]	CB_start;
	
	output h_synch_n;
	output v_synch_n;
	output blank_n;
	
	output frame_advance;
	
	wire [10:0]		column_count;
	wire [9:0]		row_count;
	wire [9:0] 		pic_x;
	wire [9:0]		pic_y;
	
	// PICTURE X AND Y COORDINATES ON SCREEN
	assign pic_x = (`H_ACTIVE - pic_width) >> 1;
	assign pic_y = (`V_ACTIVE - pic_height) >> 1;
	
	wire h_synch;
	wire v_synch;
	reg blank;
	
	reg is_primary;
	reg write_first;
	reg is_topfield;

	// STATE REGISTERS
	reg [2:0]	h_state;
	reg [2:0]	line_state;
	reg [1:0]	ZBT_counter_mode;
	reg [2:0]	v_state;
	
	////////////////////////////////////////////////////////////////////////////////////
	// GLOBAL FSM																							 //
	////////////////////////////////////////////////////////////////////////////////////

	wire [9:0]		row_inpic;
	wire [9:0]		column_inpic;
	wire [9:0]		hstart;
	assign row_inpic = row_count - pic_y - (data_mode[`IS_INTERLACED] ? 2 : 1);
	assign column_inpic = column_count - hstart;
	assign hstart = pic_x - `PIPE_DEPTH;
	
	wire [9:0]		esc_condition;
	assign esc_condition = hstart + 
								  ((ZBT_counter_mode == `ZBT_DISABLED) ? 0 : pic_width) + 
								  ((ZBT_counter_mode == `ZBT_DISABLED) ? 0 : 
									(h_state == `S_PAUSE) ? `PIPE_DEPTH - 1 : 
									(ZBT_counter_mode == `ZBT_BY8) ? 8 : 
									/*(h_state == `S_HCRUNCH) ? */16);

	wire [9:0] v_stopcrunch;
	assign v_stopcrunch = pic_height - (data_mode[`IS_INTERLACED] ? 12 : 6);
	
	wire v_setup;
	assign v_setup = (v_state == `S_SETUPA);
	wire v_firstline;
	assign v_firstline = (v_state == `S_SETUPB);
	wire v_lastlinea;
	assign v_lastlinea = (v_state == `S_TAKEDOWNA);
	wire v_lastlineb;
	assign v_lastlineb = (v_state == `S_TAKEDOWNB);
	wire v_lastline;
	assign v_lastline = (v_state == `S_TAKEDOWNC);
	wire v_display;
	assign v_display = (v_state != `S_BLANK) & (v_state != `S_SETUPA);
	
	always @(posedge clk or negedge resetn) begin
		if (~resetn) begin
			v_state <= `S_BLANK;
			blank <= 1'b1;
		end else begin
			case (v_state)
				`S_BLANK : 		begin
										if (row_inpic == (data_mode[`IS_INTERLACED] ? 1020 : 1022)) v_state <= `S_SETUPA;
									end
				`S_SETUPA : 	begin
										if (column_count == `H_TOTAL - 1) begin
											if (is_topfield) v_state <= `S_SETUPB;
										end
									end
				`S_SETUPB : 	begin
										if (column_count == `H_TOTAL - 1) begin
											if (is_topfield) v_state <= `S_VCRUNCH;
										end
									end
				`S_VCRUNCH : 	begin
										if (row_inpic == v_stopcrunch) v_state <= `S_TAKEDOWNA;
									end
				`S_TAKEDOWNA : begin
										if ((column_count == `H_TOTAL - 1) & is_primary & is_topfield) begin
											v_state <= `S_TAKEDOWNB;
										end
									end
				`S_TAKEDOWNB : begin
										if ((column_count == `H_TOTAL - 1) & is_primary & is_topfield) begin
											v_state <= `S_TAKEDOWNC;
										end
									end
				`S_TAKEDOWNC : begin
										if ((column_count == `H_TOTAL - 1) & is_topfield)
											v_state <= `S_BLANK;
									end
			endcase
			if ((column_inpic == `PIPE_DEPTH - 1) && v_display) blank <= 1'b0;
			if ((column_count == esc_condition) && (h_state == `S_PAUSE)) blank <= 1'b1;
		end
	end
		
	////////////////////////////////////////////////////////////////////////////////////
	// LINE FSM																								 //
	////////////////////////////////////////////////////////////////////////////////////

	reg [10:0]	ZBT_column;
	
	wire [31:0]	ZBT_data;
	assign ZBT_data = (h_state == `S_FIRSTCRUNCH) ? {4{ZBT_datain[31:24]}} : 
							(h_state == `S_LASTCRUNCH) ? {4{ZBT_datain[7:0]}} : 
							ZBT_datain;

	wire [9:0]	y_addr;
	wire [10:0]	v_addr;
	assign y_addr = column_inpic;
	assign v_addr = (h_state == `S_YBUF) ? ZBT_column << 1 
				: {column_inpic[9:7] + ((data_mode[`IS_INTERLACED] & ~is_topfield) ? 4'h9 : 2'h3),column_inpic[6:0]};

	wire block_firstline;
	wire block_secondline;
	wire block_thirdline;
	wire block_fourthline;
	assign block_firstline = write_first ? `LS_04 : `LS_26;
	assign block_secondline = `LS_15;
	assign block_thirdline = write_first ? `LS_26 : `LS_04;
	assign block_fourthline = `LS_37;
	
	wire [9:0]	ZBT_block;
	wire [2:0] 	ZBT_lineoffset;
	wire [9:0]	ZBT_row;

	assign ZBT_lineoffset = (ZBT_counter_mode == `ZBT_BY1) ? (data_mode[`IS_INTERLACED] ? 3'h3 : 3'h2) : 
									(data_mode[`IS_FOURTWOTWO]) ? 3'h1 : 
									(v_setup) ? 3'h2 : 
									((block_firstline | block_secondline) & v_firstline) ? 3'h1 : 
									(block_thirdline & v_firstline) ? 3'h3 : 
									(block_fourthline & v_firstline) ? 3'h5 : 
									(v_lastline | block_firstline) ? 3'h0 : 
									(v_lastlineb | block_secondline) ? 3'h2 : 
									(v_lastlinea | block_thirdline) ? 3'h4 : 
									/*(block_fourthline) ?*/ 3'h6;
	
	assign ZBT_block = row_inpic + ((!(ZBT_counter_mode == `ZBT_BY1) && data_mode[`IS_INTERLACED]) ? ZBT_lineoffset << 1 : ZBT_lineoffset);//((ZBT_counter_mode == `ZBT_BY1) | data_mode[`IS_FOURTWOTWO]) ? row_inpic : row_inpic >> 1;

	assign ZBT_row = ((ZBT_counter_mode == `ZBT_BY1) | data_mode[`IS_FOURTWOTWO]) ? ZBT_block : 
							{ZBT_block[9:2],data_mode[`IS_INTERLACED] ? ZBT_block[0] : ZBT_block[1]};
	
	//ZBT_lineoffset + ZBT_block;//((ZBT_counter_mode == `ZBT_BY1) ? ZBT_block : (v_setup | v_firstline) ? 0 : ZBT_block);
	
	assign ZBT_addr = ((ZBT_counter_mode == `ZBT_BY1) ? ZBT_column : ZBT_column >> 3) + 				// Column
							(ZBT_row * ((ZBT_counter_mode == `ZBT_BY1) ? `QPIC_WIDTH : `EPIC_WIDTH)) +		// Row
							((ZBT_counter_mode == `ZBT_BY1) ? 0 : `LS_0123 ? CR_start : CB_start);			// Field
	
	always @(posedge clk or negedge resetn) begin
		if (~resetn) begin
			ZBT_counter_mode <= `ZBT_DISABLED;
			ZBT_column <= 8'h00;
			line_state <= `S_IDLE;
		end else begin
			case (line_state)
				`S0: begin line_state <= `S1; end
				`S1: begin line_state <= `S2; end
				`S2: begin line_state <= `S3; end
				`S3: begin line_state <= `S4; end
				`S4: begin line_state <= `S5; end
				`S5: begin line_state <= `S6; end
				`S6: begin line_state <= `S7; end
				`S7: begin line_state <= `S0; end
			endcase

			case (ZBT_counter_mode)
				`ZBT_DISABLED:	begin 
					if (column_count == esc_condition) begin
						line_state <= `S_IDLE;
						ZBT_column <= 8'h00;
						ZBT_counter_mode <= `ZBT_PAUSE;
					end
				end
				`ZBT_BY8: 		begin 
					if ((h_state == `S_HCRUNCH) && (column_count == esc_condition))
						ZBT_counter_mode <= `ZBT_PAUSE;
					else if (column_count == `H_START_YBUF - `ZBT_LAG) begin
						ZBT_column <= 8'h00;
						ZBT_counter_mode <= `ZBT_BY1;
					end
					else ZBT_column <= ZBT_column + 1;
				end
				`ZBT_PAUSE:		begin 
					if (line_state == `S7) begin
						ZBT_counter_mode <= `ZBT_BY8;
					end
				end
				`ZBT_BY1: 		begin 
					ZBT_column <= ZBT_column + 1;
					line_state <= `S_IDLE;

					if (column_count == `H_START_YBUF + 180) begin
						ZBT_column <= 8'h00;
						ZBT_counter_mode <= `ZBT_DISABLED;
					end
				end
			endcase
		end
	end
	
	wire h_active;
	assign h_active = (h_state == `S_FIRSTCRUNCH) | (h_state == `S_LASTCRUNCH) | (h_state == `S_HCRUNCH);
	
	always @(posedge clk or negedge resetn) begin
		if (~resetn) begin
			h_state <= `S_HBLANK;
		end else begin
			case (h_state)
				`S_HBLANK : begin if ((ZBT_counter_mode == `ZBT_PAUSE) && (line_state == `S7)) h_state <= `S_FIRSTCRUNCH; end
				`S_FIRSTCRUNCH : begin if (line_state == `S7) h_state <= `S_HCRUNCH; end
				`S_HCRUNCH : begin if (!(ZBT_counter_mode == `ZBT_BY8) && (column_count == esc_condition)) h_state <= `S_LASTCRUNCH; end
				`S_LASTCRUNCH : begin if (line_state == `S7) h_state <= `S_PAUSE; end 
				`S_PAUSE: begin if (column_count == `H_START_YBUF) h_state <= `S_YBUF; end
				`S_YBUF : begin if (column_count == `H_START_YBUF + 180) h_state <= `S_HBLANK; end
			endcase
		end
	end

	////////////////////////////////////////////////////////////////////////////////////
	// LINE TYPE FSM																						 //
	////////////////////////////////////////////////////////////////////////////////////
		
	always @(posedge clk or negedge resetn) begin
		if (~resetn) begin
			write_first <= 1'b1;
			is_topfield <= 1'b1;
		end else begin
			if (column_count == `H_TOTAL - 2) begin
				if (v_display & ((~is_topfield) | (~data_mode[`IS_INTERLACED])) ) begin
					if (~is_primary) write_first <= ~write_first;
				end
				if (data_mode[`IS_INTERLACED]) is_topfield <= ~is_topfield;
			end else if (v_state == `S_BLANK) begin
				write_first <= 1'b1;
				is_topfield <= 1'b1;
			end
			is_primary <= data_mode[`IS_INTERLACED] ? row_inpic[1] : row_inpic[0];
		end
	end

	////////////////////////////////////////////////////////////////////////////////////
	// ACCUMULATOR																							 //
	////////////////////////////////////////////////////////////////////////////////////

	wire [7:0]		vdone_a;
	wire [7:0]		vdone_b;
	wire [7:0]		vdone_c;
	wire [7:0]		vdone_d;
	wire [15:0]		vbuf_dataout;

	accumulator accumulator(
		.clk(clk),
		.resetn(resetn),
		.line_state(line_state),
		.data_mode(data_mode[`IS_FOURTWOTWO:`IS_INTERLACED]),
		.is_primary(is_primary),
		.is_topfield(is_topfield),
		.write_first(write_first),
		.BRAM_operand(vbuf_dataout),
		.ZBT_operand(ZBT_data),
		.done_a(vdone_a),
		.done_b(vdone_b),
		.done_c(vdone_c),
		.done_d(vdone_d));

	////////////////////////////////////////////////////////////////////////////////////
	// BUFFERS																								 //
	////////////////////////////////////////////////////////////////////////////////////

	wire [15:0]		hdone_packet;
	wire [15:0]		hbuf_dataout;
	reg [7:0]		hbuffer [7:0];

	wire [7:0] Y_out;
	wire [7:0] CR_out;
	wire [7:0] CB_out;

	buffer_interface buffers (
		.clk(clk),
		.resetn(resetn),
		.line_state(line_state),

		.vbuf_addr(v_addr),
		.vbuf_dataout(vbuf_dataout),
		.vbuf_we(h_active & (v_setup | (is_primary & (write_first ? `LS_04 : `LS_26)))),

		.ZBT_datain(ZBT_data),
		
		.ybuf_addr(y_addr),
		.ybuf_we(h_state == `S_YBUF),

		.obuf_datain(hdone_packet),
		.hbuf_datain((line_state == `S4) ? {hbuffer[7],vdone_d} : 
						 (line_state == `S5) ? {hbuffer[4],hbuffer[5]} : 
						 (line_state == `S6) ? {hbuf_dataout[7:0],hbuffer[5]} : 
						 (line_state == `S0) ? {hbuffer[1],hbuffer[5]} : 
						 (line_state == `S2) ? {hbuffer[5],hbuffer[6]} : 
					  /*(line_state == `S3) ?*/{hbuffer[2],hbuffer[3]}),
		.hbuf_dataout(hbuf_dataout),
		
		.y_out(Y_out),
		.cr_out(CR_out),
		.cb_out(CB_out));

	////////////////////////////////////////////////////////////////////////////////////
	// YUV TO RGB																							 //
	////////////////////////////////////////////////////////////////////////////////////
	
	wire [23:0] video_data;

	yuv2bgr2 colourspace ({Y_out,CR_out,CB_out},1'b0,video_data);
	
	assign frame_advance = v_synch;
	
	OBUF_F_12 vga_hsynch_buf (.I(~h_synch), .O(h_synch_n));
	OBUF_F_12 vga_v_synch_buf (.I(~v_synch), .O(v_synch_n));
	OBUF_F_12 vga_blank_buf (.I(~blank), .O(blank_n));

	OBUF_F_12 red_buf_0 (.I(video_data[0]), .O(R_out[0]));
	OBUF_F_12 red_buf_1 (.I(video_data[1]), .O(R_out[1]));
	OBUF_F_12 red_buf_2 (.I(video_data[2]), .O(R_out[2]));
	OBUF_F_12 red_buf_3 (.I(video_data[3]), .O(R_out[3]));
	OBUF_F_12 red_buf_4 (.I(video_data[4]), .O(R_out[4]));
	OBUF_F_12 red_buf_5 (.I(video_data[5]), .O(R_out[5]));
	OBUF_F_12 red_buf_6 (.I(video_data[6]), .O(R_out[6]));
	OBUF_F_12 red_buf_7 (.I(video_data[7]), .O(R_out[7]));

	OBUF_F_12 green_buf0 (.I(video_data[8]), .O(G_out[0]));
	OBUF_F_12 green_buf1 (.I(video_data[9]), .O(G_out[1]));
	OBUF_F_12 green_buf2 (.I(video_data[10]), .O(G_out[2]));
	OBUF_F_12 green_buf3 (.I(video_data[11]), .O(G_out[3]));
	OBUF_F_12 green_buf4 (.I(video_data[12]), .O(G_out[4]));
	OBUF_F_12 green_buf5 (.I(video_data[13]), .O(G_out[5]));
	OBUF_F_12 green_buf6 (.I(video_data[14]), .O(G_out[6]));
	OBUF_F_12 green_buf7 (.I(video_data[15]), .O(G_out[7]));

	OBUF_F_12 blue_buf0 (.I(video_data[16]), .O(B_out[0]));
	OBUF_F_12 blue_buf1 (.I(video_data[17]), .O(B_out[1]));
	OBUF_F_12 blue_buf2 (.I(video_data[18]), .O(B_out[2]));
	OBUF_F_12 blue_buf3 (.I(video_data[19]), .O(B_out[3]));
	OBUF_F_12 blue_buf4 (.I(video_data[20]), .O(B_out[4]));
	OBUF_F_12 blue_buf5 (.I(video_data[21]), .O(B_out[5]));
	OBUF_F_12 blue_buf6 (.I(video_data[22]), .O(B_out[6]));
	OBUF_F_12 blue_buf7 (.I(video_data[23]), .O(B_out[7]));

	////////////////////////////////////////////////////////////////////////////////////
	// HORIZONTAL INTERPOLATION																		 //
	////////////////////////////////////////////////////////////////////////////////////
	
	integer loop;
	
	always @(posedge clk or negedge resetn) begin
		if (~resetn) begin
			for (loop = 0; loop < 8; loop = loop + 1) begin
				hbuffer[loop] <= 8'd0;
			end
		end else begin
			hbuffer[2] <= hbuffer[3];
			case (line_state) 
				`S0: begin
					hbuffer[0] <= hbuf_dataout[15:8];
					hbuffer[1] <= hbuf_dataout[7:0];
					hbuffer[7] <= vdone_d;
					for (loop = 3; loop < 7; loop = loop + 1) begin
						hbuffer[loop] <= hbuffer[loop + 1];
					end
				end
				`S1: begin
					for (loop = 0; loop < 7; loop = loop + 1) begin
						hbuffer[loop] <= hbuffer[loop + 1];
					end
					hbuffer[7] <= vdone_d;
				end
				`S2: begin
					for (loop = 0; loop < 6; loop = loop + 1) begin
						hbuffer[loop] <= hbuffer[loop + 1];
					end
					hbuffer[6] <= hbuf_dataout[15:8];
					hbuffer[7] <= hbuf_dataout[7:0];
				end
				`S3: begin
					hbuffer[0] <= hbuf_dataout[15:8];
					hbuffer[3] <= hbuffer[6];
					hbuffer[4] <= hbuffer[7];
					hbuffer[5] <= vdone_a;
					hbuffer[6] <= vdone_b;
					hbuffer[7] <= vdone_c;
				end
				`S4: begin
					hbuffer[0] <= hbuf_dataout[15:8];
					hbuffer[1] <= hbuf_dataout[7:0];
					hbuffer[7] <= vdone_d;
					for (loop = 3; loop < 7; loop = loop + 1) begin
						hbuffer[loop] <= hbuffer[loop + 1];
					end
				end
				`S5: begin
					for (loop = 0; loop < 7; loop = loop + 1) begin
						hbuffer[loop] <= hbuffer[loop + 1];
					end
					hbuffer[7] <= vdone_d;
				end
				`S6: begin
					for (loop = 0; loop < 6; loop = loop + 1) begin
						hbuffer[loop] <= hbuffer[loop + 1];
					end
					hbuffer[6] <= hbuf_dataout[15:8];
					hbuffer[7] <= hbuf_dataout[7:0];
				end
				`S7: begin
					hbuffer[0] <= hbuf_dataout[15:8];
					hbuffer[3] <= hbuffer[6];
					hbuffer[4] <= hbuffer[7];
					hbuffer[5] <= vdone_a;
					hbuffer[6] <= vdone_b;
					hbuffer[7] <= vdone_c;
				end
			endcase
		end
	end

	horizontal_filter hFIR (
		.MPEG2_flag(data_mode[`IS_MPEG2]),
		.im3(hbuffer[0]),
		.im2(`LS_04 ? hbuf_dataout[15:8] : hbuffer[1]),
		.im1(`LS_04 ? hbuf_dataout[7:0] : hbuffer[2]),
		.i(hbuffer[3]),
		.ip1(hbuffer[4]),
		.ip2(hbuffer[5]),
		.out_im1(hdone_packet[15:8]),
		.out_i(hdone_packet[7:0]));
		
	SVGA_TIMING timing_inst (
		.resetn(resetn),
		.video_clock(clk),
		.h_synch(h_synch),
		.v_synch(v_synch),
		.column_count(column_count),
		.row_count(row_count));

//////////////////////////////////////////////////////
	
 /* wire [35:0] control0;
  wire clk_ila;
  wire [47:0] data;
  wire [15:0] trig0;

  assign clk_ila=clk;
  assign data={CR_start,CB_start,10'd0};
  assign trig0={blank,5'd0,row_count};

////////////////////////////////////////////
  ila i_ila
    (
      .control(control0),
      .clk(clk_ila),
      .data(data),
      .trig0(trig0)
    );
	 
	 
	   


  icon i_icon
    (
      .control0(control0)
    );*/
	 
endmodule


/*
module icon 
  (
      control0
  );
  output [35:0] control0;
endmodule



module ila
  (
    control,
    clk,
    data,
    trig0
  );
  input [35:0] control;
  input clk;
  input [47:0] data;
  input [15:0] trig0;
endmodule


*/
