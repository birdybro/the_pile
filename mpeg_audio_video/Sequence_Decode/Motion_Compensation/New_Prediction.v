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
module New_Prediction(
	Current_PMV_I,
	
	Delta_Sign_I,
	Delta_Magnitude_I,
	
	F_Code_I,
	
	New_PMV_O
);

input 	[15:0]	Current_PMV_I;

input 				Delta_Sign_I;
input 	[12:0]	Delta_Magnitude_I;

input 	[3:0]		F_Code_I;

output 	[15:0]	New_PMV_O;

wire 		[16:0] 	Pre_range_PMV;

wire 		[15:0]	Range_small;
wire 		[16:0]	Range;

wire 					up_adjust, down_adjust;

wire 		[16:0]	adjustment_value;
wire 		[16:0]	adjusted_value;

wire 		[16:0]	adjust_up_check;
wire 		[16:0]	adjust_down_check;

assign Pre_range_PMV = (Delta_Sign_I) ? 
	{Current_PMV_I[15],Current_PMV_I} - {3'h0,Delta_Magnitude_I} : 
	{Current_PMV_I[15],Current_PMV_I} + {3'h0,Delta_Magnitude_I};

assign Range_small = 1 << (F_Code_I + 4);
assign Range = {1'b0,Range_small};

assign adjust_up_check = Pre_range_PMV + {1'b0,Range[16:1]};
assign adjust_down_check = Pre_range_PMV - {1'b0,Range[16:1]};

assign up_adjust = adjust_up_check[16];
assign down_adjust = ~adjust_down_check[16];

assign adjustment_value = (up_adjust | down_adjust) ? Range : 17'h00000;

assign adjusted_value = (down_adjust) ? 
	Pre_range_PMV - adjustment_value : Pre_range_PMV + adjustment_value;
	
assign New_PMV_O = adjusted_value[15:0];

endmodule
