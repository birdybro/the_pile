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
module Block_Inverse_Quantisation(
   resetn,
   clock,

   Start_Inverse_Quantisation_I,
   Done_Inverse_Quantisation_O,

   Macroblock_Intra_I,
   Intra_DC_Precision_I,
   Quant_Scale_Type_I,
   Quant_Scale_Code_I,
   Alternate_Scan_I,
	Load_Seq_Intra_Quant_I,
	Load_Seq_NIntra_Quant_I,   

   Advance_Coeff_Address_O,
   Coeff_Buffer_Data_I,

   Block_Retrieve_Write_En_O,
   Block_Retrieve_Address_O,
   Block_Retrieve_Data_O
);

input                resetn;
input                clock;

input                Start_Inverse_Quantisation_I;
output               Done_Inverse_Quantisation_O;

input 					Macroblock_Intra_I;
input 	[1:0]			Intra_DC_Precision_I;
input                Quant_Scale_Type_I;
input    [4:0]       Quant_Scale_Code_I;
input 					Alternate_Scan_I;
input 					Load_Seq_Intra_Quant_I;
input 					Load_Seq_NIntra_Quant_I;

output               Advance_Coeff_Address_O;
input    [31:0]      Coeff_Buffer_Data_I;

output               Block_Retrieve_Write_En_O;
output reg [5:0]     Block_Retrieve_Address_O;
output   [11:0]      Block_Retrieve_Data_O;

wire     [13:0]      Coeff_Code;
wire     [5:0]       Coeff_Run;
wire     [11:0]      Coeff_Level;

reg      [5:0]       Curr_Coeff_Pos;
wire     [5:0]       next_Curr_Coeff_Pos;
reg      [6:0]       state_counter;
wire     [6:0]       next_state_counter;
wire                 next_advance_Coeff_Pos;
reg                  advance_Coeff_Pos;

assign Done_Inverse_Quantisation_O = (state_counter == 7'h00);
assign next_state_counter = state_counter + 1;
assign next_advance_Coeff_Pos = 
   ((state_counter[6:1] == Curr_Coeff_Pos) & state_counter[0]);
assign Advance_Coeff_Address_O = 
   ((state_counter != 7'h00) | Start_Inverse_Quantisation_I) &
   ((state_counter[6:1] == next_Curr_Coeff_Pos) & ~state_counter[0]);

assign next_Curr_Coeff_Pos = advance_Coeff_Pos ? 
   ((Coeff_Code == `INFO_BLOCK_CODE_EOB) & (state_counter[6:1] != 6'h00)) ? 6'h3F : 
   (state_counter == 7'h00) ? Coeff_Run : Curr_Coeff_Pos + Coeff_Run + 1 : Curr_Coeff_Pos;

assign Coeff_Code = Coeff_Buffer_Data_I[31:18];
assign Coeff_Run = Coeff_Buffer_Data_I[17:12];
assign Coeff_Level = Coeff_Buffer_Data_I[11:0];

always @(posedge clock or negedge resetn) begin
   if (~resetn) begin
      Curr_Coeff_Pos <= 6'h00;
      state_counter <= 7'h00;
      advance_Coeff_Pos <= 1'b0;
   end else begin
      if (
			(state_counter != 7'h00) | 
         (Start_Inverse_Quantisation_I & 
				((Coeff_Code == `INFO_BLOCK_CODE) | 
				(Coeff_Code == `INFO_BLOCK_CODE_EOB)))
		) begin
         Curr_Coeff_Pos <= next_Curr_Coeff_Pos;         
         advance_Coeff_Pos <= next_advance_Coeff_Pos;
         state_counter <= next_state_counter;
      end
   end
end

wire                 Quant_Scan_En;
wire     [10:0]      Quant_Scan_Address;
reg 		[4:0]			Quant_Offset;
wire     [7:0]       Quant_Scan_Data;

assign Quant_Scan_En = 1'b1;
assign Quant_Scan_Address = ~state_counter[0] ? 
   {4'h0,Alternate_Scan_I,state_counter[6:1]} : 
   {Quant_Offset,Quant_Scan_Data[5:0]};

always @(
	Macroblock_Intra_I,
	Load_Seq_Intra_Quant_I,
	Load_Seq_NIntra_Quant_I
) begin
	Quant_Offset = 5'h00;
	if (Macroblock_Intra_I) begin
		if (Load_Seq_Intra_Quant_I) Quant_Offset = 5'h04;
		else Quant_Offset = 5'h02;
	end else begin
		if (Load_Seq_NIntra_Quant_I) Quant_Offset = 5'h05;
		else Quant_Offset = 5'h03;
	end
end

Quant_Scan_ROM Quant_Scan_Matrices(
   .clock(clock),
   .Enable_A_I(Quant_Scan_En),
   .Address_A_I(Quant_Scan_Address),
   .Data_A_O(Quant_Scan_Data),
   .Enable_B_I(1'b0),
   .Address_B_I(11'h000),
   .Data_B_O()
);

wire                 idp_0, idp_1, idp_2, idp_3;

reg                  Block_write_en;
reg                  sum_even;
wire                 next_sum_even;
wire     [6:0]       Quant_Scale;
wire     [6:0]       Quant_Scale_Val;
wire     [7:0]       Quant_Intermediate;

reg      [17:0]      Scale_x_Data;
wire     [35:0]      Scale_x_Data_result;

assign idp_0 = ~Intra_DC_Precision_I[1] & ~Intra_DC_Precision_I[0];
assign idp_1 = ~Intra_DC_Precision_I[1] &  Intra_DC_Precision_I[0];
assign idp_2 =  Intra_DC_Precision_I[1] & ~Intra_DC_Precision_I[0];
assign idp_3 =  Intra_DC_Precision_I[1] &  Intra_DC_Precision_I[0];

assign Quant_Intermediate = 
	((Quant_Scale_Code_I[4:3] == 2'h0) | (Quant_Scale_Code_I == 5'h8)) ? 
		Quant_Scale_Code_I : 
	((Quant_Scale_Code_I[4:3] == 2'h1) | (Quant_Scale_Code_I == 5'h10)) ? 
		{Quant_Scale_Code_I,1'h0} - 8 : 
	((Quant_Scale_Code_I[4:3] == 2'h2) | (Quant_Scale_Code_I == 5'h18)) ? 
		{Quant_Scale_Code_I,2'h0} - 40 : 
		{Quant_Scale_Code_I,3'h0} - 136;
assign Quant_Scale_Val = (~Quant_Scale_Type_I) ? 
	{1'h0,Quant_Scale_Code_I,1'h0} : Quant_Intermediate[6:0];
assign Quant_Scale = 
   (~next_advance_Coeff_Pos) ? 7'h00 : 
   ((state_counter == 7'h01) & Macroblock_Intra_I) ? {2'h0,idp_0,idp_1,idp_2,idp_3,1'h0} : 
   	Quant_Scale_Val;	

assign next_sum_even = 
   (Block_Retrieve_Address_O == 6'h00) ? 
      ~Block_Retrieve_Data_O[0] : sum_even ^ Block_Retrieve_Data_O[0];
assign Block_Retrieve_Write_En_O = Block_write_en & ~state_counter[0];
                     
always @(posedge clock or negedge resetn) begin
   if (~resetn) begin
      Block_write_en <= 1'b0;
      Block_Retrieve_Address_O <= 6'h00;
      Scale_x_Data <= 18'h00000;
      sum_even <= 1'b1;
   end else begin
      Block_write_en <= (state_counter != 7'h00);
      Block_Retrieve_Address_O <= Quant_Scan_Data[5:0];
      Scale_x_Data <= Scale_x_Data_result[17:0];
      if (Block_Retrieve_Write_En_O) sum_even <= next_sum_even;
   end
end

wire 		[17:0]		Coeff_Mult_Data;

assign Coeff_Mult_Data = 
	(Coeff_Level == 12'h000) ? 18'h00000 : 
	(Macroblock_Intra_I) ? {{5{Coeff_Level[11]}},Coeff_Level,1'b0} : 
	(~Coeff_Level[11]) ? {{5{Coeff_Level[11]}},Coeff_Level,1'b1} : 
		({{5{Coeff_Level[11]}},Coeff_Level,1'b0} - 1);

wire                 round_adjust, clip_neg, clip_pos;
wire     [35:0]      Scale_x_Data_x_Weight_result;
wire     [35:0]      Scale_x_Data_x_Weight_Rounded;
wire     [11:0]      Scale_x_Data_x_Weight_Saturated;
wire     [11:0]      Scale_x_Data_x_Weight_Mismatch_Controlled;

assign round_adjust = Scale_x_Data_x_Weight_result[17] &
   (Scale_x_Data_x_Weight_result[4:0] != 5'h0);
assign clip_pos = (Scale_x_Data_x_Weight_Rounded[35] == 1'b0) & 
                  (Scale_x_Data_x_Weight_Rounded[34:16] != 19'h00000);
assign clip_neg = (Scale_x_Data_x_Weight_Rounded[35] == 1'b1) & 
                  (Scale_x_Data_x_Weight_Rounded[34:16] != 19'h7FFFF);
assign Scale_x_Data_x_Weight_Rounded = 
   Scale_x_Data_x_Weight_result + (round_adjust ? 32 : 0);
assign Scale_x_Data_x_Weight_Saturated = 
   (clip_pos) ? 12'h7FF : //d(2047)
   (clip_neg) ? 12'h800 : //d(-2048)
   Scale_x_Data_x_Weight_Rounded[16:5];
assign Scale_x_Data_x_Weight_Mismatch_Controlled = 
   {Scale_x_Data_x_Weight_Saturated[11:1],
   ((Block_Retrieve_Address_O == 6'h3F) & sum_even) ? 
      ~Scale_x_Data_x_Weight_Saturated[0] : Scale_x_Data_x_Weight_Saturated[0]};
assign Block_Retrieve_Data_O = Scale_x_Data_x_Weight_Mismatch_Controlled;
      
wire 		[35:0]		Dequant_Product;
wire 		[17:0] 		Dequant_OP_0, Dequant_OP_1;

MULT18X18 Dequant_Mult ( 
   .P(Dequant_Product), 
   .A(Dequant_OP_0), 
   .B(Dequant_OP_1) 
);

assign Dequant_OP_0 = (state_counter[0]) ? 
	{11'h000,Quant_Scale} : {10'h000,Quant_Scan_Data};
assign Dequant_OP_1 = (state_counter[0]) ? 
	Coeff_Mult_Data : Scale_x_Data;

assign Scale_x_Data_result = Dequant_Product;
assign Scale_x_Data_x_Weight_result = Dequant_Product;

endmodule
