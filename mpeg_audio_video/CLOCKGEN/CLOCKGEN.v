module CLOCKGEN(
	MASTER_CLOCK_P,
	ALTERNATE_CLOCK_P,
	MEM_CLK_FBOUT_P,
	MEM_CLK_FBIN_P,
	EXTEND_DCM_RESET_P,
	internal_audio_clock,
	internal_video_clock,
	external_video_clock,
	internal_clock,
	external_clock,
	fpga_reset
);

input		MASTER_CLOCK_P;			// master clock input (27MHz) 
input 	ALTERNATE_CLOCK_P;		// alternate clock input (50MHz)
output	MEM_CLK_FBOUT_P;			// memory DCM feedback loop output
input		MEM_CLK_FBIN_P;			// memory DCM feedback loop input
input		EXTEND_DCM_RESET_P;		// signal to extend the DCM reset
output 	internal_audio_clock;	// internal audio clock
output	internal_video_clock;	// internal video clock
output   external_video_clock;	// external video clock
output 	internal_clock;			// internal clock for ZBT RAMs
output	external_clock;			// external clock for ZBT RAMs
output	fpga_reset;					// reset to fpga until all DCMs are locked

wire 		low;

wire		clk_27mhz, clk27mhz;
wire		clk_54mhz, clk54mhz, memory_54mhz;

wire		fpga_reset;

wire		master_clock;
wire		alternate_clock;
wire		mem_clk_fbout;
wire		mem_clk_fbin;
wire		extend_dcm_reset;
wire		dcm_reset;

wire		main_locked;
wire 		memory_locked;
wire 		video_locked;
wire 		pal_clk;
wire 		ntsc_clk;

wire     memory_pal_clk;
wire     memory_ntsc_clk;
wire     memory_video_locked;

BUFG CLK54_BUF( .O(clk_54mhz), .I(clk54mhz)); 
assign internal_clock = clk_54mhz; 
assign external_clock = memory_54mhz;
assign internal_audio_clock = clk_27mhz;

wire enable_reset_counter;

assign low 	= 1'b0;

reg [15:0] 	dcm_reset_counter;
reg 			terminal_count;

// reset the fpga until the DLLs are locked
assign fpga_reset = !(
	main_locked & 
	memory_locked &
	video_locked &
	memory_video_locked
);

//create a reset pulse for the DCM triggered by FPGA DONE
assign enable_reset_counter = !terminal_count & extend_dcm_reset;

initial begin dcm_reset_counter = 16'h0000; end

always @ (posedge master_clock) begin
	if (enable_reset_counter) dcm_reset_counter <= dcm_reset_counter +1;
end

always @ (dcm_reset_counter) begin
	if (dcm_reset_counter == 16'hFFFF) terminal_count = 1'b1;
	else terminal_count = 1'b0;
end

assign dcm_reset = !dcm_reset_counter[15];

// instantiate the input buffers for the clocks and dcm reset
IBUFG MASTER_CLOCK (.I(MASTER_CLOCK_P), .O(master_clock));
IBUFG ALTERNATE_CLOCK (.I(ALTERNATE_CLOCK_P), .O(alternate_clock));
IBUF DCM_RESET (.I(EXTEND_DCM_RESET_P), .O(extend_dcm_reset));

// instantiate the global clock buffers
BUFG CLK27_BUF(.O(clk_27mhz), .I(clk27mhz));

// instantiate the DCM for the internal clocks
DCM MAIN_DCM (
	.CLKFB(clk_27mhz), 
	.CLKIN(master_clock), 
	.DSSEN(low), 
	.PSCLK(low), 
	.PSEN(low), 
	.PSINCDEC(low), 
	.RST(dcm_reset),
	.CLK0(clk27mhz), 
	.CLK90(), 
	.CLK180(),
	.CLK270(), 
	.CLK2X(clk54mhz), 
	.CLK2X180(),
	.CLKDV(), 
	.CLKFX(), 
	.CLKFX180(), 
	.LOCKED(main_locked), 
	.PSDONE(), 
	.STATUS()
);

// instantiate the IO buffers for the memory feedback loop
assign MEM_CLK_FBOUT_P = MEM_CLK_FBIN_P;
BUFG MEM27_BUF(.O(mem_clk_fbin), .I(mem_clk_fbout));

// instantiate the DCM for the memory clocks
DCM MEMORY_DCM (
	.CLKFB(mem_clk_fbin), 
	.CLKIN(master_clock), 
	.DSSEN(low), 
	.PSCLK(low), 
	.PSEN(low), 
	.PSINCDEC(low), 
	.RST(dcm_reset),
	.CLK0(mem_clk_fbout), 
	.CLK90(), 
	.CLK180(), 
	.CLK270(), 
	.CLK2X(memory_54mhz), 
	.CLK2X180(),
	.CLKDV(), 
	.CLKFX(), 
	.CLKFX180(), 
	.LOCKED(memory_locked), 
	.PSDONE(), 
	.STATUS()
);

BUFG VID_IN_54_BUF( .O(internal_video_clock), .I(ntsc_clk));
assign external_video_clock = memory_ntsc_clk;

// instantiate the DCM for the pixel clock
DCM VIDEO_DCM (
	.CLKFB(pal_clk), 
	.CLKIN(alternate_clock), 
	.DSSEN(low), 
	.PSCLK(low), 
	.PSEN(low), 
	.PSINCDEC(low), 
	.RST(dcm_reset),
	.CLK0(pal_clk), 
	.CLK90(), 
	.CLK180(), 
	.CLK270(), 
	.CLK2X(), 
	.CLK2X180(),
	.CLKDV(), 
	.CLKFX(ntsc_clk), 
	.CLKFX180(), 
	.LOCKED(video_locked), 
	.PSDONE(), 
	.STATUS()
);

// instantiate the DCM for the pixel clock for accessing the RAM
DCM MEMORY_VIDEO_DCM (
	.CLKFB(memory_pal_clk), 
	.CLKIN(alternate_clock), 
	.DSSEN(low), 
	.PSCLK(low), 
	.PSEN(low), 
	.PSINCDEC(low), 
	.RST(dcm_reset),
	.CLK0(memory_pal_clk), 
	.CLK90(), 
	.CLK180(), 
	.CLK270(), 
	.CLK2X(), 
	.CLK2X180(),
	.CLKDV(), 
	.CLKFX(memory_ntsc_clk), 
	.CLKFX180(), 
	.LOCKED(memory_video_locked), 
	.PSDONE(), 
	.STATUS()
);

endmodule //CLOCKGEN

module BUFG(O, I); // synthesis syn_black_box
output O;
input I;
endmodule

module IBUFG(O, I); // synthesis syn_black_box
output O;
input I;
endmodule

module IBUF(O, I); // synthesis syn_black_box
output O;
input I;
endmodule

module DCM (CLKFB, CLKIN, DSSEN, PSCLK, PSEN, PSINCDEC, RST,
            CLK0, CLK90, CLK180, CLK270, CLK2X, CLK2X180,
            CLKDV, CLKFX, CLKFX180, LOCKED, PSDONE, STATUS); // synthesis syn_black_box

input CLKFB, CLKIN, DSSEN;
input PSCLK, PSEN, PSINCDEC, RST;

output CLK0, CLK90, CLK180, CLK270, CLK2X, CLK2X180;
output CLKDV, CLKFX, CLKFX180, LOCKED, PSDONE;
output [7:0] STATUS;
endmodule
