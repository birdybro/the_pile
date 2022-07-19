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
module backend (	
	clk,
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
	frame_advance
);

	input clk;
	input resetn;
	input [2:0]		data_mode;
	
	output reg [18:0]	ZBT_addr;
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
	
	wire	[10:0]	column_count;
	wire	[9:0]		row_count;

	always @(posedge resetn) #25 timing_inst.row_count = 10'h250;

	SVGA_TIMING timing_inst (
		.resetn(resetn),
		.video_clock(clk),
		.h_synch(h_synch),
		.v_synch(v_synch),
		.column_count(column_count),
		.row_count(row_count));

	assign frame_advance = v_synch;
	
	reg write_flag; initial begin write_flag = 1'b0; end
	always @(negedge frame_advance) begin
		if (write_flag) begin
			$write("Advancing frame, dumping picture\n");
			picture_advance;
		end
		write_flag = ~write_flag;
	end

integer output_picture_counter; initial begin output_picture_counter = 0; end
//always @(posedge Sequence_Decoder.Picture_Done) if (resetn) picture_advance;

task picture_advance; 
	integer i, fp;
	reg [(10*8)-1:0] filename;
	reg [((26+16)*8)-1:0] temp_str;
begin
	$swrite(filename, "frame_%1d%1d%1d%1d", 
		output_picture_counter / 1000,
		(output_picture_counter % 1000) / 100,
		(output_picture_counter % 100) / 10,
		output_picture_counter % 10);
	$write("Dumping frame to %s\n", filename);

	$swrite(temp_str, "%s%s.info", `Video_output_directory, filename);
	$write("Writing info file %s\n", temp_str);
	fp = $fopen(temp_str, "wb"); 
	$fwrite(fp, "Output filename: %s\n", filename); 
	$fwrite(fp, "Matrix Coefficients: 0\nMPEG2 flag: 1\nLayout: 4\nFlags: 1 1 0\n");
	$fwrite(fp, "Coded picture size: 720 x 480\nHorizontal 720 x Vertical 480\n");
	$fwrite(fp, "Format: 1 = 420 Format\n"); 
	$fclose(fp);

	$swrite(temp_str, "%s%s.YUV4", `Video_output_directory, filename);
	$write("Writing YUV4 file %s\n", temp_str);
	fp = $fopen(temp_str, "wb");

	@(posedge clk); #2; ZBT_addr = 19'h00000; 
	@(posedge clk); #2; ZBT_addr = 19'h00001; 
	@(posedge clk); #2; ZBT_addr = 19'h00002; 
	@(posedge clk); #2; ZBT_addr = 19'h00003; 
	@(posedge clk); #2; ZBT_addr = 19'h00004; 
	@(posedge clk); #2; ZBT_addr = 19'h00005; 
	@(posedge clk); #2; ZBT_addr = 19'h00006; 
	@(posedge clk); #2; ZBT_addr = 19'h00007; 
	@(posedge clk); #2; ZBT_addr = 19'h00008; 

	#2; for (i = 0; i < 129600; i = i + 1) begin
		#2; @(posedge clk); #2; ZBT_addr = ZBT_addr + 1; #2;
		$fwrite(fp, "%c", (ZBT_datain[31:24] == 8'h00) ? 8'h01 : ZBT_datain[31:24]);
		$fwrite(fp, "%c", (ZBT_datain[23:16] == 8'h00) ? 8'h01 : ZBT_datain[23:16]);
		$fwrite(fp, "%c", (ZBT_datain[15:8]  == 8'h00) ? 8'h01 : ZBT_datain[15:8] );
		$fwrite(fp, "%c", (ZBT_datain[7:0]   == 8'h00) ? 8'h01 : ZBT_datain[7:0]  ); 
	#2; end 

	$write("Finished writing picture\n");
	$fclose(fp); 
	
	if (output_picture_counter == 'd119) begin
		$write("Completed 120 frames, stopping\n");
		$stop;
	end else output_picture_counter = output_picture_counter + 1;
end endtask

endmodule
