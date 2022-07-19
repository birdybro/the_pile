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
module ZBT_Bitstream (
   resetn,
   clock,

   ZBT_Reset_Address_I,
   ZBT_Busy_I,
   ZBT_Address_O,
   ZBT_Data_I,

   Shift_8_En_I,
   Buffer_Empty_O,
   Bitstream_Data_O
);

input                resetn;
input                clock;

input                ZBT_Reset_Address_I;
input                ZBT_Busy_I;
output reg [18:0]    ZBT_Address_O;
input    [31:0]      ZBT_Data_I;

input                Shift_8_En_I;
output 					Buffer_Empty_O;
output   [31:0]      Bitstream_Data_O;

reg      [4:0]       Bit_count;
reg      [31:0]      In_Data_reg, Out_Data_reg;

wire     [31:0]      In_Buffer_Data;
reg      [3:0]       In_Buffer_Write_En;
wire                 In_Buffer_Full;
reg [`BITSTR_BUFFER_ADDR_WIDTH:0] In_Buffer_Address;

wire     [31:0]      Out_Buffer_Data;
wire                 Out_Buffer_En;
wire                 Out_Buffer_Empty;
reg [`BITSTR_BUFFER_ADDR_WIDTH:0] Out_Buffer_Address;

assign Bitstream_Data_O = Out_Data_reg;
assign Buffer_Empty_O = Out_Buffer_Empty;

always @(posedge clock or negedge resetn) begin
   if (~resetn) begin
      Bit_count <= 5'h00;
      In_Data_reg <= 32'h00000000;
      Out_Data_reg <= 32'h00000000;
      Out_Buffer_Address <= 'd0;
   end else begin
      if (ZBT_Reset_Address_I) begin
         Bit_count <= 5'h00;
         In_Data_reg <= 32'h00000000;
         Out_Data_reg <= 32'h00000000;
         Out_Buffer_Address <= 'd0;
      end else begin
         if (Shift_8_En_I) begin
            Bit_count <= Bit_count + 8;
            In_Data_reg <= {In_Data_reg[23:0],8'h00};
            Out_Data_reg <= {Out_Data_reg[23:0],In_Data_reg[31:24]};
         end
         if ((Bit_count == 'd24) & Shift_8_En_I) begin
            Bit_count <= 5'h00;
            In_Data_reg <= Out_Buffer_Data;
            Out_Buffer_Address <= Out_Buffer_Address + 1;
         end 
      end
   end
end

wire [`BITSTR_BUFFER_ADDR_WIDTH:0] Addr_Compare_Full_1, Addr_Compare_Full_2;
wire [`BITSTR_BUFFER_ADDR_WIDTH:0] Addr_Compare_Empty_1, Addr_Compare_Empty_2;

assign Addr_Compare_Full_1 = 
   Out_Buffer_Address - 
   (In_Buffer_Address ^ ('d1 << `BITSTR_BUFFER_ADDR_WIDTH));
assign Addr_Compare_Full_2 = 
   (Out_Buffer_Address ^ ('d1 << `BITSTR_BUFFER_ADDR_WIDTH)) - 
   In_Buffer_Address;
assign Addr_Compare_Empty_1 = 
   (In_Buffer_Address ^ ('d1 << `BITSTR_BUFFER_ADDR_WIDTH)) - 
   (Out_Buffer_Address ^ ('d1 << `BITSTR_BUFFER_ADDR_WIDTH));
assign Addr_Compare_Empty_2 = 
   In_Buffer_Address - 
   Out_Buffer_Address;

assign In_Buffer_Full = 
   (Out_Buffer_Address[`BITSTR_BUFFER_ADDR_WIDTH] & 
   ~In_Buffer_Address[`BITSTR_BUFFER_ADDR_WIDTH]) ?
      (Addr_Compare_Full_1 < `BITSTR_BUFFER_SLACK) : (Addr_Compare_Full_2 < `BITSTR_BUFFER_SLACK);
assign Out_Buffer_Empty = 
   (~In_Buffer_Address[`BITSTR_BUFFER_ADDR_WIDTH] & 
   Out_Buffer_Address[`BITSTR_BUFFER_ADDR_WIDTH]) ?
      (Addr_Compare_Empty_1 < `BITSTR_BUFFER_SLACK) : (Addr_Compare_Empty_2 < `BITSTR_BUFFER_SLACK);

assign In_Buffer_Data = ZBT_Data_I;

wire Out_Buffer_En_mod;
assign Out_Buffer_En = 1'b1;
assign Out_Buffer_En_mod = Out_Buffer_En & 
   ~((In_Buffer_Address == Out_Buffer_Address) & In_Buffer_Write_En);

Bitstream_Buffer ZBT_Decoder_Interface_Buffer(
   .clock(clock),
   .Address_A_I(In_Buffer_Address[`BITSTR_BUFFER_ADDR_WIDTH-1:0]),
   .Write_Enable_A_I(In_Buffer_Write_En[3]),
   .Data_A_I(In_Buffer_Data),
   .Enable_B_I(Out_Buffer_En_mod),
   .Address_B_I(Out_Buffer_Address[`BITSTR_BUFFER_ADDR_WIDTH-1:0]),
   .Data_B_O(Out_Buffer_Data)
);

always @(posedge clock or negedge resetn) begin
   if (~resetn) begin
      In_Buffer_Write_En <= 4'b0;
      In_Buffer_Address <= 'd0;
      ZBT_Address_O <= 19'h00000;
   end else begin
      if (ZBT_Reset_Address_I) begin
         In_Buffer_Write_En <= 4'b0;
         In_Buffer_Address <= 'd0;
         ZBT_Address_O <= 19'h00000;
      end else begin
			if (~(In_Buffer_Full | ZBT_Busy_I)) begin
				In_Buffer_Write_En <= {In_Buffer_Write_En[2:0],1'b1};
				ZBT_Address_O <= ZBT_Address_O + 1;
			end else In_Buffer_Write_En <= {In_Buffer_Write_En[2:0],1'b0};
			if (In_Buffer_Write_En[3]) In_Buffer_Address <= In_Buffer_Address + 1;
		end
   end
end

endmodule
