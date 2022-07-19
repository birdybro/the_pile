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

module adder_aa(a, aa);
	input [7:0] a;
	output [9:0] aa;
	wire [9:0] aa;
	
	wire [6:0] g;
	wire [6:1] p;
	wire [8:1] c;
	wire G0, P1;
	
	assign g[0] = a[0] & a[1];
	assign g[1] = a[1] & a[2];
	assign g[2] = a[2] & a[3];
	assign g[3] = a[3] & a[4];
	assign g[4] = a[4] & a[5];
	assign g[5] = a[5] & a[6];
	assign g[6] = a[6] & a[7];
	//note: g[7] is 0 because a[8] would be 0
	
	assign p[1] = a[1] | a[2];
	assign p[2] = a[2] | a[3];
	assign p[3] = a[3] | a[4];
	assign p[4] = a[4] | a[5];
	assign p[5] = a[5] | a[6];
	assign p[6] = a[6] | a[7];
	//note: p[7] is really just a[7] since a[8] would be 0
	
	assign G0 = g[3] | ( p[3] & g[2] ) | ( p[3] & p[2] & g[1] ) | ( p[3] & p[2] & p[1] & g[0] );
	assign P1 = a[7] & p[6] & p[5] & p[4];
	
	//note that c[0] is assumed to be 0 since unsigned adding
	assign c[1] = g[0];
	assign c[2] = g[1] | ( p[1] & g[0] );
	assign c[3] = g[2] | ( p[2] & g[1] ) | ( p[2] & p[1] & g[0] );
	
	assign c[4] = G0;
	assign c[5] = g[4] | ( p[4] & G0 );
	assign c[6] = g[5] | ( p[5] & g[4] ) | ( p[5] & p[4] & G0 );
	assign c[7] = g[6] | ( p[6] & g[5] ) | ( p[6] & p[5] & g[4] ) | ( p[6] & p[5] & p[4] & G0 );
	
	//a[7] is p[7]
	assign c[8] = ( a[7] & g[6] ) | ( a[7] & p[6] & g[5] ) | ( a[7] & p[6] & p[5] & g[4] ) | ( P1 & G0);
	
	
	assign aa[0] = a[0]; // bottom digit is not part of the adder
	assign aa[1] = a[1] ^ a[0]; // ^ c[0] which is 0
	assign aa[2] = a[2] ^ a[1] ^ c[1];
	assign aa[3] = a[3] ^ a[2] ^ c[2];
	assign aa[4] = a[4] ^ a[3] ^ c[3];
	assign aa[5] = a[5] ^ a[4] ^ c[4];
	assign aa[6] = a[6] ^ a[5] ^ c[5];
	assign aa[7] = a[7] ^ a[6] ^ c[6];
	assign aa[8] = a[7] ^ c[7]; // ^ a[8] which is 0
	assign aa[9] = c[8]; //upper digit is just catching overflow
	
endmodule 