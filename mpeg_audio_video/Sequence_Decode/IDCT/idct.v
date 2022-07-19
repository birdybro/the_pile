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
module IDCT	(CLOCK_I, 
				RESETN_I,
				FRAME_START_I,
				WRITE_I,
				ADDRESS_I,
				DATA_I,
				DATA_O,
				DONE_O,
				VALID_O);

// I/O declarations
input										CLOCK_I; 
input										RESETN_I;
input										FRAME_START_I;
input										WRITE_I;
input[5:0]								ADDRESS_I;
input[`IDCT_INPUT_WIDTH-1:0]		DATA_I;
output[`IDCT_OUTPUT_WIDTH-1:0]	DATA_O;
output									VALID_O;
output									DONE_O;
reg										VALID_O;
wire										DONE_O;

// internal signals for transfering data from/to module's I/Os
wire 										clock;
wire 										resetn;
wire 										frame_start;
wire 										we_in;
wire[`IDCT_DATA_WIDTH-1:0]			data_in;
wire[`IDCT_OUTPUT_WIDTH-1:0]		ch0_data_out;
wire[`IDCT_OUTPUT_WIDTH-1:0]		ch1_data_out;
wire[`IDCT_DATA_WIDTH-1:0]			ch0_output;
wire[`IDCT_DATA_WIDTH-1:0]			ch1_output;
reg										valid_out;
reg										done_out;

// signals used to interface the four memory blocks (two channels and two instances)
wire										ch0_we_a_0, ch0_we_b_0, ch0_we_a_1, ch0_we_b_1;
wire[`IDCT_ADDR_WIDTH-1:0]			ch0_address_a_0, ch0_address_b_0, ch0_address_a_1, ch0_address_b_1;
wire[`IDCT_DATA_WIDTH-1:0]			ch0_data_in_a_0, ch0_data_in_b_0, ch0_data_out_a_0, ch0_data_out_b_0;
wire[`IDCT_DATA_WIDTH-1:0]			ch0_data_in_a_1, ch0_data_in_b_1, ch0_data_out_a_1, ch0_data_out_b_1; 
wire										ch1_we_a_0, ch1_we_b_0, ch1_we_a_1, ch1_we_b_1;
wire[`IDCT_ADDR_WIDTH-1:0]			ch1_address_a_0, ch1_address_b_0, ch1_address_a_1, ch1_address_b_1;
wire[`IDCT_DATA_WIDTH-1:0]			ch1_data_in_a_0, ch1_data_in_b_0, ch1_data_out_a_0, ch1_data_out_b_0;
wire[`IDCT_DATA_WIDTH-1:0]			ch1_data_in_a_1, ch1_data_in_b_1, ch1_data_out_a_1, ch1_data_out_b_1; 

// signals related to the memory logic required by the specific addressing logic
reg[`IDCT_ADDR_WIDTH-1:0]			ch0_internal_address_a, ch0_internal_address_b;
reg[`IDCT_ADDR_WIDTH-1:0]			ch1_internal_address_a, ch1_internal_address_b;
reg[2:0]									ch0_address_offset_a, ch0_address_offset_b;
reg[2:0]									ch1_address_offset_a, ch1_address_offset_b;
wire										ch0_we_condition;
wire										ch1_we_condition;

// signals used to direct the data flow and the interface to the I/Os
reg										active;
reg										initial_load;
reg[3:0]									iteration;
wire[3:0]								iterationp1;
wire[3:0]								iterationm1;
reg[4:0]									counter;
wire[4:0]								del8_counter;
reg[5:0]									we_count;
reg[5:0]									output_count;
reg										output_select;
wire[5:0]								external_write_address;
reg										ch0_block_id;
reg										ch1_block_id;
reg										ch0_offset;
reg										ch1_offset;
reg										ch0_load;
reg										ch1_load;
reg										ch1_stall;

// signals before the data is passed to different butterfly paths on stage 0 of the pipe
wire 										ch0_switch_memory_port;
wire 										ch1_switch_memory_port;
wire[`IDCT_DATA_WIDTH-1:0]			ch0_data_out_a, ch0_data_out_b;
wire[`IDCT_DATA_WIDTH-1:0]			ch1_data_out_a, ch1_data_out_b;
reg[`IDCT_DATA_WIDTH-1:0]			ch0_del_data_out_a, ch0_del_data_out_b;
reg[`IDCT_DATA_WIDTH-1:0]			ch1_del_data_out_a, ch1_del_data_out_b;
wire[`IDCT_DATA_WIDTH-1:0]			ch0_butterfly_in_a, ch0_butterfly_in_b;
wire[`IDCT_DATA_WIDTH-1:0]			ch1_butterfly_in_a, ch1_butterfly_in_b;

// signals for the multiplier3 path on the stage 0 of the pipe
wire[1:0]		 						multiplier3_code;
wire 										multiplier3_sel;
wire[`IDCT_MULTIPLIER3_WIDTH-1:0]multiplier3_in_a, multiplier3_in_b;
wire[`IDCT_MULTIPLIER3_WIDTH+11:0]multiplier3_out_a, multiplier3_out_b;

// signals for the bypass path on the stage 0 of the pipe
wire[`IDCT_DATA_WIDTH-9:0]			ch0_butterfly_bypass_stage0_inc;
wire[`IDCT_DATA_WIDTH-9:0]			ch1_butterfly_bypass_stage0_inc;
wire[`IDCT_DATA_WIDTH-1:0]			ch0_butterfly_bypass_stage0_a, ch0_butterfly_bypass_stage0_b;
wire[`IDCT_DATA_WIDTH-1:0]			ch1_butterfly_bypass_stage0_a, ch1_butterfly_bypass_stage0_b;

// signals for the adder/substracter circuit where the pipe registers are inserted
reg										ch0_butterfly_sub;
reg										ch1_butterfly_sub;
reg[`IDCT_MULTIPLIER3_WIDTH+11:0]ch0_butterfly_muxed_a, ch0_butterfly_muxed_b;
reg[`IDCT_MULTIPLIER3_WIDTH+11:0]ch1_butterfly_muxed_a, ch1_butterfly_muxed_b;
wire[`IDCT_MULTIPLIER3_WIDTH+11:0]ch0_butterfly_add;
wire[`IDCT_MULTIPLIER3_WIDTH+11:0]ch1_butterfly_add;

// signals for the multiplier1 path on the stage 1 of the pipe
wire 										multiplier1_sel;
wire[`IDCT_DATA_WIDTH-1:0]			multiplier1_in_a;
wire[`IDCT_DATA_WIDTH-1:0]			multiplier1_out_a;

// signals for the bypass path on the stage 1 of the pipe
wire[`IDCT_MULTIPLIER3_WIDTH+11:0]ch0_butterfly_bypass_stage1_inc;
wire[`IDCT_MULTIPLIER3_WIDTH+11:0]ch1_butterfly_bypass_stage1_inc;
wire[`IDCT_DATA_WIDTH-1:0]			ch0_butterfly_bypass_stage1;
wire[`IDCT_DATA_WIDTH-1:0]			ch1_butterfly_bypass_stage1;

// signals for the output of the butterfly before they are fed back to the memory
wire[`IDCT_DATA_WIDTH-1:0]			ch0_butterfly_out;
wire[`IDCT_DATA_WIDTH-1:0]			ch1_butterfly_out;
reg[`IDCT_DATA_WIDTH-1:0]			ch0_del_butterfly_out;
reg[`IDCT_DATA_WIDTH-1:0]			ch1_del_butterfly_out;

// state counters and flags
always @(posedge clock or negedge resetn)
begin
	if (!resetn)
	begin
		initial_load <= 1'b0;
		iteration <= 4'd0;
		we_count <= 6'h00;
		output_count <= 6'h00;
		output_select <= 1'b0;
		counter <= 5'd0;
		active <= 1'b0;
		ch0_block_id <= 1'b0;
		ch1_block_id <= 1'b0;
		ch0_offset <= 1'b0;
		ch1_offset <= 1'b0;
		ch0_load <= 1'b0;
		ch1_load <= 1'b0;
		ch1_stall <= 1'b0;
		done_out <= 1'b0;
		valid_out <= 1'b0;
	end
	else
	begin
		done_out <= 1'b0;
		if (we_in && (ch0_load || ch1_load)) 
			we_count <= we_count + 1;
		output_count <= output_count + 1;
		if (output_count == 6'h3F)
			valid_out <= 1'b0;
		if (active) 
		begin 
			counter <= counter + 1;
			if (counter == 5'd27)
			begin
				counter <= 5'd2;
				iteration <= iterationp1;
				if (iteration[2:0] == 3'd7)
				begin
					counter <= 5'd0;
					if (iteration[3])
					begin
						done_out <= 1'b1;
						valid_out <= 1'b1;
						output_select <= 1'b0;
						if (!ch0_block_id)
							ch0_offset <= ~ch0_offset;
						ch0_block_id <= ~ch0_block_id;
						ch0_load <= 1'b1;
						output_count <= 6'h00;
					end
				end
			end
			if (del8_counter == 5'd27 && iteration == 4'd8)
			begin
				done_out <= 1'b1;
				valid_out <= !ch1_stall;
				output_select <= 1'b1;
				if (!ch1_block_id)
					ch1_offset <= ~ch1_offset;
				ch1_block_id <= ~ch1_block_id;
				ch1_load <= 1'b1;
				ch1_stall <= 1'b0;
				output_count <= 6'h00;
			end
			if (we_count == 6'h3F && we_in && (ch0_load || ch1_load))
			begin
				ch0_load <= 1'b0;
				ch1_load <= 1'b0;
			end
			if (frame_start)
			begin
				initial_load <= 1'b0;
				iteration <= 4'd0;
				we_count <= 6'h00;
				output_count <= 6'h00;
				output_select <= 1'b0;
				counter <= 5'd0;
				active <= 1'b0;
				ch0_block_id <= 1'b0;
				ch1_block_id <= 1'b0;
				ch0_offset <= 1'b0;
				ch1_offset <= 1'b0;
				ch0_load <= 1'b0;
				ch1_load <= 1'b0;
				ch1_stall <= 1'b0;
				done_out <= 1'b0;
				valid_out <= 1'b0;
			end
		end
		else 
		begin
			if (frame_start)
			begin
				done_out <= 1'b1;
				initial_load <= 1'b1;
				ch0_load <= 1'b1;
				ch0_block_id <= 1'b1;
			end
			if (initial_load)
			begin
				if (we_count == 6'h3F && we_in && (ch0_load || ch1_load))
				begin
					done_out <= 1'b1;
					ch0_load <= ~ch0_load;
					ch1_load <= ~ch1_load;
					if (ch0_load)
					begin
						ch0_block_id <= ~ch0_block_id;
						ch1_block_id <= ~ch1_block_id;
					end
					if (ch1_load)
					begin
						active <= 1'b1;
						ch1_stall <= 1'b1;
					end
				end
			end
		end
	end
end

// internal buffers
always @(posedge clock or negedge resetn)
begin
	if (!resetn)
	begin
		ch0_del_data_out_a <= {`IDCT_DATA_WIDTH{1'b0}};
		ch0_del_data_out_b <= {`IDCT_DATA_WIDTH{1'b0}};
		ch1_del_data_out_a <= {`IDCT_DATA_WIDTH{1'b0}};
		ch1_del_data_out_b <= {`IDCT_DATA_WIDTH{1'b0}};
		ch0_del_butterfly_out <= {`IDCT_DATA_WIDTH{1'b0}};
		ch1_del_butterfly_out <= {`IDCT_DATA_WIDTH{1'b0}};
		ch0_butterfly_muxed_a <= {`IDCT_MULTIPLIER3_WIDTH{1'b0}};
		ch0_butterfly_muxed_b <= {`IDCT_MULTIPLIER3_WIDTH{1'b0}};
		ch1_butterfly_muxed_a <= {`IDCT_MULTIPLIER3_WIDTH{1'b0}};
		ch1_butterfly_muxed_b <= {`IDCT_MULTIPLIER3_WIDTH{1'b0}};
		ch0_butterfly_sub <= 1'b0;
		ch1_butterfly_sub <= 1'b0;
	end
	else
	begin
		ch0_del_data_out_a <= ch0_switch_memory_port ? ch0_data_out_b : ch0_data_out_a; 
		ch0_del_data_out_b <= ch0_switch_memory_port ? ch0_data_out_a : ch0_data_out_b;
		ch1_del_data_out_a <= ch1_switch_memory_port ? ch1_data_out_b : ch1_data_out_a; 
		ch1_del_data_out_b <= ch1_switch_memory_port ? ch1_data_out_a : ch1_data_out_b;
		ch0_del_butterfly_out <= ch0_butterfly_out;
		ch1_del_butterfly_out <= ch1_butterfly_out;
		ch0_butterfly_muxed_a <= counter == 5'd3 ||
										 counter == 5'd4 ||
										 counter == 5'd5 ||
										 counter == 5'd6 ||
										 counter == 5'd7 ||
										 counter == 5'd8 ?
										 multiplier3_out_a : 
										 {{(`IDCT_MULTIPLIER3_WIDTH+12-`IDCT_DATA_WIDTH){ch0_butterfly_bypass_stage0_a[`IDCT_DATA_WIDTH-1]}},ch0_butterfly_bypass_stage0_a};
		ch0_butterfly_muxed_b <= counter == 5'd3 ||
										 counter == 5'd4 ||
										 counter == 5'd5 ||
										 counter == 5'd6 ||
										 counter == 5'd7 ||
										 counter == 5'd8 ?
										 multiplier3_out_b : 
										 {{(`IDCT_MULTIPLIER3_WIDTH+12-`IDCT_DATA_WIDTH){ch0_butterfly_bypass_stage0_b[`IDCT_DATA_WIDTH-1]}},ch0_butterfly_bypass_stage0_b};
		ch1_butterfly_muxed_a <= del8_counter == 5'd3 ||
										 del8_counter == 5'd4 ||
										 del8_counter == 5'd5 ||
										 del8_counter == 5'd6 ||
										 del8_counter == 5'd7 ||
										 del8_counter == 5'd8 ?
										 multiplier3_out_a : 
										 {{(`IDCT_MULTIPLIER3_WIDTH+12-`IDCT_DATA_WIDTH){ch1_butterfly_bypass_stage0_a[`IDCT_DATA_WIDTH-1]}},ch1_butterfly_bypass_stage0_a};
		ch1_butterfly_muxed_b <= del8_counter == 5'd3 ||
										 del8_counter == 5'd4 ||
										 del8_counter == 5'd5 ||
										 del8_counter == 5'd6 ||
										 del8_counter == 5'd7 ||
										 del8_counter == 5'd8 ?
										 multiplier3_out_b : 
										 {{(`IDCT_MULTIPLIER3_WIDTH+12-`IDCT_DATA_WIDTH){ch1_butterfly_bypass_stage0_b[`IDCT_DATA_WIDTH-1]}},ch1_butterfly_bypass_stage0_b};
		ch0_butterfly_sub <= counter == 5'd1 ||
									counter == 5'd3 ||
									counter == 5'd6 ||
									counter == 5'd8 ||
									counter == 5'd9 ||
									counter == 5'd11 ||
									counter == 5'd13 ||
									counter == 5'd15 ||
									counter == 5'd17 ||
									counter == 5'd20 ||
									counter == 5'd22 ||
									counter == 5'd24 ||
									counter == 5'd26 ||
									counter == 5'd27;
		ch1_butterfly_sub <= del8_counter == 5'd1 ||
									del8_counter == 5'd3 ||
									del8_counter == 5'd6 ||
									del8_counter == 5'd8 ||
									del8_counter == 5'd9 ||
									del8_counter == 5'd11 ||
									del8_counter == 5'd13 ||
									del8_counter == 5'd15 ||
									del8_counter == 5'd17 ||
									del8_counter == 5'd20 ||
									del8_counter == 5'd22 ||
									del8_counter == 5'd24 ||
									del8_counter == 5'd26 ||
									del8_counter == 5'd27;
	end
end

// addressing logic
always @(counter or del8_counter or iteration or ch0_offset or 
			ch0_block_id or iterationp1 or ch1_offset or ch1_block_id or iterationm1)
begin

	ch0_address_offset_a = 3'd0; ch0_address_offset_b = 3'd0;
	case (counter)
		5'd0: begin 	ch0_address_offset_a = 3'd0; ch0_address_offset_b = 3'd4; end
		5'd2: begin 	ch0_address_offset_a = 3'd2; ch0_address_offset_b = 3'd6; end
		5'd3: begin 	ch0_address_offset_a = 3'd0; ch0_address_offset_b = 3'd1; end
		5'd4: begin 	ch0_address_offset_a = 3'd7; ch0_address_offset_b = 3'd1; end
		5'd5: begin 	ch0_address_offset_a = 3'd2; ch0_address_offset_b = 3'd3; end
		5'd6: begin 	ch0_address_offset_a = 3'd3; ch0_address_offset_b = 3'd5; end
		5'd7: begin 	ch0_address_offset_a = 3'd4; ch0_address_offset_b = 3'd5; end
		5'd8: begin 	ch0_address_offset_a = 3'd0; ch0_address_offset_b = 3'd2; end
		5'd9: begin 	ch0_address_offset_a = 3'd6; ch0_address_offset_b = 3'd7; end
		5'd10: begin	ch0_address_offset_a = 3'd4; ch0_address_offset_b = 3'd6; end
		5'd11: begin	ch0_address_offset_a = 3'd0; ch0_address_offset_b = 3'd2; end
		5'd12: begin	ch0_address_offset_a = 3'd5; ch0_address_offset_b = 3'd7; end
		5'd13: begin	ch0_address_offset_a = 3'd4; ch0_address_offset_b = 3'd6; end
		5'd14: begin	ch0_address_offset_a = 3'd1; ch0_address_offset_b = 3'd3; end
		5'd15: begin	ch0_address_offset_a = 3'd5; ch0_address_offset_b = 3'd7; end
		5'd16: begin	ch0_address_offset_a = 3'd4; ch0_address_offset_b = 3'd5; end
		5'd17: begin	ch0_address_offset_a = 3'd1; ch0_address_offset_b = 3'd3; end
		5'd18: begin	ch0_address_offset_a = 3'd3; ch0_address_offset_b = 3'd6; end
		5'd19: begin	ch0_address_offset_a = 3'd4; ch0_address_offset_b = 3'd5; end
		5'd20: begin	ch0_address_offset_a = 3'd2; ch0_address_offset_b = 3'd5; end
		5'd21: begin	ch0_address_offset_a = 3'd0; ch0_address_offset_b = 3'd7; end
		5'd22: begin	ch0_address_offset_a = 3'd1; ch0_address_offset_b = 3'd7; end
		5'd23: begin	ch0_address_offset_a = 3'd1; ch0_address_offset_b = 3'd6; end
		5'd24: begin	ch0_address_offset_a = 3'd0; ch0_address_offset_b = 3'd4; end
		5'd25: begin	ch0_address_offset_a = 3'd3; ch0_address_offset_b = 3'd4; end
		5'd26: begin	ch0_address_offset_a = 3'd0; ch0_address_offset_b = 3'd4; end
		5'd27: begin	ch0_address_offset_a = 3'd2; ch0_address_offset_b = 3'd5; end
	endcase

	ch1_address_offset_a = 3'd0; ch1_address_offset_b = 3'd0;
	case (del8_counter)
		5'd0: begin 	ch1_address_offset_a = 3'd0; ch1_address_offset_b = 3'd4; end
		5'd2: begin 	ch1_address_offset_a = 3'd2; ch1_address_offset_b = 3'd6; end
		5'd3: begin 	ch1_address_offset_a = 3'd0; ch1_address_offset_b = 3'd1; end
		5'd4: begin 	ch1_address_offset_a = 3'd7; ch1_address_offset_b = 3'd1; end
		5'd5: begin 	ch1_address_offset_a = 3'd2; ch1_address_offset_b = 3'd3; end
		5'd6: begin 	ch1_address_offset_a = 3'd3; ch1_address_offset_b = 3'd5; end
		5'd7: begin 	ch1_address_offset_a = 3'd4; ch1_address_offset_b = 3'd5; end
		5'd8: begin 	ch1_address_offset_a = 3'd0; ch1_address_offset_b = 3'd2; end
		5'd9: begin 	ch1_address_offset_a = 3'd6; ch1_address_offset_b = 3'd7; end
		5'd10: begin	ch1_address_offset_a = 3'd4; ch1_address_offset_b = 3'd6; end
		5'd11: begin	ch1_address_offset_a = 3'd0; ch1_address_offset_b = 3'd2; end
		5'd12: begin	ch1_address_offset_a = 3'd5; ch1_address_offset_b = 3'd7; end
		5'd13: begin	ch1_address_offset_a = 3'd4; ch1_address_offset_b = 3'd6; end
		5'd14: begin	ch1_address_offset_a = 3'd1; ch1_address_offset_b = 3'd3; end
		5'd15: begin	ch1_address_offset_a = 3'd5; ch1_address_offset_b = 3'd7; end
		5'd16: begin	ch1_address_offset_a = 3'd4; ch1_address_offset_b = 3'd5; end
		5'd17: begin	ch1_address_offset_a = 3'd1; ch1_address_offset_b = 3'd3; end
		5'd18: begin	ch1_address_offset_a = 3'd3; ch1_address_offset_b = 3'd6; end
		5'd19: begin	ch1_address_offset_a = 3'd4; ch1_address_offset_b = 3'd5; end
		5'd20: begin	ch1_address_offset_a = 3'd2; ch1_address_offset_b = 3'd5; end
		5'd21: begin	ch1_address_offset_a = 3'd0; ch1_address_offset_b = 3'd7; end
		5'd22: begin	ch1_address_offset_a = 3'd1; ch1_address_offset_b = 3'd7; end
		5'd23: begin	ch1_address_offset_a = 3'd1; ch1_address_offset_b = 3'd6; end
		5'd24: begin	ch1_address_offset_a = 3'd0; ch1_address_offset_b = 3'd4; end
		5'd25: begin	ch1_address_offset_a = 3'd3; ch1_address_offset_b = 3'd4; end
		5'd26: begin	ch1_address_offset_a = 3'd0; ch1_address_offset_b = 3'd4; end
		5'd27: begin	ch1_address_offset_a = 3'd2; ch1_address_offset_b = 3'd5; end
	endcase

	ch0_internal_address_a = 7'h00;
	ch0_internal_address_b = 7'h00;
	if (!counter[0])
	begin
		if (counter < 5'd8 || counter > 5'd25)
		begin
			if (counter < 5'd8)
				if (iteration[3]) 
				begin
					ch0_internal_address_a = {{ch0_offset^ch0_block_id},ch0_address_offset_a,iteration[2:0]};
					ch0_internal_address_b = {{ch0_offset^ch0_block_id},ch0_address_offset_b,iteration[2:0]};
				end
				else 
				begin
					ch0_internal_address_a = {{ch0_offset^ch0_block_id},iteration[2:0],ch0_address_offset_a};
					ch0_internal_address_b = {{ch0_offset^ch0_block_id},iteration[2:0],ch0_address_offset_b};
				end 
			else
				if (iterationp1[3])	
				begin 
					ch0_internal_address_a = {{ch0_offset^ch0_block_id},ch0_address_offset_a,iterationp1[2:0]};
					ch0_internal_address_b = {{ch0_offset^ch0_block_id},ch0_address_offset_b,iterationp1[2:0]};
				end
				else
				begin
					ch0_internal_address_a = {{ch0_offset^ch0_block_id},iterationp1[2:0],ch0_address_offset_a};
					ch0_internal_address_b = {{ch0_offset^ch0_block_id},iterationp1[2:0],ch0_address_offset_b};
				end
		end
		else
		begin
			if (counter < 5'd16)	
			begin
				ch0_internal_address_a = {!{ch0_offset^ch0_block_id},3'b000,ch0_address_offset_a};
				ch0_internal_address_b = {!{ch0_offset^ch0_block_id},3'b000,ch0_address_offset_b};
			end
			else
			begin 
				ch0_internal_address_a = {!{ch0_offset^ch0_block_id},3'b001,ch0_address_offset_a};
				ch0_internal_address_b = {!{ch0_offset^ch0_block_id},3'b001,ch0_address_offset_b};
			end
		end
	end
	else
	begin
		if (counter > 5'd20)
		begin
			if (iteration[3]) 
			begin 
				ch0_internal_address_a = {{ch0_offset^ch0_block_id},ch0_address_offset_a,iteration[2:0]};
				ch0_internal_address_b = {{ch0_offset^ch0_block_id},ch0_address_offset_b,iteration[2:0]};
			end
			else
			begin
				ch0_internal_address_a = {{ch0_offset^ch0_block_id},iteration[2:0],ch0_address_offset_a};
				ch0_internal_address_b = {{ch0_offset^ch0_block_id},iteration[2:0],ch0_address_offset_b};
			end
		end
		else
		begin
			if (counter < 5'd10)	
			begin 
				ch0_internal_address_a = {!{ch0_offset^ch0_block_id},3'b000,ch0_address_offset_a};
				ch0_internal_address_b = {!{ch0_offset^ch0_block_id},3'b000,ch0_address_offset_b};
			end
			else
			begin 
				ch0_internal_address_a = {!{ch0_offset^ch0_block_id},3'b001,ch0_address_offset_a};
				ch0_internal_address_b = {!{ch0_offset^ch0_block_id},3'b001,ch0_address_offset_b};
			end
		end
	end

	ch1_internal_address_a = 7'h00;
	ch1_internal_address_b = 7'h00;
	if (!del8_counter[0])
	begin
		if (del8_counter < 5'd8 || del8_counter > 5'd25)
		begin
			if (del8_counter < 5'd8)
				if (!iteration[3])
				begin
					ch1_internal_address_a = {{ch1_offset^ch1_block_id},ch1_address_offset_a,iteration[2:0]};
					ch1_internal_address_b = {{ch1_offset^ch1_block_id},ch1_address_offset_b,iteration[2:0]};
				end
				else 
				begin
					ch1_internal_address_a = {{ch1_offset^ch1_block_id},iteration[2:0],ch1_address_offset_a};
					ch1_internal_address_b = {{ch1_offset^ch1_block_id},iteration[2:0],ch1_address_offset_b};
				end 
			else
				if (!iteration[3])
				begin 
					ch1_internal_address_a = {{ch1_offset^ch1_block_id},ch1_address_offset_a,iteration[2:0]};
					ch1_internal_address_b = {{ch1_offset^ch1_block_id},ch1_address_offset_b,iteration[2:0]};
				end
				else
				begin
					ch1_internal_address_a = {{ch1_offset^ch1_block_id},iteration[2:0],ch1_address_offset_a};
					ch1_internal_address_b = {{ch1_offset^ch1_block_id},iteration[2:0],ch1_address_offset_b};
				end
		end
		else
		begin
			if (del8_counter < 5'd16)	
			begin
				ch1_internal_address_a = {!{ch1_offset^ch1_block_id},3'b000,ch1_address_offset_a};
				ch1_internal_address_b = {!{ch1_offset^ch1_block_id},3'b000,ch1_address_offset_b};
			end
			else
			begin 
				ch1_internal_address_a = {!{ch1_offset^ch1_block_id},3'b001,ch1_address_offset_a};
				ch1_internal_address_b = {!{ch1_offset^ch1_block_id},3'b001,ch1_address_offset_b};
			end
		end
	end
	else
	begin
		if (del8_counter > 5'd20)
		begin
			if ((!iteration[3] && iteration != 4'd0) || (iteration == 4'd8)) 
			begin 
				ch1_internal_address_a = {{ch1_offset^ch1_block_id},ch1_address_offset_a,iterationm1[2:0]};
				ch1_internal_address_b = {{ch1_offset^ch1_block_id},ch1_address_offset_b,iterationm1[2:0]};
			end
			else
			begin
				ch1_internal_address_a = {{ch1_offset^ch1_block_id},iterationm1[2:0],ch1_address_offset_a};
				ch1_internal_address_b = {{ch1_offset^ch1_block_id},iterationm1[2:0],ch1_address_offset_b};
			end
		end
		else
		begin
			if (del8_counter < 5'd10)	
			begin 
				ch1_internal_address_a = {!{ch1_offset^ch1_block_id},3'b000,ch1_address_offset_a};
				ch1_internal_address_b = {!{ch1_offset^ch1_block_id},3'b000,ch1_address_offset_b};
			end
			else
			begin 
				ch1_internal_address_a = {!{ch1_offset^ch1_block_id},3'b001,ch1_address_offset_a};
				ch1_internal_address_b = {!{ch1_offset^ch1_block_id},3'b001,ch1_address_offset_b};
			end
		end
	end
end

assign external_write_address = ADDRESS_I; //we_count;

// various internal signals
assign iterationp1 = iteration + 1;
assign iterationm1 = iteration - 1;
assign del8_counter = iteration[2:0] == 3'b000 ? 
							(counter > 5'd7 ? counter - 5'd8 : counter + 5'd20): 
							(counter > 5'd9 ? counter - 5'd8 : counter + 5'd18);
assign ch0_we_condition = (counter[0]) && (counter != 5'd1);
assign ch1_we_condition = (del8_counter[0]) && (del8_counter != 5'd1);
assign ch0_data_out_a = ch0_block_id ? ch0_data_out_a_1: ch0_data_out_a_0;
assign ch0_data_out_b = ch0_block_id ? ch0_data_out_b_1: ch0_data_out_b_0;
assign ch1_data_out_a = ch1_block_id ? ch1_data_out_a_1: ch1_data_out_a_0;
assign ch1_data_out_b = ch1_block_id ? ch1_data_out_b_1: ch1_data_out_b_0;

assign ch0_switch_memory_port =  counter == 5'd3 ||
											counter == 5'd5 ||
											counter == 5'd7;
assign ch1_switch_memory_port =  del8_counter == 5'd3 ||
											del8_counter == 5'd5 ||
											del8_counter == 5'd7;

// "butterfly"-like data path
assign ch0_butterfly_in_a = !counter[0] ?			ch0_del_data_out_a :
																ch0_data_out_a;
assign ch0_butterfly_in_b = !counter[0] ?			ch0_del_data_out_b :
																ch0_data_out_b;
assign ch1_butterfly_in_a = !del8_counter[0] ?	ch1_del_data_out_a :
																ch1_data_out_a;
assign ch1_butterfly_in_b = !del8_counter[0] ?	ch1_del_data_out_b :
																ch1_data_out_b;

assign ch0_butterfly_bypass_stage0_inc = ch0_butterfly_in_a[`IDCT_DATA_WIDTH-9:0] + 32;
assign ch0_butterfly_bypass_stage0_a =  counter == 5'd1 || counter == 5'd2 || counter == 5'd27 ? 
											(iteration[3] ? {ch0_butterfly_bypass_stage0_inc, 8'h00} : 
											{ch0_butterfly_in_a[`IDCT_DATA_WIDTH-12:0], 11'h080}) : 
											 ch0_butterfly_in_a;
assign ch0_butterfly_bypass_stage0_b =  counter == 5'd1 || counter == 5'd2 || counter == 5'd27 ? 
											(iteration[3] ? {ch0_butterfly_in_b[`IDCT_DATA_WIDTH-9:0], 8'h00} : 
											{ch0_butterfly_in_b[`IDCT_DATA_WIDTH-12:0], 11'h000}) : 
											 ch0_butterfly_in_b;

assign ch1_butterfly_bypass_stage0_inc = ch1_butterfly_in_a[`IDCT_DATA_WIDTH-9:0] + 32;
assign ch1_butterfly_bypass_stage0_a =  del8_counter == 5'd1 || del8_counter == 5'd2 || del8_counter == 5'd27 ? 
											(!iteration[3] ? {ch1_butterfly_bypass_stage0_inc, 8'h00} : 
											{ch1_butterfly_in_a[`IDCT_DATA_WIDTH-12:0], 11'h080}) : 
											 ch1_butterfly_in_a;
assign ch1_butterfly_bypass_stage0_b =  del8_counter == 5'd1 || del8_counter == 5'd2 || del8_counter == 5'd27 ? 
											(!iteration[3] ? {ch1_butterfly_in_b[`IDCT_DATA_WIDTH-9:0], 8'h00} : 
											{ch1_butterfly_in_b[`IDCT_DATA_WIDTH-12:0], 11'h000}) : 
											 ch1_butterfly_in_b;

assign multiplier3_sel = (counter > 5'd2 && counter < 5'd9);
assign multiplier3_in_a = multiplier3_sel ? 
								  ch0_butterfly_in_a[`IDCT_MULTIPLIER3_WIDTH-1:0] : 
								  ch1_butterfly_in_a[`IDCT_MULTIPLIER3_WIDTH-1:0];
assign multiplier3_in_b = multiplier3_sel ? 
								  ch0_butterfly_in_b[`IDCT_MULTIPLIER3_WIDTH-1:0] : 
								  ch1_butterfly_in_b[`IDCT_MULTIPLIER3_WIDTH-1:0];
assign multiplier3_code =  (counter == 5'd3 || counter == 5'd4 || counter == 5'd11 || counter == 5'd12) ? 2'b01 :
								   (counter == 5'd5 || counter == 5'd6 || counter == 5'd13 || counter == 5'd14) ? 2'b00 :
								   2'b10;
									
multiplier3 mult3(
	.in_a(multiplier3_in_a), 
	.in_b(multiplier3_in_b), 
	.code(multiplier3_code), 
	.out_a(multiplier3_out_a), 
	.out_b(multiplier3_out_b));

assign ch0_butterfly_add = ch0_butterfly_sub ?	ch0_butterfly_muxed_a - ch0_butterfly_muxed_b: 
																ch0_butterfly_muxed_a + ch0_butterfly_muxed_b;
assign ch1_butterfly_add = ch1_butterfly_sub ?	ch1_butterfly_muxed_a - ch1_butterfly_muxed_b: 
																ch1_butterfly_muxed_a + ch1_butterfly_muxed_b;

assign multiplier1_sel = counter == 5'd18 || counter == 5'd19;
assign multiplier1_in_a = 	multiplier1_sel ? 
									ch0_butterfly_add[`IDCT_DATA_WIDTH-1:0] : 
									ch1_butterfly_add[`IDCT_DATA_WIDTH-1:0];

multiplier1 mult1(
	.in(multiplier1_in_a), 
	.out(multiplier1_out_a));

assign ch0_butterfly_bypass_stage1_inc = ch0_butterfly_add + 4;
assign ch0_butterfly_bypass_stage1 = !iteration[3] && counter > 19 ?  
										 {{8{ch0_butterfly_add[`IDCT_DATA_WIDTH-1]}},
										   ch0_butterfly_add[`IDCT_DATA_WIDTH-1:8]} :
											iteration[3] && counter > 3 && counter < 10 ? 
										   ch0_butterfly_bypass_stage1_inc[`IDCT_DATA_WIDTH+2:3] :
											ch0_butterfly_add[`IDCT_DATA_WIDTH-1:0];
assign ch0_butterfly_out = counter == 5'd18 || counter == 5'd19 ? 
									multiplier1_out_a : 
									ch0_butterfly_bypass_stage1;

assign ch1_butterfly_bypass_stage1_inc = ch1_butterfly_add + 4;
assign ch1_butterfly_bypass_stage1 = ((iteration[3] && iteration != 4'd8) || iteration == 4'd0) && del8_counter > 19 ?  
										 {{8{ch1_butterfly_add[`IDCT_DATA_WIDTH-1]}},
											ch1_butterfly_add[`IDCT_DATA_WIDTH-1:8]} :
											!iteration[3] && del8_counter > 3 && del8_counter < 10 ? 
										   ch1_butterfly_bypass_stage1_inc[`IDCT_DATA_WIDTH+2:3] :
											ch1_butterfly_add[`IDCT_DATA_WIDTH-1:0];
assign ch1_butterfly_out = del8_counter == 5'd18 || del8_counter == 5'd19 ? 
									multiplier1_out_a : 
									ch1_butterfly_bypass_stage1;

// channel 0 memory interface
assign ch0_we_a_0 = (ch0_load && ch0_block_id && we_in) || ch0_we_b_0;
assign ch0_we_b_0 = (!ch0_block_id) && ch0_we_condition;
assign ch0_data_in_a_0 = ch0_block_id ? data_in : ch0_del_butterfly_out;
assign ch0_data_in_b_0 = ch0_butterfly_out;
assign ch0_address_a_0 = ch0_block_id ? {ch0_offset,external_write_address} : ch0_internal_address_a;
assign ch0_address_b_0 = ch0_block_id ? {!ch0_offset,output_count} : ch0_internal_address_b;

bram ch0_instance_0 (
    .clock(clock), 
    .wren_a(ch0_we_a_0), 
    .wren_b(ch0_we_b_0), 
    .address_a(ch0_address_a_0), 
    .address_b(ch0_address_b_0), 
    .data_in_a(ch0_data_in_a_0), 
    .data_in_b(ch0_data_in_b_0), 
    .data_out_a(ch0_data_out_a_0), 
    .data_out_b(ch0_data_out_b_0)
    );

assign ch0_we_a_1 = (ch0_load && (!ch0_block_id) && we_in) || ch0_we_b_1;
assign ch0_we_b_1 = ch0_block_id && ch0_we_condition;
assign ch0_data_in_a_1 = !ch0_block_id ? data_in : ch0_del_butterfly_out;
assign ch0_data_in_b_1 = ch0_butterfly_out;
assign ch0_address_a_1 = !ch0_block_id ? {ch0_offset,external_write_address} : ch0_internal_address_a;
assign ch0_address_b_1 = !ch0_block_id ? {!ch0_offset,output_count} : ch0_internal_address_b;

bram ch0_instance_1 (
    .clock(clock), 
    .wren_a(ch0_we_a_1), 
    .wren_b(ch0_we_b_1), 
    .address_a(ch0_address_a_1), 
    .address_b(ch0_address_b_1), 
    .data_in_a(ch0_data_in_a_1), 
    .data_in_b(ch0_data_in_b_1), 
    .data_out_a(ch0_data_out_a_1), 
    .data_out_b(ch0_data_out_b_1)
    );

// channel 0 output interface
assign ch0_output = !ch0_block_id ? ch0_data_out_b_1: ch0_data_out_b_0;
assign ch0_data_out =	ch0_output[`IDCT_DATA_WIDTH-1] && (~&(ch0_output[`IDCT_DATA_WIDTH-1:`IDCT_OUTPUT_WIDTH+13])) ? 
								{1'b1,{`IDCT_OUTPUT_WIDTH-1{1'b0}}} : 
								(!ch0_output[`IDCT_DATA_WIDTH-1]) && (|(ch0_output[`IDCT_DATA_WIDTH-1:`IDCT_OUTPUT_WIDTH+13])) ? 
								{1'b0,{`IDCT_OUTPUT_WIDTH-1{1'b1}}} : 
								ch0_output[`IDCT_OUTPUT_WIDTH+13:14];

// channel 1 memory interface
assign ch1_we_a_0 = (ch1_load && ch1_block_id && we_in) || ch1_we_b_0;
assign ch1_we_b_0 = !ch1_stall && (!ch1_block_id) && ch1_we_condition;
assign ch1_data_in_a_0 = ch1_block_id ? data_in : ch1_del_butterfly_out;
assign ch1_data_in_b_0 = ch1_butterfly_out;
assign ch1_address_a_0 = ch1_block_id ? {ch1_offset,external_write_address} : ch1_internal_address_a;
assign ch1_address_b_0 = ch1_block_id ? {!ch1_offset,output_count} : ch1_internal_address_b;

bram ch1_instance_0 (
    .clock(clock), 
    .wren_a(ch1_we_a_0), 
    .wren_b(ch1_we_b_0), 
    .address_a(ch1_address_a_0), 
    .address_b(ch1_address_b_0), 
    .data_in_a(ch1_data_in_a_0), 
    .data_in_b(ch1_data_in_b_0), 
    .data_out_a(ch1_data_out_a_0), 
    .data_out_b(ch1_data_out_b_0)
    );

assign ch1_we_a_1 = (ch1_load && (!ch1_block_id) && we_in) || ch1_we_b_1;
assign ch1_we_b_1 = !ch1_stall && ch1_block_id && ch1_we_condition;
assign ch1_data_in_a_1 = !ch1_block_id ? data_in : ch1_del_butterfly_out;
assign ch1_data_in_b_1 = ch1_butterfly_out;
assign ch1_address_a_1 = !ch1_block_id ? {ch1_offset,external_write_address} : ch1_internal_address_a;
assign ch1_address_b_1 = !ch1_block_id ? {!ch1_offset,output_count} : ch1_internal_address_b;

bram ch1_instance_1 (
    .clock(clock), 
    .wren_a(ch1_we_a_1), 
    .wren_b(ch1_we_b_1), 
    .address_a(ch1_address_a_1), 
    .address_b(ch1_address_b_1), 
    .data_in_a(ch1_data_in_a_1), 
    .data_in_b(ch1_data_in_b_1), 
    .data_out_a(ch1_data_out_a_1), 
    .data_out_b(ch1_data_out_b_1)
    );

// channel 1 output interface
assign ch1_output = !ch1_block_id ? ch1_data_out_b_1: ch1_data_out_b_0;
assign ch1_data_out =	ch1_output[`IDCT_DATA_WIDTH-1] && (~&(ch1_output[`IDCT_DATA_WIDTH-1:`IDCT_OUTPUT_WIDTH+13])) ? 
								{1'b1,{`IDCT_OUTPUT_WIDTH-1{1'b0}}} : 
								(!ch1_output[`IDCT_DATA_WIDTH-1]) && (|(ch1_output[`IDCT_DATA_WIDTH-1:`IDCT_OUTPUT_WIDTH+13])) ? 
								{1'b0,{`IDCT_OUTPUT_WIDTH-1{1'b1}}} : 
								ch1_output[`IDCT_OUTPUT_WIDTH+13:14];

// transfering data to/from internal signals from/to inputs/outputs
assign clock = CLOCK_I;
assign resetn = RESETN_I;
assign frame_start = FRAME_START_I;
assign we_in = WRITE_I;
assign data_in = {{(`IDCT_DATA_WIDTH-`IDCT_INPUT_WIDTH){DATA_I[`IDCT_INPUT_WIDTH-1]}},
							DATA_I[`IDCT_INPUT_WIDTH-1:0]};

assign DATA_O = output_select ? ch1_data_out : ch0_data_out;
assign DONE_O = done_out;

always @(posedge clock or negedge resetn)
begin
	if (!resetn)
		VALID_O <= 1'b0;
	else
		VALID_O <= valid_out;
end

endmodule
