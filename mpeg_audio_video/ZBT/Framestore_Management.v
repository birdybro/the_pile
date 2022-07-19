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
module Framestore_Management(
	resetn,                          
	                                 
	internal_ZBT_clock,              
	internal_video_clock,            
	                                 
	Picture_Start_I,                 
	Picture_Done_I,                  
	Picture_Type_I,                  
	Display_Advance_O,               
	                                 
	Address_Reset_I,                 
	Image_Horizontal_I,              
	Image_Vertical_I,                
	                                 
	YUV_Write_En_I,                  
	YUV_Write_Data_I,   
	
	Audio_Bitstream_Access_O,
	Audio_Bitstream_Address_I,
	Audio_Bitstream_Write_Data_I,
	Audio_Bitstream_Write_En_I,
	Audio_Bitstream_Read_Data_O,

	Video_Bitstream_Access_O, 
	Video_Bitstream_Address_I,
	Video_Bitstream_Write_Data_I,
	Video_Bitstream_Write_En_I,
	Video_Bitstream_Read_Data_O,
	                                 
	Framestore0_Address_I,           
	Framestore0_Data_O,       	// forward       
	Framestore0_Busy_O,              
	Framestore0_Busy_I,              
                                    
	Framestore1_Address_I,           
	Framestore1_Data_O,      	// backward
	Framestore1_Busy_O,              
	Framestore1_Busy_I,              
	                                 
	//ZBT signals                    
	Bank_0_Address_O,                
	Bank_1_Address_O,                
	Bank_2_Address_O,                
	Bank_3_Address_O,                
	                                 
	Bank_0_Write_Data_O,             
	Bank_1_Write_Data_O,             
	Bank_2_Write_Data_O,             
	Bank_3_Write_Data_O,             
	                                 
	Bank_0_Write_En_O,               
	Bank_1_Write_En_O,               
	Bank_2_Write_En_O,               
	Bank_3_Write_En_O,               
	                                 
	Bank_0_Read_Data_I,              
	Bank_1_Read_Data_I,              
	Bank_2_Read_Data_I,              
	Bank_3_Read_Data_I,              

	VGA_OUT_PIXEL_CLOCK_P,
	VGA_COMP_SYNCH_N,
	VGA_OUT_RED_P, 
	VGA_OUT_GREEN_P, 
	VGA_OUT_BLUE_P,
	VGA_HSYNCH_N,
	VGA_VSYNCH_N,
	VGA_OUT_BLANK_N,

	Audio_Sync_I,
	Audio_Sync_O
);

input						resetn;
	
input 					internal_ZBT_clock;
input 					internal_video_clock;
	
input						Picture_Start_I;
input						Picture_Done_I;
input 	[1:0]			Picture_Type_I;
output reg				Display_Advance_O;
	
input 					Address_Reset_I;
input 	[11:0]		Image_Horizontal_I;
input		[11:0]		Image_Vertical_I;
	
input 					YUV_Write_En_I;
input 	[7:0]			YUV_Write_Data_I;

output 					Audio_Bitstream_Access_O;
input  	[18:0]		Audio_Bitstream_Address_I;
input 	[31:0]		Audio_Bitstream_Write_Data_I;
input  					Audio_Bitstream_Write_En_I;
output 	[31:0]		Audio_Bitstream_Read_Data_O;

output 					Video_Bitstream_Access_O;
input  	[18:0]		Video_Bitstream_Address_I;
input 	[31:0]		Video_Bitstream_Write_Data_I;
input  					Video_Bitstream_Write_En_I;
output 	[31:0]		Video_Bitstream_Read_Data_O;

input 	[18:0]		Framestore0_Address_I;
output 	[31:0]		Framestore0_Data_O;
output 					Framestore0_Busy_O;
input 					Framestore0_Busy_I;

input 	[18:0]		Framestore1_Address_I;
output 	[31:0]		Framestore1_Data_O;
output 					Framestore1_Busy_O;
input 					Framestore1_Busy_I;

output	[18:0]		Bank_0_Address_O;
output	[18:0]		Bank_1_Address_O;
output	[18:0]		Bank_2_Address_O;
output	[18:0]		Bank_3_Address_O;
	
output	[31:0]		Bank_0_Write_Data_O;
output	[31:0]		Bank_1_Write_Data_O;
output	[31:0]		Bank_2_Write_Data_O;
output	[31:0]		Bank_3_Write_Data_O;
	
output 					Bank_0_Write_En_O;
output 					Bank_1_Write_En_O;
output 					Bank_2_Write_En_O;
output 					Bank_3_Write_En_O;
	
input		[31:0]		Bank_0_Read_Data_I;
input		[31:0]		Bank_1_Read_Data_I;
input		[31:0]		Bank_2_Read_Data_I;
input		[31:0]		Bank_3_Read_Data_I;

output					VGA_OUT_PIXEL_CLOCK_P;
output					VGA_COMP_SYNCH_N;
output 	[7:0]			VGA_OUT_RED_P;
output 	[7:0]			VGA_OUT_GREEN_P;
output 	[7:0]			VGA_OUT_BLUE_P;
output					VGA_HSYNCH_N;
output					VGA_VSYNCH_N;
output					VGA_OUT_BLANK_N;

input 					Audio_Sync_I;
output 					Audio_Sync_O;

reg 		[5:0] 		Sample_counter;
reg 		[3:0]			Block_counter;
reg 		[5:0] 		MB_column_counter;
reg 		[18:0]		MB_Y_pointer, MB_CbCr_pointer, Address;
reg      [7:0]       Buffer_HH, Buffer_HL, Buffer_LH;

wire 		[3:0]			Block_limit;
wire 		[5:0]			MB_column_limit;

assign Block_limit = 4'h5;
assign MB_column_limit = Image_Horizontal_I[9:4] - 1;

reg Audio_Sync;
reg [1:0] Audio_offset_counter;
assign Audio_Sync_O = Audio_Sync;
//assign Audio_Sync_O = 1'b1;
always @(posedge internal_ZBT_clock or negedge resetn) begin
	if (~resetn) Audio_Sync <= 1'b0;
	else Audio_Sync <= (Audio_offset_counter == 2'h2);
end	

always @(posedge internal_ZBT_clock or negedge resetn) begin
	if (~resetn) begin
		MB_Y_pointer <= 19'h00000;
		MB_CbCr_pointer <= 19'h00000;
		Address <= 19'h00000;
		Block_counter <= 4'h0;
		Sample_counter <= 6'h00;
		MB_column_counter <= 6'h00;
	end else if (Address_Reset_I) begin
		MB_Y_pointer <= 19'h00000;
		MB_CbCr_pointer <= 19'h00000;
		Address <= 19'h00000;
		Block_counter <= 4'h0;
		Sample_counter <= 6'h00;
		MB_column_counter <= 6'h00;	
	end else begin
		if (YUV_Write_En_I) begin
			Sample_counter <= Sample_counter + 1;
			if (Sample_counter[1:0] == 2'h3) begin
				if (Sample_counter[2]) begin
					if (Block_counter[3:2] == 2'h0)
						Address <= Address + (Image_Horizontal_I >> 2) - 1;
					else Address <= Address + (Image_Horizontal_I >> 3) - 1;
				end else Address <= Address + 1;
			end
			if (Sample_counter == 6'h3F) begin
				Block_counter <= Block_counter + 1;
				case (Block_counter)
					4'h0 : Address <= MB_Y_pointer + 2;
					4'h1 : Address <= MB_Y_pointer + (Image_Horizontal_I << 1);
					4'h2 : Address <= MB_Y_pointer + (Image_Horizontal_I << 1) + 2;
					4'h3 : Address <= `ZBT_Cb_OFFSET + MB_CbCr_pointer;
					4'h4 : Address <= `ZBT_Cr_OFFSET + MB_CbCr_pointer;
				endcase
				if (Block_counter == Block_limit) begin
					Block_counter <= 4'h0;
					if (MB_column_counter == MB_column_limit) begin
						MB_column_counter <= 6'h00;
						MB_Y_pointer <= MB_Y_pointer + (Image_Horizontal_I << 2) - (Image_Horizontal_I >> 2) + 'd4;
						MB_CbCr_pointer <= MB_CbCr_pointer + Image_Horizontal_I - (Image_Horizontal_I >> 3) + 'd2;
						Address <= MB_Y_pointer + (Image_Horizontal_I << 2) - (Image_Horizontal_I >> 2) + 'd4;
					end else begin
						MB_column_counter <= MB_column_counter + 1;
						MB_Y_pointer <= MB_Y_pointer + 19'd4;
						MB_CbCr_pointer <= MB_CbCr_pointer + 19'd2;
						Address <= MB_Y_pointer + 19'd4;
					end
				end
			end
		end
	end
end

always @(posedge internal_ZBT_clock or negedge resetn) begin
   if (~resetn) begin
      Buffer_HH <= 8'h00;
      Buffer_HL <= 8'h00;
      Buffer_LH <= 8'h00;
   end else begin
   	if (YUV_Write_En_I) begin
	      if (Sample_counter[1:0] == 2'h0) 
	      	Buffer_HH <= YUV_Write_Data_I;
	      if (Sample_counter[1:0] == 2'h1) 
	      	Buffer_HL <= YUV_Write_Data_I;
	      if (Sample_counter[1:0] == 2'h2) 
	      	Buffer_LH <= YUV_Write_Data_I;
		end
   end
end

wire 	[31:0]	Decoder_Write_Data;

assign Decoder_Write_Data = {Buffer_HH,Buffer_HL,Buffer_LH,YUV_Write_Data_I};

wire 						Backend_Frame_Advance;
reg 						Backend_Frame_Advance_40;
reg 						Backend_Frame_Advance_54;
reg 						Backend_Frame_Advance_54_dly;
reg 						Advance_Frame_Flag;
reg 						picture_start_dly;
reg 						Prediction_pointer;	// 0: fwd 0 bwd 1, 1: fwd 1 bwd 0
reg 						Display_pointer;		// 0: disp bank 3, 1: disp bank 2
reg 		[3:0]			Copy_pipe;
reg 		[18:0]		Copy_address;
wire 		[31:0]		Copy_data;

always @(posedge internal_ZBT_clock or negedge resetn) begin
	if (~resetn) begin
		Audio_offset_counter <= 2'h0;
		picture_start_dly <= 1'b0;
		Prediction_pointer <= 1'b0;
		Display_pointer <= 1'b0;
		Display_Advance_O <= 1'b0;
		Backend_Frame_Advance_54 <= 1'b0;
		Backend_Frame_Advance_54_dly <= 1'b0;
		Advance_Frame_Flag <= 1'b1;
		Copy_address <= 19'h00000;
		Copy_pipe <= 4'h0;
	end else begin
		
		picture_start_dly <= Picture_Start_I;
		Backend_Frame_Advance_54 <= Backend_Frame_Advance_40;
		Backend_Frame_Advance_54_dly <= Backend_Frame_Advance_54;

		if (YUV_Write_En_I & 
			(Sample_counter[1:0] == 2'h3) & 
			(Picture_Type_I != `B_PICTURE)
		) begin
			Copy_pipe <= {1'b1, Copy_pipe[3:1]};
			Copy_address <= Address;			
		end else Copy_pipe <= {1'b0, Copy_pipe[3:1]}; 

		if (
			Picture_Start_I & ~picture_start_dly &
			(Picture_Type_I != `B_PICTURE) 
		) begin
			Prediction_pointer <= ~Prediction_pointer;
			if (Audio_offset_counter != 2'h2) 
				Audio_offset_counter <= Audio_offset_counter + 1;
		end
		
		// display pointer logic
		Display_Advance_O <= 1'b0;
		if (Backend_Frame_Advance_54 & ~Backend_Frame_Advance_54_dly) begin
			Advance_Frame_Flag <= ~Advance_Frame_Flag;
//			if (Advance_Frame_Flag) begin
			if (Advance_Frame_Flag & Audio_Sync_I) begin
				Display_pointer <= ~Display_pointer;
				Display_Advance_O <= 1'b1;
			end
		end
	end
end	

// Video - Bank0, Audio - Bank1
assign Video_Bitstream_Access_O = (Prediction_pointer) ? 
	~(Framestore1_Busy_I | Framestore1_Busy_O) : 
	~(Framestore0_Busy_I | Framestore0_Busy_O);
assign Audio_Bitstream_Access_O = (Prediction_pointer) ? 
	~(Framestore0_Busy_I | Framestore0_Busy_O) : 
	~(Framestore1_Busy_I | Framestore1_Busy_O);

assign Video_Bitstream_Read_Data_O = Bank_0_Read_Data_I;
assign Audio_Bitstream_Read_Data_O = Bank_1_Read_Data_I;

// Framestore connections
assign Framestore0_Busy_O = (Picture_Type_I != `B_PICTURE) & 
	YUV_Write_En_I & (Sample_counter[1:0] == 2'h3);
assign Framestore1_Busy_O = (Picture_Type_I != `B_PICTURE) & 
	YUV_Write_En_I & (Sample_counter[1:0] == 2'h3);

assign Framestore0_Data_O = (Prediction_pointer) ? 
	Bank_1_Read_Data_I : Bank_0_Read_Data_I;
assign Framestore1_Data_O = (Prediction_pointer) ? 
	Bank_0_Read_Data_I : Bank_1_Read_Data_I;

// Bank connections
assign Bank_0_Write_Data_O = (Video_Bitstream_Access_O) ? 
	Video_Bitstream_Write_Data_I : Decoder_Write_Data;
assign Bank_1_Write_Data_O = (Audio_Bitstream_Access_O) ? 
	Audio_Bitstream_Write_Data_I : Decoder_Write_Data;

assign Bank_0_Write_En_O = (Video_Bitstream_Access_O) ? Video_Bitstream_Write_En_I : 
	 Prediction_pointer & YUV_Write_En_I & 
	(Picture_Type_I != `B_PICTURE) & 
	(Sample_counter[1:0] == 2'h3);
assign Bank_1_Write_En_O = (Audio_Bitstream_Access_O) ? Audio_Bitstream_Write_En_I : 
	~Prediction_pointer & YUV_Write_En_I & 
	(Picture_Type_I != `B_PICTURE) & 
	(Sample_counter[1:0] == 2'h3);

assign Bank_0_Address_O = (Video_Bitstream_Access_O) ? Video_Bitstream_Address_I :
	(YUV_Write_En_I & (Picture_Type_I != `B_PICTURE) & (Sample_counter[1:0] == 2'h3)
	) ? Address : (Prediction_pointer) ? 
		Framestore1_Address_I : Framestore0_Address_I;
assign Bank_1_Address_O = (Audio_Bitstream_Access_O) ? Audio_Bitstream_Address_I : 
	(YUV_Write_En_I & (Picture_Type_I != `B_PICTURE) & (Sample_counter[1:0] == 2'h3)
	) ? Address : (Prediction_pointer) ? 
		Framestore0_Address_I : Framestore1_Address_I; 		

assign Copy_data = (Prediction_pointer) ? 
	Bank_1_Read_Data_I : Bank_0_Read_Data_I;

wire	[18:0]	ZBT_backend_address;
wire	[31:0]	ZBT_backend_data_0;

wire	[18:0]	Display_Write_Address;
wire 	[31:0]	Display_Write_Data;
wire 				Display_Write_En;

assign Display_Write_Address = 
	(Picture_Type_I != `B_PICTURE) ? 
		Copy_address : Address;
assign Display_Write_Data = 
	(Picture_Type_I != `B_PICTURE) ? 
		Copy_data : Decoder_Write_Data;
assign Display_Write_En = 
	(Picture_Type_I != `B_PICTURE) ? Copy_pipe[0] : 
		(YUV_Write_En_I & (Sample_counter[1:0] == 2'h3));

ZBT_Video_Interface Display_Bank_Interface(
   .resetn(resetn),
	.internal_clock_40(internal_video_clock),
	.internal_clock_54(internal_ZBT_clock),
   .Bank_Select_I(Display_pointer),   
   .Video_Address_40_I(ZBT_backend_address),
   .Video_Data_40_O(ZBT_backend_data_0),
   .Write_Address_54_I(Display_Write_Address),
   .Write_Data_54_I(Display_Write_Data),
   .Write_En_54_I(Display_Write_En),   
   .ZBT_Bank0_Address_O(Bank_2_Address_O),
   .ZBT_Bank0_Write_Data_O(Bank_2_Write_Data_O),
   .ZBT_Bank0_Write_En_O(Bank_2_Write_En_O),
   .ZBT_Bank0_Read_Data_I(Bank_2_Read_Data_I),   
   .ZBT_Bank1_Address_O(Bank_3_Address_O),
   .ZBT_Bank1_Write_Data_O(Bank_3_Write_Data_O),
   .ZBT_Bank1_Write_En_O(Bank_3_Write_En_O),
   .ZBT_Bank1_Read_Data_I(Bank_3_Read_Data_I)
);

// instantiate Backend
reg	[31:0]	ZBT_backend_data_1;
reg	[31:0]	ZBT_backend_data_2;
reg	[31:0]	ZBT_backend_data_3;
reg	[31:0]	ZBT_backend_data_4;
reg	[31:0]	ZBT_backend_data;

wire	[18:0] 	Backend_ZBT_CB_start;
wire	[18:0] 	Backend_ZBT_CR_start;

assign Backend_ZBT_CB_start = `ZBT_Cr_OFFSET;
assign Backend_ZBT_CR_start = `ZBT_Cb_OFFSET;

always @(posedge internal_video_clock or negedge resetn) begin
	if (~resetn) begin
		ZBT_backend_data_1 <= 32'h00000000;
		ZBT_backend_data_2 <= 32'h00000000;
		ZBT_backend_data_3 <= 32'h00000000;
		ZBT_backend_data_4 <= 32'h00000000;
		ZBT_backend_data <= 32'h00000000;
	end else begin
		ZBT_backend_data_1 <= ZBT_backend_data_0;
		ZBT_backend_data_2 <= ZBT_backend_data_1;
		ZBT_backend_data_3 <= ZBT_backend_data_2;
		ZBT_backend_data_4 <= ZBT_backend_data_3;
		ZBT_backend_data <= ZBT_backend_data_4;	//
	end
end	

backend backend_unit(	
	.clk(internal_video_clock), 
	.resetn(resetn), 
	.data_mode(3'b000),
	.ZBT_addr(ZBT_backend_address), 
	.ZBT_datain(ZBT_backend_data), 
	.R_out(VGA_OUT_RED_P), 
	.G_out(VGA_OUT_GREEN_P), 
	.B_out(VGA_OUT_BLUE_P),
	.pic_width(Image_Horizontal_I),
	.pic_height(Image_Vertical_I),
	.CR_start(Backend_ZBT_CR_start),
	.CB_start(Backend_ZBT_CB_start),
	.h_synch_n(VGA_HSYNCH_N),
	.v_synch_n(VGA_VSYNCH_N),
	.blank_n(VGA_OUT_BLANK_N),
	.frame_advance(Backend_Frame_Advance)
);

OBUF_F_12 vga_clk_buf (.I(internal_video_clock), .O(VGA_OUT_PIXEL_CLOCK_P));
OBUF_F_12 vga_comp_synch_buf (.I(1'b1), .O(VGA_COMP_SYNCH_N));

always @(posedge internal_video_clock or negedge resetn) begin
	if (~resetn) Backend_Frame_Advance_40 <= 1'b0;
	else Backend_Frame_Advance_40 <= Backend_Frame_Advance;
end

endmodule

//Bank 1 may take from YUV
//Bank 2 may take from YUV
//Bank 3 may take from YUV / Bank 1 / Bank 2
//Bank 4 may take from YUV / Bank 1 / Bank 2

/*	
							F,B												F,B at end of header decode
Decode I1 to 0																1,0
Decode P4 to 1 using 0		- 				copy 0 to 3				0,1
Decode B2 to 2 using 0,1	- display 3						I1		0,1
Decode B3 to 3 using 0,1	- display 2						B2		0,1
Decode P7 to 0 using 1		- display 3 copy 1 to 2		B3		1,0
Decode B5 to 3 using 1,0	- display 2						P4		1,0
Decode B6 to 2 using 1,0	- display 3 					B5		1,0
Decode P10 to 1 using 0		- display 2	copy 0 to 3		B6		0,1
Decode B8 to 2 using 0,1	- display 3						P7		0,1
Decode B9 to 3 using 0,1	- display 2 					B8		0,1

I/P frame - decoder -> backward bank, forward bank -> ~display bank
B frame - decoder -> ~display bank

always copy forward (post adjust) to ~display bank

							F,B												F,B at end of header decode
Decode I1 to 0																1,0
Decode P2 to 1 using 0		- 				copy 0 to 3				0,1
Decode P3 to 0 using 1		- display 3 copy 1 to 2		I1		1,0
Decode P4 to 1 using 0		- display 2	copy 0 to 3		P2		0,1
Decode P5 to 0 using 1		- display 3 copy 1 to 2		P3		1,0
Decode P6 to 1 using 0		- display 2	copy 0 to 3		P4		0,1
Decode P7 to 0 using 1		- display 3 copy 1 to 2		P5		1,0
Decode P8 to 1 using 0		- display 2	copy 0 to 3		P6		0,1
*/
