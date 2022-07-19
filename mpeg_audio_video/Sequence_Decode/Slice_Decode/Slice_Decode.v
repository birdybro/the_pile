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
module Slice_Decode(
   resetn,
   clock,

   Start_Slice_Decode_I,
   Done_Slice_Decode_O,
   
   Data_In_I,
   Shift_1_En_O,
   Shift_8_En_O,

   Start_Code_Upcoming_I,
   
   Slice_Buffer_Value_O,
   Slice_Buffer_Write_En_O,
   Slice_Buffer_Full_I,

   Picture_Type_I,
 	Picture_Structure_I,
	Intra_VLC_Format_I,
	Frame_Pred_Frame_DCT_I,
	Concealment_Vectors_I,
	F_Codes_I
);

input                resetn;
input                clock;

input                Start_Slice_Decode_I;
output               Done_Slice_Decode_O;

input    [1:0]       Data_In_I;
output               Shift_1_En_O;
output               Shift_8_En_O;

input                Start_Code_Upcoming_I;

output   [31:0]      Slice_Buffer_Value_O;
output               Slice_Buffer_Write_En_O;
input                Slice_Buffer_Full_I;

input 	[1:0]		   Picture_Type_I;
input 	[1:0]		 	Picture_Structure_I;
input 					Intra_VLC_Format_I;
input 					Frame_Pred_Frame_DCT_I;
input 					Concealment_Vectors_I;
input 	[15:0]		F_Codes_I;

reg      [2:0]       state;
reg      [2:0]       shift_counter;
reg      [4:0]       Quantiser_Scale;

reg                  Macroblock_Start;
wire                 Macroblock_Done;
wire                 Macroblock_Shift_En;
wire     [31:0]      Macroblock_Buffer_Value;
wire                 Macroblock_Buffer_Write_En;

assign Shift_8_En_O = (state == `SLICE_DECODE_START_CODE);
assign Shift_1_En_O = Macroblock_Shift_En | 
   (state == `SLICE_DECODE_QUANTISER_SCALE) | 
   (state == `SLICE_DECODE_EXTRA_BIT_SLICE);
                      
assign Done_Slice_Decode_O = (state == `SLICE_DECODE_IDLE);

assign Slice_Buffer_Value_O = (state == `SLICE_DECODE_EXTRA_BIT_SLICE) ? 
   {`INFO_SLICE_QUANT,13'h0000,Quantiser_Scale} : Macroblock_Buffer_Value;
assign Slice_Buffer_Write_En_O = 
   (state == `SLICE_DECODE_EXTRA_BIT_SLICE) | Macroblock_Buffer_Write_En;

always @(posedge clock or negedge resetn) begin
   if (~resetn) begin
      state <= `SLICE_DECODE_IDLE;
      shift_counter <= 3'h0;
      Quantiser_Scale <= 5'h00;
      Macroblock_Start <= 1'b0;
   end else begin
      case(state) 
         `SLICE_DECODE_IDLE : begin
               if (Start_Slice_Decode_I) begin
                  shift_counter <= 3'h3;
                  state <= `SLICE_DECODE_START_CODE;
               end
            end
         `SLICE_DECODE_START_CODE : begin
               if (shift_counter == 3'h0) begin
                  shift_counter <= 3'h4;
                  state <= `SLICE_DECODE_QUANTISER_SCALE;
               end else shift_counter <= shift_counter - 1;
            end
         `SLICE_DECODE_QUANTISER_SCALE : begin
               Quantiser_Scale <= {Quantiser_Scale[3:0],Data_In_I[1]};
               if (shift_counter == 3'h0) begin
                  if (Data_In_I[0] == 1'b1) begin
                     state <= `SLICE_DECODE_EXTRA_INFO;
                  end else begin
                     state <= `SLICE_DECODE_EXTRA_BIT_SLICE;
                  end
               end else shift_counter <= shift_counter - 1;
            end
         `SLICE_DECODE_EXTRA_INFO : begin
               state <= `SLICE_DECODE_IDLE;
            end
         `SLICE_DECODE_EXTRA_BIT_SLICE : begin
               state <= `SLICE_DECODE_MACROBLOCKS_WAIT;
            end
         `SLICE_DECODE_MACROBLOCKS_WAIT : begin
               if (~Slice_Buffer_Full_I) begin
                  Macroblock_Start <= 1'b1;
                  state <= `SLICE_DECODE_MACROBLOCKS;
               end
            end
         `SLICE_DECODE_MACROBLOCKS : begin
               Macroblock_Start <= 1'b0;
               if (~Macroblock_Start & Macroblock_Done) begin
                  if (~Start_Code_Upcoming_I) begin
                     if (~Slice_Buffer_Full_I) Macroblock_Start <= 1'b1;
                     else state <= `SLICE_DECODE_MACROBLOCKS_WAIT;
                  end else begin
                     state <= `SLICE_DECODE_IDLE;
                  end
               end
            end
      endcase
   end
end

reg      [11:0]      Y_Predictor, Cb_Predictor, Cr_Predictor;
wire     [11:0]      New_Y_Predictor, New_Cb_Predictor, New_Cr_Predictor;
wire                 Update_Y_Predictor, Update_Cb_Predictor, Update_Cr_Predictor;

always @(posedge clock or negedge resetn) begin
   if (~resetn) begin
      Y_Predictor <= `PREDICTOR_RESET;
      Cb_Predictor <= `PREDICTOR_RESET;
      Cr_Predictor <= `PREDICTOR_RESET;
   end else if (Start_Slice_Decode_I) begin
      Y_Predictor <= `PREDICTOR_RESET;
      Cb_Predictor <= `PREDICTOR_RESET;
      Cr_Predictor <= `PREDICTOR_RESET;
   end else begin
      if (Update_Y_Predictor) Y_Predictor <= New_Y_Predictor;
      if (Update_Cb_Predictor) Cb_Predictor <= New_Cb_Predictor;
      if (Update_Cr_Predictor) Cr_Predictor <= New_Cr_Predictor;
   end
end

Macroblock_Decode Macroblock_Decoder(
   .resetn(resetn),
   .clock(clock),
   .Start_Macroblock_Decode_I(Macroblock_Start),
   .Done_Macroblock_Decode_O(Macroblock_Done),
   .Data_In_I(Data_In_I[1]),
   .Shift_En_O(Macroblock_Shift_En),
   .Y_Predictor_I(Y_Predictor), 
   .New_Y_Predictor_O(New_Y_Predictor), 
   .Update_Y_Predictor_O(Update_Y_Predictor),
   .Cb_Predictor_I(Cb_Predictor), 
   .New_Cb_Predictor_O(New_Cb_Predictor), 
   .Update_Cb_Predictor_O(Update_Cb_Predictor),
   .Cr_Predictor_I(Cr_Predictor), 
   .New_Cr_Predictor_O(New_Cr_Predictor),
   .Update_Cr_Predictor_O(Update_Cr_Predictor),
   .Buffer_Value_O(Macroblock_Buffer_Value),
   .Buffer_Write_En_O(Macroblock_Buffer_Write_En),
   .Picture_Type_I(Picture_Type_I),
 	.Picture_Structure_I(Picture_Structure_I),
	.Intra_VLC_Format_I(Intra_VLC_Format_I),
	.Frame_Pred_Frame_DCT_I(Frame_Pred_Frame_DCT_I),
	.Concealment_Vectors_I(Concealment_Vectors_I),
	.F_Codes_I(F_Codes_I)
);

endmodule
