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
module Inverse_Quantisation(
   resetn,
   clock,
   
   Intra_DC_Precision_I,
   Quant_Scale_Type_I,
   Alternate_Scan_I,
	Load_Seq_Intra_Quant_I,
	Load_Seq_NIntra_Quant_I,
   
   Coeff_Buffer_Empty_I,
   Coeff_Buffer_En_O,
   Coeff_Buffer_Address_O,
   Coeff_Buffer_Data_I,
	Coeff_Buffer_Reset_I,
	Coeff_Buffer_Reset_Address_I,

   Block_Retrieve_Ready_I,
   Block_Retrieve_Write_En_O,
   Block_Retrieve_Address_O,
   Block_Retrieve_Data_O,
   Block_Retrieve_Waiting_O,
   
   MB_Start_Predict_O,
   Macroblock_Modes_O,
   Prediction_Data_En_O
);

input                resetn;
input                clock;

input 	[1:0]			Intra_DC_Precision_I;
input 					Quant_Scale_Type_I;
input 					Alternate_Scan_I;
input 					Load_Seq_Intra_Quant_I;
input 					Load_Seq_NIntra_Quant_I;

input                Coeff_Buffer_Empty_I;
output               Coeff_Buffer_En_O;
output [`COEFF_BUFFER_ADDR_WIDTH:0] Coeff_Buffer_Address_O;
input    [31:0]      Coeff_Buffer_Data_I;
input						Coeff_Buffer_Reset_I;
input [`COEFF_BUFFER_ADDR_WIDTH:0] Coeff_Buffer_Reset_Address_I;

input                Block_Retrieve_Ready_I;
output               Block_Retrieve_Write_En_O;
output   [5:0]       Block_Retrieve_Address_O;
output   [11:0]      Block_Retrieve_Data_O;
output               Block_Retrieve_Waiting_O;

output 					MB_Start_Predict_O;
output 	[4:0]			Macroblock_Modes_O;
output 					Prediction_Data_En_O;

reg                  Block_Deq_Start;
wire                 Block_Deq_Done;
wire                 Block_Deq_Adv_Coeff;

reg      [4:0]       Quant_Scale_Code;
reg      [4:0]       Macroblock_modes;
reg      [5:0]       Macroblock_Address;
wire     [5:0]       next_Macroblock_Count;
wire     [5:0]       next_next_Macroblock_Count;
wire     [5:0]       next_Macroblock_Address;
reg      [5:0]       Macroblock_Count;

wire     [31:0]      Coeff_Buffer_Data;
wire     [13:0]      Coeff_Code;
wire     [5:0]       Coeff_Run;
wire     [11:0]      Coeff_Level;

reg 						clear_flag;
reg      [2:0]       state;
reg      [2:0]       block_count;
reg [`COEFF_BUFFER_ADDR_WIDTH:0] Coeff_Buffer_Address;
wire [`COEFF_BUFFER_ADDR_WIDTH:0] Coeff_Buffer_Address_Offset;

reg 		[3:0]			MB_Start_Predict;

assign MB_Start_Predict_O = MB_Start_Predict[3];

assign Coeff_Code = Coeff_Buffer_Data_I[31:18];
assign Coeff_Run = Coeff_Buffer_Data_I[17:12];
assign Coeff_Level = Coeff_Buffer_Data_I[11:0];

assign next_Macroblock_Count = Macroblock_Count + 1;
assign next_next_Macroblock_Count = Macroblock_Count + 2;
assign next_Macroblock_Address = Macroblock_Address + Coeff_Buffer_Data_I[5:0];

assign Coeff_Buffer_Address_O = Coeff_Buffer_Address + Coeff_Buffer_Address_Offset;
assign Coeff_Buffer_Address_Offset = 
	((state == `INV_QUANT_MB_INFO) & (Coeff_Code != `INFO_BLOCK_CODE)) ? 'd1 : 'd0;

assign Coeff_Buffer_Data = 
	(state == `INV_QUANT_SKIPPED) ? 
		{`INFO_BLOCK_CODE,18'h00000} : 
		Coeff_Buffer_Data_I;

assign Block_Retrieve_Waiting_O = Block_Deq_Done;
assign Macroblock_Modes_O = Macroblock_modes;
assign Prediction_Data_En_O = (state == `INV_QUANT_MB_INFO);

always @(posedge clock or negedge resetn) begin
   if (~resetn) begin
      state <= `INV_QUANT_IDLE;
      Macroblock_Count <= 6'h00;
      block_count <= 3'h0;
      clear_flag <= 1'b0;
		Coeff_Buffer_Address <= 'd0;
      Quant_Scale_Code <= 5'h01;
      Macroblock_modes <= 5'h00;
      Macroblock_Address <= 6'h00;
      Block_Deq_Start <= 1'b0;
      MB_Start_Predict <= 4'h0;
   end else begin
   	MB_Start_Predict <= {MB_Start_Predict[2:0],1'b0};
      if (Coeff_Buffer_Reset_I) Coeff_Buffer_Address <= Coeff_Buffer_Reset_Address_I;
      case (state) 
         `INV_QUANT_IDLE : begin
               if (Block_Retrieve_Ready_I) begin
						if (Coeff_Code == `INFO_BLOCK_CODE) begin
							block_count <= 3'd5;
							Block_Deq_Start <= 1'b1;
							MB_Start_Predict[0] <= 1'b1;
							if (next_Macroblock_Count == Macroblock_Address) begin
								state <= `INV_QUANT_BLOCK_DEQUANT;
							end else state <= `INV_QUANT_SKIPPED;
						end else state <= `INV_QUANT_MB_INFO;
               end
            end
         `INV_QUANT_MB_INFO : begin
					Coeff_Buffer_Address <= Coeff_Buffer_Address_O;
					case (Coeff_Code)
						`INFO_BLOCK_CODE : begin
								state <= `INV_QUANT_IDLE;
							end
						`INFO_SLICE_QUANT : begin
								Quant_Scale_Code <= Coeff_Buffer_Data_I[4:0];
							end
						`INFO_MACRO_MODES : begin
								Macroblock_modes <= Coeff_Buffer_Data_I[9:5];
								if (Coeff_Buffer_Data_I[9]) Quant_Scale_Code <= Coeff_Buffer_Data_I[4:0];
							end
						`INFO_MACRO_ADDR_INCR : begin
								Macroblock_Address <= next_Macroblock_Address;
								if (next_Macroblock_Count != next_Macroblock_Address) begin
									block_count <= 3'd5;
									Block_Deq_Start <= 1'b1;
									MB_Start_Predict[0] <= 1'b1;
									state <= `INV_QUANT_SKIPPED;									
								end
							end               
					endcase
				end
			`INV_QUANT_SKIPPED : begin
					clear_flag <= 1'b1;
               if (~Block_Deq_Done) Block_Deq_Start <= 1'b0;
               if (~Block_Deq_Start & Block_Deq_Done & Block_Retrieve_Ready_I) begin
                  if (block_count == 3'd0) begin
                     Macroblock_Count <= next_Macroblock_Count;
							if (next_next_Macroblock_Count == Macroblock_Address)
								state <= `INV_QUANT_IDLE;
							else begin
								MB_Start_Predict[0] <= 1'b1;
								block_count <= 3'd5;
								Block_Deq_Start <= 1'b1;
							end								
                  end else begin
                     Block_Deq_Start <= 1'b1;
                     block_count <= block_count - 1;
                  end
               end
				end	
         `INV_QUANT_BLOCK_DEQUANT : begin
					clear_flag <= 1'b1;
               if (~Block_Deq_Done) Block_Deq_Start <= 1'b0;

               if (Block_Deq_Adv_Coeff | 
						(Block_Retrieve_Write_En_O & Block_Deq_Done & (Coeff_Code == `INFO_BLOCK_CODE_EOB))
					) Coeff_Buffer_Address <= Coeff_Buffer_Address + 1;

               if (~Block_Deq_Start & Block_Deq_Done & Block_Retrieve_Ready_I) begin
                  if (block_count == 3'd0) begin
                     Macroblock_Count <= next_Macroblock_Count;
                     state <= `INV_QUANT_IDLE;
                  end else begin
                     Block_Deq_Start <= 1'b1;
                     block_count <= block_count - 1;
                  end
               end
            end
      endcase
   end
end

assign Coeff_Buffer_En_O = 1'b1;
Block_Inverse_Quantisation Block_Dequantiser(
   .resetn(resetn),
   .clock(clock),
   .Start_Inverse_Quantisation_I(Block_Deq_Start),
   .Done_Inverse_Quantisation_O(Block_Deq_Done),
   .Macroblock_Intra_I(Macroblock_modes[0]),
   .Intra_DC_Precision_I(Intra_DC_Precision_I),
   .Quant_Scale_Type_I(Quant_Scale_Type_I),
   .Quant_Scale_Code_I(Quant_Scale_Code),
   .Alternate_Scan_I(Alternate_Scan_I),
	.Load_Seq_Intra_Quant_I(Load_Seq_Intra_Quant_I),
	.Load_Seq_NIntra_Quant_I(Load_Seq_NIntra_Quant_I),
   .Advance_Coeff_Address_O(Block_Deq_Adv_Coeff),
   .Coeff_Buffer_Data_I(Coeff_Buffer_Data),
   .Block_Retrieve_Write_En_O(Block_Retrieve_Write_En_O),
   .Block_Retrieve_Address_O(Block_Retrieve_Address_O),
   .Block_Retrieve_Data_O(Block_Retrieve_Data_O)
);

endmodule
