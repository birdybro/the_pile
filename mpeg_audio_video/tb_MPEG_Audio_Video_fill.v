`include "defines.v"
module tb_MPEG_Audio_Video();

// INTERFACE TO ZBT RAM
wire	 			MEMORY_BANK0_CLK_P,		MEMORY_BANK1_CLK_P,		MEMORY_BANK2_CLK_P,		MEMORY_BANK3_CLK_P,		MEMORY_BANK4_CLK_P;		// ZBT RAM clock
wire	 			MEMORY_BANK0_CLKEN_N,	MEMORY_BANK1_CLKEN_N,	MEMORY_BANK2_CLKEN_N,	MEMORY_BANK3_CLKEN_N,	MEMORY_BANK4_CLKEN_N;	// ZBT RAM clock enable
wire	 			MEMORY_BANK0_WEN_N,		MEMORY_BANK1_WEN_N,		MEMORY_BANK2_WEN_N,		MEMORY_BANK3_WEN_N,		MEMORY_BANK4_WEN_N;		// ZBT RAM write enable
wire	 			MEMORY_BANK0_WENA_N,		MEMORY_BANK1_WENA_N,		MEMORY_BANK2_WENA_N,		MEMORY_BANK3_WENA_N,		MEMORY_BANK4_WENA_N;		// ZBT RAM byte A write enable
wire	 			MEMORY_BANK0_WENB_N,		MEMORY_BANK1_WENB_N,		MEMORY_BANK2_WENB_N,		MEMORY_BANK3_WENB_N,		MEMORY_BANK4_WENB_N;		// ZBT RAM byte B write enable
wire	 			MEMORY_BANK0_WENC_N,		MEMORY_BANK1_WENC_N,		MEMORY_BANK2_WENC_N,		MEMORY_BANK3_WENC_N,		MEMORY_BANK4_WENC_N;		// ZBT RAM byte C write enable
wire	 			MEMORY_BANK0_WEND_N,		MEMORY_BANK1_WEND_N,		MEMORY_BANK2_WEND_N,		MEMORY_BANK3_WEND_N,		MEMORY_BANK4_WEND_N;		// ZBT RAM byte D write enable
wire	 			MEMORY_BANK0_ADV_LD_N,	MEMORY_BANK1_ADV_LD_N,	MEMORY_BANK2_ADV_LD_N,	MEMORY_BANK3_ADV_LD_N,	MEMORY_BANK4_ADV_LD_N;	// ZBT RAM address load-advance
wire	 			MEMORY_BANK0_OEN_N,		MEMORY_BANK1_OEN_N,		MEMORY_BANK2_OEN_N,		MEMORY_BANK3_OEN_N,		MEMORY_BANK4_OEN_N;		// ZBT RAM output enable
wire	 			MEMORY_BANK0_CEN_N,		MEMORY_BANK1_CEN_N,		MEMORY_BANK2_CEN_N,		MEMORY_BANK3_CEN_N,		MEMORY_BANK4_CEN_N;		// ZBT RAM chip enable
wire	 [18:0]	MEMORY_BANK0_ADDR_P,		MEMORY_BANK1_ADDR_P,		MEMORY_BANK2_ADDR_P,		MEMORY_BANK3_ADDR_P,		MEMORY_BANK4_ADDR_P;		// ZBT RAM address bus
wire   [7:0] 	MEMORY_BANK0_DATA_A_P,	MEMORY_BANK1_DATA_A_P,	MEMORY_BANK2_DATA_A_P,	MEMORY_BANK3_DATA_A_P,	MEMORY_BANK4_DATA_A_P;	// ZBT RAM data bus byte "A"
wire   [7:0] 	MEMORY_BANK0_DATA_B_P,	MEMORY_BANK1_DATA_B_P,	MEMORY_BANK2_DATA_B_P,	MEMORY_BANK3_DATA_B_P,	MEMORY_BANK4_DATA_B_P;	// ZBT RAM data bus byte "B"
wire   [7:0] 	MEMORY_BANK0_DATA_C_P,	MEMORY_BANK1_DATA_C_P,	MEMORY_BANK2_DATA_C_P,	MEMORY_BANK3_DATA_C_P,	MEMORY_BANK4_DATA_C_P;	// ZBT RAM data bus byte "C"
wire   [7:0] 	MEMORY_BANK0_DATA_D_P,	MEMORY_BANK1_DATA_D_P,	MEMORY_BANK2_DATA_D_P,	MEMORY_BANK3_DATA_D_P,	MEMORY_BANK4_DATA_D_P;	// ZBT RAM data bus byte "D"
	
// INTERFACE TO SVGA
wire 				VGA_OUT_PIXEL_CLOCK_P;
wire 				VGA_COMP_SYNCH_N;
wire 				VGA_OUT_BLANK_N;
wire 				VGA_HSYNCH_N;
wire 				VGA_VSYNCH_N;
wire 	[7:0]		VGA_OUT_RED_P;
wire 	[7:0]		VGA_OUT_GREEN_P;
wire 	[7:0]		VGA_OUT_BLUE_P;

// INTERFACE TO CLOCKS
wire 				MASTER_CLOCK_P;			// 27 MHz on-board clock
wire 				ALTERNATE_CLOCK_P;		// 50 MHz on-board clock
wire 				MEM_CLK_FBIN_P;			// ZBT clock feedback loop
wire 				MEM_CLK_FBOUT_P;			// ZBT clock feedback loop
wire 				EXTEND_DCM_RESET_P;		// DCM reset signal

// INTERFACE TO ETHERNET
wire 	[3:0]		TX_DATA_P;     			// Ethernet transmission data
wire 	     		TX_ENABLE_P;				// Ehternet transmission enable
wire 	     		TX_CLOCK_P;					// Ethernet transmission clock
wire 	     		TX_ERROR_P;					// Ethernet transmission error
wire 	[1:0]		ENET_SLEW_P;				// Ethernet slew settings
wire 	[3:0]		RX_DATA_P;					// Ethernet receive data
wire 	     		RX_DATA_VALID_P;			// Ethernet data valid
wire 	     		RX_ERROR_P;					// Ethernet receive error
wire 	     		RX_CLOCK_P;					// Ethernet receive clock
wire 	     		COLLISION_DETECTED_P;	// Ethernet collision detected
wire 	     		CARRIER_SENSE_P;			// Ethernet carrier sense
wire 	     		PAUSE_P;             	// Ethernet pause
wire 	     		MDIO_P;              	// Ethernet config data
wire 	     		MDC_P;               	// Ethernet config clock
wire 	     		MDINIT_N;            	// Ethernet config init
wire 	     		SSN_DATA_P;          	// Silicon serial number access

// INTERFACE TO AC97
reg 				AC97_BIT_CLOCK_I;			// AC97 clock
wire 				AC97_SYNCH_O;				// AC97 synch output
wire 				AC97_DATA_IN_I;			// AC97 data in
wire 				AC97_DATA_OUT_O;			// AC97 data out
wire 				AC97_BEEP_TONE_O;			// AC97 Beep setting
wire 				STARTUP_O;

// INTERFACE TO USER
wire 				PAL_NTSC_N;
wire 				S_VIDEO_N;
wire 				USER_INPUT0_P;
wire 				USER_INPUT1_P;
wire 				USER_LED0_N;
wire 				USER_LED1_N;

assign PAL_NTSC_N = 1'b1;
assign S_VIDEO_N = 1'b1;
assign USER_INPUT1_P = 1'b1;
assign USER_INPUT0_P = 1'b1;

initial begin AC97_BIT_CLOCK_I = 1'b0; end
always begin #41.67 AC97_BIT_CLOCK_I = ~AC97_BIT_CLOCK_I; end

/*
// Audio messages
always @(posedge MPEG_decoder.Audio_Decoder.Header_done) begin
	if (MPEG_decoder.resetn) $write("Audio Header Decoded, sample freq %d, format_check %b, Table %d\n", 
		MPEG_decoder.Audio_Decoder.Decode_Header_unit.Sample_Freq_O,
		MPEG_decoder.Audio_Decoder.Decode_Header_unit.Format_Check_O,
		MPEG_decoder.Audio_Decoder.Decode_Header_unit.Table_O);
end

// Video messages
integer picture_counter; initial begin picture_counter = 0; end
always @(MPEG_decoder.Sequence_Decoder.Picture_Decoder.frame_counter)
	$write("-------------------- Frame Counter %d --------------------\n", 
		MPEG_decoder.Sequence_Decoder.Picture_Decoder.frame_counter);

reg prev_shift; reg mismatch_counter;
always @(posedge MPEG_decoder.internal_ZBT_clock) begin
	prev_shift <= MPEG_decoder.Decoder_Shift_1 | MPEG_decoder.Decoder_Shift_8;
	if (prev_shift & (MPEG_decoder.Decoder_Bitstream_Data[31:8] == 24'h000001)) begin
		if ((MPEG_decoder.Decoder_Bitstream_Data[7:0] >= 8'h01) & (MPEG_decoder.Decoder_Bitstream_Data[7:0] <= 8'hAF)) begin
			$write("      Slice Start Code %x detected at time %t - %d mismatches\n", 
				MPEG_decoder.Decoder_Bitstream_Data[7:0], $realtime, mismatch_counter);
		end else if ((MPEG_decoder.Decoder_Bitstream_Data[7:0] >= 8'hB9) & (MPEG_decoder.Decoder_Bitstream_Data[7:0] <= 8'hFF))
			$write("System Start Code %x detected at time %t\n", 
				MPEG_decoder.Decoder_Bitstream_Data[7:0], $realtime);
		else case(MPEG_decoder.Decoder_Bitstream_Data[7:0])

			8'h00 : begin
				$write("      Picture Start Code %d detected at time %t\n", picture_counter, $realtime);
				picture_counter = picture_counter + 1;
			end				
			8'hB2 : $write("   User Data Start Code detected at time %t\n", $realtime);
			8'hB3 : $write("Sequence Header Code detected at time %t\n", $realtime);
			8'hB4 : $write("Sequence Error Code detected at time %t\n", $realtime);
			8'hB5 : $write("   Extension Start Code detected at time %t\n", $realtime);
			8'hB7 : $write("Sequence End Code detected at time %t\n", $realtime);
			8'hB8 : $write("   Group Start Code detected at time %t\n", $realtime);

			8'hB9 : $write("ISO End Code detected at time %t\n", $realtime);
			8'hBA : $write("Pack Start Code detected at time %t\n", $realtime);
			8'hBB : $write("System Start Code detected at time %t\n", $realtime);
			8'hE0 : $write("Video Elementary Stream Code detected at time %t\n", $realtime);
			8'hC0 : $write("Audio Elementary Stream Code detected at time %t\n", $realtime);

			default : $write("Unrecognized Start Code %x detected at time %t\n", MPEG_decoder.Decoder_Bitstream_Data[7:0], $realtime);
		endcase
	end
end
*/

MPEG_Audio_Video MPEG_decoder(
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

ZBT_bank ZBT_BANK_0(
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
	MEMORY_BANK0_DATA_D_P
);

ZBT_bank ZBT_BANK_1(
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
	MEMORY_BANK1_DATA_D_P
);

ZBT_bank ZBT_BANK_2(
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
	MEMORY_BANK2_DATA_D_P
);

ZBT_bank ZBT_BANK_3(
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
	MEMORY_BANK3_DATA_D_P
);

ZBT_bank ZBT_BANK_4(
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
	MEMORY_BANK4_DATA_D_P
);

endmodule

module ZBT_bank(
	MEMORY_BANK_CLK_P,
	MEMORY_BANK_CLKEN_N,
	MEMORY_BANK_WEN_N,
	MEMORY_BANK_WENA_N,
	MEMORY_BANK_WENB_N,
	MEMORY_BANK_WENC_N,
	MEMORY_BANK_WEND_N,
	MEMORY_BANK_ADV_LD_N,
	MEMORY_BANK_OEN_N,
	MEMORY_BANK_CEN_N,
	MEMORY_BANK_ADDR_P,
	MEMORY_BANK_DATA_A_P,
	MEMORY_BANK_DATA_B_P,
	MEMORY_BANK_DATA_C_P,
	MEMORY_BANK_DATA_D_P
);

output 			MEMORY_BANK_CLK_P;
output 			MEMORY_BANK_CLKEN_N;
output 			MEMORY_BANK_WEN_N;
output 			MEMORY_BANK_WENA_N;
output 			MEMORY_BANK_WENB_N;
output 			MEMORY_BANK_WENC_N;
output 			MEMORY_BANK_WEND_N;
output 			MEMORY_BANK_ADV_LD_N;
output 			MEMORY_BANK_OEN_N;
output 			MEMORY_BANK_CEN_N;
output [18:0]	MEMORY_BANK_ADDR_P;
inout  [7:0] 	MEMORY_BANK_DATA_A_P;
inout  [7:0] 	MEMORY_BANK_DATA_B_P;
inout  [7:0] 	MEMORY_BANK_DATA_C_P;
inout  [7:0] 	MEMORY_BANK_DATA_D_P;

reg wen, wena, wenb, wenc, wend;
reg wen_1, wena_1, wenb_1, wenc_1, wend_1;
reg [7:0] reg_file_A [0:524287];
reg [7:0] reg_file_B [0:524287];
reg [7:0] reg_file_C [0:524287];
reg [7:0] reg_file_D [0:524287];

wire [31:0] Data_out, Data_in;
reg [18:0] Address, Address_1;

always @(posedge MEMORY_BANK_CLK_P) begin
	if (~MEMORY_BANK_CLKEN_N) begin
		Address_1 <= MEMORY_BANK_ADDR_P;
		Address <= Address_1;
		wen_1 <= ~MEMORY_BANK_WEN_N;
		wena_1 <= ~MEMORY_BANK_WENA_N;
		wenb_1 <= ~MEMORY_BANK_WENB_N;
		wenc_1 <= ~MEMORY_BANK_WENC_N;
		wend_1 <= ~MEMORY_BANK_WEND_N;
		wen <= wen_1; 
		wena <= wena_1;
		wenb <= wenb_1;
		wenc <= wenc_1;
		wend <= wend_1;
		if (wen) begin
			if (wena) reg_file_A[Address] <= Data_in[7:0];
			if (wenb) reg_file_B[Address] <= Data_in[15:8];
			if (wenc) reg_file_C[Address] <= Data_in[23:16];
			if (wend) reg_file_D[Address] <= Data_in[31:24];
		end 
	end
end

assign Data_out = {
	reg_file_D[Address], reg_file_C[Address], 
	reg_file_B[Address], reg_file_A[Address]};		

IOBUF_F_12 IO_data_buf00 ( .O(Data_in[00]), .IO(MEMORY_BANK_DATA_A_P[0]), .I(Data_out[00]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf01 ( .O(Data_in[01]), .IO(MEMORY_BANK_DATA_A_P[1]), .I(Data_out[01]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf02 ( .O(Data_in[02]), .IO(MEMORY_BANK_DATA_A_P[2]), .I(Data_out[02]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf03 ( .O(Data_in[03]), .IO(MEMORY_BANK_DATA_A_P[3]), .I(Data_out[03]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf04 ( .O(Data_in[04]), .IO(MEMORY_BANK_DATA_A_P[4]), .I(Data_out[04]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf05 ( .O(Data_in[05]), .IO(MEMORY_BANK_DATA_A_P[5]), .I(Data_out[05]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf06 ( .O(Data_in[06]), .IO(MEMORY_BANK_DATA_A_P[6]), .I(Data_out[06]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf07 ( .O(Data_in[07]), .IO(MEMORY_BANK_DATA_A_P[7]), .I(Data_out[07]), .T(MEMORY_BANK_OEN_N));
                                                                                        
IOBUF_F_12 IO_data_buf08 ( .O(Data_in[08]), .IO(MEMORY_BANK_DATA_B_P[0]), .I(Data_out[08]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf09 ( .O(Data_in[09]), .IO(MEMORY_BANK_DATA_B_P[1]), .I(Data_out[09]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf10 ( .O(Data_in[10]), .IO(MEMORY_BANK_DATA_B_P[2]), .I(Data_out[10]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf11 ( .O(Data_in[11]), .IO(MEMORY_BANK_DATA_B_P[3]), .I(Data_out[11]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf12 ( .O(Data_in[12]), .IO(MEMORY_BANK_DATA_B_P[4]), .I(Data_out[12]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf13 ( .O(Data_in[13]), .IO(MEMORY_BANK_DATA_B_P[5]), .I(Data_out[13]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf14 ( .O(Data_in[14]), .IO(MEMORY_BANK_DATA_B_P[6]), .I(Data_out[14]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf15 ( .O(Data_in[15]), .IO(MEMORY_BANK_DATA_B_P[7]), .I(Data_out[15]), .T(MEMORY_BANK_OEN_N));
                                                                                        
IOBUF_F_12 IO_data_buf16 ( .O(Data_in[16]), .IO(MEMORY_BANK_DATA_C_P[0]), .I(Data_out[16]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf17 ( .O(Data_in[17]), .IO(MEMORY_BANK_DATA_C_P[1]), .I(Data_out[17]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf18 ( .O(Data_in[18]), .IO(MEMORY_BANK_DATA_C_P[2]), .I(Data_out[18]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf19 ( .O(Data_in[19]), .IO(MEMORY_BANK_DATA_C_P[3]), .I(Data_out[19]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf20 ( .O(Data_in[20]), .IO(MEMORY_BANK_DATA_C_P[4]), .I(Data_out[20]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf21 ( .O(Data_in[21]), .IO(MEMORY_BANK_DATA_C_P[5]), .I(Data_out[21]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf22 ( .O(Data_in[22]), .IO(MEMORY_BANK_DATA_C_P[6]), .I(Data_out[22]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf23 ( .O(Data_in[23]), .IO(MEMORY_BANK_DATA_C_P[7]), .I(Data_out[23]), .T(MEMORY_BANK_OEN_N));
                                                                                        
IOBUF_F_12 IO_data_buf24 ( .O(Data_in[24]), .IO(MEMORY_BANK_DATA_D_P[0]), .I(Data_out[24]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf25 ( .O(Data_in[25]), .IO(MEMORY_BANK_DATA_D_P[1]), .I(Data_out[25]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf26 ( .O(Data_in[26]), .IO(MEMORY_BANK_DATA_D_P[2]), .I(Data_out[26]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf27 ( .O(Data_in[27]), .IO(MEMORY_BANK_DATA_D_P[3]), .I(Data_out[27]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf28 ( .O(Data_in[28]), .IO(MEMORY_BANK_DATA_D_P[4]), .I(Data_out[28]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf29 ( .O(Data_in[29]), .IO(MEMORY_BANK_DATA_D_P[5]), .I(Data_out[29]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf30 ( .O(Data_in[30]), .IO(MEMORY_BANK_DATA_D_P[6]), .I(Data_out[30]), .T(MEMORY_BANK_OEN_N));
IOBUF_F_12 IO_data_buf31 ( .O(Data_in[31]), .IO(MEMORY_BANK_DATA_D_P[7]), .I(Data_out[31]), .T(MEMORY_BANK_OEN_N));

endmodule
