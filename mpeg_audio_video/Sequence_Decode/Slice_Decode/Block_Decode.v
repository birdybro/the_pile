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
module Block_Decode(
   resetn,
   clock,

   Start_Block_Decode_I,
   Done_Block_Decode_O,

   Data_In_I,
   Shift_En_O,

   Pattern_Code_I,
   Macroblock_Intra_I,
   Luma_Chroma_Sel_I,
   Intra_VLC_Format_I,   
   
   DC_predict_I,
   New_DC_predict_O,
   Update_DC_predict_O,
   
   Buffer_Value_O,
   Buffer_Write_En_O,

   DC_Coeff_En_O,
   DC_Coeff_Data_I,
   DC_Coeff_Addr_O,
   
   AC_Coeff_En_O,
   AC_Coeff_Data_I,
   AC_Coeff_Addr_O
);

input                resetn;
input                clock;

input                Start_Block_Decode_I;
output               Done_Block_Decode_O;

input                Data_In_I;
output               Shift_En_O;

input                Pattern_Code_I;
input                Macroblock_Intra_I;
input                Luma_Chroma_Sel_I;
input                Intra_VLC_Format_I;

input    [11:0]      DC_predict_I;
output   [11:0]      New_DC_predict_O;
output               Update_DC_predict_O;

output   [31:0]      Buffer_Value_O;
output               Buffer_Write_En_O;

output               DC_Coeff_En_O, AC_Coeff_En_O;  
input    [15:0]      DC_Coeff_Data_I, AC_Coeff_Data_I;
output   [9:0]       DC_Coeff_Addr_O, AC_Coeff_Addr_O;

reg      [2:0]       state;
reg      [17:0]      Escape_Symbol;
reg      [4:0]       bit_counter;
reg                  Subseq_state_delay;
reg                  Write_En_reg;

wire                 Subseq_Start;
wire                 Subseq_Done;
wire                 Subseq_Shift_En;
wire     [15:0]      Subseq_Symbol;
wire     [8:0]       Subseq_Symbol_signed;

reg                  DC_Start;
wire                 DC_Shift_En;
wire                 DC_Done;
wire     [3:0]       DC_Symbol;
reg                  DC_half_range_bit;
wire     [12:0]      DC_prediction_partial;
wire     [12:0]      DC_predict_adjust;
wire     [12:0]      DC_predict_full;

always @(posedge clock or negedge resetn) begin
   if (~resetn) begin
      state <= `BLOCK_DECODE_IDLE;
      bit_counter <= 5'h00;
      Escape_Symbol <= 18'h00000;
      Subseq_state_delay <= 1'b0;
      Write_En_reg <= 1'b0;
      DC_Start <= 1'b0;
      DC_half_range_bit <= 1'b0;
   end else begin
      Write_En_reg <= 1'b0;
      case (state)
         `BLOCK_DECODE_IDLE : begin
               if (Start_Block_Decode_I) begin
                  if (Pattern_Code_I) begin
                     if (Macroblock_Intra_I) begin
                        DC_Start <= 1'b1;
                        state <= `BLOCK_DECODE_DC_SIZE;
                     end else state <= `BLOCK_DECODE_FIRST_COEFF_0;
                  end else begin
                  	state <= `BLOCK_DECODE_EMPTY_BLOCK;
                  	Escape_Symbol <= 18'h00000;
                  	Write_En_reg <= 1'b1;
                  end
               end
            end
         `BLOCK_DECODE_EMPTY_BLOCK : begin   
         		Write_En_reg <= 1'b1;
         		state <= `BLOCK_DECODE_IDLE;
         	end
         `BLOCK_DECODE_DC_SIZE : begin
               DC_Start <= 1'b0;
               if (DC_Done & ~DC_Start) begin
                  if (DC_Symbol == 4'h0) begin
                     Escape_Symbol <= {6'h00,DC_predict_I};
                     Write_En_reg <= 1'b1;
                     state <= `BLOCK_DECODE_SUBSEQ_COEFFS;
                  end else begin
                     Escape_Symbol <= {DC_Symbol,14'h0000};
                     bit_counter <= {1'b0,DC_Symbol};
                     state <= `BLOCK_DECODE_DC_DIFF;
                  end
               end
            end
         `BLOCK_DECODE_DC_DIFF : begin
               Escape_Symbol <= {Escape_Symbol[17:14],Escape_Symbol[12:0],Data_In_I};
               if (bit_counter == 5'h00) begin
                  Escape_Symbol <= {6'h00,New_DC_predict_O};
                  Write_En_reg <= 1'b1;
                  state <= `BLOCK_DECODE_SUBSEQ_COEFFS;
               end else begin
                  bit_counter <= bit_counter - 1;
                  if (bit_counter[3:0] == Escape_Symbol[17:14]) DC_half_range_bit <= Data_In_I;
               end
            end
         `BLOCK_DECODE_FIRST_COEFF_0 : begin
         		if (Data_In_I) state <= `BLOCK_DECODE_FIRST_COEFF_1;
         		else state <= `BLOCK_DECODE_SUBSEQ_COEFFS;
            end
         `BLOCK_DECODE_FIRST_COEFF_1 : begin
               Escape_Symbol <= (Data_In_I) ?
               	{6'h00,12'hFFF} : {6'h00,12'h001};
               Write_En_reg <= 1'b1;
               state <= `BLOCK_DECODE_SUBSEQ_COEFFS;
            end
         `BLOCK_DECODE_SUBSEQ_COEFFS : begin
               Subseq_state_delay <= 1'b1;
               if (Subseq_Done) begin
                  // data handling
                  if (Subseq_Symbol != `DCT_ESCAPE) begin
                     Escape_Symbol <= (Subseq_Symbol == `DCT_END_OF_BLOCK) ? 18'h00000 : 
                        {Subseq_Symbol[13:8],{3{Subseq_Symbol_signed[8]}}, Subseq_Symbol_signed[8:0]};
                     if (Subseq_state_delay) Write_En_reg <= 1'b1;
                  end
                  // state transitions
                  if ((Subseq_state_delay) & (Subseq_Symbol == `DCT_END_OF_BLOCK)) begin
                     Subseq_state_delay <= 1'b0;
                     state <= `BLOCK_DECODE_IDLE;
                  end else if (Subseq_Symbol == `DCT_ESCAPE) begin
                     bit_counter <= 5'd17;
                     state <= `BLOCK_DECODE_SUBSEQ_ESCAPE;
                  end
               end
            end
         `BLOCK_DECODE_SUBSEQ_ESCAPE : begin           
               Escape_Symbol <= {Escape_Symbol[16:0],Data_In_I};
               if (bit_counter == 5'h00) begin
                  Write_En_reg <= 1'b1;
                  state <= `BLOCK_DECODE_SUBSEQ_COEFFS;
               end else bit_counter <= bit_counter - 1;
            end
      endcase
   end
end

assign Buffer_Value_O = {
	(state == `BLOCK_DECODE_IDLE) ? 
		`INFO_BLOCK_CODE_EOB : `INFO_BLOCK_CODE,
	Escape_Symbol };
assign Buffer_Write_En_O = Write_En_reg;

assign Done_Block_Decode_O = (state == `BLOCK_DECODE_IDLE);

assign Subseq_Start = Subseq_Done & 
   (((state == `BLOCK_DECODE_SUBSEQ_ESCAPE) & (bit_counter == 5'h00)) | 
   ((state == `BLOCK_DECODE_SUBSEQ_COEFFS) & 
      ~((Subseq_Symbol == `DCT_ESCAPE) | ((Subseq_state_delay) & (Subseq_Symbol == `DCT_END_OF_BLOCK)))));

assign Shift_En_O = DC_Shift_En | ((state == `BLOCK_DECODE_DC_DIFF) & (bit_counter != 5'h00)) |
   Subseq_Shift_En | (state == `BLOCK_DECODE_SUBSEQ_ESCAPE) |
      (Subseq_state_delay & ~(
         (state == `BLOCK_DECODE_SUBSEQ_COEFFS) &  
            ((Subseq_Symbol == `DCT_ESCAPE) | (Subseq_Symbol == `DCT_END_OF_BLOCK)))) | 
   ((state == `BLOCK_DECODE_FIRST_COEFF_0) & Data_In_I) | 
   (state == `BLOCK_DECODE_FIRST_COEFF_1);

assign Subseq_Symbol_signed = (Data_In_I) ? -Subseq_Symbol[7:0] : Subseq_Symbol[7:0];

assign DC_prediction_partial = DC_predict_I + Escape_Symbol[11:0];
assign DC_predict_adjust = (~DC_half_range_bit) ? 
   ((1 << Escape_Symbol[17:14]) - 1) : 13'h0000;
assign DC_predict_full = DC_prediction_partial - DC_predict_adjust;
assign New_DC_predict_O = DC_predict_full[11:0];

assign Update_DC_predict_O = ((state == `BLOCK_DECODE_DC_DIFF) & (bit_counter == 1'b0));

Block_Decode_DC_Coeff DC_Coeff_Decoder(
   .resetn(resetn),
   .clock(clock),
   .Start_I(DC_Start),
   .Luma_Chroma_Sel_I(Luma_Chroma_Sel_I),
   .Data_In_I(Data_In_I),
   .Shift_En_O(DC_Shift_En),
   .Valid_Code_O(DC_Done),
   .Symbol_O(DC_Symbol),
   .Coeff_Table_En_O(DC_Coeff_En_O),
   .Coeff_Table_Addr_O(DC_Coeff_Addr_O),
   .Coeff_Table_Data_I(DC_Coeff_Data_I)
);

wire                 Table_Sel;
assign Table_Sel = Macroblock_Intra_I & Intra_VLC_Format_I;

Block_Decode_Coeffs Coeff_Decoder(
   .resetn(resetn),
   .clock(clock),
   .Start_I(Subseq_Start),
   .Table_Sel_I(Table_Sel),
   .Data_In_I(Data_In_I),
   .Shift_En_O(Subseq_Shift_En),
   .Valid_Code_O(Subseq_Done),
   .Symbol_O(Subseq_Symbol),
   .Coeff_Table_En_O(AC_Coeff_En_O),
   .Coeff_Table_Addr_O(AC_Coeff_Addr_O),
   .Coeff_Table_Data_I(AC_Coeff_Data_I)
);

endmodule
