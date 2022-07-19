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
module Decode_Bitalloc_Scale (
	clock, 
	resetn,
	
	Bitalloc_Start_I,
	Scale_Done_O,

	JS_Bound_I,
	SB_Limit_I,
	
	Bitstream_Data_I,
	Shift_Busy_I,
	Shift_En_O,

	Alloc_index_i_O,
	Alloc_index_j_O,
	Alloc_bits_I,

	Table_Enable_I,
	Table_Address_I,
	Table_Data_O,

	ROM_Enable_O,
	ROM_Address_O,
	ROM_Data_I,

	RAM_Address_O,
	RAM_Data_I,
	RAM_Wen_O,
	RAM_Data_O
);

input 				clock;
input 				resetn;

input 				Bitalloc_Start_I;
output 				Scale_Done_O;

input		[4:0] 	JS_Bound_I;
input 	[4:0] 	SB_Limit_I;

input 	[15:0] 	Bitstream_Data_I;
input 				Shift_Busy_I;
output 				Shift_En_O;

output 	[4:0] 	Alloc_index_i_O;
output 	[3:0] 	Alloc_index_j_O;
input 	[4:0] 	Alloc_bits_I;
	
input 				Table_Enable_I;
input 	[9:0]		Table_Address_I;
output 	[15:0]	Table_Data_O;

output				ROM_Enable_O;
output 	[9:0]		ROM_Address_O;
input 	[15:0]	ROM_Data_I;

output reg [9:0]	RAM_Address_O;
input 	[15:0]	RAM_Data_I;
output wire			RAM_Wen_O;
output reg [15:0]	RAM_Data_O;

wire 		[15:0]	RAM_Data_I_hold;
reg 		[15:0]	RAM_Data_I_hold_reg;

reg 		[2:0] 	state;
reg 		[7:0]		counter;
reg 		[7:0]		shift_counter;
reg 					sb_limit_flag;
reg 					shift_disable;

reg 					write_enable;
reg 					write_enable_hold;
reg 					bit_alloc_reg;
reg 		[1:0]		scfsi_reg;

assign Alloc_index_i_O = counter[5:1];
assign Alloc_index_j_O = 4'h0;

assign ROM_Enable_O = Table_Enable_I;
assign ROM_Address_O = 
	(
		(state == `MP2_BITALLOC_IDLE) | 
		(state == `MP2_BITALLOC_SETUP) | 
		(state == `MP2_BITALLOC_DECODE)
	) ? Table_Address_I : 
	(
		(state == `MP2_SCALE_SETUP) |
		(state == `MP2_SCALE_SCFSI) 
	) ? 10'h000 : 10'h000;
	
assign Table_Data_O = ROM_Data_I;

assign Scale_Done_O = (state == `MP2_BITALLOC_IDLE);
assign Shift_En_O = 
	(state == `MP2_BITALLOC_SETUP) | 
	((state == `MP2_BITALLOC_DECODE) & 
		~(shift_disable | (sb_limit_flag & (shift_counter == 8'h00)))) |
	((state == `MP2_SCALE_SCFSI) & (RAM_Data_I_hold != 16'h0000) & ~shift_disable) |
	((state == `MP2_SCALE_INDEX) & 
		(
			(shift_counter[7:5] == 3'h4) | 
			(shift_counter[7:5] == 3'h5) | 
			(shift_counter[7:5] == 3'h6)
		) & (shift_counter[4:0] != 5'd0));

assign RAM_Wen_O = 
	((state == `MP2_BITALLOC_DECODE) & (shift_counter == 8'h00)) |
	(((state == `MP2_SCALE_SCFSI) | (state == `MP2_SCALE_TAKEDOWN)) & write_enable) | 
	((state == `MP2_SCALE_INDEX) & 
		(
			(shift_counter[7:5] == 3'h4) | 
			(shift_counter[7:5] == 3'h6)
		) & (shift_counter[4:0] == 5'd0));

assign RAM_Data_I_hold = (write_enable_hold) ? 
	RAM_Data_I_hold_reg : RAM_Data_I;

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		state <= `MP2_BITALLOC_IDLE;
		counter <= 8'h00;
		shift_counter <= 8'h00;
		RAM_Address_O <= 10'h000;
		RAM_Data_O <= 16'h0000;
		RAM_Data_I_hold_reg <= 16'h0000;
		sb_limit_flag <= 1'b0;
		shift_disable <= 1'b0;
		write_enable <= 1'b0;
		write_enable_hold <= 1'b0;
		bit_alloc_reg <= 1'b0;
		scfsi_reg <= 2'b00;
	end else if (~Shift_Busy_I) begin
		RAM_Data_I_hold_reg <= RAM_Data_I;
		write_enable_hold <= write_enable;
		case (state) 
			`MP2_BITALLOC_IDLE : begin
					counter <= 8'h00;
					shift_counter <= 8'h00;
					sb_limit_flag <= 1'b0;
					shift_disable <= 1'b0;
					write_enable <= 1'b0;
					if (Bitalloc_Start_I) state <= `MP2_BITALLOC_SETUP;
				end
			`MP2_BITALLOC_SETUP : begin
					RAM_Data_O <= {RAM_Data_O[14:0],Bitstream_Data_I[15]};
					shift_counter <= Alloc_bits_I - 1;
					counter <= counter + 1;
					state <= `MP2_BITALLOC_DECODE;
					RAM_Address_O <= 10'd640;
				end
			`MP2_BITALLOC_DECODE : begin
					if (~shift_disable) begin
						RAM_Data_O <= {RAM_Data_O[14:0],Bitstream_Data_I[15]};
						shift_counter <= shift_counter - 1;
						if (shift_counter == 8'h00) begin
							shift_counter <= Alloc_bits_I - 1;
							counter <= counter + 1;
							RAM_Address_O <= RAM_Address_O + 2;
							RAM_Data_O <= {15'h0000,Bitstream_Data_I[15]};
							if (counter == {SB_Limit_I,1'b1}) sb_limit_flag <= 1'b1;
							if (sb_limit_flag) begin
								shift_disable <= 1'b1;
								RAM_Data_O <= 16'h0000;
								shift_counter <= 8'h00;
								counter <= counter;
							end
						end
					end else begin
						counter <= counter + 1;	
						RAM_Address_O <= RAM_Address_O + 2;				
					end
					if (counter == 8'h3F) begin
						state <= `MP2_SCALE_SETUP;
						sb_limit_flag <= 1'b0;
						shift_disable <= 1'b0;
						RAM_Address_O <= 10'd640;
					end
				end
			`MP2_SCALE_SETUP : begin
					state <= `MP2_SCALE_SCFSI;
					counter <= 8'h00;
					RAM_Data_O <= {RAM_Data_O[14:0],Bitstream_Data_I[15]};
					write_enable <= 1'b0;
					shift_counter <= RAM_Address_O - 10'd640;
				end
			`MP2_SCALE_SCFSI : begin
					write_enable <= 1'b0;
					shift_disable <= 1'b0;
					if (RAM_Data_I_hold == 16'h0000) RAM_Data_O <= {RAM_Data_O[14:0],1'b0};
					else RAM_Data_O <= {RAM_Data_O[14:0],Bitstream_Data_I[15]};
					counter <= counter + 1;
					if (~counter[0]) 
						if (counter[3:1] == 3'h0) RAM_Address_O <= 10'd640 + shift_counter + 10'd2;
						else RAM_Address_O <= RAM_Address_O + 2;
					if (counter[3:0] == 4'hF) begin
						write_enable <= 1'b1;
						shift_counter <= RAM_Address_O - 10'd640;
						RAM_Address_O <= 10'd960 + counter[6:4];
					end
					if (write_enable & (RAM_Data_I_hold == 16'h0000)) shift_disable <= 1'b1;
					if (counter == 8'h7F) state <= `MP2_SCALE_TAKEDOWN;
				end
			`MP2_SCALE_TAKEDOWN : begin	
					sb_limit_flag <= 1'b0;
					write_enable <= 1'b0;
					state <= `MP2_SCALE_INDEX;
					counter <= 8'h00;
					shift_counter <= 8'h00;
				end
			`MP2_SCALE_INDEX : begin
					shift_counter[7:5] <= shift_counter[7:5] + 1;
					case(shift_counter[7:5])
						3'h0 : RAM_Address_O <= 10'd960 + {5'h00,counter[7:3]};
						3'h1 : RAM_Address_O <= 10'd640 + {1'b0,counter[7:0],1'b0};
						3'h2 : begin
								case(counter[2:0])
									3'h0 : scfsi_reg <= RAM_Data_I[15:14];
									3'h1 : scfsi_reg <= RAM_Data_I[13:12];
									3'h2 : scfsi_reg <= RAM_Data_I[11:10];
									3'h3 : scfsi_reg <= RAM_Data_I[9:8];
									3'h4 : scfsi_reg <= RAM_Data_I[7:6];
									3'h5 : scfsi_reg <= RAM_Data_I[5:4];
									3'h6 : scfsi_reg <= RAM_Data_I[3:2];
									3'h7 : scfsi_reg <= RAM_Data_I[1:0];
								endcase
							end
						3'h3 : begin 
								bit_alloc_reg <= (RAM_Data_I != 16'h0000);			
								RAM_Data_O <= {2'h0,6'h3F,RAM_Data_I[7:0]};
								if (RAM_Data_I != 16'h0000) begin
									shift_counter[4:0] <= 5'd6;
								end else shift_counter[4:0] <= 5'd0;
							end
						3'h4 : begin // obtain first scfsi value
								if (shift_counter[4:0] == 5'd0) begin
									RAM_Address_O <= 10'd640 + {1'b0,counter[7:0],1'b1};
									if (bit_alloc_reg) begin
										if ((scfsi_reg == 2'h0) | (scfsi_reg == 2'h3)) 
											shift_counter[4:0] <= 5'd6;
										else shift_counter[4:0] <= 5'd0;
										if ((scfsi_reg == 1) | (scfsi_reg == 2))
											RAM_Data_O <= {2'h0,6'h3F,RAM_Data_O[15:8]};
										else RAM_Data_O <= {2'h0,6'h3F,2'h0,6'h3F};
									end else begin
										shift_counter[4:0] <= 6'd0;
										RAM_Data_O <= {2'h0,6'h3F,2'h0,6'h3F};
									end
								end else begin
									shift_counter[7:5] <= shift_counter[7:5];
									RAM_Data_O <= {2'h0,RAM_Data_O[12:8],Bitstream_Data_I[15],RAM_Data_O[7:0]};
									shift_counter[4:0] <= shift_counter[4:0] - 1;
								end
							end
						3'h5 : begin // obtain second scfsi value
								if (shift_counter[4:0] == 5'd0) begin
									if (bit_alloc_reg) begin
										if ((scfsi_reg == 2'h0) | (scfsi_reg == 2'h1)) 
											shift_counter[4:0] <= 5'd6;
										else shift_counter[4:0] <= 5'd0;
										if ((scfsi_reg == 3) | (scfsi_reg == 2))
											RAM_Data_O <= {RAM_Data_O[7:0],RAM_Data_O[7:0]};
										else RAM_Data_O <= {2'h0,6'h3F,RAM_Data_O[7:0]};
									end else shift_counter[4:0] <= 6'd0;
								end else begin
									shift_counter[7:5] <= shift_counter[7:5];
									RAM_Data_O <= {RAM_Data_O[15:8],2'h0,RAM_Data_O[4:0],Bitstream_Data_I[15]};
									shift_counter[4:0] <= shift_counter[4:0] - 1;
								end
							end
						3'h6 : begin // obtain third scfsi value
								if (shift_counter[4:0] == 5'd0) begin
									if (counter == 8'h3F) state <= `MP2_BITALLOC_IDLE;
									else counter <= counter + 1;
									shift_counter[7:5] <= 3'h0;
								end else begin
									shift_counter[7:5] <= shift_counter[7:5];
									RAM_Data_O <= {2'h0,RAM_Data_O[12:8],Bitstream_Data_I[15],RAM_Data_O[7:0]};
									shift_counter[4:0] <= shift_counter[4:0] - 1;
								end
							end
					endcase
				end				
		endcase
	end
end
			
endmodule
