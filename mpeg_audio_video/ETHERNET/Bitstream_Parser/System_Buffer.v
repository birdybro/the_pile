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
module System_Buffer(
   in_clock,
	out_clock,
   Address_A_I,
   Write_Enable_A_I,
   Data_A_I,
   Enable_B_I,
   Address_B_I,
   Data_B_O
);

input             in_clock;
input             out_clock;
input [`SYSTEM_BUFFER_ADDR_WIDTH-1:0] Address_A_I;
input             Write_Enable_A_I;
input    [31:0]   Data_A_I;
input             Enable_B_I;
input [`SYSTEM_BUFFER_ADDR_WIDTH-1:0] Address_B_I;
output   [31:0]   Data_B_O;

RAMB16_S18_S18 System_Buffer_RAM_H (
   .DOA(),
   .DOB(Data_B_O[31:16]),
   .DOPA(),
   .DOPB(),
   .ADDRA(Address_A_I[9:0]),
   .ADDRB(Address_B_I[9:0]),
   .CLKA(in_clock),
   .CLKB(out_clock),
   .DIA(Data_A_I[31:16]),
   .DIB(16'h0000),
   .DIPA(2'b00),
   .DIPB(2'b00),
   .ENA(1'b1),
   .ENB(Enable_B_I),
   .SSRA(1'b0),
   .SSRB(1'b0),
   .WEA(Write_Enable_A_I),
   .WEB(1'b0)
);

RAMB16_S18_S18 System_Buffer_RAM_L (
   .DOA(),
   .DOB(Data_B_O[15:0]),
   .DOPA(),
   .DOPB(),
   .ADDRA(Address_A_I[9:0]),
   .ADDRB(Address_B_I[9:0]),
   .CLKA(in_clock),
   .CLKB(out_clock),
   .DIA(Data_A_I[15:0]),
   .DIB(16'h0000),
   .DIPA(2'b00),
   .DIPB(2'b00),
   .ENA(1'b1),
   .ENB(Enable_B_I),
   .SSRA(1'b0),
   .SSRB(1'b0),
   .WEA(Write_Enable_A_I),
   .WEB(1'b0)
);

endmodule
