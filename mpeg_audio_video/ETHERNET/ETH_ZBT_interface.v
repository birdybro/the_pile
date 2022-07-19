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
module ETH_ZBT_interface (
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
	ZBT_ready_I,
	ETH_active_O,
	Address_O,
   Data_O,
   Write_en_O
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
input             clock;
input             ZBT_ready_I;
output reg			ETH_active_O;
output reg [23:0] Address_O;
output reg [31:0] Data_O;
output reg        Write_en_O;

wire              clock_25;
wire     [23:0]   address_25;
wire     [47:0]   ethernet_MAC_25;
wire              active_tx_25;
wire              active_rx_25;
wire              error_25;
wire              start_pause_25;
reg 		[15:0] 	req_ID_25;
wire     [15:0]   ethernet_type_25;
wire              ethernet_type_valid_25;
wire     [31:0]   ethernet_data_25;
wire              ethernet_write_enable_25;

//assign ethernet_MAC_25 = 48'h000102FA70AA;
assign ethernet_MAC_25 = 48'hFFFFFFFFFFFF;

ETH_controller Ethernet_unit (
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
   .clock_25(clock_25),
   .Address_O(address_25),
   .Active_tx_O(active_tx_25),
   .Active_rx_O(active_rx_25),
	.Error_O(error_25),
   .Start_send_I(1'b0),
   .Start_pause_I(start_pause_25),
   .Dest_MAC_I(ethernet_MAC_25),
   .Type_I(req_ID_25),
   .Range_begin_I(24'h000000),
   .Range_end_I(24'h000000),
   .TX_data_I(32'h00000000),
   .TX_read_ack_O(),
   .Src_MAC_O(),
   .Type_O(ethernet_type_25),
   .Type_valid_O(ethernet_type_valid_25),
   .Range_begin_O(),
   .Range_end_O(),
   .RX_data_O(ethernet_data_25),
   .RX_write_en_O(ethernet_write_enable_25)
);

reg ethernet_write_enable_54;
reg ethernet_write_enable_54_dly1;

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		ethernet_write_enable_54 <= 1'b0;
		ethernet_write_enable_54_dly1 <= 1'b0;
	end else begin
		ethernet_write_enable_54 <= ethernet_write_enable_25;
		ethernet_write_enable_54_dly1 <= ethernet_write_enable_54;
	end
end

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		Address_O <= 24'h000000;
		Data_O <= 32'h00000000;
		Write_en_O <= 1'b0;
	end else begin
		Write_en_O <= 1'b0;
		if (
			~ethernet_write_enable_54_dly1 & 
			ethernet_write_enable_54
		) begin
			Address_O <= address_25;
			Data_O <= ethernet_data_25;
			Write_en_O <= 1'b1;
		end
	end
end

reg ETH_active_25;
always @(posedge clock or negedge resetn) begin
	if (~resetn) ETH_active_O <= 1'b0;
	else ETH_active_O <= ETH_active_25;
end
	
wire new_packet_25;
reg prev_ethernet_type_valid_25;

assign new_packet_25 = ~prev_ethernet_type_valid_25 & ethernet_type_valid_25;
always @(posedge clock_25 or negedge resetn) begin
	if (~resetn) prev_ethernet_type_valid_25 <= 1'b0;
	else prev_ethernet_type_valid_25 <= ethernet_type_valid_25;
end

always @(posedge clock_25 or negedge resetn) begin
	if (~resetn) begin
		req_ID_25 <= 16'h0000;
		ETH_active_25 <= 1'b0;
	end else begin
		if (new_packet_25) ETH_active_25 <= 1'b1;
		if (
			(address_25[7:0] == 8'hFF) & 
			ethernet_write_enable_25
		) begin
			req_ID_25 <= ethernet_type_25;
			if (req_ID_25 != ethernet_type_25) ETH_active_25 <= 1'b0;
		end
	end
end

reg ZBT_ready_25;
always @(posedge clock_25 or negedge resetn) begin
	if (~resetn) ZBT_ready_25 <= 1'b0;
	else ZBT_ready_25 <= ZBT_ready_I;
end	

reg [3:0] state_25;
reg [25:0] delay_counter_25;

assign start_pause_25 = (state_25 == 4'h1);
always @(posedge clock_25 or negedge resetn) begin
	if (~resetn) begin
		state_25 <= 4'h0;
		delay_counter_25 <= 26'd0;
	end else begin
		case (state_25)
			4'h0 : if (
				~active_rx_25 & 
				~active_tx_25 & 
				~ETH_active_25 &
				ZBT_ready_25
			) state_25 <= 4'h1;
			4'h1 : if (active_tx_25) state_25 <= 4'h2;
			4'h2 : if (~active_tx_25) begin
				state_25 <= 4'h3;
				delay_counter_25 <= 26'd0;
			end
			4'h3 : begin
				delay_counter_25 <= delay_counter_25 + 1;
//				if ((delay_counter_25 == 26'd262144) | new_packet_25) state_25 <= 4'h0;
				if ((delay_counter_25 == 26'd131072) | new_packet_25) state_25 <= 4'h0;
			end
		endcase
		if (error_25) state_25 <= 4'h0;
	end
end

endmodule
