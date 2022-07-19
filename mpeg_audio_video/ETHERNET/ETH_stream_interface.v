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
//`define SIMULATION
module ETH_stream_interface (
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

   resetn,
   clock,
	audio_clock,
	
	ZBT_Address_O,
	ZBT_Data_I,
   ZBT_Data_O,
   ZBT_Write_en_O,
	ZBT_Reset_I,
	ZBT_Initial_Fill_O,
	
	Audio_Bitstream_Access_I,
	Audio_Bitstream_Address_O,
	Audio_Bitstream_Write_Data_O,
	Audio_Bitstream_Write_En_O,
	Audio_Bitstream_Read_Data_I,

	Video_Bitstream_Access_I, 
	Video_Bitstream_Address_O,
	Video_Bitstream_Write_Data_O,
	Video_Bitstream_Write_En_O,
	Video_Bitstream_Read_Data_I,

   Video_Shift_1_En_I,
   Video_Shift_8_En_I,
	Video_Shift_Busy_O,
	Video_Byte_Allign_O,
   Video_Bitstream_Data_O,

   Audio_Shift_En_I,
	Audio_Shift_Busy_O,
	Audio_Byte_Allign_O,
   Audio_Bitstream_Data_O
,debug
);
input [1:0] debug;

output   [3:0]    TX_DATA_P;           // Ethernet transmission data
output            TX_ENABLE_P;			// Ethernet transmission enable
input             TX_CLOCK_P;				// Ethernet transmission clock
input             TX_ERROR_P;				// Ethernet transmission error
output   [1:0]    ENET_SLEW_P;			// Ethernet slew settings
input    [3:0]    RX_DATA_P;				// Ethernet receive data
input             RX_DATA_VALID_P;		// Ethernet data valid
input             RX_ERROR_P;				// Ethernet receive error
input             RX_CLOCK_P;				// Ethernet receive clock
input             COLLISION_DETECTED_P;	// Ethernet collision detected
input             CARRIER_SENSE_P;		// Ethernet carrier sense
output            PAUSE_P;             // Ethernet pause
inout             MDIO_P;              // Ethernet config data
output            MDC_P;               // Ethernet config clock
input             MDINIT_N;            // Ethernet config init
inout             SSN_DATA_P;          // Silicon serial number access

input             resetn;
input             clock;
input 				audio_clock;

output 	[18:0]	ZBT_Address_O;
input 	[31:0]	ZBT_Data_I;
output	[31:0]   ZBT_Data_O;
output				ZBT_Write_en_O;
input 				ZBT_Reset_I;
output reg			ZBT_Initial_Fill_O;

input 				Audio_Bitstream_Access_I;
output  	[18:0]	Audio_Bitstream_Address_O;
output 	[31:0]	Audio_Bitstream_Write_Data_O;
output  				Audio_Bitstream_Write_En_O;
input 	[31:0]	Audio_Bitstream_Read_Data_I;

input 				Video_Bitstream_Access_I;
output  	[18:0]	Video_Bitstream_Address_O;
output 	[31:0]	Video_Bitstream_Write_Data_O;
output  				Video_Bitstream_Write_En_O;
input 	[31:0]	Video_Bitstream_Read_Data_I;

input 				Video_Shift_1_En_I;
input 				Video_Shift_8_En_I;
output				Video_Shift_Busy_O;
output				Video_Byte_Allign_O;
output	[31:0]	Video_Bitstream_Data_O;

input 	[4:0]		Audio_Shift_En_I;
output 				Audio_Shift_Busy_O;
output 				Audio_Byte_Allign_O;
output 	[15:0]	Audio_Bitstream_Data_O;

wire [23:0] ETH_ZBT_address;
wire [18:0] BUF_ZBT_address;
assign ZBT_Address_O = (ZBT_Write_en_O) ? 
`ifdef SIMULATION
	{ETH_ZBT_address[14:0],4'hF} : {BUF_ZBT_address[14:0],4'hF};
`else
	ETH_ZBT_address[18:0] : BUF_ZBT_address[18:0];
`endif 

reg [1:0] initial_fill_reg;
wire initial_fill_flag, partial_fill_flag;
assign initial_fill_flag = &initial_fill_reg;
assign partial_fill_flag = initial_fill_reg[0];
always @(posedge clock or negedge resetn) begin
	if (~resetn) initial_fill_reg <= 2'b00;
	else if (
		ZBT_Write_en_O & 
		(ZBT_Address_O[17:0] == 18'h3FFFF)
	) initial_fill_reg <= {initial_fill_reg[0],1'b1};
end	

wire same_segment;
`ifdef SIMULATION
	assign same_segment = (BUF_ZBT_address[14] == ETH_ZBT_address[14]);
`else
	assign same_segment = (BUF_ZBT_address[18] == ETH_ZBT_address[18]);
`endif

reg same_segment_dly1;
always @(posedge clock or negedge resetn) begin
	if (~resetn) same_segment_dly1 <= 1'b0;
	else same_segment_dly1 <= same_segment;
end

reg [19:0] init_counter;
wire init_ready;
`ifdef SIMULATION
	assign init_ready = (init_counter == 20'h0000F);
`else
	assign init_ready = (init_counter == 20'hFFFFF);
`endif
always @(posedge clock or negedge resetn) begin
	if (~resetn) init_counter <= 20'h00000;
	else if (~init_ready) init_counter <= init_counter + 1;
end

wire request_burst;
assign request_burst = init_ready & same_segment & ~same_segment_dly1;

reg ZBT_ready;
wire ETH_active;

always @(posedge clock or negedge resetn) begin
	if (~resetn) ZBT_ready <= 1'b0;
	else if (ETH_active) ZBT_ready <= 1'b0;
	else if (request_burst | (init_ready & ~initial_fill_flag)) ZBT_ready <= 1'b1;
end

ETH_ZBT_interface Ethernet_unit (
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
   .clock(clock),
	.ZBT_ready_I(ZBT_ready),
	.ETH_active_O(ETH_active),
	.Address_O(ETH_ZBT_address),
   .Data_O(ZBT_Data_O),
   .Write_en_O(ZBT_Write_en_O)
);

wire ZBT_busy;
wire System_shift;
wire System_empty;
wire [31:0] System_data;

assign ZBT_busy = ZBT_Write_en_O | ~partial_fill_flag;// | same_segment;
//assign ZBT_busy = ZBT_Write_en_O | ~initial_fill_flag;// | same_segment;

ZBT_Bitstream ZBT_buffer_interface(
	.resetn(resetn),
	.clock(clock),
	.ZBT_Reset_Address_I(ZBT_Reset_I),
	.ZBT_Busy_I(ZBT_busy),
	.ZBT_Address_O(BUF_ZBT_address),
	.ZBT_Data_I(ZBT_Data_I),
	.Shift_8_En_I(System_shift),
	.Buffer_Empty_O(System_empty),
	.Bitstream_Data_O(System_data)
);

wire buffer_full;
always @(posedge clock or negedge resetn) begin
	if (~resetn) ZBT_Initial_Fill_O <= 1'b0;
//	else if (initial_fill_flag)
	else if (buffer_full)
		ZBT_Initial_Fill_O <= 1'b1;
end

System_Parser System_Parser_unit(
	.resetn(resetn),
	.clock(clock),
	.audio_clock(audio_clock),
	.Shift_8_En_O(System_shift),
	.System_Buffer_Empty_I(System_empty),
	.Bitstream_Data_I(System_data),
	.Audio_Bitstream_Access_I(Audio_Bitstream_Access_I),
	.Audio_Bitstream_Address_O(Audio_Bitstream_Address_O),
	.Audio_Bitstream_Write_Data_O(Audio_Bitstream_Write_Data_O),
	.Audio_Bitstream_Write_En_O(Audio_Bitstream_Write_En_O),
	.Audio_Bitstream_Read_Data_I(Audio_Bitstream_Read_Data_I),
	.Video_Bitstream_Access_I(Video_Bitstream_Access_I), 
	.Video_Bitstream_Address_O(Video_Bitstream_Address_O),
	.Video_Bitstream_Write_Data_O(Video_Bitstream_Write_Data_O),
	.Video_Bitstream_Write_En_O(Video_Bitstream_Write_En_O),
	.Video_Bitstream_Read_Data_I(Video_Bitstream_Read_Data_I),
	.Video_Empty_O(Video_Shift_Busy_O),
	.Video_Shift_1_En_I(Video_Shift_1_En_I),
	.Video_Shift_8_En_I(Video_Shift_8_En_I),
	.Video_Byte_Allign_O(Video_Byte_Allign_O),
	.Video_Data_O(Video_Bitstream_Data_O),
	.Audio_Shift_En_I(Audio_Shift_En_I),
	.Audio_Shift_Busy_O(Audio_Shift_Busy_O),
	.Audio_Byte_Allign_O(Audio_Byte_Allign_O),
	.Audio_Data_O(Audio_Bitstream_Data_O),
	.Reset_Address_I(ZBT_Reset_I)
,.Buffer_Full_O(buffer_full)
,.debug(debug)
);

endmodule
