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
module Window_Buffer_RAM (
	clock,
	
	address,
	data_I,
	data_O,
	write_en
);

input 				clock;

input 	[9:0] 	address;
input 	[15:0] 	data_I;
output 	[15:0] 	data_O;
input 				write_en;

RAMB16_S18_S18 window_buffer (
   .DOA(data_O),
   .DOB(),
   .DOPA(),
   .DOPB(),
   .ADDRA(address),
   .ADDRB(10'h000),
   .CLKA(clock),
   .CLKB(clock),
   .DIA(data_I),
   .DIB(16'h0000),
   .DIPA(2'b00),
   .DIPB(2'b00),
   .ENA(1'b1),
   .ENB(1'b0),
   .SSRA(1'b0),
   .SSRB(1'b0),
   .WEA(write_en),
   .WEB(1'b0)
);

// synthesis attribute INIT_00 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_01 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_02 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_03 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_04 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_05 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_06 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_07 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"

// synthesis attribute INIT_08 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_09 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_0A of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_0B of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_0C of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_0D of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_0E of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_0F of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"

// synthesis attribute INIT_10 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_11 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_12 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_13 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_14 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_15 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_16 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_17 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"

// synthesis attribute INIT_18 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_19 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_1A of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_1B of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_1C of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_1D of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_1E of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_1F of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"

// synthesis attribute INIT_20 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_21 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_22 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_23 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_24 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_25 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_26 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_27 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"

// synthesis attribute INIT_28 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_29 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_2A of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_2B of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_2C of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_2D of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_2E of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_2F of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"

// synthesis attribute INIT_30 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_31 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_32 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_33 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_34 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_35 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_36 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_37 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"

// synthesis attribute INIT_38 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_39 of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_3A of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_3B of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_3C of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_3D of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_3E of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"
// synthesis attribute INIT_3F of window_buffer is "256'h0000000000000000000000000000000000000000000000000000000000000000"

// synthesis translate_off

defparam window_buffer.INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;

defparam window_buffer.INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;

defparam window_buffer.INIT_10 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_11 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_12 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_13 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_14 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_15 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_16 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_17 = 256'h0000000000000000000000000000000000000000000000000000000000000000;

defparam window_buffer.INIT_18 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_19 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_1A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_1B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_1C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_1D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_1E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_1F = 256'h0000000000000000000000000000000000000000000000000000000000000000;

defparam window_buffer.INIT_20 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_21 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_22 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_23 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_24 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_25 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_26 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_27 = 256'h0000000000000000000000000000000000000000000000000000000000000000;

defparam window_buffer.INIT_28 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_29 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_2A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_2B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_2C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_2D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_2E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_2F = 256'h0000000000000000000000000000000000000000000000000000000000000000;

defparam window_buffer.INIT_30 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_31 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_32 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_33 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_34 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_35 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_36 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_37 = 256'h0000000000000000000000000000000000000000000000000000000000000000;

defparam window_buffer.INIT_38 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_39 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_3A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_3B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_3C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_3D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_3E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
defparam window_buffer.INIT_3F = 256'h0000000000000000000000000000000000000000000000000000000000000000;

// synthesis translate_on
endmodule