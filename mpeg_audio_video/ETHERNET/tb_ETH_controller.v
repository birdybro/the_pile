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
module ETH_controller(
   // Ethernet port
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

   // System control
   resetn,
   clock_25,
   Address_O,
   Active_tx_O,
   Active_rx_O,
	Error_O,
   
   // Transmit
   Start_send_I,
   Start_pause_I,
   Dest_MAC_I,
   Type_I,
   Range_begin_I,
   Range_end_I,
   TX_data_I,
   TX_read_ack_O,
   
   // Receive
   Src_MAC_O,
   Type_O,
   Type_valid_O,
   Range_begin_O,
   Range_end_O,
   RX_data_O,
   RX_write_en_O
);

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
output            clock_25;
output reg [23:0] Address_O;
output reg        Active_tx_O;
output reg        Active_rx_O;
output            Error_O;

input             Start_send_I;
input             Start_pause_I;
input    [47:0]   Dest_MAC_I;
input    [15:0]   Type_I;
input    [23:0]   Range_begin_I;
input    [23:0]   Range_end_I;
input    [31:0]   TX_data_I;
output            TX_read_ack_O;
   
output 	[47:0] 	Src_MAC_O;
output reg [15:0] Type_O;
output reg        Type_valid_O;
output   [23:0]   Range_begin_O;
output 	[23:0] 	Range_end_O;
output reg [31:0] RX_data_O;
output reg        RX_write_en_O;

reg Start_send_I_prev, transfer;
reg [31:0] temp_data; 
integer infile, counter, packet_counter;

reg clock_25;
initial begin clock_25 = 1'b0; end
always #20 clock_25 = ~clock_25;

always @(posedge clock_25 or negedge resetn) begin
	if (~resetn) begin
		$fclose(infile);
		infile = $fopen(`ZBT_input_file, "rb");
		Start_send_I_prev <= 1'b0;
		Address_O = 24'h000000;
		RX_write_en_O = 1'b0;
		RX_data_O = 32'h00000000;
		Active_tx_O = 1'b0;
		Active_rx_O = 1'b0;
		Type_valid_O = 1'b0;
		Type_O = 16'h0000;
	end else begin
		Start_send_I_prev <= Start_pause_I;
		if (~Start_send_I_prev & Start_pause_I) begin
			Type_O = Type_I;
			
			// the request frame
			for (counter = 0; counter < 128; counter = counter + 1) 
				@(posedge clock_25); // ifg
			Active_tx_O = 1'b1;
			for (counter = 0; counter < 16; counter = counter + 1) 
				@(posedge clock_25); // sync
			for (counter = 0; counter < 24; counter = counter + 1) 
				@(posedge clock_25); // dst/src
			for (counter = 0; counter < 104; counter = counter + 1) 
				@(posedge clock_25); // fill/CRC
			Active_tx_O = 1'b0;
			
			// acknowledgement delay
			for (counter = 0; counter < 512; counter = counter + 1)
				@(posedge clock_25);
			
			$write("Receiving Ethernet Burst : %x\n", Address_O);
			
			// burst
			for (packet_counter = 0; packet_counter < 1024; packet_counter = packet_counter + 1) begin
				for (counter = 0; counter < 128; counter = counter + 1) 
					@(posedge clock_25); // ifg
				Active_rx_O = 1'b1;
				for (counter = 0; counter < 16; counter = counter + 1) 
					@(posedge clock_25); // sync
				Type_valid_O = 1'b0;
				for (counter = 0; counter < 24; counter = counter + 1) 
					@(posedge clock_25); // dst/src
				for (counter = 0; counter < 24; counter = counter + 1) 
					@(posedge clock_25); // type
				if (packet_counter == 1023) Type_O = Type_O + 1;
				Type_valid_O = 1'b1;
				for (counter = 0; counter < 12; counter = counter + 1) 
					@(posedge clock_25); // range
				for (counter = 0; counter < 256; counter = counter + 1) begin
					@(posedge clock_25); @(posedge clock_25); @(posedge clock_25);
					temp_data[31:24] = $fgetc(infile); temp_data[23:16] = $fgetc(infile);
					temp_data[15:8] = $fgetc(infile); temp_data[7:0] = $fgetc(infile);
					RX_data_O = temp_data; RX_write_en_O = 1'b1;
					@(posedge clock_25); @(posedge clock_25); RX_write_en_O = 1'b0;
					@(posedge clock_25); @(posedge clock_25); @(posedge clock_25);
					Address_O = Address_O + 1;
				end
				for (counter = 0; counter < 8; counter = counter + 1) 
					@(posedge clock_25); // CRC
				Active_rx_O = 1'b0;
			end
		end
	end
end

assign Error_O = 1'b0;
assign TX_read_ack_O = 1'b0;
assign Src_MAC_O = 48'd0;
assign Range_begin_O = 24'd0;
assign Range_end_O = 24'd0;

endmodule
