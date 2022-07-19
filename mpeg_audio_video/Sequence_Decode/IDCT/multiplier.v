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
module multiplier3(in_a, in_b, code, out_a, out_b);
	
	input [`IDCT_MULTIPLIER3_WIDTH-1:0] in_a, in_b;
	input [1:0] code;
	output [`IDCT_MULTIPLIER3_WIDTH+11:0] out_a, out_b;
	wire [`IDCT_MULTIPLIER3_WIDTH+11:0] out_a, out_b;
	
	// code			out_a			out_b
	// 00				in_a*W7		in_b*W1
	// 01				in_a*W6		in_b*W2
	// 10				in_a*W3		in_b*W5
	// 11				???			???
	
	wire [`IDCT_MULTIPLIER3_WIDTH:0] h;
	assign h = (code[1]) ? { in_a , 1'h0 } : { in_a[`IDCT_MULTIPLIER3_WIDTH-1] , in_a };
	
	wire [`IDCT_MULTIPLIER3_WIDTH+5:0] i;
	assign i = (code[1] | code[0]) ? { in_a , 6'h00 } : { {6{in_a[`IDCT_MULTIPLIER3_WIDTH-1]}} , in_a };
	
	wire [`IDCT_MULTIPLIER3_WIDTH+6:0] hi;
	wire [`IDCT_MULTIPLIER3_WIDTH+4:0] hi_add;
	assign hi_add = i[`IDCT_MULTIPLIER3_WIDTH+5:2] + { {3{h[`IDCT_MULTIPLIER3_WIDTH]}} , h };
	assign hi = { hi_add , i[1:0] };
	
	wire [`IDCT_MULTIPLIER3_WIDTH+3:0] j;
	assign j = (code[1]) ? { in_a , 4'h0 } : { {4{in_a[`IDCT_MULTIPLIER3_WIDTH-1]}} , in_a };
	
	wire [`IDCT_MULTIPLIER3_WIDTH-1:0] k;
	assign k = (~code[0]) ? in_a : 0;
	
	wire [`IDCT_MULTIPLIER3_WIDTH+4:0] jk;
	wire [`IDCT_MULTIPLIER3_WIDTH+3:0] jk_add;
	assign jk_add = { j[`IDCT_MULTIPLIER3_WIDTH+3] , j[`IDCT_MULTIPLIER3_WIDTH+3:1] } + { {4{k[`IDCT_MULTIPLIER3_WIDTH-1]}} , k };
	assign jk = { jk_add , j[0] };
	
	wire [`IDCT_MULTIPLIER3_WIDTH+8:0] hijk;
	wire [`IDCT_MULTIPLIER3_WIDTH+4:0] hijk_add;
	assign hijk_add = jk + { {2{hi[`IDCT_MULTIPLIER3_WIDTH+6]}} , hi[`IDCT_MULTIPLIER3_WIDTH+6:4] };
	assign hijk = { hijk_add , hi[3:0] };
	
	wire [`IDCT_MULTIPLIER3_WIDTH+1:0] m;
	assign m = (code[1]) ? { in_a , 2'h0 } :
		( (code[0]) ? { in_a[`IDCT_MULTIPLIER3_WIDTH-1], in_a , 1'h0 } : { {2{in_a[`IDCT_MULTIPLIER3_WIDTH-1]}} , in_a } );
	
	wire [`IDCT_MULTIPLIER3_WIDTH+2:0] hijkm_add;
	assign hijkm_add = m + { {2{hijk[`IDCT_MULTIPLIER3_WIDTH+8]}} , hijk[`IDCT_MULTIPLIER3_WIDTH+8:9] };
	
	assign out_a = { hijkm_add , hijk[8:0] };
	
	wire [`IDCT_MULTIPLIER3_WIDTH:0] q;
	assign q = (~code[1]) ? { in_b , 1'h0 } : { in_b[`IDCT_MULTIPLIER3_WIDTH-1] , in_b };
	
	wire [`IDCT_MULTIPLIER3_WIDTH-1:0] r;
	assign r = in_b;
	
	wire [`IDCT_MULTIPLIER3_WIDTH+2:0] qr;
	wire [`IDCT_MULTIPLIER3_WIDTH+1:0] qr_add;
	assign qr_add = q + { {2{r[`IDCT_MULTIPLIER3_WIDTH-1]}} , r[`IDCT_MULTIPLIER3_WIDTH-1:1] };
	assign qr = { qr_add , r[0] };
	
	wire [`IDCT_MULTIPLIER3_WIDTH+1:0] s;
	assign s = (~code[1] & ~code[0]) ? { in_b , 2'h0 } : { {2{in_b[`IDCT_MULTIPLIER3_WIDTH-1]}} , in_b };
	
	wire [`IDCT_MULTIPLIER3_WIDTH-1:0] t;
	assign t = (~code[1]) ? in_b : 0;
	
	wire [`IDCT_MULTIPLIER3_WIDTH+4:0] st;
	wire [`IDCT_MULTIPLIER3_WIDTH+2:0] st_add;
	assign st_add = { s[`IDCT_MULTIPLIER3_WIDTH+1] , s } + { {5{t[`IDCT_MULTIPLIER3_WIDTH-1]}} , t[`IDCT_MULTIPLIER3_WIDTH-1:2] };
	assign st = { st_add , t[1:0] };
	
	wire [`IDCT_MULTIPLIER3_WIDTH+7:0] qrst;
	wire [`IDCT_MULTIPLIER3_WIDTH+2:0] qrst_add;
	assign qrst_add = qr + { {3{st[`IDCT_MULTIPLIER3_WIDTH+4]}} , st[`IDCT_MULTIPLIER3_WIDTH+4:5] };
	assign qrst = { qrst_add , st[4:0] };
	
	wire [`IDCT_MULTIPLIER3_WIDTH+3:0] u00u;
	wire [`IDCT_MULTIPLIER3_WIDTH:0] u00u_add;
	assign u00u_add = in_b + { {3{in_b[`IDCT_MULTIPLIER3_WIDTH-1]}} , in_b[`IDCT_MULTIPLIER3_WIDTH-1:3] };
	assign u00u = { u00u_add , in_b[2:0] };
	
	wire [`IDCT_MULTIPLIER3_WIDTH+5:0] u;
	assign u = (code[0]) ? { u00u , 2'h0 } : { {2{u00u[`IDCT_MULTIPLIER3_WIDTH+3]}} , u00u };
	
	wire [`IDCT_MULTIPLIER3_WIDTH+7:0] qrstu_add;
	assign qrstu_add = qrst + { {6{u[`IDCT_MULTIPLIER3_WIDTH+5]}} , u[`IDCT_MULTIPLIER3_WIDTH+5:4] };
	
	assign out_b = { qrstu_add , u[3:0] };
	
endmodule 

module multiplier1(in, out);
	
	input [`IDCT_DATA_WIDTH-1:0] in;
	output [`IDCT_DATA_WIDTH-1:0] out;
	wire [`IDCT_DATA_WIDTH-1:0] out;
	
	// out = (in * 181 + 128) >> 8
	
	wire [`IDCT_DATA_WIDTH+2:0] a0a;
	wire [`IDCT_DATA_WIDTH:0] a0a_add;
	assign a0a_add = in + { {2{in[`IDCT_DATA_WIDTH-1]}} , in[`IDCT_DATA_WIDTH-1:2] };
	assign a0a = { a0a_add , in[1:0] };
	
	wire [`IDCT_DATA_WIDTH:0] in_plus128;
	wire [`IDCT_DATA_WIDTH-7:0] in_plus128_add;
	assign in_plus128_add = { in[`IDCT_DATA_WIDTH-1] , in[`IDCT_DATA_WIDTH-1:7] } + 1;
	assign in_plus128 = { in_plus128_add , in[6:0] };
	
	wire [`IDCT_DATA_WIDTH+4:0] a2;
	wire [`IDCT_DATA_WIDTH+2:0] a2_add;
	assign a2_add = a0a + { {4{in_plus128[`IDCT_DATA_WIDTH]}} , in_plus128[`IDCT_DATA_WIDTH:2] };
	assign a2 = { a2_add , in_plus128[1:0] };
	
	wire [`IDCT_DATA_WIDTH+2:0] a3_add;
	assign a3_add = a0a + { {3{a2[`IDCT_DATA_WIDTH+4]}} , a2[`IDCT_DATA_WIDTH+4:5] };
	
	assign out = a3_add[`IDCT_DATA_WIDTH+2:3];
endmodule 

/*
`define W1 2841 
`define W2 2676 
`define W3 2408 
`define W5 1609 
`define W6 1108 
`define W7 565  

module multiplier3(in_a, in_b, code, out_a, out_b);

	input [`IDCT_MULTIPLIER3_WIDTH-1:0] in_a, in_b;
	input [1:0] code;
	output [`IDCT_MULTIPLIER3_WIDTH+11:0] out_a, out_b;
	wire [`IDCT_MULTIPLIER3_WIDTH+11:0] out_a, out_b;
	
	integer operand_a, operand_b, result_a, result_b;
	wire[31:0] res_a, res_b;
	
	always @(in_a or in_b)
	begin
		operand_a = {{32-`IDCT_MULTIPLIER3_WIDTH{in_a[`IDCT_MULTIPLIER3_WIDTH-1]}},in_a};
		operand_b = {{32-`IDCT_MULTIPLIER3_WIDTH{in_b[`IDCT_MULTIPLIER3_WIDTH-1]}},in_b};
		result_a =	(code == 2'b00) ? `W7 * operand_a :
						((code == 2'b01) ? `W6 * operand_a :
						`W3 * operand_a);
		result_b =	(code == 2'b00) ? `W1 * operand_b :
						((code == 2'b01) ? `W2 * operand_b :
						`W5 * operand_b);
	end
	
	assign res_a = result_a;
	assign res_b = result_b;
	
	assign out_a = res_a[`IDCT_MULTIPLIER3_WIDTH+11:0];
	assign out_b = res_b[`IDCT_MULTIPLIER3_WIDTH+11:0];
	
endmodule 
*/
/*
module multiplier1(in, out);

	input [`IDCT_DATA_WIDTH-1:0] in;
	output [`IDCT_DATA_WIDTH-1:0] out;
	wire [`IDCT_DATA_WIDTH-1:0] out;
	
	integer operand, result;
	wire[31:0] res;
	
	always @(in)
	begin	
		operand = {{32-`IDCT_DATA_WIDTH{in[`IDCT_DATA_WIDTH-1]}},in};
		result = (181 * operand + 128);
	end

	assign res = result;

	assign out = res[`IDCT_DATA_WIDTH+7:8];
	
endmodule 
*/