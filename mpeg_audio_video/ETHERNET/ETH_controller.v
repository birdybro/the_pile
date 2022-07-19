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
   
output reg [47:0] Src_MAC_O;
output reg [15:0] Type_O;
output reg        Type_valid_O;
output   [23:0]   Range_begin_O;
output reg [23:0] Range_end_O;
output reg [31:0] RX_data_O;
output reg        RX_write_en_O;

wire     [3:0]    tx_data;
wire              tx_enable;
wire              tx_clock;
wire              tx_error;
wire     [1:0]    enet_slew;
wire     [3:0]    rx_data;
wire              rx_data_valid;
wire              rx_error;
wire              rx_clock;
wire              collision_detected;
wire              carrier_sense;
wire              pause;
wire              mdi, mdo, mdio_dir;
wire              mdc;
wire              mdinit;
wire              ssn_in, ssn_out, ssn_dir;

reg 					tx_clock_select;
reg      [3:0]    state;
reg      [3:0]    state_counter;
reg 		[2:0]		pause_counter;
reg      [1:0]    mode;

wire              broadcast_enable;
assign broadcast_enable = 1'b0;

wire     [47:0]   MAC_ADDRESS;
assign MAC_ADDRESS = `ETH_MAC_ADDRESS;

reg      [31:0]   buffer;
wire     [31:0]   buffer_next;

always @(posedge clock_25 or negedge resetn) begin
	if (~resetn) tx_clock_select <= 1'b0;
	else if (state == `ETH_IDLE) tx_clock_select <= 1'b0;
	else if (state == `ETH_CLK_DLY) tx_clock_select <= 1'b1;
end

assign tx_data = buffer[27:24];
assign tx_enable = (
	((mode == `ETH_SEND) | (mode == `ETH_PAUSE)) & 
	((state != `ETH_CLK_DLY) & (state != `ETH_IDLE)));

assign buffer_next = {  
	buffer[19:16],
	buffer[31:28],
	buffer[11:8],
	buffer[23:20],
	buffer[3:0],
	buffer[15:12],
	(mode != `ETH_PAUSE) ? rx_data : 4'h0,
	buffer[7:4] };

wire 		[23:0] 	next_Address_O;
assign next_Address_O = Address_O + 1;

always @(posedge clock_25 or negedge resetn) begin
	if (~resetn) Address_O <= 24'h000000;
	else if (			
		(state == `ETH_RANGE_END) & 
		(mode == `ETH_RECV) & 
		(state_counter == 4'h0)
	) Address_O <= buffer[23:0];
	else if (		
		(state == `ETH_DATA) & 
		(mode == `ETH_RECV) & 
		(state_counter == 4'h7)
	) Address_O <= next_Address_O;
end

always @(posedge clock_25 or negedge resetn) begin
	if (~resetn) begin
		RX_data_O <= 32'h00000000;
		RX_write_en_O <= 1'b0;
	end else if (
		(state == `ETH_DATA) & 
		(mode == `ETH_RECV) & 
		(state_counter[2:0] == 3'h7)
	) begin
		RX_data_O <= buffer_next;
		RX_write_en_O <= 1'b1;
	end else RX_write_en_O <= 1'b0;
end
	
always @(posedge clock_25 or negedge resetn) begin
	if (~resetn) Src_MAC_O <= 48'h000000000000;
	else if (
		(state == `ETH_DEST) & 
		(mode == `ETH_RECV)
	) Src_MAC_O <= 48'h000000000000;
	else if (
		(state == `ETH_SRC) & 
		(mode == `ETH_RECV) &
		(state_counter == 4'h8)
	) Src_MAC_O[47:16] <= buffer;
	else if (
		(state == `ETH_TYPE) & 
		(mode == `ETH_RECV) &
		(state_counter == 4'h0)
	) Src_MAC_O[15:0] <= buffer[15:0];
end

always @(posedge clock_25 or negedge resetn) begin
	if (~resetn) begin
		Type_O <= 16'h0000;
		Type_valid_O <= 1'b0;
	end else begin
		if (
			(state == `ETH_DEST) & 
			(mode == `ETH_RECV)
		) begin
			Type_O <= 16'h0000;
			Type_valid_O <= 1'b0;
		end else if (
			(state == `ETH_RANGE_BEGIN) & 
			(mode == `ETH_RECV) & 
			(state_counter == 4'h0)
		) begin
			Type_O <= buffer[15:0];
			Type_valid_O <= 1'b1;
		end
	end
end

always @(posedge clock_25 or negedge resetn) begin
	if (~resetn) Range_end_O <= 24'h000000;
	else if (
		(state == `ETH_RANGE_END) & 
		(mode == `ETH_RECV) & 
		(state_counter == 4'h5)
	) Range_end_O <= buffer_next;
end

always @(posedge clock_25 or negedge resetn) begin
	if (~resetn) begin
		Active_tx_O <= 1'b0;
		Active_rx_O <= 1'b0;
	end else begin
		if (state == `ETH_DEST) begin
			if (mode == `ETH_RECV) 
				Active_rx_O <= 1'b1;
			else Active_rx_O <= 1'b0;
			if ((mode == `ETH_SEND) | (mode == `ETH_PAUSE)) 
				Active_tx_O <= 1'b1;
			else Active_tx_O <= 1'b0;
		end else if (state == `ETH_IDLE) begin
			Active_rx_O <= 1'b0;
			Active_tx_O <= 1'b0;
		end
	end
end

reg 		[31:0]   CRC_reg;
wire     [31:0]   CRC_next;
wire 		[31:0] 	CRC_extend;
wire     [3:0]    CRC_data;
reg 					CRC_error;

assign CRC_data = (state == `ETH_CRC) ? 4'h0 : 
	((state == `ETH_DEST) & ~state_counter[3]) ? 
		((mode == `ETH_RECV) ? ~rx_data : ~tx_data) :
		((mode == `ETH_RECV) ? rx_data : tx_data);
next_CRC CRC_gen_a (.curr_CRC(CRC_reg), .data(CRC_data), .next_CRC(CRC_next));
extend_CRC CRC_gen_b (.next_CRC(CRC_next), .extend_CRC(CRC_extend));

always @(posedge clock_25 or negedge resetn) begin
	if (~resetn) pause_counter <= 3'h0;
	else if (
		(state_counter == 4'hF) & 
		((state != `ETH_IDLE) | (pause_counter != 3'h7))
	) pause_counter <= pause_counter + 1;
	else if (mode == `ETH_PAUSE) begin
		if (
			(state == `ETH_SRC) & 
			(state_counter == 4'hB)
		) pause_counter <= 3'h0;
		else if (
			(state == `ETH_PAUSE_FRAME) & 
			(state_counter == 4'h7) &
			(pause_counter == 3'h6)
		) pause_counter <= 3'h0;
	end else if (state != `ETH_IDLE)
		pause_counter <= 3'h0;
end

always @(posedge clock_25 or negedge resetn) begin
	if (~resetn) begin
		CRC_reg <= 32'h00000000;
		CRC_error <= 1'b0;
	end else begin
		CRC_reg <= CRC_next;
		if (
			(state == `ETH_SYNC)	&
			(((mode == `ETH_RECV) & (rx_data == 4'hD)) | (state_counter == 4'hF))
		) begin
			CRC_reg <= 32'h00000000;
			CRC_error <= 1'b0;
		end else if (
			(mode == `ETH_RECV) & 
			(state == `ETH_CRC) & 
			(state_counter == 4'd7) & 
			(CRC_next != ~{
				buffer_next[24],buffer_next[25],buffer_next[26],buffer_next[27],
				buffer_next[28],buffer_next[29],buffer_next[30],buffer_next[31],
				buffer_next[16],buffer_next[17],buffer_next[18],buffer_next[19],
				buffer_next[20],buffer_next[21],buffer_next[22],buffer_next[23],
				buffer_next[ 8],buffer_next[ 9],buffer_next[10],buffer_next[11],
				buffer_next[12],buffer_next[13],buffer_next[14],buffer_next[15],
				buffer_next[ 0],buffer_next[ 1],buffer_next[ 2],buffer_next[ 3],
				buffer_next[ 4],buffer_next[ 5],buffer_next[ 6],buffer_next[ 7]
			})
		) CRC_error <= 1'b1;
		if (collision_detected) CRC_error <= 1'b1;
	end 
end

always @(posedge clock_25 or negedge resetn) begin
	if (~resetn) buffer <= 32'h00000000;
	else begin
		if (
			(state == `ETH_CLK_DLY) & 
			(state_counter == 4'h3)
		) buffer <= 32'h55555555;
		else if (
			(state == `ETH_SYNC) & 
			((mode == `ETH_PAUSE) | (mode == `ETH_SEND))
		) begin
			if (state_counter == 4'h7) buffer <= 32'h555555D5;
			else if (state_counter == 4'hF) buffer <= Dest_MAC_I[47:16];
			else buffer <= buffer_next;
		end else if (
			(state == `ETH_DEST) & 
			((mode == `ETH_PAUSE) | (mode == `ETH_SEND)) &
			(state_counter == 4'h7)
		) buffer <= {Dest_MAC_I[15:0],MAC_ADDRESS[47:32]};
		else if (
			(state == `ETH_SRC) & 
			((mode == `ETH_PAUSE) | (mode == `ETH_SEND)) &
			(state_counter == 4'h3)
		) buffer <= MAC_ADDRESS[31:0];
		else if (
			(state == `ETH_SRC) & 
			(mode == `ETH_PAUSE) &
			(state_counter == 4'hB)
		) buffer <= {16'h002E,Type_I};
		else if (state == `ETH_PAUSE_FRAME) begin
			if ((pause_counter == 3'h0) & (state_counter == 3'h7))
				buffer <= 32'h00000000;
			else if ((pause_counter == 3'h5) & (state_counter == 4'hF))
				buffer <= CRC_extend;
			else buffer <= buffer_next;
		end else if (
			(state == `ETH_DATA) & 
			(mode == `ETH_RECV) & 
			(state_counter[2:0] == 3'h7) &
			(next_Address_O == Range_end_O)
		) buffer <= CRC_extend;
		else buffer <= buffer_next;
	end
end

always @(posedge clock_25 or negedge resetn) begin
	if (~resetn) begin
		state <= `ETH_IDLE;
		mode <= `ETH_RECV;
		state_counter <= 4'h0;
	end else if (
		(state != `ETH_IDLE) & 
		(collision_detected | tx_error | rx_error)
	) state <= `ETH_IDLE;
	else begin
		case (state) 
			`ETH_IDLE : begin
				state_counter <= state_counter + 1;
				if (!(rx_error | tx_error)) begin
					if (rx_data_valid & (rx_data == 4'h5)) begin
						state <= `ETH_SYNC;
						mode <= `ETH_RECV;
					end else if (
						~carrier_sense & 
						~collision_detected &
						(pause_counter == 3'h7)
					) begin
						if (Start_pause_I) begin
							state <= `ETH_CLK_DLY;
							mode <= `ETH_PAUSE;
							state_counter <= 4'h0;
						end else if (Start_send_I) begin					
							state <= `ETH_CLK_DLY;
							mode <= `ETH_SEND;
							state_counter <= 4'h0;
						end
					end
				end
			end
			`ETH_SYNC : begin
				state_counter <= state_counter + 1;
				if (mode == `ETH_RECV) begin
					if (rx_data == 4'hD) begin
						state <= `ETH_DEST;
						state_counter <= 4'h0;
					end else if (rx_data != 4'h5) state <= `ETH_IDLE;
				end else if (state_counter == 4'hF) begin
					state <= `ETH_DEST;
					state_counter <= 4'd0;
				end
			end
         `ETH_DEST : begin
				state_counter <= state_counter + 1;
				if (
					(mode == `ETH_RECV) & 
					(state_counter == 4'h8) & 
					~((buffer == MAC_ADDRESS[47:16]) | (broadcast_enable & (buffer == 32'hFFFFFFFF))) 
				) state <= `ETH_IDLE;
				else if (state_counter == 4'hB) begin
					state <= `ETH_SRC;
					state_counter <= 4'd0;
				end
			end
         `ETH_SRC : begin
				state_counter <= state_counter + 1;
				if (
					(mode == `ETH_RECV) & 
					(state_counter == 4'h0) & 
					~((buffer[15:0] == MAC_ADDRESS[15:0]) | (broadcast_enable & (buffer[15:0] == 16'hFFFF))) 
				) state <= `ETH_IDLE;
				if (state_counter == 4'hB) begin
					state_counter <= 4'd0;
					if (mode == `ETH_PAUSE) 
						state <= `ETH_PAUSE_FRAME;
					else state <= `ETH_TYPE;
				end
			end
         `ETH_TYPE : begin
				state_counter <= state_counter + 1;
				if (state_counter == 4'h3) 
					if (mode == `ETH_PAUSE) begin
						state <= `ETH_DATA;
						state_counter <= 4'd0;
					end else begin
						state <= `ETH_RANGE_BEGIN;
						state_counter <= 4'd0;
					end
			end
         `ETH_RANGE_BEGIN : begin
				state_counter <= state_counter + 1;
				if (state_counter == 4'h5) begin
					state <= `ETH_RANGE_END;
					state_counter <= 4'd0;
				end
			end
         `ETH_RANGE_END : begin
				state_counter <= state_counter + 1;
				if (state_counter == 4'h5) begin
					state <= `ETH_DATA;
					state_counter <= 4'd8;
				end
			end
         `ETH_DATA : begin 
				if (state_counter[2:0] == 3'h7) state_counter <= 4'h0;
				else state_counter <= state_counter + 1;
				if (
					(mode == `ETH_RECV) & 
					(rx_error | ~rx_data_valid)
				) state <= `ETH_IDLE;
				else if (
					(mode == `ETH_RECV) & 
					(state_counter[2:0] == 3'h7) &
					(next_Address_O == Range_end_O)
				) state <= `ETH_CRC;
			end
         `ETH_CRC : begin
				state_counter <= state_counter + 1;
				if (state_counter == 4'd7) state <= `ETH_IDLE;
			end
			`ETH_PAUSE_FRAME : begin
				state_counter <= state_counter + 1;
				if ((pause_counter == 3'h6) & (state_counter == 4'h7)) state <= `ETH_IDLE;
			end				
			`ETH_CLK_DLY : begin
				state_counter <= state_counter + 1;
				if (state_counter == 4'h3) begin
					state <= `ETH_SYNC;
					state_counter <= 4'h0;
				end
			end
		endcase
	end
end

assign Error_O = CRC_error | tx_error | rx_error;

assign enet_slew = 2'b00;
assign pause = 1'b0;
assign mdc = 1'b0;
assign mdo = 1'bz; assign mdio_dir = 1'b1;
assign ssn_out = 1'bz; assign ssn_dir = 1'b1;

/*
// chipscope
wire chipscope_clock;
wire [7:0] chipscope_trigger;
wire [15:0] chipscope_data; 
wire [35:0] chipscope_control; 

eth_icon i_eth_icon (.control0(chipscope_control));
eth_ila i_eth_ila (
	.control(chipscope_control),
	.clk(chipscope_clock),
	.data(chipscope_data),
	.trig0(chipscope_trigger)
);

assign chipscope_clock = clock_25;
assign chipscope_trigger = {
	tx_enable, rx_data_valid, mode, 4'h0 };

assign chipscope_data[15] = tx_enable;
assign chipscope_data[14] = rx_data_valid;
assign chipscope_data[13:12] = mode;
assign chipscope_data[11:8] = state;
assign chipscope_data[7:4] = tx_data;
assign chipscope_data[3:0] = rx_data;
/**/

// Buffering
OBUF_F_12 TX_DATA3_BUF (.I(tx_data[3]), .O(TX_DATA_P[3]));
OBUF_F_12 TX_DATA2_BUF (.I(tx_data[2]), .O(TX_DATA_P[2]));
OBUF_F_12 TX_DATA1_BUF (.I(tx_data[1]), .O(TX_DATA_P[1]));
OBUF_F_12 TX_DATA0_BUF (.I(tx_data[0]), .O(TX_DATA_P[0]));
OBUF_F_12 TX_ENABLE_BUF (.I(tx_enable), .O(TX_ENABLE_P));
OBUF_F_12 ENET_SLEW1_BUF (.I(enet_slew[1]), .O(ENET_SLEW_P[1]));
OBUF_F_12 ENET_SLEW0_BUF (.I(enet_slew[0]), .O(ENET_SLEW_P[0]));
OBUF_F_12 PAUSE_BUF	(.I(pause), .O(PAUSE_P));
OBUF_F_12 MDC_BUF (.I(mdc), .O(MDC_P));

IBUF TX_ERROR_BUF (.I(TX_ERROR_P), .O(tx_error));
IBUF RX_DATA3_BUF (.I(RX_DATA_P[3]), .O(rx_data[3]));
IBUF RX_DATA2_BUF (.I(RX_DATA_P[2]), .O(rx_data[2]));
IBUF RX_DATA1_BUF (.I(RX_DATA_P[1]), .O(rx_data[1]));
IBUF RX_DATA0_BUF (.I(RX_DATA_P[0]), .O(rx_data[0]));
IBUF RX_DATA_VALID_BUF (.I(RX_DATA_VALID_P), .O(rx_data_valid));
IBUF RX_ERROR_BUF (.I(RX_ERROR_P), .O(rx_error));
IBUF COLLISION_DETECTED_BUF (.I(COLLISION_DETECTED_P), .O(collision_detected));
IBUF CARRIER_SENSE_BUF (.I(CARRIER_SENSE_P), .O(carrier_sense));
IBUF MDINIT_BUF (.I(MDINIT_N), .O(mdinit));

IOBUF MDIO_BUF (.I(mdi), .O(mdo), .T(mdio_dir), .IO(MDIO_P));
IOBUF SSN_DATA_BUF (.I(ssn_in), .O(ssn_out), .T(ssn_dir), .IO(SSN_DATA_P));

// clock management
IBUF TX_CLOCK_BUF (.I(TX_CLOCK_P), .O(tx_clock));
IBUF RX_CLOCK_BUF (.I(RX_CLOCK_P), .O(rx_clock));
//IBUFG TX_CLOCK_BUF (.I(TX_CLOCK_P), .O(tx_clock));
//IBUFG RX_CLOCK_BUF (.I(RX_CLOCK_P), .O(rx_clock));
BUFGMUX clock_gbuf (.I0(rx_clock), .I1(tx_clock), .S(tx_clock_select), .O(clock_25)) /* synthesis syn_noclockbuf = 1 */;

//assign clock_25 = (tx_clock_select) ? tx_clock : rx_clock;

endmodule
/* 
module eth_icon (control0); output [35:0] control0; endmodule
module eth_ila (control, clk, data, trig0);
	input [35:0] control; input clk; input [15:0] data; input [7:0] trig0;
endmodule
*/
