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

`timescale 1ns/100ps
module ZBT_connections(
	MEMORY_BANK0_CLK_P		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK0_CLKEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK0_WEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK0_WENA_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK0_WENB_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK0_WENC_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK0_WEND_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK0_ADV_LD_N	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK0_OEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK0_CEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK0_ADDR_P		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK0_DATA_A_P	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK0_DATA_B_P	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK0_DATA_C_P	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK0_DATA_D_P	/* synthesis syn_useioff = 1*/,

	MEMORY_BANK1_CLK_P		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK1_CLKEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK1_WEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK1_WENA_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK1_WENB_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK1_WENC_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK1_WEND_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK1_ADV_LD_N	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK1_OEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK1_CEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK1_ADDR_P		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK1_DATA_A_P	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK1_DATA_B_P	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK1_DATA_C_P	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK1_DATA_D_P	/* synthesis syn_useioff = 1*/,

	MEMORY_BANK2_CLK_P		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK2_CLKEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK2_WEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK2_WENA_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK2_WENB_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK2_WENC_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK2_WEND_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK2_ADV_LD_N	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK2_OEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK2_CEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK2_ADDR_P		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK2_DATA_A_P	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK2_DATA_B_P	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK2_DATA_C_P	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK2_DATA_D_P	/* synthesis syn_useioff = 1*/,

	MEMORY_BANK3_CLK_P		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK3_CLKEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK3_WEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK3_WENA_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK3_WENB_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK3_WENC_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK3_WEND_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK3_ADV_LD_N	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK3_OEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK3_CEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK3_ADDR_P		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK3_DATA_A_P	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK3_DATA_B_P	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK3_DATA_C_P	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK3_DATA_D_P	/* synthesis syn_useioff = 1*/,

	MEMORY_BANK4_CLK_P		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK4_CLKEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK4_WEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK4_WENA_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK4_WENB_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK4_WENC_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK4_WEND_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK4_ADV_LD_N	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK4_OEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK4_CEN_N		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK4_ADDR_P		/* synthesis syn_useioff = 1*/,
	MEMORY_BANK4_DATA_A_P	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK4_DATA_B_P	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK4_DATA_C_P	/* synthesis syn_useioff = 1*/,
	MEMORY_BANK4_DATA_D_P	/* synthesis syn_useioff = 1*/,

	internal_clock_bank0,
	external_clock_bank0,
	read_data_bank0,
	write_data_bank0,
	address_bank0,
	data_direction_bank0,

	internal_clock_bank1,
	external_clock_bank1,
	read_data_bank1,
	write_data_bank1,
	address_bank1,
	data_direction_bank1,

	internal_clock_bank2,
	external_clock_bank2,
	read_data_bank2,
	write_data_bank2,
	address_bank2,
	data_direction_bank2,

	internal_clock_bank3,
	external_clock_bank3,
	read_data_bank3,
	write_data_bank3,
	address_bank3,
	data_direction_bank3,

	internal_clock_bank4,
	external_clock_bank4,
	read_data_bank4,
	write_data_bank4,
	address_bank4,
	data_direction_bank4
);

// INTERFACE TO ZBT RAM
output 			MEMORY_BANK0_CLK_P,		MEMORY_BANK1_CLK_P,		MEMORY_BANK2_CLK_P,		MEMORY_BANK3_CLK_P,		MEMORY_BANK4_CLK_P;
output 			MEMORY_BANK0_CLKEN_N,	MEMORY_BANK1_CLKEN_N,	MEMORY_BANK2_CLKEN_N,	MEMORY_BANK3_CLKEN_N,	MEMORY_BANK4_CLKEN_N;
output 			MEMORY_BANK0_WEN_N,		MEMORY_BANK1_WEN_N,		MEMORY_BANK2_WEN_N,		MEMORY_BANK3_WEN_N,		MEMORY_BANK4_WEN_N;
output 			MEMORY_BANK0_WENA_N,		MEMORY_BANK1_WENA_N,		MEMORY_BANK2_WENA_N,		MEMORY_BANK3_WENA_N,		MEMORY_BANK4_WENA_N;
output 			MEMORY_BANK0_WENB_N,		MEMORY_BANK1_WENB_N,		MEMORY_BANK2_WENB_N,		MEMORY_BANK3_WENB_N,		MEMORY_BANK4_WENB_N;
output 			MEMORY_BANK0_WENC_N,		MEMORY_BANK1_WENC_N,		MEMORY_BANK2_WENC_N,		MEMORY_BANK3_WENC_N,		MEMORY_BANK4_WENC_N;
output 			MEMORY_BANK0_WEND_N,		MEMORY_BANK1_WEND_N,		MEMORY_BANK2_WEND_N,		MEMORY_BANK3_WEND_N,		MEMORY_BANK4_WEND_N;
output 			MEMORY_BANK0_ADV_LD_N,	MEMORY_BANK1_ADV_LD_N,	MEMORY_BANK2_ADV_LD_N,	MEMORY_BANK3_ADV_LD_N,	MEMORY_BANK4_ADV_LD_N;
output 			MEMORY_BANK0_OEN_N,		MEMORY_BANK1_OEN_N,		MEMORY_BANK2_OEN_N,		MEMORY_BANK3_OEN_N,		MEMORY_BANK4_OEN_N;
output 			MEMORY_BANK0_CEN_N,		MEMORY_BANK1_CEN_N,		MEMORY_BANK2_CEN_N,		MEMORY_BANK3_CEN_N,		MEMORY_BANK4_CEN_N;
output [18:0]	MEMORY_BANK0_ADDR_P,		MEMORY_BANK1_ADDR_P,		MEMORY_BANK2_ADDR_P,		MEMORY_BANK3_ADDR_P,		MEMORY_BANK4_ADDR_P;
inout  [7:0] 	MEMORY_BANK0_DATA_A_P,	MEMORY_BANK1_DATA_A_P,	MEMORY_BANK2_DATA_A_P,	MEMORY_BANK3_DATA_A_P,	MEMORY_BANK4_DATA_A_P;
inout  [7:0] 	MEMORY_BANK0_DATA_B_P,	MEMORY_BANK1_DATA_B_P,	MEMORY_BANK2_DATA_B_P,	MEMORY_BANK3_DATA_B_P,	MEMORY_BANK4_DATA_B_P;
inout  [7:0] 	MEMORY_BANK0_DATA_C_P,	MEMORY_BANK1_DATA_C_P,	MEMORY_BANK2_DATA_C_P,	MEMORY_BANK3_DATA_C_P,	MEMORY_BANK4_DATA_C_P;
inout  [7:0] 	MEMORY_BANK0_DATA_D_P,	MEMORY_BANK1_DATA_D_P,	MEMORY_BANK2_DATA_D_P,	MEMORY_BANK3_DATA_D_P,	MEMORY_BANK4_DATA_D_P;


// INTERFACE TO USER DESIGN
input 			internal_clock_bank0,	internal_clock_bank1,	internal_clock_bank2,	internal_clock_bank3,	internal_clock_bank4;
input 			external_clock_bank0,	external_clock_bank1,	external_clock_bank2,	external_clock_bank3,	external_clock_bank4;
input				data_direction_bank0,	data_direction_bank1,	data_direction_bank2,	data_direction_bank3,	data_direction_bank4;	// flag to indicate direction (read = 1, write = 0)
output [31:0]	read_data_bank0,			read_data_bank1,			read_data_bank2,			read_data_bank3,			read_data_bank4;			// data read FROM the memory
input  [31:0]	write_data_bank0,			write_data_bank1,			write_data_bank2,			write_data_bank3,			write_data_bank4;			// data to be written TO the memory
input  [18:0]	address_bank0,				address_bank1,				address_bank2,				address_bank3,				address_bank4;				// address to be read or written

ZBT_bank_connections bank0_inst(
	internal_clock_bank0,
	external_clock_bank0,
	read_data_bank0,
	write_data_bank0,
	address_bank0,
	data_direction_bank0,
   MEMORY_BANK0_CLK_P,
   MEMORY_BANK0_CLKEN_N,
   MEMORY_BANK0_WEN_N,
   MEMORY_BANK0_WENA_N,
   MEMORY_BANK0_WENB_N,
   MEMORY_BANK0_WENC_N,
   MEMORY_BANK0_WEND_N,
   MEMORY_BANK0_ADV_LD_N,
   MEMORY_BANK0_OEN_N,
   MEMORY_BANK0_CEN_N,
   MEMORY_BANK0_ADDR_P,
   MEMORY_BANK0_DATA_A_P,
   MEMORY_BANK0_DATA_B_P,
   MEMORY_BANK0_DATA_C_P,
   MEMORY_BANK0_DATA_D_P
);

ZBT_bank_connections bank1_inst(
	internal_clock_bank1,
	external_clock_bank1,
	read_data_bank1,
	write_data_bank1,
	address_bank1,
	data_direction_bank1,
   MEMORY_BANK1_CLK_P,
   MEMORY_BANK1_CLKEN_N,
   MEMORY_BANK1_WEN_N,
   MEMORY_BANK1_WENA_N,
   MEMORY_BANK1_WENB_N,
   MEMORY_BANK1_WENC_N,
   MEMORY_BANK1_WEND_N,
   MEMORY_BANK1_ADV_LD_N,
   MEMORY_BANK1_OEN_N,
   MEMORY_BANK1_CEN_N,
   MEMORY_BANK1_ADDR_P,
   MEMORY_BANK1_DATA_A_P,
   MEMORY_BANK1_DATA_B_P,
   MEMORY_BANK1_DATA_C_P,
   MEMORY_BANK1_DATA_D_P
);

ZBT_bank_connections bank2_inst(
	internal_clock_bank2,
	external_clock_bank2,
	read_data_bank2,
	write_data_bank2,
	address_bank2,
	data_direction_bank2,
   MEMORY_BANK2_CLK_P,
   MEMORY_BANK2_CLKEN_N,
   MEMORY_BANK2_WEN_N,
   MEMORY_BANK2_WENA_N,
   MEMORY_BANK2_WENB_N,
   MEMORY_BANK2_WENC_N,
   MEMORY_BANK2_WEND_N,
   MEMORY_BANK2_ADV_LD_N,
   MEMORY_BANK2_OEN_N,
   MEMORY_BANK2_CEN_N,
   MEMORY_BANK2_ADDR_P,
   MEMORY_BANK2_DATA_A_P,
   MEMORY_BANK2_DATA_B_P,
   MEMORY_BANK2_DATA_C_P,
   MEMORY_BANK2_DATA_D_P
);

ZBT_bank_connections bank3_inst(
	internal_clock_bank3,
	external_clock_bank3,
	read_data_bank3,
	write_data_bank3,
	address_bank3,
	data_direction_bank3,
   MEMORY_BANK3_CLK_P,
   MEMORY_BANK3_CLKEN_N,
   MEMORY_BANK3_WEN_N,
   MEMORY_BANK3_WENA_N,
   MEMORY_BANK3_WENB_N,
   MEMORY_BANK3_WENC_N,
   MEMORY_BANK3_WEND_N,
   MEMORY_BANK3_ADV_LD_N,
   MEMORY_BANK3_OEN_N,
   MEMORY_BANK3_CEN_N,
   MEMORY_BANK3_ADDR_P,
   MEMORY_BANK3_DATA_A_P,
   MEMORY_BANK3_DATA_B_P,
   MEMORY_BANK3_DATA_C_P,
   MEMORY_BANK3_DATA_D_P
);

ZBT_bank_connections bank4_inst(
	internal_clock_bank4,
	external_clock_bank4,
	read_data_bank4,
	write_data_bank4,
	address_bank4,
	data_direction_bank4,
   MEMORY_BANK4_CLK_P,
   MEMORY_BANK4_CLKEN_N,
   MEMORY_BANK4_WEN_N,
   MEMORY_BANK4_WENA_N,
   MEMORY_BANK4_WENB_N,
   MEMORY_BANK4_WENC_N,
   MEMORY_BANK4_WEND_N,
   MEMORY_BANK4_ADV_LD_N,
   MEMORY_BANK4_OEN_N,
   MEMORY_BANK4_CEN_N,
   MEMORY_BANK4_ADDR_P,
   MEMORY_BANK4_DATA_A_P,
   MEMORY_BANK4_DATA_B_P,
   MEMORY_BANK4_DATA_C_P,
   MEMORY_BANK4_DATA_D_P
);

endmodule
