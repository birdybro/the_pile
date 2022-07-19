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
module MB_Fetch_Prediction(
	resetn,
	clock,

	Start_MB_Fetch_I,
	Done_MB_Fetch_O,
	
	Image_Horizontal_I,
	
	Current_MB_Row_I,
	Current_MB_Column_I,
	Row_Offset_I,
	Column_Offset_I,

	Framestore_Address_O,
	Framestore_Data_I,
	Framestore_Busy_I,
	
	Write_Address_0_O,
	Write_Data_0_O,
	Write_En_0_O,

	Write_Address_1_O,
	Write_Data_1_O,
	Write_En_1_O,

	Half_pel_y_Y_O,
	Half_pel_y_CbCr_O
);

input                resetn;
input                clock;

input 					Start_MB_Fetch_I;
output 					Done_MB_Fetch_O;

input 	[11:0]		Image_Horizontal_I;

input 	[8:0]			Current_MB_Row_I;
input 	[9:0]			Current_MB_Column_I;
input 	[8:0]			Row_Offset_I;
input 	[9:0]			Column_Offset_I;

output reg [18:0]		Framestore_Address_O;
input 	[31:0]		Framestore_Data_I;
input 					Framestore_Busy_I;

output 	[8:0]			Write_Address_0_O;
output 	[15:0]		Write_Data_0_O;
output 					Write_En_0_O;

output 	[8:0]			Write_Address_1_O;
output 	[15:0]		Write_Data_1_O;
output 					Write_En_1_O;

output					Half_pel_y_Y_O;
output					Half_pel_y_CbCr_O;

reg	 	[18:0]		Mult_reg;

reg 		[1:0]			state;
reg 		[3:0]			counter_1;
reg 		[4:0]			counter_2;
reg 		[1:0]			counter_3;

wire 		[18:0]		Row_length;

assign Done_MB_Fetch_O = (state == `MB_PREDICT_FETCH_IDLE);

wire 		[18:0]		Cb_Offset, Cr_Offset;
reg 		[1:0] 		column_byte_offset;
reg 						half_pel_flag;
reg 						write_en_reg;

wire 		[3:0]			write_en_limit;
wire 		[3:0]			write_dis_limit;
wire 		[3:0]			complete_limit;
wire 		[3:0]			counter_1_limit;
wire 		[4:0]			counter_2_limit;

wire  	[8:0]			DY_adj;
wire  	[9:0]			DX_adj;
wire  	[8:0]			Curr_Row_Y;
wire  	[9:0]			Curr_Column_Y;
wire  	[8:0]			Curr_Row_CbCr;
wire  	[9:0]			Curr_Column_CbCr;
wire 						Half_pel_x_Y;
wire 						Half_pel_x_CbCr;

assign Cb_Offset = `ZBT_Cb_OFFSET;
assign Cr_Offset = `ZBT_Cr_OFFSET;

assign DY_adj = Row_Offset_I + Row_Offset_I[8];
assign DX_adj = Column_Offset_I + Column_Offset_I[9];

assign Curr_Row_Y = Current_MB_Row_I + {Row_Offset_I[8],Row_Offset_I[8:1]};
assign Curr_Row_CbCr = {1'b0,Current_MB_Row_I[8:1]} + {DY_adj[8],DY_adj[8],DY_adj[8:2]};
assign Curr_Column_Y = Current_MB_Column_I + {Column_Offset_I[9],Column_Offset_I[9:1]};
assign Curr_Column_CbCr = {1'b0,Current_MB_Column_I[9:1]} + {DX_adj[9],DX_adj[9],DX_adj[9:2]};

assign Half_pel_x_Y = Column_Offset_I[0];
assign Half_pel_x_CbCr = DX_adj[1];
assign Half_pel_y_Y_O = Row_Offset_I[0];
assign Half_pel_y_CbCr_O = DY_adj[1];

assign write_en_limit = (counter_3 == 2'h0) ? 4'd0 : 4'd0;
assign write_dis_limit = (counter_3 == 2'h0) ? 4'd4 : 4'd2;
assign complete_limit = (counter_3 == 2'h0) ? 4'd4 : 4'd2;

assign counter_1_limit = (counter_3 == 2'h0) ? 4'd4 : 4'd2;
assign counter_2_limit = (counter_3 == 2'h0) ? 5'd17 : 5'd9;

assign Row_length = (counter_3 == 2'h0) ? Image_Horizontal_I >> 2 : Image_Horizontal_I >> 3;

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		state <= `MB_PREDICT_FETCH_IDLE;
		Framestore_Address_O <= 19'h00000;
		counter_1 <= 4'h0;
		counter_2 <= 5'h00;
		counter_3 <= 2'h0;
		write_en_reg <= 1'b0;
		column_byte_offset <= 2'h0;
		half_pel_flag <= 1'b0;
		Mult_reg <= 19'h00000;
	end else begin
		case(state)
			`MB_PREDICT_FETCH_IDLE : begin
					if (Start_MB_Fetch_I) begin
						counter_3 <= 2'h0;
						write_en_reg <= 1'b0;
						column_byte_offset <= Curr_Column_Y[1:0];
						half_pel_flag <= Half_pel_x_Y;
						counter_2 <= Curr_Row_Y[8:4];
						counter_1 <= Curr_Row_Y[3:0];
						state <= `MB_PREDICT_FETCH_MULT;
						Framestore_Address_O <= 19'h00000;
						Mult_reg <= {7'h00,Image_Horizontal_I};
					end
				end
			`MB_PREDICT_FETCH_MULT : begin
					if ({counter_2,counter_1} == 9'h000) begin
						if (counter_3 == 2'h0) 
							Framestore_Address_O <= 
								(Framestore_Address_O + Curr_Column_Y) >> 2;
						else begin
							Framestore_Address_O <= Cb_Offset + ((
								Framestore_Address_O + Curr_Column_CbCr) >> 2);
							Mult_reg <= (Framestore_Address_O + Curr_Column_CbCr) >> 2;
						end
						state <= `MB_PREDICT_FETCH_FETCH;
					end else begin
						if (counter_1[0]) 
							Framestore_Address_O <= 
								Framestore_Address_O + Mult_reg;
						counter_1 <= {counter_2[0],counter_1[3:1]};
						counter_2 <= {1'b0,counter_2[4:1]};
						Mult_reg <= {Mult_reg[17:0],1'b0};
					end
				end
			`MB_PREDICT_FETCH_FETCH : begin
					if (~Framestore_Busy_I) begin
						counter_1 <= counter_1 + 1;
						Framestore_Address_O <= Framestore_Address_O + 1;
						if (counter_1 == write_en_limit) write_en_reg <= 1'b1;
						if (counter_1 == write_dis_limit) write_en_reg <= 1'b0;
						if (counter_1 == counter_1_limit) begin
							counter_1 <= 4'h0;
							counter_2 <= counter_2 + 1;
							Framestore_Address_O <= Framestore_Address_O + 
								Row_length - counter_1_limit;
							if (counter_2 == counter_2_limit) begin
								counter_2 <= 5'h00;
								if (counter_3 != 2'h1)
									state <= `MB_PREDICT_FETCH_COMPLETE;
								else begin
									counter_3 <= 2'h2;
									Framestore_Address_O <= Cr_Offset + Mult_reg;
								end
							end
						end
					end
				end
			`MB_PREDICT_FETCH_COMPLETE : begin
					if (~Framestore_Busy_I) begin
						counter_1 <= counter_1 + 1;
						if (counter_1 == write_dis_limit) write_en_reg <= 1'b0;
						if (counter_1 == complete_limit) begin
							if (counter_3 == 2'h2) begin
								state <= `MB_PREDICT_FETCH_IDLE;
								counter_3 <= 2'h0;
							end else begin
								counter_1 <= 4'h0;
								counter_3 <= 2'h1;
								column_byte_offset <= Curr_Column_CbCr[1:0];
								half_pel_flag <= Half_pel_x_CbCr;
								counter_2 <= Curr_Row_CbCr[8:4];
								counter_1 <= Curr_Row_CbCr[3:0];
								Mult_reg <= {1'b0,Image_Horizontal_I[11:1]};
								Framestore_Address_O <= 19'h00000;
								state <= `MB_PREDICT_FETCH_MULT;
							end
						end
					end
				end
		endcase
	end
end

reg 		[3:0]			busy_pipe;
reg		[2:0]			write_en_pipe;

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		busy_pipe <= 4'h0;
		write_en_pipe <= 3'h0;
	end else begin
		busy_pipe <= {Framestore_Busy_I,busy_pipe[3:1]};
		write_en_pipe <= {write_en_reg,write_en_pipe[2:1]};
	end
end

reg		[7:0]		buffer_1, buffer_0;

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		buffer_1 <= 8'h00; buffer_0 <= 8'h00;
	end else if (~busy_pipe[0]) begin
		buffer_0 <= Framestore_Data_I[7:0];
		buffer_1 <= Framestore_Data_I[15:8];
	end
end
		
reg 		[15:0]	ref_write_data_0;
reg 		[15:0]	ref_write_data_1;

always @(
	half_pel_flag,	column_byte_offset,
	Framestore_Data_I, buffer_1, buffer_0
) begin	
	ref_write_data_0 = 16'h0000;
	ref_write_data_1 = 16'h0000;
	if (~half_pel_flag) begin
		if (~column_byte_offset[0]) begin
			ref_write_data_0 = Framestore_Data_I[31:16];
			ref_write_data_1 = Framestore_Data_I[15:0];
		end else begin
			ref_write_data_0 = {buffer_0, Framestore_Data_I[31:24]};
			ref_write_data_1 = Framestore_Data_I[23:8];
		end
	end else begin
		if (~column_byte_offset[0]) begin
			ref_write_data_0[15:8] = (buffer_1 + buffer_0 + 1) >> 1;
			ref_write_data_0[7:0]  = (buffer_0 + Framestore_Data_I[31:24] + 1) >> 1;
			ref_write_data_1[15:8] = (Framestore_Data_I[31:24] + Framestore_Data_I[23:16] + 1) >> 1;
			ref_write_data_1[7:0]  = (Framestore_Data_I[23:16] + Framestore_Data_I[15:8] + 1) >> 1;
		end else begin
			ref_write_data_0[15:8] = (buffer_0 + Framestore_Data_I[31:24] + 1) >> 1;
			ref_write_data_0[7:0]  = (Framestore_Data_I[31:24] + Framestore_Data_I[23:16] + 1) >> 1;
			ref_write_data_1[15:8] = (Framestore_Data_I[23:16] + Framestore_Data_I[15:8] + 1) >> 1;
			ref_write_data_1[7:0]  = (Framestore_Data_I[15:8] + Framestore_Data_I[7:0] + 1) >> 1;
		end				
	end		
end

reg 					write_en_reg_delay;
wire 					write_en_delay;
wire 					write_en, write_en_0, write_en_1;
reg 		[7:0] 	write_address, write_address_delay;
reg 		[8:0]		write_address_0, write_address_1;

assign write_en = ~busy_pipe[0] & write_en_pipe[0];
assign write_en_delay = ~busy_pipe[0] & write_en_reg_delay;

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		write_address <= 8'h00;
		write_address_delay <= 8'h00;
		write_en_reg_delay <= 1'b0;
	end else begin
		if (~busy_pipe[0]) write_en_reg_delay <= write_en_pipe[0];
		if (state == `MB_PREDICT_FETCH_IDLE) write_address <= 8'h00;
		else if (write_en) begin
			write_address_delay <= write_address;
			case (write_address)
				8'd71 : write_address <= 8'd72;
				8'd91 : write_address <= 8'd144;
				default : write_address <= write_address + 1;
			endcase
		end
	end
end

assign write_en_0 = (~half_pel_flag & (column_byte_offset == 2'h0)) ? 
	write_en : write_en_delay;
assign write_en_1 = (~column_byte_offset[1] | (~half_pel_flag & (column_byte_offset == 2'h2))) ? 
	write_en : write_en_delay;

always @(
	write_address,	write_address_delay,
	half_pel_flag,	column_byte_offset
) begin
	write_address_0 = 8'h00;
	write_address_1 = 8'h00;
	if (~half_pel_flag) begin
		case (column_byte_offset) 
			2'h0 : begin
					write_address_0 = {write_address,1'b0};
					write_address_1 = {write_address,1'b1};
				end
			2'h1 : begin
					write_address_0 = {write_address_delay,1'b1};
					write_address_1 = {write_address,1'b0};
				end
			2'h2 : begin
					write_address_0 = {write_address_delay,1'b1};
					write_address_1 = {write_address,1'b0};
				end
			2'h3 : begin
					write_address_0 = {write_address_delay,1'b0};
					write_address_1 = {write_address_delay,1'b1};
				end
		endcase
	end else begin
		case (column_byte_offset) 
			2'h0 : begin
					write_address_0 = {write_address_delay,1'b1};
					write_address_1 = {write_address,1'b0};
				end
			2'h1 : begin
					write_address_0 = {write_address_delay,1'b1};
					write_address_1 = {write_address,1'b0};
				end
			2'h2 : begin
					write_address_0 = {write_address_delay,1'b0};
					write_address_1 = {write_address_delay,1'b1};
				end
			2'h3 : begin
					write_address_0 = {write_address_delay,1'b0};
					write_address_1 = {write_address_delay,1'b1};
				end
		endcase
	end
end

assign Write_Address_0_O = write_address_0;
assign Write_Address_1_O = write_address_1;

assign Write_Data_0_O = ref_write_data_0;
assign Write_Data_1_O = ref_write_data_1;

assign Write_En_0_O = write_en_0;
assign Write_En_1_O = write_en_1;

endmodule
