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

module yuv2bgr2(yuv, select_const, bgr);
	input select_const; //0 for rec 624, 1 for 709
	input [23:0] yuv;
	output [23:0] bgr;
	wire [23:0] bgr;
	
	wire [7:0] y, u, v, r, g, b;
	assign y = yuv[23:16];
	assign u = yuv[15:8];
	assign v = yuv[7:0];
	assign bgr = { b, g, r };
	
	
	
	wire [9:0] vv, uu;
	/*
	assign vv = {v, 1'h0} + v;
	assign uu = {u, 1'h0} + u;
	*/
	adder_aa adder_vv_inst(
		.a(v),
		.aa(vv)
	);
	
	adder_aa adder_uu_inst(
		.a(u),
		.aa(uu)
	);
	
	
	wire [7:0] crv2_in;
	wire [8:0] crv2_add;
	wire [3:0] crv2_lsb;
	wire [12:0] crv2_out;
	wire [9:0] crv3_in_a, crv3_in_b, crv3_add;
	wire [7:0] crv3_lsb;
	wire [17:0] crv3_out;
	wire [9:0] crv4_in, crv4_add;
	wire [11:0] crv4_lsb;
	wire [21:0] crv4_out;
	wire [25:0] crv_v;
	
	assign crv2_in = (select_const) ?  {1'h0, vv[9:3]} : {2'h0, vv[9:4]};
	assign crv2_add = crv2_in + v;
	assign crv2_lsb = (select_const) ? {vv[2:0], 1'h0} : {vv[3:0]};
	assign crv2_out = { crv2_add , crv2_lsb };
	
	assign crv3_in_a = (select_const) ? {4'h0,crv2_out[12:7]} : {5'h00,crv2_out[12:8]};
	assign crv3_in_b = (select_const) ? {2'h0,v} : vv;
	assign crv3_add = crv3_in_a + crv3_in_b;
	assign crv3_lsb = (select_const) ? {crv2_out[6:1],2'h0} : crv2_out[7:0];
	assign crv3_out = { crv3_add , crv3_lsb };
	
	assign crv4_in = (select_const) ? {2'h0,crv3_out[16:9]} : {4'h0,crv3_out[17:12]};
	assign crv4_add = crv4_in + vv;
	assign crv4_lsb = (select_const) ? {crv3_out[8:2],5'h00} : crv3_out[11:0];
	assign crv4_out = { crv4_add , crv4_lsb };
	
	assign crv_v = { 1'h0 , crv4_out , 3'h0 };
	
	
	
	
	
	wire [8:0] cgv2_add;
	wire [4:0] cgv2_lsb;
	wire [13:0] cgv2_out;
	wire [17:0] cgv3_in_a, cgv3_in_b, cgv3_add;
	wire [2:0] cgv3_lsb;
	wire [20:0] cgv3_out;
	wire [23:0] cgv_v;
	
	assign cgv2_add = v + {5'h00,v[7:5]};
	assign cgv2_lsb = v[4:0];
	assign cgv2_out = { cgv2_add , cgv2_lsb };
	
	assign cgv3_in_a = (select_const) ? {4'h0,cgv2_out} : {4'h0,v,6'h00};
	assign cgv3_in_b = (select_const) ? {1'h0,v,2'h0,vv[9:3]} : {vv,1'h0,v[7:1]};
	assign cgv3_add = cgv3_in_a + cgv3_in_b;
	assign cgv3_lsb = (select_const) ? vv[2:0] : {v[0],2'h0};
	assign cgv3_out = { cgv3_add, cgv3_lsb };
	
	assign cgv_v = { cgv3_out , 3'h0 };
	
	
	
	
	wire [9:0] cgu2_in;
	wire [10:0] cgu2_add;
	wire [1:0] cgu2_lsb;
	wire [12:0] cgu2_out;
	wire [16:0] cgu3_in_a, cgu3_in_b, cgu3_add;
	wire [4:0] cgu3_lsb;
	wire [21:0] cgu3_out;
	wire [23:0] cgu_u;
	
	assign cgu2_in = (select_const) ? uu : {u,2'h0};
	assign cgu2_add = cgu2_in + {4'h0,u[7:2]};
	assign cgu2_lsb = u[1:0];
	assign cgu2_out = { cgu2_add , cgu2_lsb };
	
	assign cgu3_in_a = (select_const) ? {4'h0,cgu2_out[11:0],1'h0} : {4'h0,cgu2_out};
	assign cgu3_in_b = (select_const) ? {1'h0,uu,3'h0,u[7:5]} : {uu,1'h0,uu[9:4]};
	assign cgu3_add = cgu3_in_a + cgu3_in_b;
	assign cgu3_lsb = (select_const) ? u[4:0] : {uu[3:0],1'h0};
	assign cgu3_out = { cgu3_add , cgu3_lsb };
	
	assign cgu_u = { 1'h0 , cgu3_out , 1'h0 };
	
	
	
	
	
	wire [9:0] cbu2a_x, cbu2a_add;
	wire [2:0] cbu2a_lsb;
	wire [12:0] cbu2a_out;
	wire [7:0] cbu2b_in;
	wire [8:0] cbu2b_add;
	wire [4:0] cbu2b_lsb;
	wire [13:0] cbu2b_out;
	wire [13:0] cbu3_in_a, cbu3_in_b, cbu3_add;
	wire [4:0] cbu3_lsb;
	wire [18:0] cbu3_out;
	wire [7:0] cbu4_in;
	wire [8:0] cbu4_add;
	wire [16:0] cbu4_lsb;
	wire [25:0] cbu4_out;
	wire [26:0] cbu_u;
	
	assign cbu2a_x = (select_const) ? uu : {2'h0,u};
	assign cbu2a_add = cbu2a_x + {3'h0,cbu2a_x[9:3]};
	assign cbu2a_lsb = cbu2a_x[2:0];
	assign cbu2a_out = { cbu2a_add , cbu2a_lsb };
	
	assign cbu2b_in = (select_const) ? uu[9:2] : {3'h0,uu[9:5]};
	assign cbu2b_add = cbu2b_in + u;
	assign cbu2b_lsb = (select_const) ? {uu[1:0],3'h0} : uu[4:0];
	assign cbu2b_out = { cbu2b_add , cbu2b_lsb };
	
	assign cbu3_in_a = (select_const) ? {1'h0,cbu2b_out[13:3],2'h0} : cbu2b_out;
	assign cbu3_in_b = (select_const) ? {6'h00,cbu2a_out[12:5]} : {7'h00,cbu2a_out[11:5]};
	assign cbu3_add = cbu3_in_a + cbu3_in_b;
	assign cbu3_lsb = cbu2a_out[4:0];
	assign cbu3_out = { cbu3_add , cbu3_lsb };
	
	assign cbu4_in = (select_const) ? {4'h0,cbu3_out[17:14]} : {6'h00,cbu3_out[18:17]};
	assign cbu4_add = cbu4_in + u;
	assign cbu4_lsb = (select_const) ? {cbu3_out[13:0],3'h0} : cbu3_out[16:0];
	assign cbu4_out = { cbu4_add , cbu4_lsb };
	
	assign cbu_u = { 1'h0 , cbu4_out };
	
	
	
	
	wire [8:0] y1_add;
	wire [10:0] y1_out;
	wire [8:0] y2_add;
	wire [12:0] y2_out;
	wire [15:0] y3_add;
	wire [24:0] y3_out;
	wire [25:0] yy;
	
	assign y1_add = y + {2'h0,y[7:2]};
	assign y1_out = { y1_add , y[1:0] };
	
	assign y2_add = y + {1'h0,y1_out[10:4]};
	assign y2_out = { y2_add , y1_out[3:0] };
	
	assign y3_add = {y,3'h0,y2_out[12:9]} + {2'h0,y2_out};
	assign y3_out = { y3_add , y2_out[8:0] };
	
	assign yy = { 1'h0, y3_out };
	
	
	wire [21:0] red_const;
	wire [21:0] green_const;
	wire [22:0] blue_const;
	
	//26 bit signed, minus 4 lsb which are 0, sign extension from 25 bit
	assign red_const = (select_const) ? -16228688/16 : -14576976/16;
	
	//26 bit signed, minus 4 lsb which are 0, positive values
	assign green_const = (select_const) ? 5065648/16 : 8918192/16;
	
	//27 bit signed, minus 4 lsb which are 0, sign extension from 26 bit
	assign blue_const = (select_const) ? -18910544/16 : -18109904/16;
	
	
	
	wire [21:0] red_add1;
	wire [25:0] red_add2;
	assign red_add1 = red_const + yy[25:4];
	assign red_add2 = {red_add1, yy[3:0]} + crv_v;
	assign r = (red_add2[25]) ? 8'h00 : ((red_add2[24]) ? 8'hff : red_add2[23:16] );

	wire [22:0] blue_add1;
	wire [26:0] blue_add2;
	assign blue_add1 = blue_const + {1'b0, yy[25:4]};
	assign blue_add2 = {blue_add1, yy[3:0]} + cbu_u;
	assign b = (blue_add2[26]) ? 8'h00 : ((blue_add2[25] | blue_add2[24]) ? 8'hff : blue_add2[23:16] );
	
	wire [21:0] green_add1a;
	wire [25:0] green_add1b, green_subtr;
	assign green_add1a = green_const + yy[25:4];
	assign green_add1b = cgu_u + cgv_v;
	assign green_subtr = {green_add1a, yy[3:0]} - green_add1b;
	assign g = (green_subtr[25]) ? 8'h00 : ((green_subtr[24]) ? 8'hff : green_subtr[23:16] );
	
endmodule 