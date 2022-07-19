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
module Bitstream_Buffer(
   clock,
   Address_A_I,
   Write_Enable_A_I,
   Data_A_I,
   Enable_B_I,
   Address_B_I,
   Data_B_O
);

input             clock;
input [`BITSTR_BUFFER_ADDR_WIDTH-1:0] Address_A_I;
input             Write_Enable_A_I;
input    [31:0]   Data_A_I;
input             Enable_B_I;
input [`BITSTR_BUFFER_ADDR_WIDTH-1:0] Address_B_I;
output   [31:0]   Data_B_O;

wire     [31:0]   Data_B;

assign Data_B_O = Data_B;

RAMB16_S36_S36 Bitstream_Buffer_RAM (
   .DOA(),
   .DOB(Data_B),
   .DOPA(),
   .DOPB(),
   .ADDRA(Address_A_I),
   .ADDRB(Address_B_I),
   .CLKA(clock),
   .CLKB(clock),
   .DIA(Data_A_I),
   .DIB(32'h0000),
   .DIPA(4'b00),
   .DIPB(4'b00),
   .ENA(1'b1),
   .ENB(Enable_B_I),
   .SSRA(1'b0),
   .SSRB(1'b0),
   .WEA(Write_Enable_A_I),
   .WEB(1'b0)
);

endmodule
