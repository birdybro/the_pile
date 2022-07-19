/////////////////////////////////////////////////////////////////////
////  Serial Input Block                                         ////
/////////////////////////////////////////////////////////////////////

`timescale 1 ns/ 100 ps

module ac97_sin(clk, //rst,

	out_le, slt0, slt1, slt2, slt3, slt4, 
//	slt5, slt6, slt7, slt8, slt9, slt10, slt11, slt12, 

	sdata_in
	);

input		clk;
//input		rst;

// --------------------------------------
// Misc Signals
input	[4:0]	out_le;
output	[15:0]	slt0;
output	[19:0]	slt1;
output	[19:0]	slt2;
output	[19:0]	slt3;
output	[19:0]	slt4;
//output	[19:0]	slt5;
//output	[19:0]	slt6;
//output	[19:0]	slt7;
//output	[19:0]	slt8;
//output	[19:0]	slt9;
//output	[19:0]	slt10;
//output	[19:0]	slt11;
//output	[19:0]	slt12;

// --------------------------------------
// AC97 Codec Interface
input		sdata_in;

////////////////////////////////////////////////////////////////////
//
// Local Wires
//

reg		sdata_in_r;
reg	[19:0]	sr;

reg	[15:0]	slt0;
reg	[19:0]	slt1;
reg	[19:0]	slt2;
reg	[19:0]	slt3;
reg	[19:0]	slt4;
//reg	[19:0]	slt5;
//reg	[19:0]	slt6;
//reg	[19:0]	slt7;
//reg	[19:0]	slt8;
//reg	[19:0]	slt9;
//reg	[19:0]	slt10;
//reg	[19:0]	slt11;
//reg	[19:0]	slt12;

////////////////////////////////////////////////////////////////////
//
// Output Registers
//

always @(posedge clk)
	if(out_le[0])	slt0 <= #1 sr[15:0];

always @(posedge clk)
	if(out_le[1])	slt1 <= #1 sr;

always @(posedge clk)
	if(out_le[2])	slt2 <= #1 sr;

always @(posedge clk)
	if(out_le[3])	slt3 <= #1 sr;

always @(posedge clk)
	if(out_le[4])	slt4 <= #1 sr;
/*
always @(posedge clk)
	if(out_le[5])	slt5 <= #1 sr;

always @(posedge clk)
	if(out_le[6])	slt6 <= #1 sr;

always @(posedge clk)
	if(out_le[7])	slt7 <= #1 sr;

always @(posedge clk)
	if(out_le[8])	slt8 <= #1 sr;

always @(posedge clk)
	if(out_le[9])	slt9 <= #1 sr;

always @(posedge clk)
	if(out_le[10])	slt10 <= #1 sr;

always @(posedge clk)
	if(out_le[11])	slt11 <= #1 sr;

always @(posedge clk)
	if(out_le[12])	slt12 <= #1 sr;		 */


////////////////////////////////////////////////////////////////////
//
// Serial Shift Register
//

always @(negedge clk)
	sdata_in_r <= #1 sdata_in;

always @(posedge clk)
	sr <= #1 {sr[18:0], sdata_in_r };

endmodule


