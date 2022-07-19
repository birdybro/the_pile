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
`define ZBT_VID_SIZE 17
`define ZBT_VID_SLACK 1024
module Video_ZBT_Bitstream(
	resetn,
	clock,
	Reset_Address_I,
	
	Buffer_Write_I,
	Buffer_Full_O,
	Video_Data_I,

   Video_Shift_1_En_I,
   Video_Shift_8_En_I,
	Buffer_Empty_O,
	Video_Data_O,
	Video_Byte_Allign_O,
	
	ZBT_Access_I,
	ZBT_Address_O,
	ZBT_Write_Data_O,
	ZBT_Write_En_O,
	ZBT_Read_Data_I
);

input 					resetn;
input 					clock;
input 					Reset_Address_I;

input 					Buffer_Write_I;
output 					Buffer_Full_O;
input 	[7:0]			Video_Data_I;

input 				   Video_Shift_1_En_I;
input 				   Video_Shift_8_En_I;
output 					Buffer_Empty_O;
output 	[31:0]		Video_Data_O;
output 					Video_Byte_Allign_O;

input 					ZBT_Access_I;
output  	[18:0]		ZBT_Address_O;
output 	[31:0]		ZBT_Write_Data_O;
output  					ZBT_Write_En_O;
input 	[31:0]		ZBT_Read_Data_I;

wire     [31:0]      In_Buffer_Data;
wire             		In_Buffer_Write_En;
wire                 In_Buffer_Full;
reg [`SYSTEM_BUFFER_ADDR_WIDTH:0] In_Buffer_Address;

wire     [31:0]      Video_to_ZBT_Data;
wire             		Video_to_ZBT_En;
wire                 Video_to_ZBT_Empty;
reg [`SYSTEM_BUFFER_ADDR_WIDTH:0] Video_to_ZBT_Address;

wire     [31:0]      ZBT_to_Video_Data;
wire             		ZBT_to_Video_Write_En;
wire                 ZBT_to_Video_Full;
reg [`SYSTEM_BUFFER_ADDR_WIDTH:0] ZBT_to_Video_Address;

wire     [31:0]      Out_Buffer_Data;
wire                 Out_Buffer_En;
wire                 Out_Buffer_Empty;
reg [`SYSTEM_BUFFER_ADDR_WIDTH:0] Out_Buffer_Address;

reg 						write_cycle;
reg      [4:0]       Bit_count;
reg      [31:0]      In_Data_reg, Out_Data_reg;

wire 						ZBT_Full, ZBT_Empty;
wire 						ZBT_write_en, ZBT_read_en;
reg 		[3:0] 		ZBT_read_en_reg;
reg [`ZBT_VID_SIZE:0]	ZBT_Write_Address;
reg [`ZBT_VID_SIZE:0] 	ZBT_Read_Address; 
wire [`ZBT_VID_SIZE:0] 	next_ZBT_Read_Address; 

assign ZBT_Address_O = {{(19-`ZBT_VID_SIZE){1'b1}}, (write_cycle) ? 
	ZBT_Write_Address[`ZBT_VID_SIZE-1:0] : ZBT_Read_Address[`ZBT_VID_SIZE-1:0]};
//assign ZBT_Address_O = {{(18-`ZBT_VID_SIZE){1'b1}},
//	(write_cycle) ? ZBT_Write_Address : ZBT_Read_Address};

// Output from ZBT handling
assign ZBT_to_Video_Write_En = ZBT_read_en_reg[0];
assign ZBT_to_Video_Data = ZBT_Read_Data_I;

assign Video_Data_O = Out_Data_reg;
assign Buffer_Empty_O = Out_Buffer_Empty;
assign Video_Byte_Allign_O = (Bit_count[2:0] == 3'h0);

always @(posedge clock or negedge resetn) begin
   if (~resetn) begin
      Bit_count <= 5'h00;
      In_Data_reg <= 32'h00000000;
      Out_Data_reg <= 32'h00000000;
      Out_Buffer_Address <= 'd0;
   end else begin
      if (Reset_Address_I) begin
         Bit_count <= 5'h00;
         In_Data_reg <= 32'h00000000;
         Out_Data_reg <= 32'h00000000;
         Out_Buffer_Address <= 'd0;
      end else begin
         if (Video_Shift_1_En_I) begin
            Bit_count <= Bit_count + 1;
            In_Data_reg <= {In_Data_reg[30:0],1'b0};
            Out_Data_reg <= {Out_Data_reg[30:0],In_Data_reg[31]};
         end
         if (Video_Shift_8_En_I) begin
            Bit_count <= Bit_count + 8;
            In_Data_reg <= {In_Data_reg[23:0],8'h00};
            Out_Data_reg <= {Out_Data_reg[23:0],In_Data_reg[31:24]};
         end
         if (((Bit_count == 'd31) & Video_Shift_1_En_I) | ((Bit_count == 'd24) & Video_Shift_8_En_I)) begin
            Bit_count <= 5'h00;
            In_Data_reg <= Out_Buffer_Data;
            Out_Buffer_Address <= Out_Buffer_Address + 1;
         end 
      end
   end
end

wire [`SYSTEM_BUFFER_ADDR_WIDTH:0] ZV_Addr_Compare_Full_1, ZV_Addr_Compare_Full_2;
wire [`SYSTEM_BUFFER_ADDR_WIDTH:0] ZV_Addr_Compare_Empty_1, ZV_Addr_Compare_Empty_2;

assign ZV_Addr_Compare_Full_1 = 
   Out_Buffer_Address - 
   (ZBT_to_Video_Address ^ ('d1 << `SYSTEM_BUFFER_ADDR_WIDTH));
assign ZV_Addr_Compare_Full_2 = 
   (Out_Buffer_Address ^ ('d1 << `SYSTEM_BUFFER_ADDR_WIDTH)) - 
   ZBT_to_Video_Address;
assign ZV_Addr_Compare_Empty_1 = 
   (ZBT_to_Video_Address ^ ('d1 << `SYSTEM_BUFFER_ADDR_WIDTH)) - 
   (Out_Buffer_Address ^ ('d1 << `SYSTEM_BUFFER_ADDR_WIDTH));
assign ZV_Addr_Compare_Empty_2 = 
   ZBT_to_Video_Address - 
   Out_Buffer_Address;

assign ZBT_to_Video_Full = 
   (Out_Buffer_Address[`SYSTEM_BUFFER_ADDR_WIDTH] & 
   ~ZBT_to_Video_Address[`SYSTEM_BUFFER_ADDR_WIDTH]) ?
      (ZV_Addr_Compare_Full_1 < `SYSTEM_BUFFER_SLACK) : (ZV_Addr_Compare_Full_2 < `SYSTEM_BUFFER_SLACK);
assign Out_Buffer_Empty = 
   (~ZBT_to_Video_Address[`SYSTEM_BUFFER_ADDR_WIDTH] & 
   Out_Buffer_Address[`SYSTEM_BUFFER_ADDR_WIDTH]) ?
      (ZV_Addr_Compare_Empty_1 < `SYSTEM_BUFFER_SLACK) : (ZV_Addr_Compare_Empty_2 < `SYSTEM_BUFFER_SLACK);

wire Out_Buffer_En_mod;
assign Out_Buffer_En = 1'b1;
assign Out_Buffer_En_mod = Out_Buffer_En;

System_Buffer ZBT_to_Video_Buffer(
   .in_clock(clock),
   .out_clock(clock),
   .Address_A_I(ZBT_to_Video_Address[`SYSTEM_BUFFER_ADDR_WIDTH-1:0]),
   .Write_Enable_A_I(ZBT_to_Video_Write_En),
   .Data_A_I(ZBT_to_Video_Data),
   .Enable_B_I(Out_Buffer_En_mod),
   .Address_B_I(Out_Buffer_Address[`SYSTEM_BUFFER_ADDR_WIDTH-1:0]),
   .Data_B_O(Out_Buffer_Data)
);

// ZBT interface handling
assign ZBT_read_en = ZBT_Access_I & ~ZBT_Empty & ~ZBT_to_Video_Full & ~write_cycle;
assign next_ZBT_Read_Address = (ZBT_read_en) ? 
	ZBT_Read_Address + 1 : ZBT_Read_Address;
always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		ZBT_Read_Address <= 'd0;
		ZBT_read_en_reg <= 4'h0;
		ZBT_to_Video_Address <= 'd0;
	end else begin
		ZBT_read_en_reg[3] <= ZBT_read_en;
		ZBT_read_en_reg[2:0] <= ZBT_read_en_reg[3:1];
		ZBT_Read_Address <= next_ZBT_Read_Address;
		if (ZBT_to_Video_Write_En) 
			ZBT_to_Video_Address <= ZBT_to_Video_Address + 1;
	end
end

wire [`ZBT_VID_SIZE:0] Z_Addr_Compare_Full_1, Z_Addr_Compare_Full_2;
wire [`ZBT_VID_SIZE:0] Z_Addr_Compare_Empty_1, Z_Addr_Compare_Empty_2;

assign Z_Addr_Compare_Full_1 = 
   ZBT_Read_Address - 
   (ZBT_Write_Address ^ ('d1 << `ZBT_VID_SIZE));
assign Z_Addr_Compare_Full_2 = 
   (ZBT_Read_Address ^ ('d1 << `ZBT_VID_SIZE)) - 
   ZBT_Write_Address;
assign Z_Addr_Compare_Empty_1 = 
   (ZBT_Write_Address ^ ('d1 << `ZBT_VID_SIZE)) - 
   (ZBT_Read_Address ^ ('d1 << `ZBT_VID_SIZE));
assign Z_Addr_Compare_Empty_2 = 
   ZBT_Write_Address - 
   ZBT_Read_Address;

assign ZBT_Full = 
   (ZBT_Read_Address[`ZBT_VID_SIZE] & 
   ~ZBT_Write_Address[`ZBT_VID_SIZE]) ?
      (Z_Addr_Compare_Full_1 < `ZBT_VID_SLACK) : (Z_Addr_Compare_Full_2 < `ZBT_VID_SLACK);
assign ZBT_Empty = 
   (~ZBT_Read_Address[`ZBT_VID_SIZE] & 
   ZBT_Write_Address[`ZBT_VID_SIZE]) ?
      (Z_Addr_Compare_Empty_1 < `ZBT_VID_SLACK) : (Z_Addr_Compare_Empty_2 < `ZBT_VID_SLACK);

wire [`SYSTEM_BUFFER_ADDR_WIDTH:0] next_Video_to_ZBT_Address;

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		Video_to_ZBT_Address <= 'd0;
		ZBT_Write_Address <= 'd0;
		write_cycle <= 1'b0;
	end else begin
		write_cycle <= ~write_cycle;
		Video_to_ZBT_Address <= next_Video_to_ZBT_Address;
		if (ZBT_write_en) ZBT_Write_Address <= ZBT_Write_Address + 1;
	end
end
assign ZBT_write_en = ZBT_Access_I & ~ZBT_Full & ~Video_to_ZBT_Empty & write_cycle;
assign next_Video_to_ZBT_Address = (ZBT_write_en) ? 
	Video_to_ZBT_Address + 1 : Video_to_ZBT_Address;

// Input to ZBT handling
assign Buffer_Full_O = In_Buffer_Full;

wire [`SYSTEM_BUFFER_ADDR_WIDTH:0] VZ_Addr_Compare_Full_1, VZ_Addr_Compare_Full_2;
wire [`SYSTEM_BUFFER_ADDR_WIDTH:0] VZ_Addr_Compare_Empty_1, VZ_Addr_Compare_Empty_2;

assign VZ_Addr_Compare_Full_1 = 
   Video_to_ZBT_Address - 
   (In_Buffer_Address ^ ('d1 << `SYSTEM_BUFFER_ADDR_WIDTH));
assign VZ_Addr_Compare_Full_2 = 
   (Video_to_ZBT_Address ^ ('d1 << `SYSTEM_BUFFER_ADDR_WIDTH)) - 
   In_Buffer_Address;
assign VZ_Addr_Compare_Empty_1 = 
   (In_Buffer_Address ^ ('d1 << `SYSTEM_BUFFER_ADDR_WIDTH)) - 
   (Video_to_ZBT_Address ^ ('d1 << `SYSTEM_BUFFER_ADDR_WIDTH));
assign VZ_Addr_Compare_Empty_2 = 
   In_Buffer_Address - 
   Video_to_ZBT_Address;

assign In_Buffer_Full = 
   (Video_to_ZBT_Address[`SYSTEM_BUFFER_ADDR_WIDTH] & 
   ~In_Buffer_Address[`SYSTEM_BUFFER_ADDR_WIDTH]) ?
      (VZ_Addr_Compare_Full_1 < `SYSTEM_BUFFER_SLACK) : (VZ_Addr_Compare_Full_2 < `SYSTEM_BUFFER_SLACK);
assign Video_to_ZBT_Empty = 
   (~In_Buffer_Address[`SYSTEM_BUFFER_ADDR_WIDTH] & 
   Video_to_ZBT_Address[`SYSTEM_BUFFER_ADDR_WIDTH]) ?
      (VZ_Addr_Compare_Empty_1 < `SYSTEM_BUFFER_SLACK) : (VZ_Addr_Compare_Empty_2 < `SYSTEM_BUFFER_SLACK);

wire Video_to_ZBT_En_mod;
assign Video_to_ZBT_En = 1'b1;
assign Video_to_ZBT_En_mod = Video_to_ZBT_En;

System_Buffer Video_to_ZBT_Buffer(
   .in_clock(clock),
   .out_clock(clock),
   .Address_A_I(In_Buffer_Address[`SYSTEM_BUFFER_ADDR_WIDTH-1:0]),
   .Write_Enable_A_I(In_Buffer_Write_En),
   .Data_A_I(In_Buffer_Data),
   .Enable_B_I(Video_to_ZBT_En_mod),
   .Address_B_I(next_Video_to_ZBT_Address[`SYSTEM_BUFFER_ADDR_WIDTH-1:0]),
   .Data_B_O(Video_to_ZBT_Data)
);
assign ZBT_Write_En_O = ZBT_write_en;
assign ZBT_Write_Data_O = Video_to_ZBT_Data;

reg [1:0] In_byte_counter;
reg [23:0] In_write_data_reg;

assign In_Buffer_Data = {In_write_data_reg,Video_Data_I};
assign In_Buffer_Write_En = Buffer_Write_I & (In_byte_counter == 2'h3);

always @(posedge clock or negedge resetn) begin
   if (~resetn) begin
   	In_byte_counter <= 2'h0;
		In_Buffer_Address <= 'd0;
		In_write_data_reg <= 24'h000000;
   end else begin
      if (Reset_Address_I) begin
	   	In_byte_counter <= 2'h0;
			In_Buffer_Address <= 'd0;
			In_write_data_reg <= 24'h000000;
      end else begin
			if (Buffer_Write_I) begin
				In_byte_counter <= In_byte_counter + 1;
				In_write_data_reg <= In_Buffer_Data[23:0];
				if (In_Buffer_Write_En) In_Buffer_Address <= In_Buffer_Address + 1;
			end
		end
   end
end

endmodule
