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

`timescale 1ns/100ps
module ZBT_bank_connections(
	internal_clock,
	external_clock,
	read_data,
	write_data,
	address,
	data_direction,
	
   MEMORY_CLK_P,
   MEMORY_CLKEN_N,
   MEMORY_WEN_N,
   MEMORY_WENA_N,
   MEMORY_WENB_N,
   MEMORY_WENC_N,
   MEMORY_WEND_N,
   MEMORY_ADV_LD_N,
   MEMORY_OEN_N,
   MEMORY_CEN_N,
   MEMORY_ADDR_P,
   MEMORY_DATA_A_P,
   MEMORY_DATA_B_P,
   MEMORY_DATA_C_P,
   MEMORY_DATA_D_P
);

input 				internal_clock;
input 				external_clock;
output reg [31:0]	read_data;
input		[31:0]	write_data;
input		[18:0]	address;
input 				data_direction;

output   			MEMORY_CLK_P;
output   			MEMORY_CLKEN_N;
output   			MEMORY_WEN_N;
output   			MEMORY_WENA_N;
output   			MEMORY_WENB_N;
output   			MEMORY_WENC_N;
output   			MEMORY_WEND_N;
output   			MEMORY_ADV_LD_N;
output   			MEMORY_OEN_N;
output   			MEMORY_CEN_N;

output   [18:0] 	MEMORY_ADDR_P;

inout		[7:0] 	MEMORY_DATA_A_P;
inout		[7:0] 	MEMORY_DATA_B_P;
inout		[7:0] 	MEMORY_DATA_C_P;
inout		[7:0] 	MEMORY_DATA_D_P;

tri		[7:0] 	MEMORY_DATA_A_P;
tri		[7:0] 	MEMORY_DATA_B_P;
tri		[7:0] 	MEMORY_DATA_C_P;
tri		[7:0] 	MEMORY_DATA_D_P;

// internal signals 
wire clken_at_ram;
wire wen_at_ram;
wire wena_at_ram;
wire wenb_at_ram;
wire wenc_at_ram;
wire wend_at_ram;
wire advld_at_ram;
wire oen_at_ram;
wire cen_at_ram;
wire wen;
wire oen;

wire [18:0] address_at_ram;
wire [31:0]	read_data_at_ram;
wire [31:0] write_data_at_ram;
wire [3:0] tristate_fanout;
wire [31:0] tristate_control;

reg [31:0] write_data_buffer_1;
reg [31:0] write_data_buffer_2;
wire [31:0] read_data_capture;
reg data_direction_buffer_1;

assign wen = data_direction;
assign clken_at_ram = 1'b0;
assign advld_at_ram = 1'b0;
assign cen_at_ram = 1'b0;

always @(posedge internal_clock) begin
	write_data_buffer_1 <= write_data;
	write_data_buffer_2 <= write_data_buffer_1;
	data_direction_buffer_1 <= data_direction;
end

always @(read_data_capture)
	read_data = read_data_capture;

FD tsfo_0 ( .Q(tristate_fanout[0]), .C(internal_clock), .D(data_direction_buffer_1));
FD tsfo_1 ( .Q(tristate_fanout[1]), .C(internal_clock), .D(data_direction_buffer_1));
FD tsfo_2 ( .Q(tristate_fanout[2]), .C(internal_clock), .D(data_direction_buffer_1));
FD tsfo_3 ( .Q(tristate_fanout[3]), .C(internal_clock), .D(data_direction_buffer_1));
FD oen_inv_buf ( .Q(oen), .C(internal_clock), .D(~data_direction_buffer_1));

FD FD_wen ( .Q(wen_at_ram), .C(internal_clock), .D(wen)); /* synthesis syn_useioff = 1*/
FD FD_wena ( .Q(wena_at_ram), .C(internal_clock), .D(wen)); /* synthesis syn_useioff = 1*/
FD FD_wenb ( .Q(wenb_at_ram), .C(internal_clock), .D(wen)); /* synthesis syn_useioff = 1*/
FD FD_wenc ( .Q(wenc_at_ram), .C(internal_clock), .D(wen)); /* synthesis syn_useioff = 1*/
FD FD_wend ( .Q(wend_at_ram), .C(internal_clock), .D(wen)); /* synthesis syn_useioff = 1*/
FD FD_oen ( .Q(oen_at_ram), .C(internal_clock), .D(oen)); /* synthesis syn_useioff = 1*/

FD addr_FD_buf_0 ( .Q(address_at_ram[0]), .C(internal_clock), .D(address[0])); /* synthesis syn_useioff = 1*/
FD addr_FD_buf_1 ( .Q(address_at_ram[1]), .C(internal_clock), .D(address[1])); /* synthesis syn_useioff = 1*/
FD addr_FD_buf_2 ( .Q(address_at_ram[2]), .C(internal_clock), .D(address[2])); /* synthesis syn_useioff = 1*/
FD addr_FD_buf_3 ( .Q(address_at_ram[3]), .C(internal_clock), .D(address[3])); /* synthesis syn_useioff = 1*/
FD addr_FD_buf_4 ( .Q(address_at_ram[4]), .C(internal_clock), .D(address[4])); /* synthesis syn_useioff = 1*/
FD addr_FD_buf_5 ( .Q(address_at_ram[5]), .C(internal_clock), .D(address[5])); /* synthesis syn_useioff = 1*/
FD addr_FD_buf_6 ( .Q(address_at_ram[6]), .C(internal_clock), .D(address[6])); /* synthesis syn_useioff = 1*/
FD addr_FD_buf_7 ( .Q(address_at_ram[7]), .C(internal_clock), .D(address[7])); /* synthesis syn_useioff = 1*/
FD addr_FD_buf_8 ( .Q(address_at_ram[8]), .C(internal_clock), .D(address[8])); /* synthesis syn_useioff = 1*/
FD addr_FD_buf_9 ( .Q(address_at_ram[9]), .C(internal_clock), .D(address[9])); /* synthesis syn_useioff = 1*/
FD addr_FD_buf_10 ( .Q(address_at_ram[10]), .C(internal_clock), .D(address[10])); /* synthesis syn_useioff = 1*/
FD addr_FD_buf_11 ( .Q(address_at_ram[11]), .C(internal_clock), .D(address[11])); /* synthesis syn_useioff = 1*/
FD addr_FD_buf_12 ( .Q(address_at_ram[12]), .C(internal_clock), .D(address[12])); /* synthesis syn_useioff = 1*/
FD addr_FD_buf_13 ( .Q(address_at_ram[13]), .C(internal_clock), .D(address[13])); /* synthesis syn_useioff = 1*/
FD addr_FD_buf_14 ( .Q(address_at_ram[14]), .C(internal_clock), .D(address[14])); /* synthesis syn_useioff = 1*/
FD addr_FD_buf_15 ( .Q(address_at_ram[15]), .C(internal_clock), .D(address[15])); /* synthesis syn_useioff = 1*/
FD addr_FD_buf_16 ( .Q(address_at_ram[16]), .C(internal_clock), .D(address[16])); /* synthesis syn_useioff = 1*/
FD addr_FD_buf_17 ( .Q(address_at_ram[17]), .C(internal_clock), .D(address[17])); /* synthesis syn_useioff = 1*/
FD addr_FD_buf_18 ( .Q(address_at_ram[18]), .C(internal_clock), .D(address[18])); /* synthesis syn_useioff = 1*/

FD read_data_buf_0 ( .Q(read_data_capture[0]), .C(internal_clock), .D(read_data_at_ram[0])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_1 ( .Q(read_data_capture[1]), .C(internal_clock), .D(read_data_at_ram[1])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_2 ( .Q(read_data_capture[2]), .C(internal_clock), .D(read_data_at_ram[2])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_3 ( .Q(read_data_capture[3]), .C(internal_clock), .D(read_data_at_ram[3])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_4 ( .Q(read_data_capture[4]), .C(internal_clock), .D(read_data_at_ram[4])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_5 ( .Q(read_data_capture[5]), .C(internal_clock), .D(read_data_at_ram[5])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_6 ( .Q(read_data_capture[6]), .C(internal_clock), .D(read_data_at_ram[6])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_7 ( .Q(read_data_capture[7]), .C(internal_clock), .D(read_data_at_ram[7])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_8 ( .Q(read_data_capture[8]), .C(internal_clock), .D(read_data_at_ram[8])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_9 ( .Q(read_data_capture[9]), .C(internal_clock), .D(read_data_at_ram[9])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_10 ( .Q(read_data_capture[10]), .C(internal_clock), .D(read_data_at_ram[10])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_11 ( .Q(read_data_capture[11]), .C(internal_clock), .D(read_data_at_ram[11])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_12 ( .Q(read_data_capture[12]), .C(internal_clock), .D(read_data_at_ram[12])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_13 ( .Q(read_data_capture[13]), .C(internal_clock), .D(read_data_at_ram[13])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_14 ( .Q(read_data_capture[14]), .C(internal_clock), .D(read_data_at_ram[14])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_15 ( .Q(read_data_capture[15]), .C(internal_clock), .D(read_data_at_ram[15])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_16 ( .Q(read_data_capture[16]), .C(internal_clock), .D(read_data_at_ram[16])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_17 ( .Q(read_data_capture[17]), .C(internal_clock), .D(read_data_at_ram[17])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_18 ( .Q(read_data_capture[18]), .C(internal_clock), .D(read_data_at_ram[18])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_19 ( .Q(read_data_capture[19]), .C(internal_clock), .D(read_data_at_ram[19])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_20 ( .Q(read_data_capture[20]), .C(internal_clock), .D(read_data_at_ram[20])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_21 ( .Q(read_data_capture[21]), .C(internal_clock), .D(read_data_at_ram[21])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_22 ( .Q(read_data_capture[22]), .C(internal_clock), .D(read_data_at_ram[22])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_23 ( .Q(read_data_capture[23]), .C(internal_clock), .D(read_data_at_ram[23])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_24 ( .Q(read_data_capture[24]), .C(internal_clock), .D(read_data_at_ram[24])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_25 ( .Q(read_data_capture[25]), .C(internal_clock), .D(read_data_at_ram[25])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_26 ( .Q(read_data_capture[26]), .C(internal_clock), .D(read_data_at_ram[26])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_27 ( .Q(read_data_capture[27]), .C(internal_clock), .D(read_data_at_ram[27])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_28 ( .Q(read_data_capture[28]), .C(internal_clock), .D(read_data_at_ram[28])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_29 ( .Q(read_data_capture[29]), .C(internal_clock), .D(read_data_at_ram[29])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_30 ( .Q(read_data_capture[30]), .C(internal_clock), .D(read_data_at_ram[30])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/
FD read_data_buf_31 ( .Q(read_data_capture[31]), .C(internal_clock), .D(read_data_at_ram[31])); /* synthesis syn_useioff = 1, synthesis attribute is "IFD"*/

FD write_data_buf_0 ( .Q(write_data_at_ram[0]), .C(internal_clock), .D(write_data_buffer_2[0])); /* synthesis syn_useioff = 1*/
FD write_data_buf_1 ( .Q(write_data_at_ram[1]), .C(internal_clock), .D(write_data_buffer_2[1])); /* synthesis syn_useioff = 1*/
FD write_data_buf_2 ( .Q(write_data_at_ram[2]), .C(internal_clock), .D(write_data_buffer_2[2])); /* synthesis syn_useioff = 1*/
FD write_data_buf_3 ( .Q(write_data_at_ram[3]), .C(internal_clock), .D(write_data_buffer_2[3])); /* synthesis syn_useioff = 1*/
FD write_data_buf_4 ( .Q(write_data_at_ram[4]), .C(internal_clock), .D(write_data_buffer_2[4])); /* synthesis syn_useioff = 1*/
FD write_data_buf_5 ( .Q(write_data_at_ram[5]), .C(internal_clock), .D(write_data_buffer_2[5])); /* synthesis syn_useioff = 1*/
FD write_data_buf_6 ( .Q(write_data_at_ram[6]), .C(internal_clock), .D(write_data_buffer_2[6])); /* synthesis syn_useioff = 1*/
FD write_data_buf_7 ( .Q(write_data_at_ram[7]), .C(internal_clock), .D(write_data_buffer_2[7])); /* synthesis syn_useioff = 1*/
FD write_data_buf_8 ( .Q(write_data_at_ram[8]), .C(internal_clock), .D(write_data_buffer_2[8])); /* synthesis syn_useioff = 1*/
FD write_data_buf_9 ( .Q(write_data_at_ram[9]), .C(internal_clock), .D(write_data_buffer_2[9])); /* synthesis syn_useioff = 1*/
FD write_data_buf_10 ( .Q(write_data_at_ram[10]), .C(internal_clock), .D(write_data_buffer_2[10])); /* synthesis syn_useioff = 1*/
FD write_data_buf_11 ( .Q(write_data_at_ram[11]), .C(internal_clock), .D(write_data_buffer_2[11])); /* synthesis syn_useioff = 1*/
FD write_data_buf_12 ( .Q(write_data_at_ram[12]), .C(internal_clock), .D(write_data_buffer_2[12])); /* synthesis syn_useioff = 1*/
FD write_data_buf_13 ( .Q(write_data_at_ram[13]), .C(internal_clock), .D(write_data_buffer_2[13])); /* synthesis syn_useioff = 1*/
FD write_data_buf_14 ( .Q(write_data_at_ram[14]), .C(internal_clock), .D(write_data_buffer_2[14])); /* synthesis syn_useioff = 1*/
FD write_data_buf_15 ( .Q(write_data_at_ram[15]), .C(internal_clock), .D(write_data_buffer_2[15])); /* synthesis syn_useioff = 1*/
FD write_data_buf_16 ( .Q(write_data_at_ram[16]), .C(internal_clock), .D(write_data_buffer_2[16])); /* synthesis syn_useioff = 1*/
FD write_data_buf_17 ( .Q(write_data_at_ram[17]), .C(internal_clock), .D(write_data_buffer_2[17])); /* synthesis syn_useioff = 1*/
FD write_data_buf_18 ( .Q(write_data_at_ram[18]), .C(internal_clock), .D(write_data_buffer_2[18])); /* synthesis syn_useioff = 1*/
FD write_data_buf_19 ( .Q(write_data_at_ram[19]), .C(internal_clock), .D(write_data_buffer_2[19])); /* synthesis syn_useioff = 1*/
FD write_data_buf_20 ( .Q(write_data_at_ram[20]), .C(internal_clock), .D(write_data_buffer_2[20])); /* synthesis syn_useioff = 1*/
FD write_data_buf_21 ( .Q(write_data_at_ram[21]), .C(internal_clock), .D(write_data_buffer_2[21])); /* synthesis syn_useioff = 1*/
FD write_data_buf_22 ( .Q(write_data_at_ram[22]), .C(internal_clock), .D(write_data_buffer_2[22])); /* synthesis syn_useioff = 1*/
FD write_data_buf_23 ( .Q(write_data_at_ram[23]), .C(internal_clock), .D(write_data_buffer_2[23])); /* synthesis syn_useioff = 1*/
FD write_data_buf_24 ( .Q(write_data_at_ram[24]), .C(internal_clock), .D(write_data_buffer_2[24])); /* synthesis syn_useioff = 1*/
FD write_data_buf_25 ( .Q(write_data_at_ram[25]), .C(internal_clock), .D(write_data_buffer_2[25])); /* synthesis syn_useioff = 1*/
FD write_data_buf_26 ( .Q(write_data_at_ram[26]), .C(internal_clock), .D(write_data_buffer_2[26])); /* synthesis syn_useioff = 1*/
FD write_data_buf_27 ( .Q(write_data_at_ram[27]), .C(internal_clock), .D(write_data_buffer_2[27])); /* synthesis syn_useioff = 1*/
FD write_data_buf_28 ( .Q(write_data_at_ram[28]), .C(internal_clock), .D(write_data_buffer_2[28])); /* synthesis syn_useioff = 1*/
FD write_data_buf_29 ( .Q(write_data_at_ram[29]), .C(internal_clock), .D(write_data_buffer_2[29])); /* synthesis syn_useioff = 1*/
FD write_data_buf_30 ( .Q(write_data_at_ram[30]), .C(internal_clock), .D(write_data_buffer_2[30])); /* synthesis syn_useioff = 1*/
FD write_data_buf_31 ( .Q(write_data_at_ram[31]), .C(internal_clock), .D(write_data_buffer_2[31])); /* synthesis syn_useioff = 1*/

FD tsfo_00 ( .Q(tristate_control[0]), .C(internal_clock), .D(tristate_fanout[0])); /* synthesis syn_useioff = 1*/
FD tsfo_01 ( .Q(tristate_control[1]), .C(internal_clock), .D(tristate_fanout[0])); /* synthesis syn_useioff = 1*/
FD tsfo_02 ( .Q(tristate_control[2]), .C(internal_clock), .D(tristate_fanout[0])); /* synthesis syn_useioff = 1*/
FD tsfo_03 ( .Q(tristate_control[3]), .C(internal_clock), .D(tristate_fanout[0])); /* synthesis syn_useioff = 1*/
FD tsfo_04 ( .Q(tristate_control[4]), .C(internal_clock), .D(tristate_fanout[0])); /* synthesis syn_useioff = 1*/
FD tsfo_05 ( .Q(tristate_control[5]), .C(internal_clock), .D(tristate_fanout[0])); /* synthesis syn_useioff = 1*/
FD tsfo_06 ( .Q(tristate_control[6]), .C(internal_clock), .D(tristate_fanout[0])); /* synthesis syn_useioff = 1*/
FD tsfo_07 ( .Q(tristate_control[7]), .C(internal_clock), .D(tristate_fanout[0])); /* synthesis syn_useioff = 1*/
FD tsfo_10 ( .Q(tristate_control[8]), .C(internal_clock), .D(tristate_fanout[1])); /* synthesis syn_useioff = 1*/
FD tsfo_11 ( .Q(tristate_control[9]), .C(internal_clock), .D(tristate_fanout[1])); /* synthesis syn_useioff = 1*/
FD tsfo_12 ( .Q(tristate_control[10]), .C(internal_clock), .D(tristate_fanout[1])); /* synthesis syn_useioff = 1*/
FD tsfo_13 ( .Q(tristate_control[11]), .C(internal_clock), .D(tristate_fanout[1])); /* synthesis syn_useioff = 1*/
FD tsfo_14 ( .Q(tristate_control[12]), .C(internal_clock), .D(tristate_fanout[1])); /* synthesis syn_useioff = 1*/
FD tsfo_15 ( .Q(tristate_control[13]), .C(internal_clock), .D(tristate_fanout[1])); /* synthesis syn_useioff = 1*/
FD tsfo_16 ( .Q(tristate_control[14]), .C(internal_clock), .D(tristate_fanout[1])); /* synthesis syn_useioff = 1*/
FD tsfo_17 ( .Q(tristate_control[15]), .C(internal_clock), .D(tristate_fanout[1])); /* synthesis syn_useioff = 1*/
FD tsfo_20 ( .Q(tristate_control[16]), .C(internal_clock), .D(tristate_fanout[2])); /* synthesis syn_useioff = 1*/
FD tsfo_21 ( .Q(tristate_control[17]), .C(internal_clock), .D(tristate_fanout[2])); /* synthesis syn_useioff = 1*/
FD tsfo_22 ( .Q(tristate_control[18]), .C(internal_clock), .D(tristate_fanout[2])); /* synthesis syn_useioff = 1*/
FD tsfo_23 ( .Q(tristate_control[19]), .C(internal_clock), .D(tristate_fanout[2])); /* synthesis syn_useioff = 1*/
FD tsfo_24 ( .Q(tristate_control[20]), .C(internal_clock), .D(tristate_fanout[2])); /* synthesis syn_useioff = 1*/
FD tsfo_25 ( .Q(tristate_control[21]), .C(internal_clock), .D(tristate_fanout[2])); /* synthesis syn_useioff = 1*/
FD tsfo_26 ( .Q(tristate_control[22]), .C(internal_clock), .D(tristate_fanout[2])); /* synthesis syn_useioff = 1*/
FD tsfo_27 ( .Q(tristate_control[23]), .C(internal_clock), .D(tristate_fanout[2])); /* synthesis syn_useioff = 1*/
FD tsfo_30 ( .Q(tristate_control[24]), .C(internal_clock), .D(tristate_fanout[3])); /* synthesis syn_useioff = 1*/
FD tsfo_31 ( .Q(tristate_control[25]), .C(internal_clock), .D(tristate_fanout[3])); /* synthesis syn_useioff = 1*/
FD tsfo_32 ( .Q(tristate_control[26]), .C(internal_clock), .D(tristate_fanout[3])); /* synthesis syn_useioff = 1*/
FD tsfo_33 ( .Q(tristate_control[27]), .C(internal_clock), .D(tristate_fanout[3])); /* synthesis syn_useioff = 1*/
FD tsfo_34 ( .Q(tristate_control[28]), .C(internal_clock), .D(tristate_fanout[3])); /* synthesis syn_useioff = 1*/
FD tsfo_35 ( .Q(tristate_control[29]), .C(internal_clock), .D(tristate_fanout[3])); /* synthesis syn_useioff = 1*/
FD tsfo_36 ( .Q(tristate_control[30]), .C(internal_clock), .D(tristate_fanout[3])); /* synthesis syn_useioff = 1*/
FD tsfo_37 ( .Q(tristate_control[31]), .C(internal_clock), .D(tristate_fanout[3])); /* synthesis syn_useioff = 1*/

OBUF_F_12 clk_buf ( .O(MEMORY_CLK_P), .I(external_clock));

OBUF_F_12 clken_buf ( .O(MEMORY_CLKEN_N), .I(clken_at_ram));
OBUF_F_12 wen_buf ( .O(MEMORY_WEN_N), .I(wen_at_ram));
OBUF_F_12 wena_buf ( .O(MEMORY_WENA_N), .I(wena_at_ram));
OBUF_F_12 wenb_buf ( .O(MEMORY_WENB_N), .I(wenb_at_ram));
OBUF_F_12 wenc_buf ( .O(MEMORY_WENC_N), .I(wenc_at_ram));
OBUF_F_12 wend_buf ( .O(MEMORY_WEND_N), .I(wend_at_ram));
OBUF_F_12 advld_buf ( .O(MEMORY_ADV_LD_N), .I(advld_at_ram));
OBUF_F_12 oen_buf ( .O(MEMORY_OEN_N), .I(oen_at_ram));
OBUF_F_12 cen_buf ( .O(MEMORY_CEN_N), .I(cen_at_ram));

OBUF_F_12 addr_buf_0 ( .O(MEMORY_ADDR_P[0]), .I(address_at_ram[0]));
OBUF_F_12 addr_buf_1 ( .O(MEMORY_ADDR_P[1]), .I(address_at_ram[1]));
OBUF_F_12 addr_buf_2 ( .O(MEMORY_ADDR_P[2]), .I(address_at_ram[2]));
OBUF_F_12 addr_buf_3 ( .O(MEMORY_ADDR_P[3]), .I(address_at_ram[3]));
OBUF_F_12 addr_buf_4 ( .O(MEMORY_ADDR_P[4]), .I(address_at_ram[4]));
OBUF_F_12 addr_buf_5 ( .O(MEMORY_ADDR_P[5]), .I(address_at_ram[5]));
OBUF_F_12 addr_buf_6 ( .O(MEMORY_ADDR_P[6]), .I(address_at_ram[6]));
OBUF_F_12 addr_buf_7 ( .O(MEMORY_ADDR_P[7]), .I(address_at_ram[7]));
OBUF_F_12 addr_buf_8 ( .O(MEMORY_ADDR_P[8]), .I(address_at_ram[8]));
OBUF_F_12 addr_buf_9 ( .O(MEMORY_ADDR_P[9]), .I(address_at_ram[9]));
OBUF_F_12 addr_buf_10 ( .O(MEMORY_ADDR_P[10]), .I(address_at_ram[10]));
OBUF_F_12 addr_buf_11 ( .O(MEMORY_ADDR_P[11]), .I(address_at_ram[11]));
OBUF_F_12 addr_buf_12 ( .O(MEMORY_ADDR_P[12]), .I(address_at_ram[12]));
OBUF_F_12 addr_buf_13 ( .O(MEMORY_ADDR_P[13]), .I(address_at_ram[13]));
OBUF_F_12 addr_buf_14 ( .O(MEMORY_ADDR_P[14]), .I(address_at_ram[14]));
OBUF_F_12 addr_buf_15 ( .O(MEMORY_ADDR_P[15]), .I(address_at_ram[15]));
OBUF_F_12 addr_buf_16 ( .O(MEMORY_ADDR_P[16]), .I(address_at_ram[16]));
OBUF_F_12 addr_buf_17 ( .O(MEMORY_ADDR_P[17]), .I(address_at_ram[17]));
OBUF_F_12 addr_buf_18 ( .O(MEMORY_ADDR_P[18]), .I(address_at_ram[18]));

IOBUF_F_12 IO_data_buf0 ( .O(read_data_at_ram[0]), .IO(MEMORY_DATA_A_P[0]), .I(write_data_at_ram[0]), .T(tristate_control[0]));
IOBUF_F_12 IO_data_buf1 ( .O(read_data_at_ram[1]), .IO(MEMORY_DATA_A_P[1]), .I(write_data_at_ram[1]), .T(tristate_control[1]));
IOBUF_F_12 IO_data_buf2 ( .O(read_data_at_ram[2]), .IO(MEMORY_DATA_A_P[2]), .I(write_data_at_ram[2]), .T(tristate_control[2]));
IOBUF_F_12 IO_data_buf3 ( .O(read_data_at_ram[3]), .IO(MEMORY_DATA_A_P[3]), .I(write_data_at_ram[3]), .T(tristate_control[3]));
IOBUF_F_12 IO_data_buf4 ( .O(read_data_at_ram[4]), .IO(MEMORY_DATA_A_P[4]), .I(write_data_at_ram[4]), .T(tristate_control[4]));
IOBUF_F_12 IO_data_buf5 ( .O(read_data_at_ram[5]), .IO(MEMORY_DATA_A_P[5]), .I(write_data_at_ram[5]), .T(tristate_control[5]));
IOBUF_F_12 IO_data_buf6 ( .O(read_data_at_ram[6]), .IO(MEMORY_DATA_A_P[6]), .I(write_data_at_ram[6]), .T(tristate_control[6]));
IOBUF_F_12 IO_data_buf7 ( .O(read_data_at_ram[7]), .IO(MEMORY_DATA_A_P[7]), .I(write_data_at_ram[7]), .T(tristate_control[7]));
IOBUF_F_12 IO_data_buf8 ( .O(read_data_at_ram[8]), .IO(MEMORY_DATA_B_P[0]), .I(write_data_at_ram[8]), .T(tristate_control[8]));
IOBUF_F_12 IO_data_buf9 ( .O(read_data_at_ram[9]), .IO(MEMORY_DATA_B_P[1]), .I(write_data_at_ram[9]), .T(tristate_control[9]));
IOBUF_F_12 IO_data_buf10 ( .O(read_data_at_ram[10]), .IO(MEMORY_DATA_B_P[2]), .I(write_data_at_ram[10]), .T(tristate_control[10]));
IOBUF_F_12 IO_data_buf11 ( .O(read_data_at_ram[11]), .IO(MEMORY_DATA_B_P[3]), .I(write_data_at_ram[11]), .T(tristate_control[11]));
IOBUF_F_12 IO_data_buf12 ( .O(read_data_at_ram[12]), .IO(MEMORY_DATA_B_P[4]), .I(write_data_at_ram[12]), .T(tristate_control[12]));
IOBUF_F_12 IO_data_buf13 ( .O(read_data_at_ram[13]), .IO(MEMORY_DATA_B_P[5]), .I(write_data_at_ram[13]), .T(tristate_control[13]));
IOBUF_F_12 IO_data_buf14 ( .O(read_data_at_ram[14]), .IO(MEMORY_DATA_B_P[6]), .I(write_data_at_ram[14]), .T(tristate_control[14]));
IOBUF_F_12 IO_data_buf15 ( .O(read_data_at_ram[15]), .IO(MEMORY_DATA_B_P[7]), .I(write_data_at_ram[15]), .T(tristate_control[15]));
IOBUF_F_12 IO_data_buf16 ( .O(read_data_at_ram[16]), .IO(MEMORY_DATA_C_P[0]), .I(write_data_at_ram[16]), .T(tristate_control[16]));
IOBUF_F_12 IO_data_buf17 ( .O(read_data_at_ram[17]), .IO(MEMORY_DATA_C_P[1]), .I(write_data_at_ram[17]), .T(tristate_control[17]));
IOBUF_F_12 IO_data_buf18 ( .O(read_data_at_ram[18]), .IO(MEMORY_DATA_C_P[2]), .I(write_data_at_ram[18]), .T(tristate_control[18]));
IOBUF_F_12 IO_data_buf19 ( .O(read_data_at_ram[19]), .IO(MEMORY_DATA_C_P[3]), .I(write_data_at_ram[19]), .T(tristate_control[19]));
IOBUF_F_12 IO_data_buf20 ( .O(read_data_at_ram[20]), .IO(MEMORY_DATA_C_P[4]), .I(write_data_at_ram[20]), .T(tristate_control[20]));
IOBUF_F_12 IO_data_buf21 ( .O(read_data_at_ram[21]), .IO(MEMORY_DATA_C_P[5]), .I(write_data_at_ram[21]), .T(tristate_control[21]));
IOBUF_F_12 IO_data_buf22 ( .O(read_data_at_ram[22]), .IO(MEMORY_DATA_C_P[6]), .I(write_data_at_ram[22]), .T(tristate_control[22]));
IOBUF_F_12 IO_data_buf23 ( .O(read_data_at_ram[23]), .IO(MEMORY_DATA_C_P[7]), .I(write_data_at_ram[23]), .T(tristate_control[23]));
IOBUF_F_12 IO_data_buf24 ( .O(read_data_at_ram[24]), .IO(MEMORY_DATA_D_P[0]), .I(write_data_at_ram[24]), .T(tristate_control[24]));
IOBUF_F_12 IO_data_buf25 ( .O(read_data_at_ram[25]), .IO(MEMORY_DATA_D_P[1]), .I(write_data_at_ram[25]), .T(tristate_control[25]));
IOBUF_F_12 IO_data_buf26 ( .O(read_data_at_ram[26]), .IO(MEMORY_DATA_D_P[2]), .I(write_data_at_ram[26]), .T(tristate_control[26]));
IOBUF_F_12 IO_data_buf27 ( .O(read_data_at_ram[27]), .IO(MEMORY_DATA_D_P[3]), .I(write_data_at_ram[27]), .T(tristate_control[27]));
IOBUF_F_12 IO_data_buf28 ( .O(read_data_at_ram[28]), .IO(MEMORY_DATA_D_P[4]), .I(write_data_at_ram[28]), .T(tristate_control[28]));
IOBUF_F_12 IO_data_buf29 ( .O(read_data_at_ram[29]), .IO(MEMORY_DATA_D_P[5]), .I(write_data_at_ram[29]), .T(tristate_control[29]));
IOBUF_F_12 IO_data_buf30 ( .O(read_data_at_ram[30]), .IO(MEMORY_DATA_D_P[6]), .I(write_data_at_ram[30]), .T(tristate_control[30]));
IOBUF_F_12 IO_data_buf31 ( .O(read_data_at_ram[31]), .IO(MEMORY_DATA_D_P[7]), .I(write_data_at_ram[31]), .T(tristate_control[31]));

endmodule
