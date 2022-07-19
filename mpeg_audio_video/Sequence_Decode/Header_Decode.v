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
module Header_Decode(
   resetn,
   clock,

   Start_Header_Decode_I,
   Done_Header_Decode_O,

   Data_In_I,
   Shift_1_En_O,
   Shift_8_En_O,
	Byte_Allign_I,
	Shift_Busy_I,
	Slice_Start_Code_I,

	Quant_Matrix_Value_O,
	Quant_Matrix_Write_En_O,

	Horizontal_Size,  
	Vertical_Size,
	load_seq_intra_quant_matrix,
	load_seq_non_intra_quant_matrix,
	progressive_sequence,
	chroma_format,
	picture_coding_type,
	f_codes,
	intra_dc_precision,
	picture_structure,
	top_field_first,
	frame_pred_frame_dct,
	concealment_mv,
	q_scale_type,
	intra_vlc_format,
	alternate_scan,
	progressive_frame
);

input                resetn;
input                clock;

input 				   Start_Header_Decode_I;
output 				   Done_Header_Decode_O;

input    [31:0]      Data_In_I;
output               Shift_1_En_O;
output               Shift_8_En_O;
input 					Byte_Allign_I;
input						Shift_Busy_I;
input 					Slice_Start_Code_I;

output 	[11:0]		Horizontal_Size;
output 	[11:0]		Vertical_Size;
output 					load_seq_intra_quant_matrix;
output 					load_seq_non_intra_quant_matrix;
output					progressive_sequence;
output	[1:0]			chroma_format;
output	[2:0]			picture_coding_type;
output	[15:0]		f_codes;
output	[1:0]			intra_dc_precision;
output	[1:0]			picture_structure;
output					top_field_first;
output					frame_pred_frame_dct;
output					concealment_mv;
output					q_scale_type;
output					intra_vlc_format;
output					alternate_scan;
output					progressive_frame;

output 	[7:0]			Quant_Matrix_Value_O;
output 					Quant_Matrix_Write_En_O;

reg 		[11:0]		Horizontal_Size;
reg 		[11:0]		Vertical_Size;
reg 						load_seq_intra_quant_matrix;
reg 						load_seq_non_intra_quant_matrix;
reg 						progressive_sequence;
reg 		[1:0]			chroma_format;
reg 		[2:0]			picture_coding_type;
reg 		[15:0]		f_codes;
reg 		[1:0]			intra_dc_precision;
reg 		[1:0]			picture_structure;
reg 						top_field_first;
reg 						frame_pred_frame_dct;
reg 						concealment_mv;
reg 						q_scale_type;
reg 						intra_vlc_format;
reg 						alternate_scan;
reg 						progressive_frame;

wire 						Start_Code;
wire 						Recognized_Start_Code;

reg 		[3:0] 		state;
reg 		[8:0] 		counter;

reg 						start_code_search;
reg 						pic_header_found;
reg 						shift_8_reg;
reg 						shift_1_reg;

reg 						quant_reg_wen_0;
reg 						quant_reg_wen_1;
reg 		[2:0]			user_extension_code;

assign Done_Header_Decode_O = (state == `HEADER_DECODE_IDLE);
assign Start_Code = (Data_In_I[31:8] == 24'h000001);
assign Recognized_Start_Code = Start_Code & (
	(pic_header_found & Slice_Start_Code_I) | 
	(Data_In_I[7:0] == 8'hB3) | 
	(Data_In_I[7:0] == 8'hB5) | 
	(Data_In_I[7:0] == 8'hB8) |
	(Data_In_I[7:0] == 8'h00));

assign Shift_1_En_O = shift_1_reg | 
	(~Byte_Allign_I & ~Shift_Busy_I & start_code_search & ~Recognized_Start_Code);
assign Shift_8_En_O = shift_8_reg | 
	( Byte_Allign_I & ~Shift_Busy_I & start_code_search & ~Recognized_Start_Code);

assign Quant_Matrix_Value_O = 
	(quant_reg_wen_0) ? Data_In_I[24:17] : Data_In_I[23:16];
assign Quant_Matrix_Write_En_O = quant_reg_wen_0 | quant_reg_wen_1;

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		state <= `HEADER_DECODE_IDLE;
		counter <= 9'h000;
		start_code_search <= 1'b0;
		pic_header_found <= 1'b0;
		shift_8_reg <= 1'b0;
		shift_1_reg <= 1'b0;
		quant_reg_wen_0 <= 1'b0;
		quant_reg_wen_1 <= 1'b0;
		user_extension_code <= 3'h0;
		Horizontal_Size <= 12'd720; //12'h000;
		Vertical_Size <= 12'd480; //12'h000;
		load_seq_intra_quant_matrix <= 1'b0;
		load_seq_non_intra_quant_matrix <= 1'b0;
		progressive_sequence <= 1'b0;
		chroma_format <= 2'h0;
		picture_coding_type <= 3'h0;
		f_codes <= 16'h0000;
		intra_dc_precision <= 2'h0;
		picture_structure <= 2'h0;
		top_field_first <= 1'b0;
		frame_pred_frame_dct <= 1'b0;
		concealment_mv <= 1'b0;
		q_scale_type <= 1'b0;
		intra_vlc_format <= 1'b0;
		alternate_scan <= 1'b0;
		progressive_frame <= 1'b0;
	end else begin
		case (state)
			`HEADER_DECODE_IDLE : begin
					if (Start_Header_Decode_I) begin
						start_code_search <= 1'b1;
						state <= `HEADER_DECODE_SEARCH_START;
					end
				end
			`HEADER_DECODE_SEARCH_START : begin
					shift_8_reg <= 1'b0;
					if (pic_header_found & Slice_Start_Code_I) begin
						start_code_search <= 1'b0;
						pic_header_found <= 1'b0;
						state <= `HEADER_DECODE_IDLE;
					end else if (Start_Code) begin
						case (Data_In_I[7:0])
							8'hB3 : begin
									state <= `HEADER_DECODE_SEQ_HEADER;
									counter <= 9'h000;
									shift_8_reg <= 1'b1;
									start_code_search <= 1'b0;
								end
							8'hB5 : begin
									if (user_extension_code == 3'h0) begin
										state <= `HEADER_DECODE_SEQ_EXT;
										counter <= 9'h000;
										shift_8_reg <= 1'b1;
										start_code_search <= 1'b0;
									end
									if (user_extension_code == 3'h1) begin
										state <= `HEADER_DECODE_PIC_EXT;
										counter <= 9'h000;
										shift_8_reg <= 1'b1;
										start_code_search <= 1'b0;
									end
									if (user_extension_code == 3'h2) begin
										state <= `HEADER_DECODE_EXT_2;
										counter <= 9'h000;
										shift_8_reg <= 1'b1;
										start_code_search <= 1'b0;
									end
								end
							8'hB8 : begin
									state <= `HEADER_DECODE_GOP_HEADER;
									counter <= 9'h000;
									shift_8_reg <= 1'b1;
									start_code_search <= 1'b0;
								end
							8'h00 : begin
									state <= `HEADER_DECODE_PIC_HEADER;
									pic_header_found <= 1'b1;
									counter <= 9'h000;
									shift_8_reg <= 1'b1;
									start_code_search <= 1'b0;
								end
						endcase
					end
				end					
			`HEADER_DECODE_SEQ_HEADER : begin
					user_extension_code <= 3'h0;
					counter <= counter + 1;
					case (counter)
						9'd4 : begin
								Horizontal_Size <= Data_In_I[31:20];
								Vertical_Size <= Data_In_I[19:8];
							end
						9'd10 : begin
								load_seq_intra_quant_matrix <= Data_In_I[17];
								if (~Data_In_I[17]) begin
									load_seq_non_intra_quant_matrix <= Data_In_I[16];
									if (~Data_In_I[16]) begin
										shift_8_reg <= 1'b0;
										start_code_search <= 1'b1;
										state <= `HEADER_DECODE_SEARCH_START;
									end else quant_reg_wen_1 <= 1'b1;
								end else quant_reg_wen_0 <= 1'b1;
							end 
						9'd74 : begin
								if (quant_reg_wen_0) begin
									quant_reg_wen_0 <= 1'b0;
									load_seq_non_intra_quant_matrix <= Data_In_I[16];
									if (~Data_In_I[18]) begin
										shift_8_reg <= 1'b0;
										start_code_search <= 1'b1;
										state <= `HEADER_DECODE_SEARCH_START;
									end else quant_reg_wen_1 <= 1'b1; 
								end else begin
									quant_reg_wen_1 <= 1'b0;
									shift_8_reg <= 1'b0;
									start_code_search <= 1'b1;
									state <= `HEADER_DECODE_SEARCH_START;
								end										
							end
						9'd137 : begin
								quant_reg_wen_1 <= 1'b0; 
								shift_8_reg <= 1'b0;
								start_code_search <= 1'b1;
								state <= `HEADER_DECODE_SEARCH_START;
							end
					endcase
				end
			`HEADER_DECODE_EXTENSION_USER : begin					
				end
			`HEADER_DECODE_SEQ_EXT: begin
					counter <= counter + 1;
					if (counter == 9'd4) begin
						progressive_sequence <= Data_In_I[19];
						chroma_format <= Data_In_I[18:17];
						shift_8_reg <= 1'b0;
						start_code_search <= 1'b1;
						state <= `HEADER_DECODE_SEARCH_START;
					end
				end
			`HEADER_DECODE_GOP_HEADER : begin
					counter <= counter + 1;
					if (counter == 9'd4) begin
						// timecode = [31:7]
						shift_8_reg <= 1'b0;
						start_code_search <= 1'b1;
						state <= `HEADER_DECODE_SEARCH_START;						
					end
				end
			`HEADER_DECODE_PIC_HEADER : begin
					user_extension_code <= 3'h1;
					counter <= counter + 1;
					if (counter == 9'd5) begin
						picture_coding_type <= Data_In_I[29:27];
						shift_8_reg <= 1'b0;
						start_code_search <= 1'b1;
						state <= `HEADER_DECODE_SEARCH_START;						
					end						
				end
			`HEADER_DECODE_PIC_EXT : begin
					user_extension_code <= 3'h2;
					counter <= counter + 1;
					case (counter)
						9'd4 : begin
								f_codes <= Data_In_I[27:12];
								intra_dc_precision <= Data_In_I[11:10];
								picture_structure <= Data_In_I[9:8];
								top_field_first <= Data_In_I[7];
								frame_pred_frame_dct <= Data_In_I[6];
								concealment_mv <= Data_In_I[5];
								q_scale_type <= Data_In_I[4];
								intra_vlc_format <= Data_In_I[3];
								alternate_scan <= Data_In_I[2];
							end
						9'd5 : begin
								progressive_frame <= Data_In_I[7];
								shift_8_reg <= 1'b0;
								start_code_search <= 1'b1;
								state <= `HEADER_DECODE_SEARCH_START;
							end
					endcase
				end	
			`HEADER_DECODE_EXT_2 : begin
					case(Data_In_I[7:3]) 
						4'h3 : begin
								state <= `HEADER_DECODE_QUANT_EXT;
							end
						default : begin
								shift_8_reg <= 1'b0;
								start_code_search <= 1'b1;
								state <= `HEADER_DECODE_SEARCH_START;								
							end
					endcase
				end
			`HEADER_DECODE_QUANT_EXT : begin	
					counter <= counter + 1;
					shift_8_reg <= 1'b0;
					start_code_search <= 1'b1;
					state <= `HEADER_DECODE_SEARCH_START;								
				end
		endcase
	end
end

endmodule
