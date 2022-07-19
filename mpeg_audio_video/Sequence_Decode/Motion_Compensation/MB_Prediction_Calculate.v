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
module MB_Prediction_Calculate(
	resetn,
	clock,
	
	Start_MB_Calculate_I,
	Done_MB_Calculate_O,
	Prediction_Indicator_I,

	FWD_Half_Pel_0_I,
	FWD_Half_Pel_1_I,
	BWD_Half_Pel_0_I,
	BWD_Half_Pel_1_I,
	
	FWD_Addr_0_O,
	FWD_Addr_1_O,
	BWD_Addr_0_O,
	BWD_Addr_1_O,

	FWD_Data_0_I,
	FWD_Data_1_I,
	BWD_Data_0_I,
	BWD_Data_1_I,
	
	Prediction_Address_I,
	Prediction_Data_O
);

input						resetn;
input						clock;

input						Start_MB_Calculate_I;
output					Done_MB_Calculate_O;
input 	[3:0]			Prediction_Indicator_I;

input 	[1:0]			FWD_Half_Pel_0_I;
input 	[1:0]			FWD_Half_Pel_1_I;
input 	[1:0]			BWD_Half_Pel_0_I;
input 	[1:0]			BWD_Half_Pel_1_I;

output 	[9:0]			FWD_Addr_0_O;
output 	[9:0]			FWD_Addr_1_O;
output 	[9:0]			BWD_Addr_0_O;
output 	[9:0]			BWD_Addr_1_O;

input 	[15:0]		FWD_Data_0_I;
input 	[15:0]		FWD_Data_1_I;
input 	[15:0]		BWD_Data_0_I;
input 	[15:0]		BWD_Data_1_I;

input 	[10:0]		Prediction_Address_I;
output	[7:0]			Prediction_Data_O;

reg		[3:0] 		row_counter;
reg		[1:0] 		column_counter;
reg		[3:0] 		block_counter;

reg 		[2:0]			state;
reg 						bank_sel_flag;
wire 						row_counter_limit;

assign Done_MB_Calculate_O = (state == `MB_PREDICT_CALC_IDLE);
assign row_counter_limit = (row_counter == 4'h8);

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		state <= `MB_PREDICT_CALC_IDLE;
		row_counter <= 4'h0;
		column_counter <= 2'h0;
		block_counter <= 4'h0;
		bank_sel_flag <= 1'b1;
	end else begin
		case (state)
			`MB_PREDICT_CALC_IDLE : begin
					if (Start_MB_Calculate_I) begin
						state <= `MB_PREDICT_CALC_CALC;
						row_counter <= 4'h0;
						column_counter <= 2'h0;
						block_counter <= 4'h0;
						bank_sel_flag <= ~bank_sel_flag;
					end
				end
			`MB_PREDICT_CALC_CALC : begin
					row_counter <= row_counter + 1;
					if (row_counter_limit) begin
						row_counter <= 4'h0;
						column_counter <= column_counter + 1;
						if (column_counter == 2'h3) begin
							if ((block_counter == 4'h3) | (block_counter == 4'h5)) begin
								row_counter <= 4'h0;
								state <= `MB_PREDICT_CALC_CROSS;
							end else block_counter <= block_counter + 1;
						end
					end
				end
			`MB_PREDICT_CALC_CROSS : begin
					row_counter <= row_counter + 1;
					if (row_counter == 4'h2) begin
						row_counter <= 4'h0;
						if (block_counter == 4'h3) begin
							block_counter <= block_counter + 1;
							state <= `MB_PREDICT_CALC_CALC;
						end else state <= `MB_PREDICT_CALC_IDLE;
					end 
				end
		endcase
	end
end

wire 		[9:0]			write_address;
wire 		[15:0]		write_data;
wire 						write_enable;

wire 		[10:0]		Sum_Data_0, Sum_Data_1;
wire 		[7:0]			AVG_Data_0, AVG_Data_1;
wire 		[3:0]			Half_pel_flags;

wire 		[9:0]			next_write_address;
wire 		[8:0]			retrieve_address;
wire 						Y_nCbCr;

reg 		[10:0]		Prev_Data_0, Prev_Data_1;
reg 		[9:0]			write_address_reg, write_address_delay;
reg 						write_enable_reg, write_enable_delay;

assign FWD_Addr_0_O = {1'b0,retrieve_address};
assign FWD_Addr_1_O = {1'b1,retrieve_address};
assign BWD_Addr_0_O = {1'b0,retrieve_address};
assign BWD_Addr_1_O = {1'b1,retrieve_address};

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		Prev_Data_0 <= 11'h000;
		Prev_Data_1 <= 11'h000;
		write_address_reg <= 10'h000; write_address_delay <= 10'h000;
		write_enable_reg <= 1'b0; write_address_delay <= 1'b0;
	end else begin
		Prev_Data_0 <= 
			((~Prediction_Indicator_I[0]) ? 11'h000 : 
				(Half_pel_flags[0]) ? 
					{3'h0,FWD_Data_0_I[15:8]} : 
					{2'h0,FWD_Data_0_I[15:8],1'b0}) + 
			((~Prediction_Indicator_I[1]) ? 11'h000 : 
				(Half_pel_flags[1]) ? 
					{3'h0,FWD_Data_1_I[15:8]} : 
					{2'h0,FWD_Data_1_I[15:8],1'b0}) + 
			((~Prediction_Indicator_I[2]) ? 11'h000 : 
				(Half_pel_flags[2]) ? 
					{3'h0,BWD_Data_0_I[15:8]} : 
					{2'h0,BWD_Data_0_I[15:8],1'b0}) + 
			((~Prediction_Indicator_I[3]) ? 11'h000 : 
				(Half_pel_flags[3]) ? 
					{3'h0,BWD_Data_1_I[15:8]} : 
					{2'h0,BWD_Data_1_I[15:8],1'b0});
		Prev_Data_1 <= 
			((~Prediction_Indicator_I[0]) ? 11'h000 : 
				(Half_pel_flags[0]) ? 
					{3'h0,FWD_Data_0_I[7:0]} : 
					{2'h0,FWD_Data_0_I[7:0],1'b0}) + 
			((~Prediction_Indicator_I[1]) ? 11'h000 : 
				(Half_pel_flags[1]) ? 
					{3'h0,FWD_Data_1_I[7:0]} : 
					{2'h0,FWD_Data_1_I[7:0],1'b0}) + 
			((~Prediction_Indicator_I[2]) ? 11'h000 : 
				(Half_pel_flags[2]) ? 
					{3'h0,BWD_Data_0_I[7:0]} : 
					{2'h0,BWD_Data_0_I[7:0],1'b0}) + 
			((~Prediction_Indicator_I[3]) ? 11'h000 : 
				(Half_pel_flags[3]) ? 
					{3'h0,BWD_Data_1_I[7:0]} : 
					{2'h0,BWD_Data_1_I[7:0],1'b0});

		write_address_reg <= next_write_address;
		write_address_delay <= write_address_reg;
		write_enable_delay <= write_enable_reg;
		if (state == `MB_PREDICT_CALC_CALC) begin
			if (row_counter == 4'h0) write_enable_reg <= 1'b1;
			if (row_counter_limit) write_enable_reg <= 1'b0;
		end
	end
end

Pred_Calc_Addr_Gen Address_Calculation(
	.Bank_Sel_Flag_I(bank_sel_flag),
	.Block_Counter_I(block_counter),
	.Row_Counter_I(row_counter),
	.Column_Counter_I(column_counter),
	.Write_Address_O(next_write_address),
	.Retrieve_Address_O(retrieve_address),
	.Y_nCbCr_O(Y_nCbCr)
);

assign Half_pel_flags = Prediction_Indicator_I & {
	BWD_Half_Pel_1_I[Y_nCbCr], 
	BWD_Half_Pel_0_I[Y_nCbCr],
	FWD_Half_Pel_1_I[Y_nCbCr],
	FWD_Half_Pel_0_I[Y_nCbCr]};

assign Sum_Data_0 = Prev_Data_0 + 
	((Prediction_Indicator_I == 4'b1111) ? 11'd4 : 
		(~^Prediction_Indicator_I) ? 11'd2 : 11'd1) + 
	((Half_pel_flags[3]) ? {3'h0,BWD_Data_1_I[15:8]} : 11'h000) + 
	((Half_pel_flags[2]) ? {3'h0,BWD_Data_0_I[15:8]} : 11'h000) + 
	((Half_pel_flags[1]) ? {3'h0,FWD_Data_1_I[15:8]} : 11'h000) + 
	((Half_pel_flags[0]) ? {3'h0,FWD_Data_0_I[15:8]} : 11'h000);
assign Sum_Data_1 = Prev_Data_1 + 
	((Prediction_Indicator_I == 4'b1111) ? 11'd4 : 
		(~^Prediction_Indicator_I) ? 11'd2 : 11'd1) + 
	((Half_pel_flags[3]) ? {3'h0,BWD_Data_1_I[7:0]} : 11'h000) + 
	((Half_pel_flags[2]) ? {3'h0,BWD_Data_0_I[7:0]} : 11'h000) + 
	((Half_pel_flags[1]) ? {3'h0,FWD_Data_1_I[7:0]} : 11'h000) + 
	((Half_pel_flags[0]) ? {3'h0,FWD_Data_0_I[7:0]} : 11'h000);
	
assign AVG_Data_0 = Sum_Data_0 >> (
	(Prediction_Indicator_I == 4'b1111) ? 3 : 
	(~^Prediction_Indicator_I) ? 2 : 1);
assign AVG_Data_1 = Sum_Data_1 >> (
	(Prediction_Indicator_I == 4'b1111) ? 3 : 
	(~^Prediction_Indicator_I) ? 2 : 1);

assign write_enable = write_enable_delay;
assign write_data = 
	(Prediction_Indicator_I == 4'h0) ? 16'h8080 : 
		{AVG_Data_1, AVG_Data_0} ;
assign write_address = write_address_delay;

Completed_Prediction_Buffer Prediction_Block_Buffer(
	.clock(clock),	
	.Write_En_A_I(write_enable),
	.Address_A_I(write_address),
	.Data_A_I(write_data),
	.Address_B_I(Prediction_Address_I),
	.Data_B_O(Prediction_Data_O)
);

endmodule
