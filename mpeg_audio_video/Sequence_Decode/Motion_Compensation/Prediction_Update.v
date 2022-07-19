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
module Prediction_Update(
	resetn,
	clock,
	
	Start_Update_I,
	Done_Update_O,

	F_Codes_I,
	
	PMV_Reset_I,
	
	Index_0_O,
	Index_1_O,
	
	Data_0_I,
	Data_1_I,
	
	Data_1_O,
	Write_En_1_O
);

input 				resetn;
input 				clock;

input 				Start_Update_I;
output 				Done_Update_O;

input 	[15:0]	F_Codes_I;

input 				PMV_Reset_I;

output 	[2:0] 	Index_0_O;
output 	[2:0]		Index_1_O;

input 	[15:0]	Data_0_I;
input 	[15:0]	Data_1_I;

output 	[15:0]	Data_1_O;
output     			Write_En_1_O;

reg 		[2:0]		state;
reg 		[3:0]		counter;

wire 		[15:0]	Current_PMV;

assign Done_Update_O = (state == `MB_PREDICT_UPDATE_IDLE);

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		state <= `MB_PREDICT_UPDATE_IDLE;
		counter <= 4'h0;
	end else begin				
		case (state)
			`MB_PREDICT_UPDATE_IDLE : begin
					if (Start_Update_I) begin
						state <= `MB_PREDICT_UPDATE_CALC;
						counter <= 4'h0;
					end
				end
			`MB_PREDICT_UPDATE_CALC : begin
					counter <= counter + 1;
					if (counter[3:0] == 4'hF) state <= `MB_PREDICT_UPDATE_IDLE;
				end
		endcase
	end
end

reg [3:0] f_code;

assign Index_0_O = counter[3:1];
assign Index_1_O = counter[3:1];
assign Write_En_1_O = counter[0];

assign Current_PMV = (PMV_Reset_I) ? 16'h0000 : Data_1_I;

New_Prediction Prediction_Former(
	.Current_PMV_I(Current_PMV),	
	.Delta_Sign_I(Data_0_I[13]),
	.Delta_Magnitude_I(Data_0_I[12:0]),	
	.F_Code_I(f_code),	
	.New_PMV_O(Data_1_O)
);

always @(F_Codes_I, counter) begin
	f_code = 4'h0;
	case ({counter[3],counter[1]})
		2'h0 : f_code = F_Codes_I[15:12];
		2'h1 : f_code = F_Codes_I[11:8];
		2'h2 : f_code = F_Codes_I[7:4];
		2'h3 : f_code = F_Codes_I[3:0];
	endcase
end

endmodule
