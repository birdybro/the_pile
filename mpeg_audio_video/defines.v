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
`timescale 1ns / 100ps
`default_nettype none
`default_nettype wire

`define ZBT_input_file						"../Validation_Data/sample_clip.mpg"
`define Block_validate_file				"../Validation_Data/sample_clip.post_mix"
`define Audio_output_file					"../Validation_Data/sample_clip.pcm"
`define Video_output_directory			"../Validation_Data/frames/"

`define CLOCK_PERIOD							18.51
`define VIDEO_CLOCK_PERIOD					25

//// MPEG decoder defines
`define BLOCKS_PER_MACROBLOCK          'd6
`define ZBT_Cb_OFFSET                  'd86400
`define ZBT_Cr_OFFSET                  'd108000

`define PREDICTOR_RESET                12'h000

`define I_PICTURE                      2'h1
`define P_PICTURE                      2'h2
`define B_PICTURE                      2'h3

`define TOP_FIELD 							2'h1
`define BOTTOM_FIELD 						2'h2
`define FRAME_PICTURE 						2'h3

`define CHROMA_FORMAT_420					2'h1
`define CHROMA_FORMAT_422					2'h2
`define CHROMA_FORMAT_444					2'h3

`define SYSTEM_BUFFER_ADDR_WIDTH       10
`define SYSTEM_BUFFER_SLACK            'd32

`define BITSTR_BUFFER_ADDR_WIDTH       9
`define BITSTR_BUFFER_SLACK            'd8

`define COEFF_BUFFER_ADDR_WIDTH        11
`define COEFF_BUFFER_SLACK             'd350

`define PICTURE_DECODE_SETUP_TIME      'd2000

`define SYS_PARSE_IDLE						3'h0
`define SYS_PARSE_IDLE_2					3'h1
`define SYS_PARSE_PARSE						3'h2
`define SYS_PARSE_VIDEO						3'h3
`define SYS_PARSE_VIDEO_HEADER			3'h4
`define SYS_PARSE_AUDIO						3'h5
`define SYS_PARSE_AUDIO_HEADER			3'h6

`define IDCT_ADDR_WIDTH                7
`define IDCT_DATA_WIDTH                24
`define IDCT_INPUT_WIDTH               12
`define IDCT_OUTPUT_WIDTH              9
`define IDCT_MULTIPLIER3_WIDTH         16

`define DECODER_IDLE                   3'h0
`define DECODER_RESET                  3'h1
`define DECODER_FILL_PIPE              3'h2
`define DECODER_SEARCH_SEQ_HEADER      3'h3
`define DECODER_HEADERS						3'h4
`define DECODER_RUN                    3'h5
`define DECODER_WAIT_VSYNCH				3'h6

`define HEADER_DECODE_IDLE					4'h0
`define HEADER_DECODE_SEARCH_START		4'h1
`define HEADER_DECODE_SEQ_HEADER			4'h2
`define HEADER_DECODE_EXTENSION_USER	4'h3
`define HEADER_DECODE_SEQ_EXT				4'h4
`define HEADER_DECODE_GOP_HEADER			4'h5
`define HEADER_DECODE_PIC_HEADER			4'h6
`define HEADER_DECODE_PIC_EXT				4'h7	
`define HEADER_DECODE_EXT_2				4'h8
`define HEADER_DECODE_QUANT_EXT			4'h9

`define MB_PREDICT_IDLE						3'h0
`define MB_PREDICT_PMV						3'h1
`define MB_PREDICT_FETCH_PREP				3'h2
`define MB_PREDICT_FETCH					3'h3
`define MB_PREDICT_CALCULATE				3'h4

`define MB_PREDICT_UPDATE_IDLE			3'h0
`define MB_PREDICT_UPDATE_CALC			3'h1

`define MB_PREDICT_FETCH_IDLE				2'h0
`define MB_PREDICT_FETCH_MULT				2'h1
`define MB_PREDICT_FETCH_FETCH			2'h2
`define MB_PREDICT_FETCH_COMPLETE		2'h3

`define MB_PREDICT_CALC_IDLE				3'h0
`define MB_PREDICT_CALC_CALC				3'h1
`define MB_PREDICT_CALC_CROSS				3'h2

`define INV_QUANT_IDLE                 3'h0
`define INV_QUANT_MB_INFO              3'h1
`define INV_QUANT_BLOCK_DEQUANT        3'h2
`define INV_QUANT_SKIPPED              3'h3

`define PICTURE_DECODE_IN_IDLE         3'h0
`define PICTURE_DECODE_IN_START_CODE   3'h1
`define PICTURE_DECODE_IN_SLICE        3'h2

`define PICTURE_DECODE_OUT_IDLE        3'h0
`define PICTURE_DECODE_OUT_SETUP       3'h1
`define PICTURE_DECODE_OUT_MAIN        3'h2

`define SLICE_DECODE_IDLE              3'h0
`define SLICE_DECODE_START_CODE        3'h1
`define SLICE_DECODE_QUANTISER_SCALE   3'h2
`define SLICE_DECODE_EXTRA_INFO        3'h3
`define SLICE_DECODE_EXTRA_BIT_SLICE   3'h4
`define SLICE_DECODE_MACROBLOCKS_WAIT  3'h5         
`define SLICE_DECODE_MACROBLOCKS       3'h6         

`define MACRO_DECODE_CC_Y              2'h0
`define MACRO_DECODE_CC_Cb             2'h1
`define MACRO_DECODE_CC_Cr             2'h2

`define MACRO_DECODE_IDLE              4'h0
`define MACRO_DECODE_ADDRESS           4'h1
`define MACRO_DECODE_MODES             4'h2
`define MACRO_DECODE_MODES_2				4'h3
`define MACRO_DECODE_QUANTISER_SCALE   4'h4
`define MACRO_DECODE_MOTION_VECTORS    4'h5
`define MACRO_DECODE_MARKER				4'h6
`define MACRO_DECODE_CBP 					4'h7
`define MACRO_DECODE_BLOCKS            4'h8

`define VECTOR_DECODE_IDLE					3'h0
`define VECTOR_DECODE_S						3'h1
`define VECTOR_DECODE_R						3'h2
`define VECTOR_DECODE_CODE					3'h3
`define VECTOR_DECODE_RESIDUAL			3'h4
`define VECTOR_DECODE_DMVEC				3'h5

`define BLOCK_DECODE_LUMA_SEL          1'b0
`define BLOCK_DECODE_CHROMA_SEL        1'b1
                                       
`define BLOCK_DECODE_IDLE              3'h0
`define BLOCK_DECODE_EMPTY_BLOCK    	3'h1
`define BLOCK_DECODE_DC_SIZE           3'h2
`define BLOCK_DECODE_DC_DIFF           3'h3
`define BLOCK_DECODE_FIRST_COEFF_0     3'h4
`define BLOCK_DECODE_FIRST_COEFF_1     3'h5
`define BLOCK_DECODE_SUBSEQ_COEFFS     3'h6
`define BLOCK_DECODE_SUBSEQ_ESCAPE     3'h7
                                       
`define DCT_ESCAPE                     16'h4100
`define DCT_END_OF_BLOCK               16'h4000
`define TABLE_B1_START                 10'h1F8
`define TABLE_B2_START                 10'h17A
`define TABLE_B3_START                 10'h1F1
`define TABLE_B4_START                 10'h0F1
`define TABLE_B9_START 						10'h240
`define TABLE_B10_START 					10'h21E
`define TABLE_B12_START                10'h071
`define TABLE_B13_START                10'h072
`define TABLE_B14_START                10'h000
`define TABLE_B15_START                10'h100

`define INFO_BLOCK_CODE                14'h0001
`define INFO_BLOCK_CODE_EOB            14'h0002
`define INFO_MACRO_ADDR_INCR           14'h0003
`define INFO_MACRO_MODES               14'h0004
`define INFO_MACRO_CBP               	14'h0005
`define INFO_MACRO_MOTION_VECTOR      	14'h0006
`define INFO_SLICE_QUANT               14'h0007

//// MP2 decoder defines
`define BITALLOC_ROM_OFFSET				10'd384

`define FREQUENCY_48K 						'd1
`define FREQUENCY_44K 						'd0
`define FREQUENCY_32K 						'd2
`define FREQUENCY_8K 						'd3

`define MP2_SUBBAND_IDLE					3'h0
`define MP2_SUBBAND_FILTER					3'h1
`define MP2_SUBBAND_DELAY_1				3'h2
`define MP2_SUBBAND_WINDOW					3'h3
`define MP2_SUBBAND_DELAY_2				3'h4
                              			
`define MP2_BITALLOC_IDLE					3'h0
`define MP2_BITALLOC_SETUP					3'h1
`define MP2_BITALLOC_DECODE				3'h2
`define MP2_SCALE_SETUP						3'h3
`define MP2_SCALE_SCFSI						3'h4
`define MP2_SCALE_TAKEDOWN					3'h5
`define MP2_SCALE_INDEX			  			3'h6
                              			
`define MP2_BDD_IDLE							3'h0
`define MP2_BDD_IJSETUP						3'h1
`define MP2_BDD_CSHIFT						3'h2
`define MP2_BDD_MODULUS						3'h3
`define MP2_BDD_DEQUANT						3'h4
                              			
`define MP2_HEADER_IDLE						3'h0
`define MP2_HEADER_SYNC						3'h1
`define MP2_HEADER_INFO						3'h2
`define MP2_HEADER_TEMP1					3'h3
`define MP2_HEADER_TEMP2					3'h4
                              			
`define MP2_DECODE_IDLE						3'h0
`define MP2_DECODE_HEADER					3'h1
`define MP2_DECODE_SCALE					3'h2
`define MP2_DECODE_BUFFER					3'h3
`define MP2_DECODE_CHECK_FILL				3'h4
`define MP2_DECODE_SYNTH					3'h5

//// backend defines
`define IS_MPEG2			0
`define IS_INTERLACED	1
`define IS_FOURTWOTWO	2

`define HPIC_WIDTH		(pic_width >> 1)
`define QPIC_WIDTH		(pic_width >> 2)
`define EPIC_WIDTH		(pic_width >> 3)

`define LS_04 ((line_state == `S0) | (line_state == `S4))
`define LS_15 ((line_state == `S1) | (line_state == `S5))
`define LS_26 ((line_state == `S2) | (line_state == `S6))
`define LS_37 ((line_state == `S3) | (line_state == `S7))
`define LS_0123 ((line_state == `S0) | (line_state == `S1) | (line_state == `S2) | (line_state == `S3))

// states for global FSM
`define S_BLANK			3'h0
`define S_SETUPA			3'h1
`define S_SETUPB			3'h2
`define S_VCRUNCH			3'h3
`define S_TAKEDOWNA		3'h4
`define S_TAKEDOWNB		3'h5
`define S_TAKEDOWNC		3'h6
`define S_TAKEDOWND		3'h7

// states for horizontal FSM
`define S_HBLANK			3'h0
`define S_FIRSTCRUNCH	3'h1
`define S_HCRUNCH			3'h2
`define S_LASTCRUNCH		3'h3
`define S_PAUSE			3'h4
`define S_YBUF				3'h5

// internal line states
`define S0					3'h0
`define S1					3'h1
`define S2					3'h2
`define S3					3'h3
`define S4					3'h4
`define S5					3'h5
`define S6					3'h6
`define S7					3'h7
`define S_IDLE				3'h0

// ZBT addressing states
`define ZBT_DISABLED		2'h0
`define ZBT_BY8			2'h1
`define ZBT_PAUSE			2'h2
`define ZBT_BY1			2'h3

// Synchronization with display
`define ZBT_LAG			8
`define PIPE_DEPTH		(25 + `ZBT_LAG)
`define H_START_YBUF		800

// 800 X 600 @ 60Hz with a 40.000MHz pixel clock
`define H_ACTIVE			800	// pixels
`define H_FRONT_PORCH	40		// pixels
`define H_SYNCH			128	// pixels
`define H_BACK_PORCH		88		// pixels
`define H_TOTAL			1056	// pixels

`define V_ACTIVE			600	// lines
`define V_FRONT_PORCH	2		// lines
`define V_SYNCH			5		// lines
`define V_BACK_PORCH		25		// lines
`define V_TOTAL			632	// lines

//`define V_FRONT_PORCH	1		// lines
//`define V_SYNCH			4		// lines
//`define V_BACK_PORCH		23		// lines
//`define V_TOTAL			628	// lines

// Multiplier Coefficients
`define BRAM_times_0 		6'b000000
`define BRAM_times_1 		6'b000001
`define BRAM_times_3			6'b010001
`define BRAM_times_4			6'b000100
`define BRAM_times_5			6'b000101
`define BRAM_times_7			6'b010101
`define BRAM_times_neg7		6'b110101
`define BRAM_times_neg16	6'b101000
`define BRAM_times_neg21	6'b101101
`define BRAM_times_neg24	6'b101010
`define BRAM_times_neg32	6'b100110
`define BRAM_times_neg35	6'b110111
`define ZBT_times_0 			9'b000000000
`define ZBT_times_1 			9'b000000001
`define ZBT_times_3			9'b000000011
`define ZBT_times_4			9'b000000100
`define ZBT_times_5			9'b000000101
`define ZBT_times_7			9'b000000111
`define ZBT_times_neg7		9'b100000111
`define ZBT_times_neg16		9'b100010000
`define ZBT_times_neg21		9'b100010101
`define ZBT_times_neg24		9'b100011000
`define ZBT_times_30			9'b000011110
`define ZBT_times_neg32		9'b100100000
`define ZBT_times_neg35		9'b100100011
`define ZBT_times_64			9'b001000000
`define ZBT_times_67			9'b001000011
`define ZBT_times_110		9'b001101110
`define ZBT_times_194		9'b011000010
`define ZBT_times_227		9'b011100011
`define ZBT_times_248		9'b011111000

//// Ethernet defines
`define ETH_RECV 				2'b00
`define ETH_SEND 				2'b01
`define ETH_PAUSE				2'b10

`define ETH_IDLE 				4'h0
`define ETH_SYNC 				4'h1
`define ETH_DEST 				4'h2
`define ETH_SRC 				4'h3
`define ETH_TYPE 				4'h4
`define ETH_RANGE_BEGIN		4'h5
`define ETH_RANGE_END 		4'h6
`define ETH_DATA 				4'h7
`define ETH_CRC 				4'h8
`define ETH_PAUSE_FRAME		4'h9
`define ETH_CLK_DLY			4'hA
`define ETH_MAC_ADDRESS 	48'h5F43D4EA7B13
