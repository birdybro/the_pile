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
module Vector_Decode(
   resetn,
   clock, 

   Start_I,
	Done_O,

	Data_In_I,
	Shift_En_O,

	Buffer_Value_O,
	Buffer_Write_En_O,

	Forward_I,
	Backward_I,
	Intra_I,
	Concealment_I,
	F_Codes_I,

   Coeff_Table_En_O,
   Coeff_Table_Addr_O,
   Coeff_Table_Data_I
);

input                resetn;
input                clock;

input                Start_I;
output 					Done_O;

input                Data_In_I;
output               Shift_En_O;

output   [31:0]		Buffer_Value_O;
output   				Buffer_Write_En_O;

input 					Forward_I;
input 					Backward_I;
input						Intra_I;
input 					Concealment_I;
input 	[15:0]		F_Codes_I;

output 					Coeff_Table_En_O;
output 	[9:0]			Coeff_Table_Addr_O;
input 	[15:0]		Coeff_Table_Data_I;

reg 		[2:0]			state;
reg 						R, S, T;
reg 		[3:0]			motion_vert_field_sel;
reg 		[2:0]			bit_counter;
reg 		[13:0]		motion_residual;
wire 		[12:0]		motion_residual_adj;
reg 						f_codes_flag;
reg 		[2:0]			f_codes_limit;

reg 						Vector_Start;
wire 						Vector_Shift;
wire 						Vector_Code_Valid;
reg  						Vector_Code_Valid_reg;
wire 		[5:0] 		Vector_Symbol;
wire 		[4:0] 		Vector_Symbol_Adj;
reg 						shift_en_reg;

assign Done_O = (state == `VECTOR_DECODE_IDLE);
assign Shift_En_O = 
	Vector_Shift | 
	(shift_en_reg & Vector_Symbol[4:0] != 5'h00) | 
	(state == `VECTOR_DECODE_RESIDUAL);
assign Buffer_Value_O = 
	(state == `VECTOR_DECODE_RESIDUAL) ? 
		{`INFO_MACRO_MOTION_VECTOR,R,S,T,1'b1,motion_residual[13],motion_residual_adj} : 
		{`INFO_MACRO_MOTION_VECTOR,R,S,T,1'b0,Vector_Symbol[5],8'h00,Vector_Symbol[4:0]};
assign Buffer_Write_En_O = (
		Vector_Code_Valid & 
		~Vector_Code_Valid_reg & 
		((Vector_Symbol[4:0] == 5'h00) | ~f_codes_flag)) |
	((state == `VECTOR_DECODE_RESIDUAL) & (bit_counter == 3'h0));

always @(posedge clock or negedge resetn) begin
	if (~resetn) Vector_Code_Valid_reg <= 1'b1;
	else Vector_Code_Valid_reg <= Vector_Code_Valid;
end

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		state <= `VECTOR_DECODE_IDLE;
		R <= 1'b0; S <= 1'b0; T <= 1'b0;
		motion_vert_field_sel <= 4'h0;
		Vector_Start <= 1'b0;
		shift_en_reg <= 1'b0;
		bit_counter <= 3'h0;
		motion_residual <= 14'h0000;
	end else begin
		case (state)
			`VECTOR_DECODE_IDLE : begin
					if (Start_I) begin
						if (Forward_I | (Intra_I & Concealment_I)) begin
							R <= 1'b0;
							S <= 1'b0;
							T <= 1'b0;
							state <= `VECTOR_DECODE_S;
						end else if (Backward_I) begin
							R <= 1'b0;
							S <= 1'b1;
							T <= 1'b0;
							state <= `VECTOR_DECODE_S;
						end
					end
				end
			`VECTOR_DECODE_R : begin
					motion_vert_field_sel[{R,S}] <= Data_In_I;
					state <= `VECTOR_DECODE_R;
				end
			`VECTOR_DECODE_S : begin
					Vector_Start <= 1'b1;
					state <= `VECTOR_DECODE_CODE;
				end
			`VECTOR_DECODE_CODE : begin
					Vector_Start <= 1'b0;
					if (Vector_Shift) shift_en_reg <= 1'b1;
					if (~Vector_Start & Vector_Code_Valid) begin
						shift_en_reg <= 1'b0;
						if ((Vector_Symbol[4:0] != 5'h00) & f_codes_flag) begin
							state <= `VECTOR_DECODE_RESIDUAL;
							motion_residual <= {Vector_Symbol[5],8'h00,Vector_Symbol_Adj};
							bit_counter <= f_codes_limit;
						end else if (1'b0) begin // dmv
							state <= `VECTOR_DECODE_DMVEC;
						end else begin
							if (T == 1'b0) begin
								Vector_Start <= 1'b1;
								T <= 1'b1;
							end else if (S == 1'b0) begin
								if (Backward_I) begin
									S <= 1'b1;
									T <= 1'b0;
									state <= `VECTOR_DECODE_S;
								end else state <= `VECTOR_DECODE_IDLE;
//							end else if (R == 1'b0) begin
//								R <= 1'b1;
//								state <= `VECTOR_DECODE_S;
							end else state <= `VECTOR_DECODE_IDLE;
						end
					end
				end
			`VECTOR_DECODE_RESIDUAL : begin
					motion_residual <= {motion_residual[13],motion_residual[11:0],Data_In_I};
					bit_counter <= bit_counter - 1;
					if (bit_counter == 3'h0) begin
						if (T == 1'b0) begin
							Vector_Start <= 1'b1;
							T <= 1'b1;
							state <= `VECTOR_DECODE_CODE;
						end else if (S == 1'b0) begin
							if (Backward_I) begin
								S <= 1'b1;
								T <= 1'b0;
								state <= `VECTOR_DECODE_S;
							end else state <= `VECTOR_DECODE_IDLE;
//							end else if (S == 1'b0) begin
//								S <= 1'b1;
//								state <= `VECTOR_DECODE_S;
						end else state <= `VECTOR_DECODE_IDLE;
					end					
				end
			`VECTOR_DECODE_DMVEC : begin
				end
		endcase
	end
end

assign Vector_Symbol_Adj = Vector_Symbol[4:0] - 5'd1;
assign motion_residual_adj = {motion_residual[11:0],Data_In_I} + 13'd1;

always @(F_Codes_I, S, T) begin
	f_codes_flag = 1'b0;
	f_codes_limit = 1'b0;
	case ({S,T})
		2'h0 : begin
				f_codes_limit = F_Codes_I[15:12] - 4'h2;
				if (F_Codes_I[15:12] != 4'h1) f_codes_flag = 1'b1;
			end
		2'h1 : begin
				f_codes_limit = F_Codes_I[11:8] - 4'h2;
				if (F_Codes_I[11:8] != 4'h1) f_codes_flag = 1'b1;
			end
		2'h2 : begin
				f_codes_limit = F_Codes_I[7:4] - 4'h2;
				if (F_Codes_I[7:4] != 4'h1) f_codes_flag = 1'b1;
			end
		2'h3 : begin
				f_codes_limit = F_Codes_I[3:0] - 4'h2;
				if (F_Codes_I[3:0] != 4'h1) f_codes_flag = 1'b1;
			end
	endcase
end

Macroblock_Decode_Vectors Macroblock_Vector_Decoder(
   .resetn(resetn),
   .clock(clock),
   .Start_I(Vector_Start),
   .Data_In_I(Data_In_I),
   .Shift_En_O(Vector_Shift),
   .Valid_Code_O(Vector_Code_Valid),
   .Symbol_O(Vector_Symbol),
   .Coeff_Table_En_O(Coeff_Table_En_O),
   .Coeff_Table_Addr_O(Coeff_Table_Addr_O),
   .Coeff_Table_Data_I(Coeff_Table_Data_I)
);

endmodule
