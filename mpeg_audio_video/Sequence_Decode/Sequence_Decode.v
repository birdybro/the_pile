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
module Sequence_Decode (
   resetn,
   clock,
   
   Start_Sequence_Decode,
	Advance_Frame_I,
   
	ZBT_Reset_O,
   Shift_1_En_O,
   Shift_8_En_O,
	Shift_Busy_I,
	Byte_Allign_I,
   Bitstream_Data_I,

	Image_Horizontal_O,
	Image_Vertical_O,
	Picture_Type_O,
	Picture_Start_O,

   YUV_Data_O,
   YUV_Write_En_O,
   YUV_Start_O,

	Framestore0_Address_O,
	Framestore0_Data_I,
	Framestore0_Busy_I,
	Framestore0_Busy_O,

	Framestore1_Address_O,
	Framestore1_Data_I,
	Framestore1_Busy_I,   
	Framestore1_Busy_O  
);

input                resetn;
input                clock;

input                Start_Sequence_Decode;
input 					Advance_Frame_I;

output               ZBT_Reset_O;
output               Shift_1_En_O;
output               Shift_8_En_O;
input 					Shift_Busy_I;
input 					Byte_Allign_I;
input    [31:0]      Bitstream_Data_I;

output 	[11:0]		Image_Horizontal_O;
output 	[11:0]		Image_Vertical_O;
output 	[1:0]			Picture_Type_O;
output					Picture_Start_O;

output   [7:0]       YUV_Data_O;
output               YUV_Write_En_O;
output 					YUV_Start_O;

output 	[18:0]		Framestore0_Address_O;
input 	[31:0]		Framestore0_Data_I;
input						Framestore0_Busy_I;
output					Framestore0_Busy_O;

output 	[18:0]		Framestore1_Address_O;
input 	[31:0]		Framestore1_Data_I;
input						Framestore1_Busy_I;
output					Framestore1_Busy_O;

wire                 Start_Code;
wire                 Slice_Start_Code;
wire                 Picture_Start_Code;
wire 						Sequence_Header_Start_Code;
wire                 Start_Code_Upcoming;

reg                  Picture_Start;
wire                 Picture_Done;
wire                 Picture_Shift_1_En;
wire                 Picture_Shift_8_En;

reg                  Headers_Start;
wire                 Headers_Done;
wire                 Headers_Shift_1_En;
wire                 Headers_Shift_8_En;

reg      [2:0]       state;
reg      [4:0]       counter;

assign Shift_1_En_O = Picture_Shift_1_En | Headers_Shift_1_En; 
assign Shift_8_En_O = Picture_Shift_8_En | Headers_Shift_8_En |
   ((state == `DECODER_FILL_PIPE) & (counter[4:2] == 3'b111));

always @(posedge clock or negedge resetn) begin
   if (~resetn) begin
      state <= `DECODER_IDLE;
      counter <= 'd0;
      Picture_Start <= 1'b0;
      Headers_Start <= 1'b0;
   end else begin
      case (state) 
         `DECODER_IDLE : if (Start_Sequence_Decode) state <= `DECODER_RESET;
         `DECODER_RESET : begin
               if (~Start_Sequence_Decode) begin
                  state <= `DECODER_FILL_PIPE;
                  counter <= 'd0;
               end
            end
         `DECODER_FILL_PIPE : begin
               if (counter == 'd31) begin
						state <= `DECODER_WAIT_VSYNCH;
               end else counter <= counter + 1;
            end
         `DECODER_HEADERS : begin
         		Headers_Start <= 1'b0;
               if (Headers_Done & ~Headers_Start) begin
                  Picture_Start <= 1'b1;
                  state <= `DECODER_RUN;
               end
            end
         `DECODER_RUN : begin
               if (~Picture_Done) Picture_Start <= 1'b0;
					else if (~Picture_Start) state <= `DECODER_WAIT_VSYNCH;
            end
         `DECODER_WAIT_VSYNCH : begin
         		if (Advance_Frame_I) begin
               	state <= `DECODER_HEADERS;
                  Headers_Start <= 1'b1;
					end
				end         			
      endcase
   end
end

assign ZBT_Reset_O = 1'b0;

assign Start_Code = Start_Code_Upcoming & Bitstream_Data_I[8];
assign Slice_Start_Code = Start_Code & (Bitstream_Data_I[7:0] != 8'h00) &
   (~Bitstream_Data_I[7] | ~Bitstream_Data_I[6]) & 
   (~Bitstream_Data_I[7] | ~Bitstream_Data_I[5] | ~Bitstream_Data_I[4]);
assign Picture_Start_Code = Start_Code & (Bitstream_Data_I[7:0] == 8'h00);
assign Sequence_Header_Start_Code = Start_Code & (Bitstream_Data_I[7:0] == 8'hB3);
assign Start_Code_Upcoming = (Bitstream_Data_I[31:9] == 23'h00000);

wire [16:0] debug;
assign debug[16] = Advance_Frame_I;
assign debug[15] = Start_Code;				// 127
assign debug[14] = Slice_Start_Code;		// 126
assign debug[13] = Picture_Start_Code;		// 125
assign debug[12] = Start_Code_Upcoming;	// 124
assign debug[11] = Picture_Start;			// 123
assign debug[10] = Picture_Done;				// 122
assign debug[9] = Shift_1_En_O;				// 121
assign debug[8] = Shift_8_En_O;				// 120
assign debug[7:5] = state;						// 119 - 117
assign debug[4:0] = counter;					// 116 - 112

wire [2:0] Picture_Type;
wire [1:0] Picture_Structure;
wire Intra_VLC_Format;
wire Frame_Pred_Frame_DCT;
wire Concealment_Vectors;
wire [15:0]	f_codes;
wire [1:0] Intra_DC_Precision;
wire Quant_Scale_Type;
wire Alternate_Scan;
wire Load_Seq_Intra_Quant;
wire Load_Seq_NIntra_Quant;

assign Picture_Type_O = Picture_Type[1:0];
assign Picture_Start_O = Picture_Start;

Picture_Decode Picture_Decoder(
   .resetn(resetn),
   .clock(clock),
   .Start_Picture_Decode_I(Picture_Start),
   .Done_Picture_Decode_O(Picture_Done),
   .Data_In_I(Bitstream_Data_I[31:30]),
   .Shift_1_En_O(Picture_Shift_1_En),
   .Shift_8_En_O(Picture_Shift_8_En),
	.Shift_Busy_I(Shift_Busy_I),
	.Byte_Allign_I(Byte_Allign_I),
   .Start_Code_I(Start_Code),
   .Slice_Start_Code_I(Slice_Start_Code),
   .Start_Code_Upcoming_I(Start_Code_Upcoming),
   .Picture_Type_I(Picture_Type[1:0]),
 	.Picture_Structure_I(Picture_Structure),
	.Intra_VLC_Format_I(Intra_VLC_Format),
	.Frame_Pred_Frame_DCT_I(Frame_Pred_Frame_DCT),
	.Concealment_Vectors_I(Concealment_Vectors),
	.F_Codes_I(f_codes),
	.Intra_DC_Precision_I(Intra_DC_Precision),
	.Quant_Scale_Type_I(Quant_Scale_Type),
	.Alternate_Scan_I(Alternate_Scan),
	.Image_Horizontal_I(Image_Horizontal_O),  
	.Image_Vertical_I(Image_Vertical_O),
	.Load_Seq_Intra_Quant_I(Load_Seq_Intra_Quant),
	.Load_Seq_NIntra_Quant_I(Load_Seq_NIntra_Quant),
   .YUV_Data_O(YUV_Data_O),
   .YUV_Write_En_O(YUV_Write_En_O),
	.YUV_Start_O(YUV_Start_O),
	.Forward_Framestore_Address_O(Framestore0_Address_O),
	.Forward_Framestore_Data_I(Framestore0_Data_I),
	.Forward_Framestore_Busy_I(Framestore0_Busy_I),
	.Forward_Framestore_Busy_O(Framestore0_Busy_O),
	.Backward_Framestore_Address_O(Framestore1_Address_O),
	.Backward_Framestore_Data_I(Framestore1_Data_I),
	.Backward_Framestore_Busy_I(Framestore1_Busy_I),   
	.Backward_Framestore_Busy_O(Framestore1_Busy_O)   
,.debug(debug)
);

Header_Decode Header_Decoder(
   .resetn(resetn),
   .clock(clock),
   .Start_Header_Decode_I(Headers_Start),
   .Done_Header_Decode_O(Headers_Done),
   .Data_In_I(Bitstream_Data_I),
   .Shift_1_En_O(Headers_Shift_1_En),
   .Shift_8_En_O(Headers_Shift_8_En),
	.Shift_Busy_I(Shift_Busy_I),
	.Byte_Allign_I(Byte_Allign_I),
   .Slice_Start_Code_I(Slice_Start_Code),
	.Quant_Matrix_Value_O(),
	.Quant_Matrix_Write_En_O(),
	.Horizontal_Size(Image_Horizontal_O),  
	.Vertical_Size(Image_Vertical_O),
	.load_seq_intra_quant_matrix(Load_Seq_Intra_Quant),
	.load_seq_non_intra_quant_matrix(Load_Seq_NIntra_Quant),
	.progressive_sequence(),
	.chroma_format(),
	.picture_coding_type(Picture_Type),
	.f_codes(f_codes),
	.intra_dc_precision(Intra_DC_Precision),
	.picture_structure(Picture_Structure),
	.top_field_first(),
	.frame_pred_frame_dct(Frame_Pred_Frame_DCT),
	.concealment_mv(Concealment_Vectors),
	.q_scale_type(Quant_Scale_Type),
	.intra_vlc_format(Intra_VLC_Format),
	.alternate_scan(Alternate_Scan),
	.progressive_frame()	
);

endmodule

