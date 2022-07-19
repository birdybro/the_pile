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
module MPEG_Audio_Video (
	MEMORY_BANK0_CLK_P,		MEMORY_BANK1_CLK_P,		MEMORY_BANK2_CLK_P,		MEMORY_BANK3_CLK_P,   	MEMORY_BANK4_CLK_P,   
	MEMORY_BANK0_CLKEN_N,	MEMORY_BANK1_CLKEN_N,	MEMORY_BANK2_CLKEN_N,   MEMORY_BANK3_CLKEN_N,   MEMORY_BANK4_CLKEN_N, 
	MEMORY_BANK0_WEN_N,		MEMORY_BANK1_WEN_N,		MEMORY_BANK2_WEN_N,     MEMORY_BANK3_WEN_N,     MEMORY_BANK4_WEN_N,   
	MEMORY_BANK0_WENA_N,		MEMORY_BANK1_WENA_N,		MEMORY_BANK2_WENA_N,    MEMORY_BANK3_WENA_N,    MEMORY_BANK4_WENA_N,  
	MEMORY_BANK0_WENB_N,		MEMORY_BANK1_WENB_N,		MEMORY_BANK2_WENB_N,    MEMORY_BANK3_WENB_N,    MEMORY_BANK4_WENB_N,  
	MEMORY_BANK0_WENC_N,		MEMORY_BANK1_WENC_N,		MEMORY_BANK2_WENC_N,    MEMORY_BANK3_WENC_N,    MEMORY_BANK4_WENC_N,  
	MEMORY_BANK0_WEND_N,		MEMORY_BANK1_WEND_N,		MEMORY_BANK2_WEND_N,    MEMORY_BANK3_WEND_N,    MEMORY_BANK4_WEND_N,  
	MEMORY_BANK0_ADV_LD_N,	MEMORY_BANK1_ADV_LD_N,	MEMORY_BANK2_ADV_LD_N,  MEMORY_BANK3_ADV_LD_N,  MEMORY_BANK4_ADV_LD_N,
	MEMORY_BANK0_OEN_N,		MEMORY_BANK1_OEN_N,		MEMORY_BANK2_OEN_N,     MEMORY_BANK3_OEN_N,     MEMORY_BANK4_OEN_N,   
	MEMORY_BANK0_CEN_N,		MEMORY_BANK1_CEN_N,		MEMORY_BANK2_CEN_N,     MEMORY_BANK3_CEN_N,     MEMORY_BANK4_CEN_N,   
	MEMORY_BANK0_ADDR_P,		MEMORY_BANK1_ADDR_P,		MEMORY_BANK2_ADDR_P,    MEMORY_BANK3_ADDR_P,    MEMORY_BANK4_ADDR_P,  
	MEMORY_BANK0_DATA_A_P,	MEMORY_BANK1_DATA_A_P,	MEMORY_BANK2_DATA_A_P,  MEMORY_BANK3_DATA_A_P,  MEMORY_BANK4_DATA_A_P,
	MEMORY_BANK0_DATA_B_P,	MEMORY_BANK1_DATA_B_P,	MEMORY_BANK2_DATA_B_P,  MEMORY_BANK3_DATA_B_P,  MEMORY_BANK4_DATA_B_P,
	MEMORY_BANK0_DATA_C_P,	MEMORY_BANK1_DATA_C_P,	MEMORY_BANK2_DATA_C_P,  MEMORY_BANK3_DATA_C_P,  MEMORY_BANK4_DATA_C_P,
	MEMORY_BANK0_DATA_D_P,	MEMORY_BANK1_DATA_D_P,	MEMORY_BANK2_DATA_D_P,  MEMORY_BANK3_DATA_D_P,  MEMORY_BANK4_DATA_D_P,

	VGA_OUT_PIXEL_CLOCK_P,
	VGA_COMP_SYNCH_N,
	VGA_OUT_BLANK_N,
	VGA_HSYNCH_N,
	VGA_VSYNCH_N,
	VGA_OUT_RED_P,
	VGA_OUT_GREEN_P,
	VGA_OUT_BLUE_P,

	MASTER_CLOCK_P,
	ALTERNATE_CLOCK_P,
	MEM_CLK_FBIN_P,
	MEM_CLK_FBOUT_P,
	EXTEND_DCM_RESET_P,

   TX_DATA_P,
   TX_ENABLE_P,
   TX_CLOCK_P,
   TX_ERROR_P,
   ENET_SLEW_P,
   RX_DATA_P,
   RX_DATA_VALID_P,
   RX_ERROR_P,
   RX_CLOCK_P,
   COLLISION_DETECTED_P,
   CARRIER_SENSE_P,
   PAUSE_P,
   MDIO_P,
   MDC_P,
   MDINIT_N,
   SSN_DATA_P,

	AC97_BIT_CLOCK_I,
	AC97_SYNCH_O,
	AC97_DATA_IN_I,
	AC97_DATA_OUT_O,
	AC97_BEEP_TONE_O,
	STARTUP_O,

	PAL_NTSC_N,
	S_VIDEO_N,
	USER_INPUT0_P,
	USER_INPUT1_P,
	USER_LED0_N,
	USER_LED1_N
);

// INTERFACE TO ZBT RAM
output 			MEMORY_BANK0_CLK_P,		MEMORY_BANK1_CLK_P,		MEMORY_BANK2_CLK_P,		MEMORY_BANK3_CLK_P,		MEMORY_BANK4_CLK_P;		// ZBT RAM clock
output 			MEMORY_BANK0_CLKEN_N,	MEMORY_BANK1_CLKEN_N,	MEMORY_BANK2_CLKEN_N,	MEMORY_BANK3_CLKEN_N,	MEMORY_BANK4_CLKEN_N;	// ZBT RAM clock enable
output 			MEMORY_BANK0_WEN_N,		MEMORY_BANK1_WEN_N,		MEMORY_BANK2_WEN_N,		MEMORY_BANK3_WEN_N,		MEMORY_BANK4_WEN_N;		// ZBT RAM write enable
output 			MEMORY_BANK0_WENA_N,		MEMORY_BANK1_WENA_N,		MEMORY_BANK2_WENA_N,		MEMORY_BANK3_WENA_N,		MEMORY_BANK4_WENA_N;		// ZBT RAM byte A write enable
output 			MEMORY_BANK0_WENB_N,		MEMORY_BANK1_WENB_N,		MEMORY_BANK2_WENB_N,		MEMORY_BANK3_WENB_N,		MEMORY_BANK4_WENB_N;		// ZBT RAM byte B write enable
output 			MEMORY_BANK0_WENC_N,		MEMORY_BANK1_WENC_N,		MEMORY_BANK2_WENC_N,		MEMORY_BANK3_WENC_N,		MEMORY_BANK4_WENC_N;		// ZBT RAM byte C write enable
output 			MEMORY_BANK0_WEND_N,		MEMORY_BANK1_WEND_N,		MEMORY_BANK2_WEND_N,		MEMORY_BANK3_WEND_N,		MEMORY_BANK4_WEND_N;		// ZBT RAM byte D write enable
output 			MEMORY_BANK0_ADV_LD_N,	MEMORY_BANK1_ADV_LD_N,	MEMORY_BANK2_ADV_LD_N,	MEMORY_BANK3_ADV_LD_N,	MEMORY_BANK4_ADV_LD_N;	// ZBT RAM address load-advance
output 			MEMORY_BANK0_OEN_N,		MEMORY_BANK1_OEN_N,		MEMORY_BANK2_OEN_N,		MEMORY_BANK3_OEN_N,		MEMORY_BANK4_OEN_N;		// ZBT RAM output enable
output 			MEMORY_BANK0_CEN_N,		MEMORY_BANK1_CEN_N,		MEMORY_BANK2_CEN_N,		MEMORY_BANK3_CEN_N,		MEMORY_BANK4_CEN_N;		// ZBT RAM chip enable
output [18:0]	MEMORY_BANK0_ADDR_P,		MEMORY_BANK1_ADDR_P,		MEMORY_BANK2_ADDR_P,		MEMORY_BANK3_ADDR_P,		MEMORY_BANK4_ADDR_P;		// ZBT RAM address bus
inout  [7:0] 	MEMORY_BANK0_DATA_A_P,	MEMORY_BANK1_DATA_A_P,	MEMORY_BANK2_DATA_A_P,	MEMORY_BANK3_DATA_A_P,	MEMORY_BANK4_DATA_A_P;	// ZBT RAM data bus byte "A"
inout  [7:0] 	MEMORY_BANK0_DATA_B_P,	MEMORY_BANK1_DATA_B_P,	MEMORY_BANK2_DATA_B_P,	MEMORY_BANK3_DATA_B_P,	MEMORY_BANK4_DATA_B_P;	// ZBT RAM data bus byte "B"
inout  [7:0] 	MEMORY_BANK0_DATA_C_P,	MEMORY_BANK1_DATA_C_P,	MEMORY_BANK2_DATA_C_P,	MEMORY_BANK3_DATA_C_P,	MEMORY_BANK4_DATA_C_P;	// ZBT RAM data bus byte "C"
inout  [7:0] 	MEMORY_BANK0_DATA_D_P,	MEMORY_BANK1_DATA_D_P,	MEMORY_BANK2_DATA_D_P,	MEMORY_BANK3_DATA_D_P,	MEMORY_BANK4_DATA_D_P;	// ZBT RAM data bus byte "D"
	
// INTERFACE TO SVGA
output			VGA_OUT_PIXEL_CLOCK_P;
output			VGA_COMP_SYNCH_N;
output			VGA_OUT_BLANK_N;
output			VGA_HSYNCH_N;
output			VGA_VSYNCH_N;
output [7:0]	VGA_OUT_RED_P;
output [7:0]	VGA_OUT_GREEN_P;
output [7:0]	VGA_OUT_BLUE_P;

// INTERFACE TO CLOCKS
input				MASTER_CLOCK_P;			// 27 MHz on-board clock
input				ALTERNATE_CLOCK_P;		// 50 MHz on-board clock
input				MEM_CLK_FBIN_P;			// ZBT clock feedback loop
output			MEM_CLK_FBOUT_P;			// ZBT clock feedback loop
input				EXTEND_DCM_RESET_P;		// DCM reset signal

// INTERFACE TO ETHERNET
output [3:0]	TX_DATA_P;     			// Ethernet transmission data
output         TX_ENABLE_P;				// Ehternet transmission enable
input          TX_CLOCK_P;					// Ethernet transmission clock
input          TX_ERROR_P;					// Ethernet transmission error
output [1:0]   ENET_SLEW_P;				// Ethernet slew settings
input  [3:0]   RX_DATA_P;					// Ethernet receive data
input          RX_DATA_VALID_P;			// Ethernet data valid
input          RX_ERROR_P;					// Ethernet receive error
input          RX_CLOCK_P;					// Ethernet receive clock
input          COLLISION_DETECTED_P;	// Ethernet collision detected
input          CARRIER_SENSE_P;			// Ethernet carrier sense
output         PAUSE_P;             	// Ethernet pause
inout          MDIO_P;              	// Ethernet config data
output         MDC_P;               	// Ethernet config clock
input          MDINIT_N;            	// Ethernet config init
inout          SSN_DATA_P;          	// Silicon serial number access

// INTERFACE TO AC97
input 			AC97_BIT_CLOCK_I;			// AC97 clock
output 			AC97_SYNCH_O;				// AC97 synch output
input 			AC97_DATA_IN_I;			// AC97 data in
output 			AC97_DATA_OUT_O;			// AC97 data out
output 			AC97_BEEP_TONE_O;			// AC97 Beep setting
output 			STARTUP_O;

// INTERFACE TO USER
input				PAL_NTSC_N;	reg pal_sw_1;
input				S_VIDEO_N;	reg svid_sw_1;
input 			USER_INPUT0_P;
input 			USER_INPUT1_P;
output			USER_LED0_N;
output			USER_LED1_N;

// global and top level signals
wire 				resetn, fpga_reset;
wire 				internal_ZBT_clock;
wire 				external_ZBT_clock;
wire 				internal_video_clock;
wire 				external_video_clock;
wire 				audio_decoder_clock;

reg audio_header_found_reg;
assign resetn = USER_INPUT0_P & ~fpga_reset;
assign USER_LED0_N = ~USER_INPUT0_P;
assign USER_LED1_N = ~(USER_INPUT1_P & pal_sw_1 & audio_header_found_reg);

always @(posedge internal_ZBT_clock or negedge resetn) begin
	if (~resetn) begin
		pal_sw_1 <= 1'b0;
		svid_sw_1 <= 1'b0;
	end else begin
		pal_sw_1 <= PAL_NTSC_N;
		svid_sw_1 <= S_VIDEO_N;
	end 
end

// ZBT Interface signals
wire 		[18:0]	ZBT_address_0,		ZBT_address_1,		ZBT_address_2,		ZBT_address_3,    ZBT_address_4;   
wire 					ZBT_write_0,		ZBT_write_1,		ZBT_write_2,      ZBT_write_3,      ZBT_write_4;     
wire		[31:0]	ZBT_write_data_0,	ZBT_write_data_1,	ZBT_write_data_2, ZBT_write_data_3, ZBT_write_data_4;
wire		[31:0]	ZBT_read_data_0,	ZBT_read_data_1,	ZBT_read_data_2,  ZBT_read_data_3,  ZBT_read_data_4; 

CLOCKGEN clock_gen_1(
	MASTER_CLOCK_P,
	ALTERNATE_CLOCK_P,
	MEM_CLK_FBOUT_P,
	MEM_CLK_FBIN_P,
	EXTEND_DCM_RESET_P,
	audio_decoder_clock,
	internal_video_clock,
	external_video_clock,
	internal_ZBT_clock,
	external_ZBT_clock,
	fpga_reset
);

// instantiate Ethernet <-> ZBT interface
wire 				Decoder_ZBT_reset;
wire 				Decoder_ZBT_fill;
wire 				Decoder_Shift_1;
wire 				Decoder_Shift_8;
wire 				Decoder_Shift_Busy;
wire 				Decoder_Byte_Allign;
wire 	[31:0]	Decoder_Bitstream_Data;

wire 				Audio_Byte_Allign;
wire 	[15:0]	Audio_Bitstream_Data;
wire 				Audio_Shift_Busy;
wire 	[4:0]		Audio_Shift;

wire 	[31:0] 	ZBT_Video_Read_Data, ZBT_Audio_Read_Data;
wire 	[31:0] 	ZBT_Video_Write_Data, ZBT_Audio_Write_Data;
wire 	[18:0] 	ZBT_Video_Address, ZBT_Audio_Address;
wire 				ZBT_Video_Write_En, ZBT_Audio_Write_En;
wire 				ZBT_Video_Access, ZBT_Audio_Access;
wire 				Audio_Sync_AtoV, Audio_Sync_VtoA;

ETH_stream_interface Ethernet_unit (
   .TX_DATA_P(TX_DATA_P),
   .TX_ENABLE_P(TX_ENABLE_P),
   .TX_CLOCK_P(TX_CLOCK_P),
   .TX_ERROR_P(TX_ERROR_P),
   .ENET_SLEW_P(ENET_SLEW_P),
   .RX_DATA_P(RX_DATA_P),
   .RX_DATA_VALID_P(RX_DATA_VALID_P),
   .RX_ERROR_P(RX_ERROR_P),
   .RX_CLOCK_P(RX_CLOCK_P),
   .COLLISION_DETECTED_P(COLLISION_DETECTED_P),
   .CARRIER_SENSE_P(CARRIER_SENSE_P),
   .PAUSE_P(PAUSE_P),
   .MDIO_P(MDIO_P),
   .MDC_P(MDC_P),
   .MDINIT_N(MDINIT_N),
   .SSN_DATA_P(SSN_DATA_P),
   .resetn(resetn),
   .clock(internal_ZBT_clock),
	.audio_clock(audio_decoder_clock),
	.ZBT_Address_O(ZBT_address_0),
	.ZBT_Data_I(ZBT_read_data_0),
   .ZBT_Data_O(ZBT_write_data_0),
   .ZBT_Write_en_O(ZBT_write_0),
	.ZBT_Reset_I(1'b0),
	.ZBT_Initial_Fill_O(Decoder_ZBT_fill),
	.Audio_Bitstream_Access_I(ZBT_Audio_Access),
	.Audio_Bitstream_Address_O(ZBT_Audio_Address),
	.Audio_Bitstream_Write_Data_O(ZBT_Audio_Write_Data),
	.Audio_Bitstream_Write_En_O(ZBT_Audio_Write_En),
	.Audio_Bitstream_Read_Data_I(ZBT_Audio_Read_Data),
	.Video_Bitstream_Access_I(ZBT_Video_Access), 
	.Video_Bitstream_Address_O(ZBT_Video_Address),
	.Video_Bitstream_Write_Data_O(ZBT_Video_Write_Data),
	.Video_Bitstream_Write_En_O(ZBT_Video_Write_En),
	.Video_Bitstream_Read_Data_I(ZBT_Video_Read_Data),	
   .Video_Shift_1_En_I(Decoder_Shift_1),
   .Video_Shift_8_En_I(Decoder_Shift_8),
	.Video_Shift_Busy_O(Decoder_Shift_Busy),
	.Video_Byte_Allign_O(Decoder_Byte_Allign),
   .Video_Bitstream_Data_O(Decoder_Bitstream_Data),
   .Audio_Shift_En_I(Audio_Shift),
	.Audio_Shift_Busy_O(Audio_Shift_Busy),
	.Audio_Byte_Allign_O(Audio_Byte_Allign),
   .Audio_Bitstream_Data_O(Audio_Bitstream_Data)
,.debug({pal_sw_1,svid_sw_1})
);

reg 				Video_start;
reg 				Audio_start_ZBTclock;
reg	[27:0]	sequence_start_count;
wire	[7:0]		Decoder_write_data;
wire				Decoder_write_en;

wire 				Advance_Frame;
wire 	[1:0]		Picture_type;
wire 				Picture_start;
wire 				Address_reset;

wire audio_header_found;
always @(posedge internal_ZBT_clock or negedge resetn) begin
	if (~resetn) audio_header_found_reg <= 1'b1;
	else if (Audio_start_ZBTclock) audio_header_found_reg <= 1'b0;
	else if (audio_header_found) audio_header_found_reg <= 1'b1;
end

always @(posedge internal_ZBT_clock or negedge resetn) begin
	if (~resetn) begin
		sequence_start_count <= 28'h000000;
		Video_start <= 1'b0;
		Audio_start_ZBTclock <= 1'b0;
	end else begin
		if (
			Decoder_ZBT_fill & 
			(sequence_start_count != 28'h000FFFF)
		) sequence_start_count <= sequence_start_count + 1;
		if (sequence_start_count == 28'h000FFFC) Video_start <= 1'b1;
		if (sequence_start_count == 28'h000FFFF) Video_start <= 1'b0;
		if (sequence_start_count == 28'h0000FFC) Audio_start_ZBTclock <= 1'b1;
		if (sequence_start_count == 28'h0000FFF) Audio_start_ZBTclock <= 1'b0;
	end
end        

wire 	[11:0]	Backend_Image_Width;
wire 	[11:0]	Backend_Image_Height;

wire 	[18:0]	Forward_Framestore_Address, Backward_Framestore_Address;
wire 	[31:0]	Forward_Framestore_Data, Backward_Framestore_Data;
wire 				Forward_Framestore_Busy_1, Backward_Framestore_Busy_1;
wire 				Forward_Framestore_Busy_2, Backward_Framestore_Busy_2;

Sequence_Decode Sequence_Decoder(
   .resetn(resetn),
   .clock(internal_ZBT_clock),
   .Start_Sequence_Decode(Video_start),
	.Advance_Frame_I(Advance_Frame),
	.ZBT_Reset_O(),
   .Shift_1_En_O(Decoder_Shift_1),
   .Shift_8_En_O(Decoder_Shift_8),
	.Shift_Busy_I(Decoder_Shift_Busy),
	.Byte_Allign_I(Decoder_Byte_Allign),
   .Bitstream_Data_I(Decoder_Bitstream_Data),
	.Image_Horizontal_O(Backend_Image_Width),
	.Image_Vertical_O(Backend_Image_Height),
	.Picture_Type_O(Picture_type),
	.Picture_Start_O(Picture_start),
   .YUV_Data_O(Decoder_write_data),
   .YUV_Write_En_O(Decoder_write_en),
	.YUV_Start_O(Address_reset),
	.Framestore0_Address_O(Forward_Framestore_Address),
	.Framestore0_Data_I(Forward_Framestore_Data),
	.Framestore0_Busy_I(Forward_Framestore_Busy_1),
	.Framestore0_Busy_O(Forward_Framestore_Busy_2),
	.Framestore1_Address_O(Backward_Framestore_Address),
	.Framestore1_Data_I(Backward_Framestore_Data),
	.Framestore1_Busy_I(Backward_Framestore_Busy_1),  
	.Framestore1_Busy_O(Backward_Framestore_Busy_2)  
);

// instantiate the framestore manager
Framestore_Management Framestore_Manager(
	.resetn(resetn),
	.internal_ZBT_clock(internal_ZBT_clock),
	.internal_video_clock(internal_video_clock),
	.Picture_Start_I(Picture_start),
	.Picture_Done_I(1'b0),
	.Picture_Type_I(Picture_type),
	.Display_Advance_O(Advance_Frame),
	.Address_Reset_I(Address_reset),
	.Image_Horizontal_I(Backend_Image_Width),
	.Image_Vertical_I(Backend_Image_Height),
	.YUV_Write_En_I(Decoder_write_en),
	.YUV_Write_Data_I(Decoder_write_data),
	.Audio_Bitstream_Access_O(ZBT_Video_Access),
	.Audio_Bitstream_Address_I(ZBT_Video_Address),
	.Audio_Bitstream_Write_Data_I(ZBT_Video_Write_Data),
	.Audio_Bitstream_Write_En_I(ZBT_Video_Write_En),
	.Audio_Bitstream_Read_Data_O(ZBT_Video_Read_Data),
	.Video_Bitstream_Access_O(ZBT_Audio_Access), 
	.Video_Bitstream_Address_I(ZBT_Audio_Address),
	.Video_Bitstream_Write_Data_I(ZBT_Audio_Write_Data),
	.Video_Bitstream_Write_En_I(ZBT_Audio_Write_En),
	.Video_Bitstream_Read_Data_O(ZBT_Audio_Read_Data),
	.Framestore0_Address_I(Forward_Framestore_Address),
	.Framestore0_Data_O(Forward_Framestore_Data),
	.Framestore0_Busy_O(Forward_Framestore_Busy_1),
	.Framestore0_Busy_I(Forward_Framestore_Busy_2),
	.Framestore1_Address_I(Backward_Framestore_Address),
	.Framestore1_Data_O(Backward_Framestore_Data),
	.Framestore1_Busy_O(Backward_Framestore_Busy_1),
	.Framestore1_Busy_I(Backward_Framestore_Busy_2),
	.Bank_0_Address_O(ZBT_address_3),
	.Bank_1_Address_O(ZBT_address_4),
	.Bank_2_Address_O(ZBT_address_1),
	.Bank_3_Address_O(ZBT_address_2),
	.Bank_0_Write_Data_O(ZBT_write_data_3),
	.Bank_1_Write_Data_O(ZBT_write_data_4),
	.Bank_2_Write_Data_O(ZBT_write_data_1),
	.Bank_3_Write_Data_O(ZBT_write_data_2),
	.Bank_0_Write_En_O(ZBT_write_3),
	.Bank_1_Write_En_O(ZBT_write_4),
	.Bank_2_Write_En_O(ZBT_write_1),
	.Bank_3_Write_En_O(ZBT_write_2),
	.Bank_0_Read_Data_I(ZBT_read_data_3),
	.Bank_1_Read_Data_I(ZBT_read_data_4),
	.Bank_2_Read_Data_I(ZBT_read_data_1),
	.Bank_3_Read_Data_I(ZBT_read_data_2),
	.VGA_OUT_PIXEL_CLOCK_P(VGA_OUT_PIXEL_CLOCK_P),
	.VGA_COMP_SYNCH_N(VGA_COMP_SYNCH_N),
	.VGA_OUT_RED_P(VGA_OUT_RED_P), 
	.VGA_OUT_GREEN_P(VGA_OUT_GREEN_P), 
	.VGA_OUT_BLUE_P(VGA_OUT_BLUE_P),
	.VGA_HSYNCH_N(VGA_HSYNCH_N),
	.VGA_VSYNCH_N(VGA_VSYNCH_N),
	.VGA_OUT_BLANK_N(VGA_OUT_BLANK_N),
	.Audio_Sync_I(Audio_Sync_AtoV),
	.Audio_Sync_O(Audio_Sync_VtoA)
);

// instantiate MP2 audio decoder
reg				Audio_start;
wire 				AC97_source_select;
wire 	[1:0]		sample_frequency;

assign AC97_source_select = pal_sw_1;
assign sample_frequency = `FREQUENCY_48K;

always @(posedge audio_decoder_clock or negedge resetn) begin
	if (~resetn) Audio_start <= 1'b0;
	else Audio_start <= Audio_start_ZBTclock;
end

MP2_Decode_16 Audio_Decoder(
	.resetn(resetn),
	.audio_decoder_clock(audio_decoder_clock),
	.Decode_Start_I(Audio_start),
	.Decode_Done_O(),
	.Bitstream_Byte_Allign_I(Audio_Byte_Allign),
	.Bitstream_Data_I(Audio_Bitstream_Data),
	.Shift_Busy_I(1'b0),//Audio_Shift_Busy),
	.Shift_En_O(Audio_Shift),
	.AC97_RESETN_I(USER_INPUT1_P & resetn),
	.AC97_BIT_CLOCK_I(AC97_BIT_CLOCK_I),
	.SAMPLE_FREQUENCY_I(sample_frequency),
	.SOURCE_SELECT_I(AC97_source_select),
	.AC97_SYNCH_O(AC97_SYNCH_O),
	.AC97_DATA_IN_I(AC97_DATA_IN_I),
	.AC97_DATA_OUT_O(AC97_DATA_OUT_O),
	.AC97_BEEP_TONE_O(AC97_BEEP_TONE_O),
	.STARTUP_O(STARTUP_O),
.Header_found(audio_header_found),
	.Audio_Sync_I(Audio_Sync_VtoA),
	.Audio_Sync_O(Audio_Sync_AtoV)
);

// ZBT RAM connections
wire internal_ZBT_clock_bank0, internal_ZBT_clock_bank1, internal_ZBT_clock_bank2, internal_ZBT_clock_bank3, internal_ZBT_clock_bank4;	
wire external_ZBT_clock_bank0, external_ZBT_clock_bank1, external_ZBT_clock_bank2, external_ZBT_clock_bank3, external_ZBT_clock_bank4;	
wire 				data_direction_bank0,	data_direction_bank1,	data_direction_bank2,	data_direction_bank3,	data_direction_bank4;	// flag to indicate direction (read = 1, write = 0)
wire	[31:0]	read_data_bank0,			read_data_bank1,			read_data_bank2,			read_data_bank3,			read_data_bank4;			// data read FROM the memory
wire  [31:0]	write_data_bank0,			write_data_bank1,			write_data_bank2,			write_data_bank3,			write_data_bank4;			// data to be written TO the memory
wire  [18:0]	address_bank0,				address_bank1,				address_bank2,				address_bank3,				address_bank4;				// address to be read or written

assign internal_ZBT_clock_bank0 = internal_ZBT_clock;
assign external_ZBT_clock_bank0 = external_ZBT_clock;
assign data_direction_bank0 = ~ZBT_write_0;
assign ZBT_read_data_0 = read_data_bank0;
assign write_data_bank0 = ZBT_write_data_0;
assign address_bank0 = ZBT_address_0;

assign internal_ZBT_clock_bank1 = internal_video_clock;
assign external_ZBT_clock_bank1 = external_video_clock;
assign data_direction_bank1 = ~ZBT_write_1;
assign ZBT_read_data_1 = read_data_bank1;
assign write_data_bank1 = ZBT_write_data_1;
assign address_bank1 = ZBT_address_1;

assign internal_ZBT_clock_bank2 = internal_video_clock;
assign external_ZBT_clock_bank2 = external_video_clock;
assign data_direction_bank2 = ~ZBT_write_2;
assign ZBT_read_data_2 = read_data_bank2;
assign write_data_bank2 = ZBT_write_data_2;
assign address_bank2 = ZBT_address_2;

assign internal_ZBT_clock_bank3 = internal_ZBT_clock;
assign external_ZBT_clock_bank3 = external_ZBT_clock;
assign data_direction_bank3 = ~ZBT_write_3;
assign ZBT_read_data_3 = read_data_bank3;
assign write_data_bank3 = ZBT_write_data_3;
assign address_bank3 = ZBT_address_3;

assign internal_ZBT_clock_bank4 = internal_ZBT_clock;
assign external_ZBT_clock_bank4 = external_ZBT_clock;
assign data_direction_bank4 = ~ZBT_write_4;
assign ZBT_read_data_4 = read_data_bank4;
assign write_data_bank4 = ZBT_write_data_4;
assign address_bank4 = ZBT_address_4;

ZBT_connections ZBT_unit(
	MEMORY_BANK0_CLK_P,
	MEMORY_BANK0_CLKEN_N,
	MEMORY_BANK0_WEN_N,
	MEMORY_BANK0_WENA_N,
	MEMORY_BANK0_WENB_N,
	MEMORY_BANK0_WENC_N,
	MEMORY_BANK0_WEND_N,
	MEMORY_BANK0_ADV_LD_N,
	MEMORY_BANK0_OEN_N,
	MEMORY_BANK0_CEN_N,
	MEMORY_BANK0_ADDR_P,
	MEMORY_BANK0_DATA_A_P,
	MEMORY_BANK0_DATA_B_P,
	MEMORY_BANK0_DATA_C_P,
	MEMORY_BANK0_DATA_D_P,
	MEMORY_BANK1_CLK_P,
	MEMORY_BANK1_CLKEN_N,
	MEMORY_BANK1_WEN_N,
	MEMORY_BANK1_WENA_N,
	MEMORY_BANK1_WENB_N,
	MEMORY_BANK1_WENC_N,
	MEMORY_BANK1_WEND_N,
	MEMORY_BANK1_ADV_LD_N,
	MEMORY_BANK1_OEN_N,
	MEMORY_BANK1_CEN_N,
	MEMORY_BANK1_ADDR_P,
	MEMORY_BANK1_DATA_A_P,
	MEMORY_BANK1_DATA_B_P,
	MEMORY_BANK1_DATA_C_P,
	MEMORY_BANK1_DATA_D_P,
	MEMORY_BANK2_CLK_P,
	MEMORY_BANK2_CLKEN_N,
	MEMORY_BANK2_WEN_N,
	MEMORY_BANK2_WENA_N,
	MEMORY_BANK2_WENB_N,
	MEMORY_BANK2_WENC_N,
	MEMORY_BANK2_WEND_N,
	MEMORY_BANK2_ADV_LD_N,
	MEMORY_BANK2_OEN_N,
	MEMORY_BANK2_CEN_N,
	MEMORY_BANK2_ADDR_P,
	MEMORY_BANK2_DATA_A_P,
	MEMORY_BANK2_DATA_B_P,
	MEMORY_BANK2_DATA_C_P,
	MEMORY_BANK2_DATA_D_P,
	MEMORY_BANK3_CLK_P,
	MEMORY_BANK3_CLKEN_N,
	MEMORY_BANK3_WEN_N,
	MEMORY_BANK3_WENA_N,
	MEMORY_BANK3_WENB_N,
	MEMORY_BANK3_WENC_N,
	MEMORY_BANK3_WEND_N,
	MEMORY_BANK3_ADV_LD_N,
	MEMORY_BANK3_OEN_N,
	MEMORY_BANK3_CEN_N,
	MEMORY_BANK3_ADDR_P,
	MEMORY_BANK3_DATA_A_P,
	MEMORY_BANK3_DATA_B_P,
	MEMORY_BANK3_DATA_C_P,
	MEMORY_BANK3_DATA_D_P,
	MEMORY_BANK4_CLK_P,
	MEMORY_BANK4_CLKEN_N,
	MEMORY_BANK4_WEN_N,
	MEMORY_BANK4_WENA_N,
	MEMORY_BANK4_WENB_N,
	MEMORY_BANK4_WENC_N,
	MEMORY_BANK4_WEND_N,
	MEMORY_BANK4_ADV_LD_N,
	MEMORY_BANK4_OEN_N,
	MEMORY_BANK4_CEN_N,
	MEMORY_BANK4_ADDR_P,
	MEMORY_BANK4_DATA_A_P,
	MEMORY_BANK4_DATA_B_P,
	MEMORY_BANK4_DATA_C_P,
	MEMORY_BANK4_DATA_D_P,
	internal_ZBT_clock_bank0,
	external_ZBT_clock_bank0,
	read_data_bank0,
	write_data_bank0,
	address_bank0,
	data_direction_bank0,
	internal_ZBT_clock_bank1,
	external_ZBT_clock_bank1,
	read_data_bank1,
	write_data_bank1,
	address_bank1,
	data_direction_bank1,
	internal_ZBT_clock_bank2,
	external_ZBT_clock_bank2,
	read_data_bank2,
	write_data_bank2,
	address_bank2,
	data_direction_bank2,
	internal_ZBT_clock_bank3,
	external_ZBT_clock_bank3,
	read_data_bank3,
	write_data_bank3,
	address_bank3,
	data_direction_bank3,
	internal_ZBT_clock_bank4,
	external_ZBT_clock_bank4,
	read_data_bank4,
	write_data_bank4,
	address_bank4,
	data_direction_bank4
);

endmodule
