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
module MB_Prediction(
	resetn,
	clock,
	
	Start_MB_Predict_I,
	Done_MB_Predict_O,
	
	Current_MB_Row_I,
	Current_MB_Column_I,

	F_Codes_I,
	Picture_Type_I,
	Macroblock_Intra_I,
	Motion_Forward_I,
	Motion_Backward_I,
	Image_Horizontal_I,
	
	Forward_Address_O,
	Forward_Data_I,
	Forward_Busy_I,
	Forward_Active_O,
	
	Backward_Address_O,
	Backward_Data_I,
	Backward_Busy_I,
	Backward_Active_O,
	
	Coeff_Data_En_I,
	Coeff_Data_I,

	Prediction_Address_I,
	Prediction_Data_O
);

input						resetn;
input						clock;

input						Start_MB_Predict_I;
output					Done_MB_Predict_O;

input 	[8:0]			Current_MB_Row_I;
input 	[9:0]			Current_MB_Column_I;

input 	[15:0] 		F_Codes_I;
input 	[1:0]			Picture_Type_I;
input 					Macroblock_Intra_I;
input 					Motion_Forward_I;
input						Motion_Backward_I;
input 	[11:0]		Image_Horizontal_I;

output	[18:0]		Forward_Address_O, Backward_Address_O;
input 	[31:0]		Forward_Data_I, Backward_Data_I;
input 					Forward_Busy_I, Backward_Busy_I;
output 					Forward_Active_O, Backward_Active_O;

input 					Coeff_Data_En_I;
input 	[31:0]		Coeff_Data_I;

input 	[10:0]		Prediction_Address_I;
output 	[7:0]			Prediction_Data_O;

reg						Forward_Start, Backward_Start, Calculate_Start;
wire 						Forward_Done, Backward_Done, Calculate_Done;

wire		[8:0]			Fwd_Pred_Addr_0, Fwd_Pred_Addr_1;
wire 		[15:0]		Fwd_Pred_Data_0, Fwd_Pred_Data_1;
wire 						Fwd_Pred_Wen_0, Fwd_Pred_Wen_1;

wire		[8:0]			Bwd_Pred_Addr_0, Bwd_Pred_Addr_1;
wire 		[15:0]		Bwd_Pred_Data_0, Bwd_Pred_Data_1;
wire 						Bwd_Pred_Wen_0, Bwd_Pred_Wen_1;

wire		[9:0]			Fwd_Buffer_Addr_0, Fwd_Buffer_Addr_1;
wire 		[15:0]		Fwd_Buffer_Read_Data_0, Fwd_Buffer_Read_Data_1;
wire 		[15:0]		Fwd_Buffer_Write_Data_0, Fwd_Buffer_Write_Data_1;
wire 						Fwd_Buffer_Wen_0, Fwd_Buffer_Wen_1;

wire		[9:0]			Bwd_Buffer_Addr_0, Bwd_Buffer_Addr_1;
wire 		[15:0]		Bwd_Buffer_Read_Data_0, Bwd_Buffer_Read_Data_1;
wire 		[15:0]		Bwd_Buffer_Write_Data_0, Bwd_Buffer_Write_Data_1;
wire 						Bwd_Buffer_Wen_0, Bwd_Buffer_Wen_1;

wire 		[9:0]			Fwd_Calc_Addr_0, Fwd_Calc_Addr_1;
wire 		[9:0]			Bwd_Calc_Addr_0, Bwd_Calc_Addr_1;

wire 						Fwd_HPY, Fwd_HPCbCr, Bwd_HPY, Bwd_HPCbCr;

reg 		[2:0]			state;
reg 		[1:0]			counter;

reg 						Start_update;
wire 						Done_update;

wire 		[15:0]		Update_Read_Data_0;
wire 		[15:0]		Update_Read_Data_1;
wire 		[15:0]		Update_Write_Data_1;
wire 						Update_Write_En_1;
wire 		[2:0]			Update_Index_0;
wire 		[2:0]			Update_Index_1;

reg 						PMV_Reset, FWD_Vec_Reset, BWD_Vec_Reset, Skipped_MB;
reg 		[8:0]			Fwd_Row_Offset, Bwd_Row_Offset;
reg	 	[9:0]			Fwd_Column_Offset, Bwd_Column_Offset;

reg 		[1:0]			Fwd_half_pel_reg_0, Fwd_half_pel_reg_1;
reg 		[1:0]			Bwd_half_pel_reg_0, Bwd_half_pel_reg_1;

reg 		[3:0]			prediction_indicator;

assign Done_MB_Predict_O = (state == `MB_PREDICT_IDLE);
assign Forward_Active_O = ~Forward_Done | Forward_Busy_I;
assign Backward_Active_O = ~Backward_Done | Backward_Busy_I;

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		state <= `MB_PREDICT_IDLE;
		Start_update <= 1'b0;
		PMV_Reset <= 1'b0; 
		FWD_Vec_Reset <= 1'b0; BWD_Vec_Reset <= 1'b0;
		Skipped_MB <= 1'b0;
		Forward_Start <= 1'b0;
		Backward_Start <= 1'b0;
		Calculate_Start <= 1'b0;
		counter <= 2'h0;
		Fwd_Row_Offset <= 9'h000;
		Bwd_Row_Offset <= 9'h000;
		Fwd_Column_Offset <= 10'h000;
		Bwd_Column_Offset <= 10'h000;
		Fwd_half_pel_reg_0 <= 2'h0; Fwd_half_pel_reg_1 <= 2'h0;
		Bwd_half_pel_reg_0 <= 2'h0; Bwd_half_pel_reg_1 <= 2'h0;
	end else begin
		case (state) 
			`MB_PREDICT_IDLE : begin
					if (Start_MB_Predict_I) begin
						state <= `MB_PREDICT_PMV;
						Start_update <= 1'b1;
					end
					if (Coeff_Data_En_I) begin
						if (Coeff_Data_I[31:18] == `INFO_SLICE_QUANT) begin
							PMV_Reset <= 1'b1; FWD_Vec_Reset <= 1'b1; BWD_Vec_Reset <= 1'b1;
						end
						if ((Coeff_Data_I[31:18] == `INFO_MACRO_MODES) & 
							(Coeff_Data_I[8])) FWD_Vec_Reset <= 1'b0;
						if ((Coeff_Data_I[31:18] == `INFO_MACRO_MODES) & 
							(Coeff_Data_I[7])) BWD_Vec_Reset <= 1'b0;
						if (
							((Picture_Type_I == `P_PICTURE) & 
								(Coeff_Data_I[31:18] == `INFO_MACRO_ADDR_INCR) & 
								(Coeff_Data_I[17:0] > 18'd1)) | 
							((Picture_Type_I == `P_PICTURE) & 
								(Coeff_Data_I[31:18] == `INFO_MACRO_MODES) & 
								(~Coeff_Data_I[8] & ~Coeff_Data_I[5])) | 
							((Coeff_Data_I[31:18] == `INFO_MACRO_MODES) & 
								(Coeff_Data_I[5]))
						) begin
							FWD_Vec_Reset <= 1'b1;
							BWD_Vec_Reset <= 1'b1;
							PMV_Reset <= 1'b1;
						end
						if (Coeff_Data_I[31:18] == `INFO_MACRO_ADDR_INCR) 
							Skipped_MB <= (Coeff_Data_I[17:0] > 18'd1);
						if (
							(Coeff_Data_I[31:18] == `INFO_SLICE_QUANT) |
							(Coeff_Data_I[31:18] == `INFO_MACRO_MODES)
						) Skipped_MB <= 1'b0;						
					end
				end
			`MB_PREDICT_PMV : begin
					Start_update <= 1'b0;
					if (~Start_update & Done_update) begin
						state <= `MB_PREDICT_FETCH_PREP;
						FWD_Vec_Reset <= 1'b0;
						BWD_Vec_Reset <= 1'b0;
						PMV_Reset <= 1'b0;
						counter <= 2'h0;
					end
				end
			`MB_PREDICT_FETCH_PREP : begin
					counter <= counter + 1;
					case (counter)
						2'h1 : begin
								Fwd_Column_Offset <= Fwd_Buffer_Read_Data_1[9:0];
								Bwd_Column_Offset <= Bwd_Buffer_Read_Data_1[9:0];
							end
						2'h2 : begin
								Fwd_Row_Offset <= Fwd_Buffer_Read_Data_1[8:0];
								Bwd_Row_Offset <= Bwd_Buffer_Read_Data_1[8:0];
								Forward_Start <= prediction_indicator[0] | PMV_Reset | FWD_Vec_Reset;
								Backward_Start <= prediction_indicator[2] | PMV_Reset | BWD_Vec_Reset;
								state <= `MB_PREDICT_FETCH;								
							end
					endcase
				end
			`MB_PREDICT_FETCH : begin
					Forward_Start <= 1'b0;
					Backward_Start <= 1'b0;
					if (~Forward_Start & Forward_Done & 
						 ~Backward_Start & Backward_Done
					) begin
						Fwd_half_pel_reg_0 <= {Fwd_HPY,Fwd_HPCbCr};
						Bwd_half_pel_reg_0 <= {Bwd_HPY,Bwd_HPCbCr};
						state <= `MB_PREDICT_CALCULATE;
						Calculate_Start <= 1'b1;
					end
				end
			`MB_PREDICT_CALCULATE : begin
					Calculate_Start <= 1'b0;
					if (~Calculate_Start & Calculate_Done) state <= `MB_PREDICT_IDLE;
				end
		endcase
	end
end

assign Fwd_Buffer_Wen_0 = 
	(state == `MB_PREDICT_IDLE) ? 
		Coeff_Data_En_I & (Coeff_Data_I[31:18] == `INFO_MACRO_MOTION_VECTOR) & ~Coeff_Data_I[16] : 
	(state == `MB_PREDICT_PMV) ? FWD_Vec_Reset :
	(state == `MB_PREDICT_FETCH) ? Fwd_Pred_Wen_0 : 
	1'b0;

assign Fwd_Buffer_Wen_1 = 
	(state == `MB_PREDICT_PMV) ? (
		~Update_Index_1[2] & Update_Write_En_1 & ~Skipped_MB & 
		prediction_indicator[Update_Index_1[2:1]]) | FWD_Vec_Reset :
	(state == `MB_PREDICT_FETCH) ? Fwd_Pred_Wen_1 : 
	1'b0;

assign Fwd_Buffer_Addr_0 =
	(state == `MB_PREDICT_IDLE) ? 
		{Coeff_Data_I[17],7'h7E,Coeff_Data_I[15],1'b0} : 
	(state == `MB_PREDICT_PMV) ? 
		{Update_Index_0[1],7'h7E,Update_Index_0[0],1'b0} :
	(state == `MB_PREDICT_FETCH) ? Fwd_Pred_Addr_0 :
	(state == `MB_PREDICT_CALCULATE) ? Fwd_Calc_Addr_0 : 
	10'h000;

assign Fwd_Buffer_Addr_1 = 	
	(state == `MB_PREDICT_PMV) ? 
		{Update_Index_1[1],7'h7F,Update_Index_1[0],1'b0} :
	(state == `MB_PREDICT_FETCH_PREP) ?
		{1'b0,7'h7F,counter[0],1'b0} :
	(state == `MB_PREDICT_FETCH) ? Fwd_Pred_Addr_1 : 
	(state == `MB_PREDICT_CALCULATE) ? Fwd_Calc_Addr_1 : 
	10'h000;
	
assign Fwd_Buffer_Write_Data_0 = 
	(state == `MB_PREDICT_IDLE) ? {2'h0,Coeff_Data_I[13:0]} : 
	(state == `MB_PREDICT_PMV) ? ((FWD_Vec_Reset) ? 16'h0000 : Update_Write_Data_1) :
	(state == `MB_PREDICT_FETCH) ? Fwd_Pred_Data_0 : 
		16'h0000;

assign Fwd_Buffer_Write_Data_1 = 
	(state == `MB_PREDICT_PMV) ? ((FWD_Vec_Reset) ? 16'h0000 : Update_Write_Data_1) :
	(state == `MB_PREDICT_FETCH) ? Fwd_Pred_Data_1 : 
		16'h0000;

assign Bwd_Buffer_Wen_0 = 
	(state == `MB_PREDICT_IDLE) ? 
		Coeff_Data_En_I & (Coeff_Data_I[31:18] == `INFO_MACRO_MOTION_VECTOR) & Coeff_Data_I[16] : 
	(state == `MB_PREDICT_PMV) ? BWD_Vec_Reset :
	(state == `MB_PREDICT_FETCH) ? Bwd_Pred_Wen_0 : 
	1'b0;

assign Bwd_Buffer_Wen_1 = 
	(state == `MB_PREDICT_PMV) ? (
		Update_Index_1[2] & Update_Write_En_1 & ~Skipped_MB & 
		prediction_indicator[Update_Index_1[2:1]]) | BWD_Vec_Reset :
	(state == `MB_PREDICT_FETCH) ? Bwd_Pred_Wen_1 : 
	1'b0;

assign Bwd_Buffer_Addr_0 =
	(state == `MB_PREDICT_IDLE) ? 
		{Coeff_Data_I[17],7'h7E,Coeff_Data_I[15],1'b0} : 
	(state == `MB_PREDICT_PMV) ? 
		{Update_Index_0[1],7'h7E,Update_Index_0[0],1'b0} :
	(state == `MB_PREDICT_FETCH) ? Bwd_Pred_Addr_0 : 
	(state == `MB_PREDICT_CALCULATE) ? Bwd_Calc_Addr_0 : 
	10'h000;
	
assign Bwd_Buffer_Addr_1 = 	
	(state == `MB_PREDICT_PMV) ? 
		{Update_Index_1[1],7'h7F,Update_Index_1[0],1'b0} :
	(state == `MB_PREDICT_FETCH_PREP) ?
		{1'b0,7'h7F,counter[0],1'b0} :
	(state == `MB_PREDICT_FETCH) ? Bwd_Pred_Addr_1 : 
	(state == `MB_PREDICT_CALCULATE) ? Bwd_Calc_Addr_1 : 
	10'h000;
	
assign Bwd_Buffer_Write_Data_0 = 
	(state == `MB_PREDICT_IDLE) ? {2'h0,Coeff_Data_I[13:0]} : 
	(state == `MB_PREDICT_PMV) ? ((BWD_Vec_Reset) ? 16'h0000 : Update_Write_Data_1) :
	(state == `MB_PREDICT_FETCH) ? Bwd_Pred_Data_0 : 
		16'h0000;

assign Bwd_Buffer_Write_Data_1 = 
	(state == `MB_PREDICT_PMV) ? ((BWD_Vec_Reset) ? 16'h0000 : Update_Write_Data_1) :
	(state == `MB_PREDICT_FETCH) ? Bwd_Pred_Data_1 : 
		16'h0000;

assign Update_Read_Data_0 = (Update_Index_0[2]) ? 
	Bwd_Buffer_Read_Data_0 : Fwd_Buffer_Read_Data_0;
assign Update_Read_Data_1 = (Update_Index_1[2]) ? 
	Bwd_Buffer_Read_Data_1 : Fwd_Buffer_Read_Data_1;

Prediction_Update Prediction_Updater(
	.resetn(resetn),
	.clock(clock),
	.Start_Update_I(Start_update),
	.Done_Update_O(Done_update),
	.F_Codes_I(F_Codes_I),
	.PMV_Reset_I(PMV_Reset),
	.Index_0_O(Update_Index_0),
	.Index_1_O(Update_Index_1),
	.Data_0_I(Update_Read_Data_0),
	.Data_1_I(Update_Read_Data_1),
	.Data_1_O(Update_Write_Data_1),
	.Write_En_1_O(Update_Write_En_1)
);

MB_Fetch_Prediction Forward_Prediction_Fetch(
	.resetn(resetn),
	.clock(clock),
	.Start_MB_Fetch_I(Forward_Start),
	.Done_MB_Fetch_O(Forward_Done),	
	.Image_Horizontal_I(Image_Horizontal_I),
	.Current_MB_Row_I(Current_MB_Row_I),
	.Current_MB_Column_I(Current_MB_Column_I),
	.Row_Offset_I(Fwd_Row_Offset),
	.Column_Offset_I(Fwd_Column_Offset),
	.Framestore_Address_O(Forward_Address_O),
	.Framestore_Data_I(Forward_Data_I),
	.Framestore_Busy_I(Forward_Busy_I),	
	.Write_Address_0_O(Fwd_Pred_Addr_0),
	.Write_Data_0_O(Fwd_Pred_Data_0),
	.Write_En_0_O(Fwd_Pred_Wen_0),
	.Write_Address_1_O(Fwd_Pred_Addr_1),
	.Write_Data_1_O(Fwd_Pred_Data_1),
	.Write_En_1_O(Fwd_Pred_Wen_1),
	.Half_pel_y_Y_O(Fwd_HPY),
	.Half_pel_y_CbCr_O(Fwd_HPCbCr)	
);

MB_Fetch_Prediction Backward_Prediction_Fetch(
	.resetn(resetn),
	.clock(clock),
	.Start_MB_Fetch_I(Backward_Start),
	.Done_MB_Fetch_O(Backward_Done),	
	.Image_Horizontal_I(Image_Horizontal_I),
	.Current_MB_Row_I(Current_MB_Row_I),
	.Current_MB_Column_I(Current_MB_Column_I),
	.Row_Offset_I(Bwd_Row_Offset),
	.Column_Offset_I(Bwd_Column_Offset),
	.Framestore_Address_O(Backward_Address_O),
	.Framestore_Data_I(Backward_Data_I),
	.Framestore_Busy_I(Backward_Busy_I),	
	.Write_Address_0_O(Bwd_Pred_Addr_0),
	.Write_Data_0_O(Bwd_Pred_Data_0),
	.Write_En_0_O(Bwd_Pred_Wen_0),
	.Write_Address_1_O(Bwd_Pred_Addr_1),
	.Write_Data_1_O(Bwd_Pred_Data_1),
	.Write_En_1_O(Bwd_Pred_Wen_1),
	.Half_pel_y_Y_O(Bwd_HPY),
	.Half_pel_y_CbCr_O(Bwd_HPCbCr)	
);

MC_Prediction_Buffer Forward_Prediction_Buffer(
   .clock(clock),
   .Write_En_A_I(Fwd_Buffer_Wen_0),
   .Address_A_I(Fwd_Buffer_Addr_0),
   .Data_A_I(Fwd_Buffer_Write_Data_0),
   .Data_A_O(Fwd_Buffer_Read_Data_0),
   .Write_En_B_I(Fwd_Buffer_Wen_1),
   .Address_B_I(Fwd_Buffer_Addr_1),
   .Data_B_I(Fwd_Buffer_Write_Data_1),
   .Data_B_O(Fwd_Buffer_Read_Data_1)
);

MC_Prediction_Buffer Backward_Prediction_Buffer(
   .clock(clock),
   .Write_En_A_I(Bwd_Buffer_Wen_0),
   .Address_A_I(Bwd_Buffer_Addr_0),
   .Data_A_I(Bwd_Buffer_Write_Data_0),
   .Data_A_O(Bwd_Buffer_Read_Data_0),
   .Write_En_B_I(Bwd_Buffer_Wen_1),
   .Address_B_I(Bwd_Buffer_Addr_1),
   .Data_B_I(Bwd_Buffer_Write_Data_1),
   .Data_B_O(Bwd_Buffer_Read_Data_1)
);

always @(
	Macroblock_Intra_I,
	Motion_Forward_I,
	Motion_Backward_I,
	Picture_Type_I,
	Skipped_MB
) begin
	prediction_indicator = {
		1'b0, Motion_Backward_I, 1'b0, Motion_Forward_I};
	if (~Motion_Backward_I) prediction_indicator[0] = 1'b1;
	if (Skipped_MB) begin
//		if (Picture_Type_I != `I_PICTURE) 
//			prediction_indicator[0] = 1'b1;
//		if (Picture_Type_I == `B_PICTURE) 
//			prediction_indicator[2] = 1'b1;
		if (Picture_Type_I == `P_PICTURE) 
			prediction_indicator[0] = 1'b1;
	end else if (Macroblock_Intra_I)
		prediction_indicator = 4'b0000;
//	if (PMV_Reset | Vec_Reset) prediction_indicator = 4'hF;
end

MB_Prediction_Calculate Prediction_Calculator(
	.resetn(resetn),
	.clock(clock),
	.Start_MB_Calculate_I(Calculate_Start),
	.Done_MB_Calculate_O(Calculate_Done),
	.Prediction_Indicator_I(prediction_indicator),
	.FWD_Half_Pel_0_I(Fwd_half_pel_reg_0),
	.FWD_Half_Pel_1_I(Fwd_half_pel_reg_1),
	.BWD_Half_Pel_0_I(Bwd_half_pel_reg_0),
	.BWD_Half_Pel_1_I(Bwd_half_pel_reg_1),	
	.FWD_Addr_0_O(Fwd_Calc_Addr_0),
	.FWD_Addr_1_O(Fwd_Calc_Addr_1),
	.BWD_Addr_0_O(Bwd_Calc_Addr_0),
	.BWD_Addr_1_O(Bwd_Calc_Addr_1),
	.FWD_Data_0_I(Fwd_Buffer_Read_Data_0),
	.FWD_Data_1_I(Fwd_Buffer_Read_Data_1),
	.BWD_Data_0_I(Bwd_Buffer_Read_Data_0),
	.BWD_Data_1_I(Bwd_Buffer_Read_Data_1),
	.Prediction_Address_I(Prediction_Address_I),
	.Prediction_Data_O(Prediction_Data_O)
);

endmodule
