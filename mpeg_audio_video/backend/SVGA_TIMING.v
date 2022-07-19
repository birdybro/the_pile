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
module SVGA_TIMING (
	resetn,
	video_clock,
	h_synch,
	v_synch,
	column_count,
	row_count
);

input 				resetn;				// reset
input 				video_clock;		// pixel clock 
output 				h_synch;				// horizontal synch for VGA connector
output 				v_synch;				// vertical synch for VGA connector
output	[10:0]	column_count;
output	[9:0]		row_count;

reg 	[10:0]	column_count;	// counts the pixels in a line	
reg 	[9:0]		row_count;		// counts the display lines
reg				h_synch;			// horizontal synch
reg				v_synch;			// vertical synch

// CREATE THE HORIZONTAL LINE PIXEL COUNTER
always @ (posedge video_clock or negedge resetn) begin
	if (~resetn) column_count <= 11'h000;
	else if (column_count == (`H_TOTAL - 1)) column_count <= 11'h000;
	else column_count <= column_count + 1;
end

// CREATE THE HORIZONTAL SYNCH PULSE
always @ (posedge video_clock or negedge resetn) begin
	if (~resetn) h_synch <= 1'b0;		// remove h_synch
	else if (column_count == (`H_ACTIVE + `H_FRONT_PORCH - 1)) h_synch <= 1'b1;
	else if (column_count == (`H_TOTAL - `H_BACK_PORCH - 1)) h_synch <= 1'b0;
end

// CREATE THE VERTICAL FRAME LINE COUNTER
always @ (posedge video_clock or negedge resetn) begin
	if (~resetn) row_count <= 10'h000;
	else if ((row_count == (`V_TOTAL - 1))&& (column_count == (`H_TOTAL - 1))) row_count <= 10'h000;
	else if ((column_count == (`H_TOTAL - 1))) row_count <= row_count + 1;
end

// CREATE THE VERTICAL SYNCH PULSE
always @ (posedge video_clock or negedge resetn) begin
	if (~resetn) v_synch = 1'b0;
	else if ((row_count == (`V_ACTIVE + `V_FRONT_PORCH - 1) && (column_count == `H_TOTAL - 1))) v_synch = 1'b1;
	else if ((row_count == (`V_TOTAL - `V_BACK_PORCH - 1)) && (column_count == (`H_TOTAL - 1))) v_synch = 1'b0;
end

endmodule
