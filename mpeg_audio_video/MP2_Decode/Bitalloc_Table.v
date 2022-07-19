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
module Bitalloc_Table(
	clock,
	resetn, 
	
	Shift_Busy_I,
	
	Table_I, 
	index_i_I,
	index_j_I,
	
	SB_Limit_O,
	steps_MSB_O,
	steps_O,
	bits_O,
	group_O,
	quant_O,
	
	Table_En_O,
   Table_Address_O,
   Table_Data_I
);

input 				clock;
input 				resetn;

input 				Shift_Busy_I;

input		[2:0]		Table_I;
input 	[4:0] 	index_i_I;
input 	[3:0] 	index_j_I;

output 	[4:0] 	SB_Limit_O;
output 	[3:0] 	steps_MSB_O;
output 	[15:0] 	steps_O;
output 	[4:0] 	bits_O;
output 	[2:0]		group_O;
output 	[4:0]		quant_O;

output 				Table_En_O;
output 	[9:0]		Table_Address_O;
input 	[15:0]	Table_Data_I;

reg 		[4:0] 	SB_Limit_O;
reg 		[3:0] 	steps_MSB_O;
reg 	 	[15:0] 	steps_O;
reg 	 	[4:0] 	bits_O;
reg 	 	[2:0]		group_O;
reg 	 	[4:0]		quant_O;

always @(Table_I) begin
	SB_Limit_O = 5'h00;
	case(Table_I)
		3'h0 : SB_Limit_O = 5'd26; // 27
		3'h1 : SB_Limit_O = 5'd29; // 30 
		3'h2 : SB_Limit_O = 5'd7;  // 8
		3'h3 : SB_Limit_O = 5'd11; // 12
		3'h4 : SB_Limit_O = 5'd29; // 30
	endcase
end

wire 		[3:0] 	table_code;
reg 		[1:0] 	table_code_select;
reg 		[9:0] 	table_address;
wire 		[15:0] 	table_data;
reg 					bypass_flag;

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		table_code_select <= 2'h0;
		bypass_flag <= 1'b0;
	end else if (~Shift_Busy_I) begin
		table_code_select <= table_address[1:0];
		bypass_flag <= (index_j_I[3:1] == 3'h0);
	end
end

assign table_code = (table_code_select[1]) ?
	(table_code_select[0]) ? table_data[15:12] : table_data[11:8] : 
	(table_code_select[0]) ? table_data[7:4]   : table_data[3:0];
	
always @(table_code, bypass_flag) begin
	steps_MSB_O = 4'h0;
	steps_O = 16'h0000;
	bits_O = 5'h00;
	group_O = 3'h0;
	quant_O = 5'h00;
	if (bypass_flag) begin
		case(table_code[1:0])
			2'h0 : begin
					steps_MSB_O = 4'h1;
					steps_O = 16'h0003;
					bits_O = 5'h05;
					group_O = 3'h1;
					quant_O = 5'h00;
				end
			2'h1 : bits_O = 5'h04;
			2'h2 : bits_O = 5'h03;
			2'h3 : bits_O = 5'h02;
		endcase
	end else begin
		if (table_code == 4'hF) begin
			steps_MSB_O = 4'h3;
			steps_O = 16'h0009;
			bits_O = 5'h0A;
			group_O = 3'h1;
			quant_O = 5'h03;
		end else if (table_code == 4'hE) begin
			steps_MSB_O = 4'h2;
			steps_O = 16'h0005;
			bits_O = 5'h07;
			group_O = 3'h1;
			quant_O = 5'h01;
		end else begin
			steps_MSB_O = table_code + 2;
			steps_O = (8 << table_code) - 1;
			bits_O = table_code + 5'h03;
			group_O = 3'h3;
			if (table_code == 4'h0) quant_O = 5'h02;
			else quant_O = table_code + 5'h03;
		end
	end
end

always @(Table_I, index_i_I, index_j_I) begin
	table_address = 10'h000;
	case(Table_I[2:1])
		2'h0 : 
			if (index_i_I < 5'd11) table_address = {1'b0,index_i_I,index_j_I};
			else if (index_i_I < 5'd23) table_address = {2'b00,(index_i_I-5'd11),index_j_I[2:0]} + 10'd176;
			else table_address = {3'b000,(index_i_I-5'd23),index_j_I[1:0]} + 10'd272;
		2'h1 : 
			if (index_i_I < 5'd2) table_address = {1'b0,index_i_I,index_j_I} + 10'd300;
			else table_address = {2'b00,(index_i_I-5'd2),index_j_I[2:0]} + 10'd332;
		2'h2 : 
			if (index_i_I < 5'd4) table_address = {1'b0,index_i_I,index_j_I} + 10'd412;
			else if (index_i_I < 5'd11) table_address = {2'b00,(index_i_I-5'd4),index_j_I[2:0]} + 10'd476;
			else table_address = {3'b000,(index_i_I-5'd11),index_j_I[1:0]} + 10'd532;
	endcase
end

assign Table_En_O = ~Shift_Busy_I;
assign Table_Address_O = {2'h0,table_address[9:2]} + `BITALLOC_ROM_OFFSET;
assign table_data = Table_Data_I;

endmodule
