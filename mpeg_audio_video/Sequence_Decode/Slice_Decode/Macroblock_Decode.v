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
module Macroblock_Decode(
   resetn,
   clock,

   Start_Macroblock_Decode_I,
   Done_Macroblock_Decode_O,
   
   Data_In_I,
   Shift_En_O,
   
   Y_Predictor_I, New_Y_Predictor_O, Update_Y_Predictor_O,
   Cb_Predictor_I, New_Cb_Predictor_O, Update_Cb_Predictor_O,
   Cr_Predictor_I, New_Cr_Predictor_O, Update_Cr_Predictor_O,

   Buffer_Value_O,
   Buffer_Write_En_O,

	Picture_Type_I,
   Picture_Structure_I,
	Intra_VLC_Format_I,
	Frame_Pred_Frame_DCT_I,
	Concealment_Vectors_I,
	F_Codes_I
);

input                resetn;
input                clock;

input                Start_Macroblock_Decode_I;
output               Done_Macroblock_Decode_O;

input                Data_In_I;
output               Shift_En_O;

input    [11:0]      Y_Predictor_I, Cb_Predictor_I, Cr_Predictor_I;
output   [11:0]      New_Y_Predictor_O, New_Cb_Predictor_O, New_Cr_Predictor_O;
output               Update_Y_Predictor_O, Update_Cb_Predictor_O, Update_Cr_Predictor_O;

output   [31:0]      Buffer_Value_O;
output               Buffer_Write_En_O;

input 	[1:0]			Picture_Type_I;
input 	[1:0] 		Picture_Structure_I;
input 					Intra_VLC_Format_I;
input 					Frame_Pred_Frame_DCT_I;
input 					Concealment_Vectors_I;
input 	[15:0]		F_Codes_I;

wire                 Macroblock_Quant;
wire                 Macroblock_Motion_Forward;
wire                 Macroblock_Motion_Backward;
wire                 Macroblock_Pattern;
wire                 Macroblock_Intra;
reg                  Macroblock_Info_Write_En;

reg      [3:0]       state;
wire     [1:0]       cc;

reg                  Block_Start, Addr_Start, Modes_Start, Vectors_Start, CBP_Start;
reg 						Modes_2_shift;
reg      [31:0]      Macroblock_Address_Increment;

wire                 Block_Done, Block_Shift_En;
wire                 Addr_Done, Addr_Shift_En;
wire                 Modes_Done, Modes_Shift_En;
wire                 Vectors_Done, Vectors_Shift_En;
wire                 CBP_Done, CBP_Shift_En;

wire     [7:0]       Addr_Symbol;
wire     [4:0]       Modes_Symbol;
reg 		[4:0]			Modes_reg;
wire 		[5:0] 		CBP_Symbol;
reg 		[5:0]			CBP_reg;

reg      [3:0]       Block_Counter;
wire     [11:0]      Block_DC_predictor;
wire     [11:0]      Block_New_DC_predictor;
wire                 Block_Update_DC_predictor;
wire                 Block_Luma_Chroma_Sel;

wire     [31:0]      Block_Buffer_Value;
wire                 Block_Buffer_Write_En;

wire     [31:0]      Vector_Buffer_Value;
wire                 Vector_Buffer_Write_En;

assign Buffer_Value_O = 
	(Macroblock_Info_Write_En) ? Macroblock_Address_Increment : 
	((state == `MACRO_DECODE_CBP) & ~CBP_Start & CBP_Done) ? 
		{`INFO_MACRO_CBP,12'h000,CBP_Symbol} : 
	(Vector_Buffer_Write_En) ? Vector_Buffer_Value : 
		Block_Buffer_Value;
		
assign Buffer_Write_En_O = 
	Macroblock_Info_Write_En | Block_Buffer_Write_En | Vector_Buffer_Write_En | 
	((state == `MACRO_DECODE_CBP) & ~CBP_Start & CBP_Done);

assign Done_Macroblock_Decode_O = (state == `MACRO_DECODE_IDLE);
assign Shift_En_O = 
	Modes_Shift_En | Addr_Shift_En | Block_Shift_En |
	Vectors_Shift_En | CBP_Shift_En | 
   ((state == `MACRO_DECODE_MODES_2) & Modes_2_shift) | 
   (state == `MACRO_DECODE_QUANTISER_SCALE) | 
   (state == `MACRO_DECODE_MARKER);
assign cc = {(Block_Counter[3] | Block_Counter[2]) & Block_Counter[0],
             (Block_Counter[3] | Block_Counter[2]) & ~Block_Counter[0]};

assign Macroblock_Quant = Modes_reg[4];
assign Macroblock_Motion_Forward = Modes_reg[3];
assign Macroblock_Motion_Backward = Modes_reg[2];
assign Macroblock_Pattern = Modes_reg[1];
assign Macroblock_Intra = Modes_reg[0];

always @(posedge clock or negedge resetn) begin
   if (~resetn) begin
      state <= `MACRO_DECODE_IDLE;
      Block_Start <= 1'b0;
      Addr_Start <= 1'b0;
      Modes_Start <= 1'b0;
      Modes_2_shift <= 1'b0;
      Vectors_Start <= 1'b0;
      CBP_Start <= 1'b0;
      Block_Counter <= 4'h0;
      Macroblock_Address_Increment <= 32'h00000000;     
      Macroblock_Info_Write_En <= 1'b0;
      CBP_reg <= 6'h00;
      Modes_reg <= 5'h0;
   end else begin
      Macroblock_Info_Write_En <= 1'b0;
      case (state)
         `MACRO_DECODE_IDLE : begin
               if (Start_Macroblock_Decode_I) begin
                  Addr_Start <= 1'b1;
                  Macroblock_Address_Increment <= 
                     {`INFO_MACRO_ADDR_INCR,
                      18'h0000};
                  state <= `MACRO_DECODE_ADDRESS;
               end
            end
         `MACRO_DECODE_ADDRESS : begin
               Addr_Start <= 1'b0;
               if (Addr_Done) begin
                  Macroblock_Address_Increment[17:0] <= 
                     Macroblock_Address_Increment[17:0] + Addr_Symbol[5:0];
                  if (Addr_Symbol[6]) Addr_Start <= 1'b1;
                  else begin
                     Macroblock_Info_Write_En <= 1'b1;
                     Modes_Start <= 1'b1;
                     state <= `MACRO_DECODE_MODES;
                  end
               end
            end
         `MACRO_DECODE_MODES : begin
               Modes_Start <= 1'b0;
               if (Modes_Done) begin
						Modes_reg <= Modes_Symbol;
                  Macroblock_Address_Increment <= {
                  	`INFO_MACRO_MODES,
                     8'h00,
                     Modes_Symbol,
                     5'h00 };
						if (Modes_Symbol[0]) CBP_reg <= 6'h3F;
						else CBP_reg <= 6'h00;
                  if (Modes_Symbol[3] | Modes_Symbol[2] | (
                  	~Frame_Pred_Frame_DCT_I &
                  	(Picture_Structure_I == `FRAME_PICTURE) &
                  	(Modes_Symbol[0] | Modes_Symbol[1])
                  )) begin
                  	Block_Counter <= 4'h0;
                  	state <= `MACRO_DECODE_MODES_2;
                  end else if (Modes_Symbol[4]) begin
                     Block_Counter <= 4'h0;
                     state <= `MACRO_DECODE_QUANTISER_SCALE;
                  end else if (Modes_Symbol[0] & Concealment_Vectors_I) begin 
                  	Macroblock_Info_Write_En <= 1'b1;
                  	state <= `MACRO_DECODE_MARKER;
                  end else if (Modes_Symbol[1]) begin
                  	Macroblock_Info_Write_En <= 1'b1;
                  	CBP_Start <= 1'b1;
                  	state <= `MACRO_DECODE_CBP;
                  end else begin
                     Block_Counter <= 4'h0;
                     Block_Start <= 1'b1;
                     Macroblock_Info_Write_En <= 1'b1;
                     state <= `MACRO_DECODE_BLOCKS;      
                  end
               end
            end
         `MACRO_DECODE_MODES_2 : begin
         		Block_Counter <= Block_Counter + 1;
					if (Macroblock_Motion_Forward | Macroblock_Motion_Backward) begin
						if (Picture_Structure_I == `FRAME_PICTURE) begin
							if (~Frame_Pred_Frame_DCT_I) begin
								if (Block_Counter == 4'h0) begin
									Modes_2_shift <= 1'b1;
								end 
								if (Block_Counter == 4'h1) begin
									Macroblock_Address_Increment[11] <= Data_In_I;
								end 
								if (Block_Counter == 4'h2) begin
									Modes_2_shift <= 1'b0;
									Macroblock_Address_Increment[10] <= Data_In_I;
								end
							end 
						end else begin
							if (Block_Counter == 4'h0) begin
								Modes_2_shift <= 1'b1;
							end 
							if (Block_Counter == 4'h1) begin
								Macroblock_Address_Increment[11] <= Data_In_I;
							end 
							if (Block_Counter == 4'h2) begin
								Modes_2_shift <= 1'b0;
								Macroblock_Address_Increment[10] <= Data_In_I;
							end
						end
					end else Block_Counter <= 4'h3;
					if (
						~Frame_Pred_Frame_DCT_I &
						(Picture_Structure_I == `FRAME_PICTURE) & 
						(Macroblock_Pattern | Macroblock_Intra)
					) begin
						if (Block_Counter == 4'h3) Modes_2_shift <= 1'b1;
						if (Block_Counter == 4'h4) begin
							Modes_2_shift <= 1'b0;
							Macroblock_Address_Increment[12] <= Data_In_I;
						end
					end
					if (Block_Counter == 4'h4) begin
                  if (Macroblock_Quant) begin
                     Block_Counter <= 4'h0;
                     state <= `MACRO_DECODE_QUANTISER_SCALE;
                  end else if (
                    	Macroblock_Motion_Forward | 
                  	Macroblock_Motion_Backward | 
                  	(Macroblock_Intra & Concealment_Vectors_I)
                  ) begin
                  	Macroblock_Info_Write_En <= 1'b1;
                  	Vectors_Start <= 1'b1;
                  	state <= `MACRO_DECODE_MOTION_VECTORS;
						end else if (Macroblock_Pattern) begin
                  	Macroblock_Info_Write_En <= 1'b1;
                  	CBP_Start <= 1'b1;
                  	state <= `MACRO_DECODE_CBP;
                  end else begin
                     Block_Counter <= 4'h0;
                     Block_Start <= 1'b1;
                     Macroblock_Info_Write_En <= 1'b1;
                     state <= `MACRO_DECODE_BLOCKS;      
                  end
					end
         	end
         `MACRO_DECODE_QUANTISER_SCALE : begin
               Macroblock_Address_Increment <= 
                  {Macroblock_Address_Increment[31:5],
                   Macroblock_Address_Increment[3:0],
                   Data_In_I};
               if (Block_Counter == 4'h4) begin
                  Macroblock_Info_Write_En <= 1'b1;

                  if (
                    	Macroblock_Motion_Forward | 
                  	Macroblock_Motion_Backward | 
                  	(Macroblock_Intra & Concealment_Vectors_I)
                  ) begin
                  	Vectors_Start <= 1'b1;
                  	state <= `MACRO_DECODE_MOTION_VECTORS;
						end else if (Macroblock_Pattern) begin
                  	CBP_Start <= 1'b1;
                  	state <= `MACRO_DECODE_CBP;
                  end else begin
                     Block_Counter <= 4'h0;
                     Block_Start <= 1'b1;
                     state <= `MACRO_DECODE_BLOCKS;      
                  end
               end else Block_Counter <= Block_Counter + 1;
            end
			`MACRO_DECODE_MOTION_VECTORS : begin
					Vectors_Start <= 1'b0;
					if (~Vectors_Start & Vectors_Done) begin
                	if (Macroblock_Intra & Concealment_Vectors_I) begin
                  	state <= `MACRO_DECODE_MARKER;
						end else if (Macroblock_Pattern) begin
                  	CBP_Start <= 1'b1;
                  	state <= `MACRO_DECODE_CBP;
                  end else begin
                     Block_Counter <= 4'h0;
                     Block_Start <= 1'b1;
                     state <= `MACRO_DECODE_BLOCKS;      
                  end
               end else Block_Counter <= Block_Counter + 1;
            end
			`MACRO_DECODE_MARKER : begin
					if (Macroblock_Pattern) begin
               	CBP_Start <= 1'b1;
               	state <= `MACRO_DECODE_CBP;
               end else begin
                  Block_Counter <= 4'h0;
                  Block_Start <= 1'b1;
                  state <= `MACRO_DECODE_BLOCKS;      
					end
				end
			`MACRO_DECODE_CBP : begin
               CBP_Start <= 1'b0;
               if (~CBP_Start & CBP_Done) begin
                  Block_Counter <= 4'h0;
                  Block_Start <= 1'b1;
                  state <= `MACRO_DECODE_BLOCKS;      
						CBP_reg <= CBP_Symbol;
					end
				end
         `MACRO_DECODE_BLOCKS : begin
               Block_Start <= 1'b0;
               if (~Block_Start & Block_Done) begin
                  // number of blocks per macroblock - 1
                  if (Block_Counter == 4'h5) state <= `MACRO_DECODE_IDLE; 
                  else begin
                     Block_Start <= 1'b1;
                     Block_Counter <= Block_Counter + 1;
                  end
               end
            end
      endcase
   end
end

wire                 Table_ROM_En_A, Table_ROM_En_B;
wire     [15:0]      Table_ROM_Data_A, Table_ROM_Data_B;
wire     [9:0]       Table_ROM_Addr_A, Table_ROM_Addr_B;

wire                 Addr_Table_En;
wire     [15:0]      Addr_Table_Data;
wire     [9:0]       Addr_Table_Addr;

wire                 Modes_Table_En;
wire     [15:0]      Modes_Table_Data;
wire     [9:0]       Modes_Table_Addr;

wire                 Vectors_Table_En;
wire     [15:0]      Vectors_Table_Data;
wire     [9:0]       Vectors_Table_Addr;

wire                 CBP_Table_En;
wire     [15:0]      CBP_Table_Data;
wire     [9:0]       CBP_Table_Addr;

wire                 Block_DC_Table_En, Block_AC_Table_En;  
wire     [15:0]      Block_DC_Table_Data, Block_AC_Table_Data;
wire     [9:0]       Block_DC_Table_Addr, Block_AC_Table_Addr;

assign Table_ROM_En_A = 
	(state == `MACRO_DECODE_ADDRESS) ? Addr_Table_En : 
   (state == `MACRO_DECODE_MODES) ? Modes_Table_En : 
   (state == `MACRO_DECODE_MOTION_VECTORS) ? Vectors_Table_En :
   (state == `MACRO_DECODE_CBP) ? CBP_Table_En :
   	Block_DC_Table_En;
assign Table_ROM_Addr_A = 
	(state == `MACRO_DECODE_ADDRESS) ? Addr_Table_Addr : 
   (state == `MACRO_DECODE_MODES) ? Modes_Table_Addr : 
   (state == `MACRO_DECODE_MOTION_VECTORS) ? Vectors_Table_Addr :
   (state == `MACRO_DECODE_CBP) ? CBP_Table_Addr :
   	Block_DC_Table_Addr;

assign Block_DC_Table_Data = Table_ROM_Data_A;
assign Addr_Table_Data = Table_ROM_Data_A;
assign Modes_Table_Data = Table_ROM_Data_A;
assign Vectors_Table_Data = Table_ROM_Data_A;
assign CBP_Table_Data = Table_ROM_Data_A;

assign Table_ROM_En_B = Block_AC_Table_En;
assign Table_ROM_Addr_B = Block_AC_Table_Addr;
assign Block_AC_Table_Data = Table_ROM_Data_B;

Table_B1toB15 Coeff_ROM(
   .clock(clock),
   .Enable_A_I(Table_ROM_En_A),
   .Address_A_I(Table_ROM_Addr_A),
   .Data_A_O(Table_ROM_Data_A),
   .Enable_B_I(Table_ROM_En_B),
   .Address_B_I(Table_ROM_Addr_B),
   .Data_B_O(Table_ROM_Data_B)
);

Macroblock_Decode_Addr Macroblock_Addr_Decoder(
   .resetn(resetn),
   .clock(clock), 
   .Start_I(Addr_Start),
   .Data_In_I(Data_In_I),
   .Shift_En_O(Addr_Shift_En),
   .Valid_Code_O(Addr_Done),
   .Symbol_O(Addr_Symbol),
   .Coeff_Table_En_O(Addr_Table_En),
   .Coeff_Table_Addr_O(Addr_Table_Addr),
   .Coeff_Table_Data_I(Addr_Table_Data)   
);

Macroblock_Decode_Modes Macroblock_Mode_Decoder(
   .resetn(resetn),
   .clock(clock), 
   .Start_I(Modes_Start),
   .Macroblock_Type_I(Picture_Type_I),
   .Data_In_I(Data_In_I),
   .Shift_En_O(Modes_Shift_En),
   .Valid_Code_O(Modes_Done),
   .Symbol_O(Modes_Symbol),
   .Coeff_Table_En_O(Modes_Table_En),
   .Coeff_Table_Addr_O(Modes_Table_Addr),
   .Coeff_Table_Data_I(Modes_Table_Data)   
);

Vector_Decode Vector_Decoder(
   .resetn(resetn),
   .clock(clock), 
   .Start_I(Vectors_Start),
	.Done_O(Vectors_Done),
	.Data_In_I(Data_In_I),
	.Shift_En_O(Vectors_Shift_En),
	.Buffer_Value_O(Vector_Buffer_Value),
	.Buffer_Write_En_O(Vector_Buffer_Write_En),
	.Forward_I(Macroblock_Motion_Forward),
	.Backward_I(Macroblock_Motion_Backward),
	.Intra_I(Macroblock_Intra),
	.Concealment_I(Concealment_Vectors_I),
	.F_Codes_I(F_Codes_I),
   .Coeff_Table_En_O(Vectors_Table_En),
   .Coeff_Table_Addr_O(Vectors_Table_Addr),
   .Coeff_Table_Data_I(Vectors_Table_Data)
);

Macroblock_Decode_CBP Macroblock_CBP_Decoder(
   .resetn(resetn),
   .clock(clock),
   .Start_I(CBP_Start),
   .Data_In_I(Data_In_I),
   .Shift_En_O(CBP_Shift_En),
   .Valid_Code_O(CBP_Done),
   .Symbol_O(CBP_Symbol),
   .Coeff_Table_En_O(CBP_Table_En),
   .Coeff_Table_Addr_O(CBP_Table_Addr),
   .Coeff_Table_Data_I(CBP_Table_Data)
);

assign Block_Luma_Chroma_Sel = cc[1] | cc[0];

wire Predictor_Reset;
assign Predictor_Reset = 
	(Modes_Start & (Macroblock_Address_Increment[17:0] != 18'h001)) | 
	((state == `MACRO_DECODE_MODES) & Modes_Done & ~Modes_Symbol[0]);

assign New_Y_Predictor_O = (Predictor_Reset | ~Macroblock_Intra) ? 
   `PREDICTOR_RESET : Block_New_DC_predictor;
assign New_Cb_Predictor_O = (Predictor_Reset | ~Macroblock_Intra) ? 
   `PREDICTOR_RESET : Block_New_DC_predictor;
assign New_Cr_Predictor_O = (Predictor_Reset | ~Macroblock_Intra) ? 
   `PREDICTOR_RESET : Block_New_DC_predictor;

assign Block_DC_predictor = (cc == `MACRO_DECODE_CC_Y) ? Y_Predictor_I :
   (cc[0]) ? Cb_Predictor_I : Cr_Predictor_I;

assign Update_Y_Predictor_O = Predictor_Reset | 
   (Block_Update_DC_predictor & (cc == `MACRO_DECODE_CC_Y));
assign Update_Cb_Predictor_O = Predictor_Reset | 
   (Block_Update_DC_predictor & (cc == `MACRO_DECODE_CC_Cb));
assign Update_Cr_Predictor_O = Predictor_Reset | 
   (Block_Update_DC_predictor & (cc == `MACRO_DECODE_CC_Cr));

wire Block_Pattern_Code;
assign Block_Pattern_Code = CBP_reg[4'h5-Block_Counter];

Block_Decode Block_Decoder(
   .resetn(resetn),
   .clock(clock),
   .Start_Block_Decode_I(Block_Start),
   .Done_Block_Decode_O(Block_Done),
   .Data_In_I(Data_In_I),
   .Shift_En_O(Block_Shift_En),
   .Pattern_Code_I(Block_Pattern_Code),
   .Macroblock_Intra_I(Macroblock_Intra),
   .Luma_Chroma_Sel_I(Block_Luma_Chroma_Sel),
   .Intra_VLC_Format_I(Intra_VLC_Format_I),   
   .DC_predict_I(Block_DC_predictor),
   .New_DC_predict_O(Block_New_DC_predictor),
   .Update_DC_predict_O(Block_Update_DC_predictor),
   .Buffer_Value_O(Block_Buffer_Value),
   .Buffer_Write_En_O(Block_Buffer_Write_En),
   .DC_Coeff_En_O(Block_DC_Table_En),
   .DC_Coeff_Data_I(Block_DC_Table_Data),
   .DC_Coeff_Addr_O(Block_DC_Table_Addr),
   .AC_Coeff_En_O(Block_AC_Table_En),
   .AC_Coeff_Data_I(Block_AC_Table_Data),
   .AC_Coeff_Addr_O(Block_AC_Table_Addr)
);
         
endmodule
