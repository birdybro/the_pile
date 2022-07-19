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
module Buffer_Deq_Denorm(
	clock,
	resetn,

	Buffer_Start_I,
	Denorm_Done_O,

	JS_Bound_I,
	SB_Limit_I,
	Scale_Block_I,
	
	Bitstream_Data_I,
	Shift_Busy_I,
	Shift_En_O,

	Alloc_index_i_O,
	Alloc_index_j_O,
	
	Alloc_steps_MSB_I,
	Alloc_steps_I,
	Alloc_bits_I,
	Alloc_group_I,
	Alloc_quant_I,
	
	Table_Enable_I,
	Table_Address_I,
	Table_Data_O,

	ROM_Enable_O,
	ROM_Address_O,
	ROM_Data_I,

	RAM_Address_O,
	RAM_Data_I,
	RAM_Wen_O,
	RAM_Data_O,
	
	Mult_OP_0_O,
	Mult_OP_1_O,
	Mult_Result_I
);

input 				clock;
input 				resetn;

input 				Buffer_Start_I;
output 				Denorm_Done_O;

input		[4:0] 	JS_Bound_I;
input 	[4:0] 	SB_Limit_I;
input 	[3:0] 	Scale_Block_I;

input 	[15:0] 	Bitstream_Data_I;
input 				Shift_Busy_I;
output 			 	Shift_En_O;

output 	[4:0] 	Alloc_index_i_O;
output 	[3:0] 	Alloc_index_j_O;

input 	[3:0] 	Alloc_steps_MSB_I;
input 	[15:0] 	Alloc_steps_I;
input 	[4:0] 	Alloc_bits_I;
input 	[2:0]		Alloc_group_I;
input 	[4:0]		Alloc_quant_I;

input 				Table_Enable_I;
input 	[9:0]		Table_Address_I;
output 	[15:0]	Table_Data_O;

output				ROM_Enable_O;
output 	[9:0]		ROM_Address_O;
input 	[15:0]	ROM_Data_I;

output reg [9:0]	RAM_Address_O;
input 	[15:0]	RAM_Data_I;
output 				RAM_Wen_O;
output 	[15:0]	RAM_Data_O;

output 	[17:0] 	Mult_OP_0_O;
output 	[17:0] 	Mult_OP_1_O;
input 	[35:0] 	Mult_Result_I;

reg 					ra_flag;
reg 					shift_disable;
reg 		[2:0] 	state;
reg 		[2:0] 	bit_alloc_reg;

reg 		[5:0] 	sample_counter;
reg 		[5:0] 	state_counter;
reg 		[5:0]		shift_counter;

reg 		[17:0]	temp1;
reg 		[16:0]	c_sample_reg;
reg 		[15:0] 	c_div_lev;

wire 		[9:0] 	c_address, d_address;
wire 		[9:0] 	multiple_address, sample_address;

assign ROM_Enable_O = Table_Enable_I;
assign ROM_Address_O = Table_Address_I;
assign Table_Data_O = ROM_Data_I;

assign Denorm_Done_O = (state == `MP2_BDD_IDLE);

wire [35:0] Mult_Result_Post_Round;
wire [20:0] Mult_Result_Pre_Clip;
assign Mult_Result_Post_Round = Mult_Result_I + 36'h4000;
assign Mult_Result_Pre_Clip = Mult_Result_Post_Round[35:15];
assign RAM_Data_O = (Mult_Result_Pre_Clip[20]) ?
	(&Mult_Result_Pre_Clip[19:16]) ? Mult_Result_Pre_Clip[15:0] : 16'h8000 :
	(|Mult_Result_Pre_Clip[19:16]) ? 16'h7FFF : Mult_Result_Pre_Clip[15:0];
assign RAM_Wen_O = (state == `MP2_BDD_DEQUANT) & (state_counter[2:0] == 3'h2);

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		state <= `MP2_BDD_IDLE;
		sample_counter <= 6'h00;
		state_counter <= 5'h00;
		shift_counter <= 5'h00;
		bit_alloc_reg <= 3'h0;
		RAM_Address_O <= 10'h000;
		shift_disable <= 1'b0;
		temp1 <= 18'h00000;
		ra_flag <= 1'b0;
		c_sample_reg <= 17'h0000;
		c_div_lev <= 16'h0000;
	end else if (~Shift_Busy_I) begin
		case (state)
			`MP2_BDD_IDLE : begin
					if (Buffer_Start_I) begin
						sample_counter <= 6'h00;
						state_counter <= 5'h00;
						state <= `MP2_BDD_IJSETUP;
						RAM_Address_O <= 10'd640;
					end
				end
			`MP2_BDD_IJSETUP : begin
					state_counter <= state_counter + 1;
					if (state_counter[2:0] == 3'h0) 
						RAM_Address_O <= 10'd640 + {3'h0,sample_counter,|Scale_Block_I[3:2]};
					if (state_counter[2:0] == 3'h1) bit_alloc_reg <= RAM_Data_I[2:0];
					if (state_counter[2:0] == 3'h2) begin
						state_counter <= 5'h00;
						c_sample_reg <= 17'h0000;
						ra_flag <= 1'b1;
						shift_disable <= 1'b0;
						
						if (bit_alloc_reg != 3'h0) begin
							shift_counter <= 5'd15;
							state <= `MP2_BDD_CSHIFT;
						end else begin
							state_counter <= 5'h01;
							state <= `MP2_BDD_DEQUANT;
						end
					end
				end
			`MP2_BDD_CSHIFT : begin
					ra_flag <= 1'b0;
					if (ra_flag) RAM_Address_O <= multiple_address;
					if (shift_disable) c_sample_reg <= {c_sample_reg[15:0],1'b0};
					else c_sample_reg <= {c_sample_reg[15:0],Bitstream_Data_I[15]};
					
					if (~shift_disable & 
						(shift_counter == ('d16 - Alloc_bits_I))
					) begin
						shift_disable <= 1'b1;
						if (Alloc_group_I != 3'h3) begin
							state <= `MP2_BDD_MODULUS;
							c_div_lev <= 16'h0000;				
						end		
					end

					if (shift_counter == 5'h00) begin
						state <= `MP2_BDD_DEQUANT;
						RAM_Address_O <= c_address;
					end else shift_counter <= shift_counter - 1;
				end
			`MP2_BDD_MODULUS : begin
					ra_flag <= 1'b0;
					if (ra_flag) RAM_Address_O <= multiple_address;
					if (c_sample_reg >= Alloc_steps_I) begin
						c_sample_reg <= c_sample_reg - Alloc_steps_I;
						c_div_lev <= c_div_lev + 1;
					end else begin
						state <= `MP2_BDD_CSHIFT;
						shift_disable <= 1'b1;
						shift_counter <= 5'd14 - Alloc_steps_MSB_I;
					end
				end
			`MP2_BDD_DEQUANT : begin
					state_counter <= state_counter + 1;
					if (state_counter[2:0] == 3'h0) begin
						shift_disable <= 1'b0;
						temp1 <= RAM_Data_I;
						RAM_Address_O <= d_address;
					end
					if (state_counter[2:0] == 3'h1) begin
						temp1 <= (bit_alloc_reg == 3'h0) ? 18'h00000 : 
							Mult_Result_Post_Round[31:15];
						RAM_Address_O <= sample_address;
						if (state_counter[4:3] == 2'h2) begin
							sample_counter <= sample_counter + 1;
							if (sample_counter == 6'h3F) shift_disable <= 1'b1;
						end
					end
					if (state_counter[2:0] == 3'h2) begin
						temp1 <= Mult_Result_Post_Round[31:15];
						if (state_counter[4:3] == 2'h2)
							RAM_Address_O <= 10'd640 + {3'h0,sample_counter,1'b0};
						else 
							RAM_Address_O <= 10'd640 + {3'h0,sample_counter,|Scale_Block_I[3:2]};
					end 
					if (state_counter[2:0] == 3'h3) begin
						state_counter[4:3] <= state_counter[4:3] + 1;
						if (state_counter[4:3] != 2'h2) begin
							state_counter[2:0] <= 3'h0;
							if (bit_alloc_reg != 3'h0) begin
								ra_flag <= 1'b1;
								if (Alloc_group_I != 3'h3) begin
									c_sample_reg <= {1'b0,c_div_lev};
									c_div_lev <= 16'h0000;
									state <= `MP2_BDD_MODULUS;								
								end else begin
									c_sample_reg <= 17'h00000;
									shift_disable <= 1'b0;
									shift_counter <= 5'd15;
									state <= `MP2_BDD_CSHIFT;
								end
							end else begin
								state_counter[2:0] <= 3'h1;
								state <= `MP2_BDD_DEQUANT;
							end
						end else begin
							state_counter <= 5'h00;
							if (shift_disable) state <= `MP2_BDD_IDLE;
							else state <= `MP2_BDD_IJSETUP;
						end
					end
				end
		endcase
	end
end

assign Shift_En_O = (state == `MP2_BDD_CSHIFT) & ~shift_disable;

assign sample_address = 10'd768 + {state_counter[4:3],sample_counter[0],sample_counter[5:1]};
assign multiple_address = 10'd256 + (
	(Scale_Block_I[2]) ? RAM_Data_I[5:0] : RAM_Data_I[13:8]);
assign c_address = 10'd320 + Alloc_quant_I;
assign d_address = 10'd335 + {
	4'h0, Alloc_quant_I[4:2],
	(Alloc_quant_I[4:2] == 3'h0) ? 
	(Alloc_quant_I[1:0] == 5'h2) ? 2'h3 : 2'h2 :
	Alloc_quant_I[1:0] };

assign Mult_OP_0_O = temp1;
assign Mult_OP_1_O = {2'h0,RAM_Data_I} + (
	(state_counter[2:0] == 3'h1) ? 18'h10000 : {{3{~c_sample_reg[15]}},c_sample_reg[14:0]} );

assign Alloc_index_i_O = sample_counter[5:1];
assign Alloc_index_j_O = 
	((state == `MP2_BDD_IJSETUP) & (state_counter[2:0] == 3'h1)) ? 
		RAM_Data_I[3:0] : {1'b0,bit_alloc_reg};

endmodule
