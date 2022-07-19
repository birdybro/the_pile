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
module SubBandSynthesis(
	clock,
	resetn,
	
	Start_Subband_I,
	Done_Subband_O,

	Sample_Data_O,
	Sample_Write_En_O,

	ROM_Enable_O,
	ROM_Address_O,
	ROM_Data_I,
	
	RAM_Address_O,
	RAM_Data_I,

	Subblock_I,
	Channel_I,

	Mult_OP_0_O,
	Mult_OP_1_O,
	Mult_Result_I	
);

input 				clock;
input 				resetn;

input 				Start_Subband_I;
output				Done_Subband_O;

output 	[15:0] 	Sample_Data_O;
output 				Sample_Write_En_O;

output				ROM_Enable_O;
output 	[9:0]		ROM_Address_O;
input 	[15:0]	ROM_Data_I;

output 	[9:0]		RAM_Address_O;
input 	[15:0]	RAM_Data_I;

input		[1:0]		Subblock_I;
input 				Channel_I;

output 	[17:0]	Mult_OP_0_O;
output 	[17:0] 	Mult_OP_1_O;
input 	[35:0]	Mult_Result_I;

reg 		[2:0] 	state;
reg 		[5:0]		i_count;
reg 		[4:0]		k_count;

reg 		[8:0]		address_reg; 
wire 		[7:0] 	offset_16;
reg 					sign;
reg 					zero;

wire 		[31:0] 	next_sum;
reg 		[31:0] 	sum;
reg 					sum_write;

assign Done_Subband_O = (state == `MP2_SUBBAND_IDLE);

wire [31:0] Sample_Data_post_round;
wire [20:0] Sample_Data_pre_clip;
assign Sample_Data_post_round = next_sum + 32'h400;
assign Sample_Data_pre_clip = Sample_Data_post_round[31:11];
assign Sample_Data_O = (Sample_Data_pre_clip[20]) ?
	(&Sample_Data_pre_clip[19:16]) ? Sample_Data_pre_clip[15:0] : 16'h8000 :
	(|Sample_Data_pre_clip[19:16]) ? 16'h7FFF : Sample_Data_pre_clip[15:0];

assign Sample_Write_En_O = sum_write & 
	((state == `MP2_SUBBAND_WINDOW) | (state == `MP2_SUBBAND_DELAY_2));

assign offset_16 = {2'b0,i_count} + 8'h10;

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		state <= `MP2_SUBBAND_IDLE;
		i_count <= 6'h00;
		k_count <= 5'h00;
		address_reg <= 9'h00;
		sum <= 32'h00000000;
		sum_write <= 1'b0;
		sign <= 1'b0;
		zero <= 1'b0;
	end else begin
		sum_write <= 1'b0;
		case(state)
			`MP2_SUBBAND_IDLE : begin
					if (Start_Subband_I) begin
						state <= `MP2_SUBBAND_FILTER;
						i_count <= 6'h00;
						k_count <= 5'h00;
						address_reg <= 9'h10;
					end
				end
			`MP2_SUBBAND_FILTER : begin
					sign <= address_reg[5] ^ address_reg[6];
					zero <= (address_reg[6:0] == 7'h20) | (address_reg[6:0] == 7'h60);
					if (k_count == 5'h00) sum <= 32'h00000000;
					else sum <= next_sum;
					k_count <= k_count + 1;
					address_reg <= address_reg + {offset_16,1'b0};
					if (k_count == 5'h1F) begin
						sum_write <= 1'b1;
						address_reg <= {1'b0,offset_16} + 1;
						i_count <= i_count + 1;
						if (i_count == 6'h3F) begin
							state <= `MP2_SUBBAND_DELAY_1;
						end
					end
				end
			`MP2_SUBBAND_DELAY_1 : begin
					state <= `MP2_SUBBAND_WINDOW;
					i_count <= 6'h00;
					k_count <= 5'h00;
					address_reg <= 9'h00;
				end
			`MP2_SUBBAND_WINDOW : begin
					sign <= i_count[3] & ({i_count[0],k_count} != 6'h00);
					zero <= (address_reg[7:0] == 8'h00);
					if (i_count[3:0] == 4'h0) sum <= 32'h00000000;
					else sum <= next_sum;
					i_count <= i_count + 1;
					address_reg <= address_reg + 1;
					if (i_count[3:0] == 4'hF) begin
						sum_write <= 1'b1;
						address_reg <= address_reg + 1;
						k_count <= k_count + 1;
						if (k_count == 5'h1F) begin
							state <= `MP2_SUBBAND_DELAY_2;
						end
					end
				end
			`MP2_SUBBAND_DELAY_2 : state <= `MP2_SUBBAND_IDLE;
		endcase
	end
end
 
wire		[7:0]		address_reg_adj;

assign next_sum = (zero) ? sum : (sign) ? 
	sum - Mult_Result_I[35:4] : sum + Mult_Result_I[35:4];

assign address_reg_adj = 
	(state == `MP2_SUBBAND_FILTER) ? 
		((address_reg[5]) ? -{3'h0,address_reg[4:0]} : {3'h0,address_reg[4:0]}) : 
		((i_count[3]) ? -{i_count[2:0],k_count} : {i_count[2:0],k_count});

assign ROM_Enable_O = 1'b1;
assign ROM_Address_O = (state == `MP2_SUBBAND_FILTER) ? 
	{5'h0B,address_reg_adj[4:0]} : {2'h0,address_reg_adj};
	
assign RAM_Address_O = 10'd768 + {2'h0,Subblock_I,Channel_I,k_count};

reg  		[3:0] 	window_pointer;
wire 		[5:0] 	window_write_offset;
wire 		[9:0] 	window_address;
wire 		[31:0] 	window_write_data_post_round;
wire 		[19:0] 	window_write_data_pre_clip;
wire 		[15:0] 	window_write_data;
wire 		[15:0] 	window_read_data;
wire 		[15:0] 	window_read_data_left;
wire 		[15:0] 	window_read_data_right;
wire 					window_write_en;
wire 					window_write_en_left;
wire 					window_write_en_right;

assign window_write_offset = i_count - 1;
assign window_write_data_post_round = next_sum + 32'h800;
assign window_write_data_pre_clip = window_write_data_post_round[31:12];
assign window_write_data = (window_write_data_pre_clip[19]) ?
	(&window_write_data_pre_clip[18:16]) ? window_write_data_pre_clip[15:0] : 16'h8000 :
	(|window_write_data_pre_clip[18:16]) ? 16'hFFFF : window_write_data_pre_clip[15:0];

assign window_write_en = sum_write & 
	((state == `MP2_SUBBAND_FILTER) | (state == `MP2_SUBBAND_DELAY_1));

assign window_address = 
	((state == `MP2_SUBBAND_FILTER) | (state == `MP2_SUBBAND_DELAY_1)) ? 
		{window_pointer,window_write_offset} : 
		{1'b0,i_count[3:0],k_count} + 
		 	{window_pointer,6'h00} +
			(({1'b0,i_count[3:0],5'h00} + 10'd32) & 10'h3C0);

always @(posedge clock or negedge resetn) begin
	if (~resetn) window_pointer <= 4'h0;
	else if (Channel_I & (state == `MP2_SUBBAND_DELAY_2))
		window_pointer <= window_pointer - 1;
end

assign window_write_en_left = ~Channel_I & window_write_en;
assign window_write_en_right = Channel_I & window_write_en;
assign window_read_data = (Channel_I) ? window_read_data_right : window_read_data_left;

Window_Buffer_RAM window_buffer_left(
	.clock(clock),
	.address(window_address),
	.data_I(window_write_data),
	.data_O(window_read_data_left),
	.write_en(window_write_en_left)	
);

Window_Buffer_RAM window_buffer_right(
	.clock(clock),
	.address(window_address),
	.data_I(window_write_data),
	.data_O(window_read_data_right),
	.write_en(window_write_en_right)	
);

assign Mult_OP_0_O = (state == `MP2_SUBBAND_WINDOW) ? 
	{ROM_Data_I[15],ROM_Data_I,1'b0} : {2'h0,ROM_Data_I};
assign Mult_OP_1_O = (state == `MP2_SUBBAND_WINDOW) ? 
	{window_read_data[15],window_read_data[15],window_read_data} : 
	{RAM_Data_I[15],RAM_Data_I[15],RAM_Data_I};

endmodule
