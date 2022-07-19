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
module ac97_ctr (
	BIT_CLOCK_I,
	SAMPLE_FREQUENCY_I,
	AC97_RESETN_I,
	SOURCE_SELECT_I,
	AC97_SYNCH_O,
	AC97_DATA_IN_I,
	AC97_DATA_OUT_O,
	AC97_BEEP_TONE_O,
	PCM_READ_ADVANCE_EN_I,
	PCM_READ_ADDRESS_O,
	CH0_PCM_DATA_I,
	CH1_PCM_DATA_I,
	STARTUP_O
); 	

input 				BIT_CLOCK_I;
input 				AC97_RESETN_I;
input 	[1:0] 	SAMPLE_FREQUENCY_I;
input 				SOURCE_SELECT_I;
output 				AC97_SYNCH_O;
input 				AC97_DATA_IN_I;
output 				AC97_DATA_OUT_O;
output 				AC97_BEEP_TONE_O;
output 				STARTUP_O;
input 	[15:0] 	CH0_PCM_DATA_I;
input 	[15:0] 	CH1_PCM_DATA_I;
input 				PCM_READ_ADVANCE_EN_I;
output reg [8:0] 	PCM_READ_ADDRESS_O;

assign AC97_SYNCH_O = 1'b0;
assign AC97_DATA_OUT_O = 1'b0;
assign AC97_BEEP_TONE_O = 1'b0;
assign STARTUP_O = AC97_RESETN_I;

wire sample_clock_en;
reg [7:0] sample_clock_counter;
always @(posedge BIT_CLOCK_I or negedge AC97_RESETN_I) begin
	if (~AC97_RESETN_I) sample_clock_counter <= 8'h00;
	else if (sample_clock_counter == 8'd249) sample_clock_counter <= 8'h00;
	else sample_clock_counter <= sample_clock_counter + 1;
end

integer outfile;

initial begin
	$write("Opening output file: %s\n", `Audio_output_file);
	outfile = $fopen(`Audio_output_file, "wb");
//	AIFF_header;
	PCM_READ_ADDRESS_O <= 9'h000;
end

assign sample_clock_en = (sample_clock_counter == 8'h00);
always @(posedge BIT_CLOCK_I) begin
	if (sample_clock_en) begin
//		$fwrite(outfile, "%02h %02h %02h %02h ", 
//			CH0_PCM_DATA_I[15:8],
//			CH0_PCM_DATA_I[7:0],
//			CH1_PCM_DATA_I[15:8],
//			CH1_PCM_DATA_I[7:0]);
		$fwrite(outfile, "%c", (CH0_PCM_DATA_I[15:8] == 8'h00) ? 8'h01 : CH0_PCM_DATA_I[15:8]);
		$fwrite(outfile, "%c", (CH0_PCM_DATA_I[7:0]  == 8'h00) ? 8'h01 : CH0_PCM_DATA_I[7:0] );
		$fwrite(outfile, "%c", (CH1_PCM_DATA_I[15:8] == 8'h00) ? 8'h01 : CH1_PCM_DATA_I[15:8]);
		$fwrite(outfile, "%c", (CH1_PCM_DATA_I[7:0]  == 8'h00) ? 8'h01 : CH1_PCM_DATA_I[7:0] );
		if (PCM_READ_ADVANCE_EN_I)
			PCM_READ_ADDRESS_O <= PCM_READ_ADDRESS_O + 1;
	end
end

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
