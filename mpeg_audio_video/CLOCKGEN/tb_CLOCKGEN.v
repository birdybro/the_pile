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
module CLOCKGEN(
	MASTER_CLOCK_P,
	ALTERNATE_CLOCK_P,
	MEM_CLK_FBOUT_P,
	MEM_CLK_FBIN_P,
	EXTEND_DCM_RESET_P,
	internal_audio_clock,
	internal_video_clock,
	external_video_clock,
	internal_clock,
	external_clock,
	fpga_reset
);

input  		MASTER_CLOCK_P;			// master clock input (27MHz) 
input  		ALTERNATE_CLOCK_P;		// alternate clock input (50MHz)
output 		MEM_CLK_FBOUT_P;			// memory DCM feedback loop output
input  		MEM_CLK_FBIN_P;			// memory DCM feedback loop input
input  		EXTEND_DCM_RESET_P;		// signal to extend the DCM reset
output reg 	internal_audio_clock;	// internal audio clock
output reg 	internal_video_clock;	// internal video clock
output		external_video_clock;	// external video clock
output reg 	internal_clock;			// internal clock for ZBT RAMs
output 		external_clock;			// external clock for ZBT RAMs
output reg	fpga_reset;					// reset to fpga until all DCMs are locked

assign MEM_CLK_FBOUT_P = MEM_CLK_FBIN_P;
assign external_video_clock = internal_video_clock;
assign external_clock = internal_clock;

initial begin
	internal_audio_clock = 1'b0;
	internal_video_clock = 1'b0;
	internal_clock = 1'b0;
	fpga_reset = 1'b1; #10000 fpga_reset = 1'b0;
end

always begin
	#9.259 internal_clock = 1'b0;
	#9.259 internal_clock = 1'b1; internal_audio_clock = 1'b0;
	#9.259 internal_clock = 1'b0;
	#9.259 internal_clock = 1'b1; internal_audio_clock = 1'b1;
end

always begin
	#12.5 internal_video_clock = 1'b0;
	#12.5 internal_video_clock = 1'b1;
end 

endmodule
