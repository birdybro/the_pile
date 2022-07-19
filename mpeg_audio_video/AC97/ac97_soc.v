/////////////////////////////////////////////////////////////////////
////  Serial Output Controller                                   ////
/////////////////////////////////////////////////////////////////////

`timescale 1 ns/ 100 ps

module ac97_soc(
		clk, rst, sample_frequency, sync, out_le, ld, pause_cnt
		);

input		clk;
input		rst;
input		[15:0] sample_frequency;
output		sync;
output	[4:0]	out_le;
output		ld;
output pause_cnt;
////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg	[7:0]	cnt;
reg		sync_beat;
reg	[4:0]	out_le;
reg		ld;
reg [10:0] void_count;
reg pause_cnt;

assign sync = sync_beat ;
////////////////////////////////////////////////////////////////////
//
// Misc Logic
//

always @(posedge clk)
	if (!rst) cnt <= 8'hff;
	else 
		if (pause_cnt == 0) cnt <= cnt + 8'h1;

always @(posedge clk)
	ld <= #1 (cnt == 8'h00);

always @(posedge clk) begin
	sync_beat <= #1 (cnt == 8'h00) | ((cnt > 8'h00) & (cnt < 8'h10));
end

always @ (posedge clk) begin
	if (!rst) void_count <= 11'h0;
	else if (cnt == 'hff) void_count <= void_count + 11'h1;
	else void_count <= 0;
end

always @ (cnt or void_count or sample_frequency) begin
	if (cnt < 'hff) pause_cnt <= 0;
	else begin
		case (sample_frequency)
		16'h1F40: // 8k
			if (void_count < 'd1280) pause_cnt <= 1;
			else pause_cnt <= 0;
		16'h3E80: // 16k
			if (void_count < 'd512) pause_cnt <= 1;
			else pause_cnt <= 0;
		16'h5622: //22.05k
			if (void_count < 'd301) pause_cnt <= 1;
			else pause_cnt <= 0;
		16'hAC44: // 44.1k
			if (void_count < 'd23) pause_cnt <= 1;
			else pause_cnt <= 0;
		default: // 48k
			pause_cnt <= 0;
		endcase
	end
end

always @(posedge clk)
	out_le[0] <= #1 (cnt == 8'h11);		// Slot 0 Latch Enable

always @(posedge clk)
	out_le[1] <= #1 (cnt == 8'h25);		// Slot 1 Latch Enable

always @(posedge clk)
	out_le[2] <= #1 (cnt == 8'h39);		// Slot 2 Latch Enable

always @(posedge clk)
	out_le[3] <= #1 (cnt == 8'h4d);		// Slot 3 Latch Enable

always @(posedge clk)
	out_le[4] <= #1 (cnt == 8'h61);		// Slot 4 Latch Enable
/*
always @(posedge clk)
	out_le[5] <= #1 (cnt == 8'h75);		// Slot 5 Latch Enable

always @(posedge clk)
	out_le[6] <= #1 (cnt == 8'h89);		// Slot 6 Latch Enable

always @(posedge clk)
	out_le[7] <= #1 (cnt == 8'h9d);		// Slot 7 Latch Enable

always @(posedge clk)
	out_le[8] <= #1 (cnt == 8'hb1);		// Slot 8 Latch Enable

always @(posedge clk)
	out_le[9] <= #1 (cnt == 8'hc5);		// Slot 9 Latch Enable

always @(posedge clk)
	out_le[10] <= #1 (cnt == 8'hd9);		// Slot 10 Latch Enable

always @(posedge clk)
	out_le[11] <= #1 (cnt == 8'hEd);		// Slot 11 Latch Enable

always @(posedge clk)
	out_le[12] <= #1 (cnt == 8'h00);	*/	// Slot 12 Latch Enable	

endmodule
