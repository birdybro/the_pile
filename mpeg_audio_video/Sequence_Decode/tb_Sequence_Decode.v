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

`define START_PICTURE						0
`define START_SLICE							0

//`define INPUT_TRACE							1
`define VALIDATE								1
//`define PRE_IDCT_VALIDATE					1
//`define POST_IDCT_VALIDATE					1
`define POST_MIX_VALIDATE					1

module tb_Sequence_Decode();

reg 						resetn;
reg 						clock, clock_40, clock_27;
reg						Start_Sequence_Decode;
reg  						Advance_Frame;

wire 						ZBT_Reset;
wire 						Shift_1_En;
wire 						Shift_8_En;
wire 						Shift_Busy;
wire 						Byte_allign;
wire 		[31:0]      Bitstream_Data;
wire 		[31:0]		seq_Bitstream_Data;

wire 		[7:0] 		YUV_Data;
wire 						YUV_Write_En;
wire 						YUV_Start;

wire 		[31:0]		FWD_Data, BWD_Data;
wire 		[18:0]		FWD_Addr, BWD_Addr;
wire 						FWD_Busy, BWD_Busy;

wire 						picture_code;
wire 						slice_code;
reg 						skip_shift_en;
reg 						slice_skip_en;
wire 						seq_Shift_8_En;

reg 						Bank_Select;
wire 		[31:0]		Bank_1_Read_data, Bank_2_Read_data, Bank_3_Read_data, Bank_4_Read_data;
wire 		[31:0]		Bank_1_Write_data, Bank_2_Write_data, Bank_3_Write_data, Bank_4_Write_data;
wire 		[18:0]		Bank_1_Address, Bank_2_Address, Bank_3_Address, Bank_4_Address;
wire 						Bank_1_Write_en, Bank_2_Write_en, Bank_3_Write_en, Bank_4_Write_en;

wire seq_pic_start, seq_Advance_Frame;
wire [1:0] seq_pic_type;
wire [11:0] Image_Height, Image_Width;

wire audio_en_flag, video_en_flag;
assign audio_en_flag = 1'b0;
assign video_en_flag = 1'b1;

Sequence_Decode Sequence_Decoder(
   .resetn(resetn),
   .clock(clock),   
   .Start_Sequence_Decode(Start_Sequence_Decode),
	.Advance_Frame_I(seq_Advance_Frame),
	.ZBT_Reset_O(ZBT_Reset),
   .Shift_1_En_O(Shift_1_En),
   .Shift_8_En_O(seq_Shift_8_En),
	.Shift_Busy_I(Shift_Busy),
	.Byte_Allign_I(Byte_allign),
   .Bitstream_Data_I(seq_Bitstream_Data),
	.Image_Horizontal_O(Image_Width),
	.Image_Vertical_O(Image_Height),
	.Picture_Type_O(seq_pic_type),
	.Picture_Start_O(seq_pic_start),
   .YUV_Data_O(YUV_Data),
   .YUV_Write_En_O(YUV_Write_En),
	.YUV_Start_O(YUV_Start),
	.Framestore0_Address_O(FWD_Addr),
	.Framestore0_Data_I(FWD_Data),
	.Framestore0_Busy_I(FWD_Busy),
	.Framestore0_Busy_O(),
	.Framestore1_Address_O(BWD_Addr),
	.Framestore1_Data_I(BWD_Data),
	.Framestore1_Busy_I(BWD_Busy),
	.Framestore1_Busy_O()  
);

Framestore_Management Framestore_Manager(
	.resetn(resetn),                          
	.internal_ZBT_clock(clock),              
	.internal_video_clock(clock_40),            
	.Picture_Start_I(seq_pic_start),                 
	.Picture_Done_I(1'b0),                  
	.Picture_Type_I(seq_pic_type),                  
	.Display_Advance_O(seq_Advance_Frame),               
	.Address_Reset_I(YUV_Start),                 
	.Image_Horizontal_I(Image_Width),              
	.Image_Vertical_I(Image_Height),                
	.YUV_Write_En_I(YUV_Write_En),                  
	.YUV_Write_Data_I(YUV_Data),   
	.Audio_Bitstream_Access_O(),
	.Audio_Bitstream_Address_I(19'h00000),
	.Audio_Bitstream_Write_Data_I(32'h00000000),
	.Audio_Bitstream_Write_En_I(1'b0),
	.Audio_Bitstream_Read_Data_O(),
	.Video_Bitstream_Access_O(), 
	.Video_Bitstream_Address_I(19'h00000),
	.Video_Bitstream_Write_Data_I(32'h00000000),
	.Video_Bitstream_Write_En_I(1'b0),
	.Video_Bitstream_Read_Data_O(),
	.Framestore0_Address_I(FWD_Addr),           
	.Framestore0_Data_O(FWD_Data),
	.Framestore0_Busy_O(FWD_Busy),                            
	.Framestore0_Busy_I(1'b0),                            
	.Framestore1_Address_I(BWD_Addr),           
	.Framestore1_Data_O(BWD_Data),
	.Framestore1_Busy_O(BWD_Busy),              
	.Framestore1_Busy_I(1'b0),                            	                                 
	.Bank_0_Address_O(Bank_1_Address),                
	.Bank_1_Address_O(Bank_2_Address),                
	.Bank_2_Address_O(Bank_3_Address),                
	.Bank_3_Address_O(Bank_4_Address),                                                 
	.Bank_0_Write_Data_O(Bank_1_Write_data),             
	.Bank_1_Write_Data_O(Bank_2_Write_data),             
	.Bank_2_Write_Data_O(Bank_3_Write_data),             
	.Bank_3_Write_Data_O(Bank_4_Write_data),                                              
	.Bank_0_Write_En_O(Bank_1_Write_en),               
	.Bank_1_Write_En_O(Bank_2_Write_en),               
	.Bank_2_Write_En_O(Bank_3_Write_en),               
	.Bank_3_Write_En_O(Bank_4_Write_en),                                                
	.Bank_0_Read_Data_I(Bank_1_Read_data),              
	.Bank_1_Read_Data_I(Bank_2_Read_data),              
	.Bank_2_Read_Data_I(Bank_3_Read_data),              
	.Bank_3_Read_Data_I(Bank_4_Read_data),              
	.VGA_OUT_PIXEL_CLOCK_P(),
	.VGA_COMP_SYNCH_N(),
	.VGA_OUT_RED_P(), 
	.VGA_OUT_GREEN_P(), 
	.VGA_OUT_BLUE_P(),
	.VGA_HSYNCH_N(),
	.VGA_VSYNCH_N(),
	.VGA_OUT_BLANK_N(),
	.Audio_Sync_I(1'b1),
	.Audio_Sync_O()
);

integer picture_counter, slice_skip_count;
initial begin picture_counter = 0; slice_skip_count = 0; end
assign Shift_8_En = seq_Shift_8_En & 
	~ETH_ZBT_emulator.
		System_Parser_unit.AV_External_Buffer.
		Video_Bitstream_unit.Buffer_Empty_O;// | skip_shift_en;
assign picture_code = (Bitstream_Data == 32'h00000100);
assign slice_code = 
	(Bitstream_Data[31:8] == 24'h000001) & 
	(Bitstream_Data[7:0] >= 8'h01) & 
	(Bitstream_Data[7:0] <= 8'hAF);
 
assign seq_Bitstream_Data = Bitstream_Data & ((
	(skip_shift_en & ~((picture_counter == `START_PICTURE) & picture_code)) |
	(slice_skip_en & ~((slice_skip_count == `START_SLICE) & slice_code))) ? 
		32'h00000000 : 32'hFFFFFFFF);
		
tb_ETH_ZBT_emulator ETH_ZBT_emulator(
   .resetn(resetn),
   .clock(clock),
   .audio_clock(clock_27),
	.ZBT_Reset_I(ZBT_Reset),
	.ZBT_Initial_Fill_O(),
   .Video_Empty_O(),
   .Video_Shift_1_En_I(Shift_1_En),
   .Video_Shift_8_En_I(Shift_8_En),
	.Video_Shift_Busy_O(Shift_Busy),
	.Video_Byte_Allign_O(Byte_allign),
   .Video_Bitstream_Data_O(Bitstream_Data),
   .Audio_Shift_En_I(5'h00),
	.Audio_Shift_Busy_O(),
	.Audio_Byte_Allign_O(),
   .Audio_Bitstream_Data_O()
,.debug({audio_en_flag,video_en_flag})
);

ZBT_model Bank_1(
	.clock(clock),
	.Address(Bank_1_Address),
	.Read_data(Bank_1_Read_data),
	.Write_data(Bank_1_Write_data),
	.Write_en(Bank_1_Write_en)
);

ZBT_model Bank_2(
	.clock(clock),
	.Address(Bank_2_Address),
	.Read_data(Bank_2_Read_data),
	.Write_data(Bank_2_Write_data),
	.Write_en(Bank_2_Write_en)
);

ZBT_model Bank_3(
	.clock(clock_40),
	.Address(Bank_3_Address),
	.Read_data(Bank_3_Read_data),
	.Write_data(Bank_3_Write_data),
	.Write_en(Bank_3_Write_en)
);

ZBT_model Bank_4(
	.clock(clock_40),
	.Address(Bank_4_Address),
	.Read_data(Bank_4_Read_data),
	.Write_data(Bank_4_Write_data),
	.Write_en(Bank_4_Write_en)
);

always begin #(0.5*`CLOCK_PERIOD) clock = ~clock; end
always begin #(0.5*`VIDEO_CLOCK_PERIOD) clock_40 = ~clock_40; end
always begin #(`CLOCK_PERIOD) clock_27 = ~clock_27; end

initial begin 
	// set the time format
	$timeformat(-3, 2, " ms", 10);
	$write("Simulation started at %t\n\n", $realtime);

	// initialize signals
	clock = 1'b0; clock_40 = 1'b0; clock_27 = 1'b0; resetn = 1'b0; 
	Start_Sequence_Decode = 1'b0; 
	Advance_Frame = 1'b0; Bank_Select = 1'b0;
	
	// master reset
	#(2*`CLOCK_PERIOD) resetn = 1'b1;	
	
	// Sequence decode start pulse
	wait(ETH_ZBT_emulator.ZBT_buffer_interface.In_Buffer_Full == 1'b1);
	#(10*`CLOCK_PERIOD) Start_Sequence_Decode = 1'b1;	
	$write("Sequence decode started at %t\n", $realtime);
	#(`CLOCK_PERIOD) Start_Sequence_Decode = 1'b0;	
end

initial begin
	skip_shift_en = 1'b0;
	slice_skip_en = 1'b0;
	
	// skip to beginning picture	
	wait(picture_code); 
	skip_shift_en = 1'b1; 
	wait(picture_counter == `START_PICTURE + 1); 
	skip_shift_en = 1'b0;
	slice_skip_count = 0;
	
	// upload Framestore
	Upload_Framestore;

	// skip to beginning slice
	wait(slice_code);
	slice_skip_en = 1'b1; 
	wait(slice_skip_count == `START_SLICE + 1); 
	slice_skip_en = 1'b0;
end

// generate the advance frame signal
always @(posedge clock) begin
	if (Sequence_Decoder.state == `DECODER_WAIT_VSYNCH) begin
		Advance_Frame <= 1'b1;
		wait(Sequence_Decoder.state != `DECODER_WAIT_VSYNCH)
		$write("Finished picture %d, frame advance at %t\n", picture_counter, $realtime);
		Advance_Frame <= 1'b0;
	end
end

always @(Sequence_Decoder.Picture_Decoder.frame_counter)
	$write("-------------------- Frame Counter %d --------------------\n", 
		Sequence_Decoder.Picture_Decoder.frame_counter);

integer data_block_counter, mismatch_counter;
`ifdef VALIDATE
integer temp_data_block, num_data_blocks;
integer ref_block [63:0];
integer data_block [63:0];
initial begin num_data_blocks = 0; data_block_counter = 0; mismatch_counter = 0; end
always @(posedge clock) begin
`ifdef PRE_IDCT_VALIDATE
	if (Sequence_Decoder.Picture_Decoder.Block_Write_En) begin
		data_block[Sequence_Decoder.Picture_Decoder.Block_Address] = 
			(Sequence_Decoder.Picture_Decoder.Block_Data > 2047) ? 
					-(4096 - Sequence_Decoder.Picture_Decoder.Block_Data) : 
					Sequence_Decoder.Picture_Decoder.Block_Data;
`endif
`ifdef POST_IDCT_VALIDATE
	if (
		Sequence_Decoder.Picture_Decoder.IDCT_Valid &
		Sequence_Decoder.Picture_Decoder.IDCT_Flags[0]
	) begin
		data_block[data_block_counter] = 
			(Sequence_Decoder.Picture_Decoder.IDCT_Data > 255) ? 
				-(512 - Sequence_Decoder.Picture_Decoder.IDCT_Data) : 
				Sequence_Decoder.Picture_Decoder.IDCT_Data;
`endif
`ifdef POST_MIX_VALIDATE
	if (Sequence_Decoder.Picture_Decoder.IDCT_valid_reg) begin
		data_block[data_block_counter] = 
			Sequence_Decoder.Picture_Decoder.Clipped_Mixed_Data;
`endif
//		$write("%d %d\n", data_block_counter, data_block[data_block_counter]);
`ifdef PRE_IDCT_VALIDATE
		if (Sequence_Decoder.Picture_Decoder.Block_Address == 6'h3F) begin
`endif
`ifdef POST_IDCT_VALIDATE
		if (data_block_counter == 63) begin
`endif
`ifdef POST_MIX_VALIDATE
		if (data_block_counter == 63) begin
`endif
			$write("--- MB %d, B %d ---", num_data_blocks/6, num_data_blocks % 6);
`ifdef POST_MIX_VALIDATE
`else
			$write("\n");
`endif
			get_reference_block;
/*
			if (num_data_blocks/6 > 1340) begin
				for (data_block_counter = 0; data_block_counter < 8; data_block_counter = data_block_counter + 1) begin
					$write("%5d %5d %5d %5d %5d %5d %5d %5d \t\t\t\t %5d %5d %5d %5d %5d %5d %5d %5d\n", 
/*
						(data_block[8*data_block_counter+0] > 2047) ? 
						-(4096 - data_block[8*data_block_counter+0]) : data_block[8*data_block_counter+0],
						(data_block[8*data_block_counter+1] > 2047) ? 
						-(4096 - data_block[8*data_block_counter+1]) : data_block[8*data_block_counter+1],
						(data_block[8*data_block_counter+2] > 2047) ? 
						-(4096 - data_block[8*data_block_counter+2]) : data_block[8*data_block_counter+2],
						(data_block[8*data_block_counter+3] > 2047) ? 
						-(4096 - data_block[8*data_block_counter+3]) : data_block[8*data_block_counter+3],
						(data_block[8*data_block_counter+4] > 2047) ? 
						-(4096 - data_block[8*data_block_counter+4]) : data_block[8*data_block_counter+4],
						(data_block[8*data_block_counter+5] > 2047) ? 
						-(4096 - data_block[8*data_block_counter+5]) : data_block[8*data_block_counter+5],
						(data_block[8*data_block_counter+6] > 2047) ? 
						-(4096 - data_block[8*data_block_counter+6]) : data_block[8*data_block_counter+6],
						(data_block[8*data_block_counter+7] > 2047) ? 
						-(4096 - data_block[8*data_block_counter+7]) : data_block[8*data_block_counter+7],
*//*
						data_block[8*data_block_counter+0], data_block[8*data_block_counter+1], 
						data_block[8*data_block_counter+2], data_block[8*data_block_counter+3], 
						data_block[8*data_block_counter+4], data_block[8*data_block_counter+5], 
						data_block[8*data_block_counter+6], data_block[8*data_block_counter+7], 
						ref_block[8*data_block_counter+0], ref_block[8*data_block_counter+1],
						ref_block[8*data_block_counter+2], ref_block[8*data_block_counter+3],
						ref_block[8*data_block_counter+4], ref_block[8*data_block_counter+5],
						ref_block[8*data_block_counter+6], ref_block[8*data_block_counter+7]);
				end
				$write("\n");
			end
*/
			for (data_block_counter = 0; data_block_counter < 64; data_block_counter = data_block_counter + 1) begin
/*
`ifdef PRE_IDCT_VALIDATE
				temp_data_block = (data_block[data_block_counter] > 2047) ? 
					-(4096 - data_block[data_block_counter]) : data_block[data_block_counter];
`endif
`ifdef POST_IDCT_VALIDATE
				temp_data_block = (data_block[data_block_counter] > 255) ? 
					-(512 - data_block[data_block_counter]) : data_block[data_block_counter];
`endif
*/
				temp_data_block = data_block[data_block_counter];
//				$write("%5d", temp_data_block);
//				if ((data_block_counter % 8) == 7) $write("\n");
				if (ref_block[data_block_counter] != temp_data_block) begin
					mismatch_counter = mismatch_counter + 1;
`ifdef POST_MIX_VALIDATE
if (((ref_block[data_block_counter] > temp_data_block) ? 
	(ref_block[data_block_counter] - temp_data_block) : 
	(temp_data_block - ref_block[data_block_counter])) <= 2
) begin
	$write("x");
end else begin
`endif
					$write("   mismatch: sample %d : expect %d got %d\n", 
						data_block_counter, ref_block[data_block_counter], temp_data_block);
				end
			end
`ifdef POST_MIX_VALIDATE
end
$write("\n"); 
`endif
//			$write("\n"); 
			num_data_blocks = num_data_blocks + 1;
			data_block_counter = 0;
		end else data_block_counter = data_block_counter + 1;		
	end
end

integer ref_block_fp, ref_block_counter;
integer temp_char_1, temp_char_2;
initial begin ref_block_fp = $fopen(`Block_validate_file, "rb"); end
task get_reference_block; begin
	temp_char_1 = $fgetc(ref_block_fp);
	temp_char_2 = $fgetc(ref_block_fp);	
	while ((temp_char_1 != "-") | (temp_char_2 != "-")) begin
		temp_char_1 = temp_char_2;
		temp_char_2 = $fgetc(ref_block_fp);
	end
	for (temp_char_1 = $fgetc(ref_block_fp); temp_char_1 != "\n"; temp_char_1 = $fgetc(ref_block_fp));
	for (ref_block_counter = 0; ref_block_counter < 64; ref_block_counter = ref_block_counter + 1) 
		temp_char_2 = $fscanf(ref_block_fp, "%d", ref_block[ref_block_counter]);
end endtask
`endif

integer slice_counter;
always @(posedge Sequence_Decoder.Picture_Start) slice_counter <= 1;

always @(posedge Sequence_Decoder.Picture_Decoder.Done_Slice_Decode) begin
	if (resetn) begin
//		$write("Slice decoder finished at %t: slice %d\n", $realtime, slice_counter);
		slice_counter = slice_counter + 1;
	end
end

`ifdef INPUT_TRACE
always @(negedge Sequence_Decoder.Picture_Decoder.Start_Slice_Decode) if (resetn) 
	$write("      ---Slice decoder started at %t: slice %d\n", $realtime, slice_counter);
`endif

//`ifdef INPUT_TRACE
reg prev_shift;
always @(posedge clock) begin
	prev_shift <= Shift_1_En | Shift_8_En;
	if (prev_shift & (Bitstream_Data[31:8] == 24'h000001)) begin
		if ((Bitstream_Data[7:0] >= 8'h01) & (Bitstream_Data[7:0] <= 8'hAF)) begin
			$write("      Slice Start Code %x detected at time %t - %d mismatches\n", 
				Bitstream_Data[7:0], $realtime, mismatch_counter);
			slice_skip_count = slice_skip_count + 1;
		end else if ((Bitstream_Data[7:0] >= 8'hB9) & (Bitstream_Data[7:0] <= 8'hFF))
			$write("System Start Code %x detected at time %t\n", Bitstream_Data[7:0], $realtime);
		else case(Bitstream_Data[7:0])

			8'h00 : begin
				$write("      Picture Start Code %d detected at time %t\n", picture_counter, $realtime);
				picture_counter = picture_counter + 1;
			end				
			8'hB2 : $write("   User Data Start Code detected at time %t\n", $realtime);
			8'hB3 : $write("Sequence Header Code detected at time %t\n", $realtime);
			8'hB4 : $write("Sequence Error Code detected at time %t\n", $realtime);
			8'hB5 : $write("   Extension Start Code detected at time %t\n", $realtime);
			8'hB7 : $write("Sequence End Code detected at time %t\n", $realtime);
			8'hB8 : $write("   Group Start Code detected at time %t\n", $realtime);

			8'hB9 : $write("ISO End Code detected at time %t\n", $realtime);
			8'hBA : $write("Pack Start Code detected at time %t\n", $realtime);
			8'hBB : $write("System Start Code detected at time %t\n", $realtime);
			8'hE0 : $write("Video Elementary Stream Code detected at time %t\n", $realtime);
			8'hC0 : $write("Audio Elementary Stream Code detected at time %t\n", $realtime);

			default : $write("Unrecognized Start Code %x detected at time %t\n", Bitstream_Data[7:0], $realtime);
		endcase
	end
end
//`endif

`ifdef INPUT_TRACE
always @(posedge clock) begin
	if (Sequence_Decoder.Picture_Decoder.Slice_Decoder.Macroblock_Start) 
		$write("\n      ---Macroblock decoder started at %t\n", $realtime);
end
`endif

integer block_counter, MB_counter;
initial begin block_counter = 0; MB_counter = 0; end

`ifdef INPUT_TRACE
always @(posedge clock) begin
	if (Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Write_En_O) begin
		case (Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[31:18])
			`INFO_BLOCK_CODE : $write("   Block data: run %d level %d\n",  
					Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[17:12],
					Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[11:0]);
			`INFO_BLOCK_CODE_EOB : begin
					$write("   ---End of block %d decoded\n", block_counter);
					block_counter <= block_counter + 1;
			end
			`INFO_MACRO_ADDR_INCR : begin
					MB_counter = MB_counter + 
						Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[17:0];
					$write("Macroblock address increment %d decoded - Macroblock %d\n", 
						Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[17:0], 
						MB_counter-1);
				end
			`INFO_MACRO_MODES : begin
					$write("Macroblock modes\n");
					$write("   --- frame/field type = %d, dct type = %d\n", 
						Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[11:10],
						Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[12]);
					if (Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[5]) 
						$write("   --- Intra\n");
					if (Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[6]) 
						$write("   --- Pattern\n");
					if (Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[7]) 
						$write("   --- Motion backward\n");
					if (Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[8]) 
						$write("   --- Motion forward\n");
					if (Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[9]) 
						$write("   --- Quant: %d\n", 
						Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[4:0]);
				end
			`INFO_MACRO_CBP : begin
					$write("Coded Block Pattern: %b\n",
						Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[5:0]);
				end
			`INFO_MACRO_MOTION_VECTOR : begin
					if (Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[14]) begin
						$write("Macroblock motion vector (with residual): (%b,%b,%b) - (%b) %d\n",
							Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[17],
							Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[16],
							Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[15],
							Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[13],
							Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[12:0]);
					end else begin
						$write("Macroblock motion vector (no residual): (%b,%b,%b) - (%b) %d\n",
							Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[17],
							Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[16],
							Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[15],
							Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[13],
							Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[12:0]);
					end
				end
//			`INFO_MACRO_MOTION_VECTOR : begin
//					case (Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[17:11])
//						7'h00 : $write("Macroblock motion vector: (%b,%b,%b) - %d\n",
//							Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[10],
//							Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[9],
//							Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[8],
//							Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[5:0]);
//						7'h01 : $write("Macroblock motion residual: (%b,%b,%b) - %d\n",
//							Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[10],
//							Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[9],
//							Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[8],
//							Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[7:0]);
//					endcase
//				end
			`INFO_SLICE_QUANT : $write("Slice quantisation value: %d\n",
					Sequence_Decoder.Picture_Decoder.Slice_Decoder.Slice_Buffer_Value_O[17:0]);
		endcase
	end
end
`endif

`ifdef INPUT_TRACE
always @(posedge Sequence_Decoder.Headers_Done) begin
	if (resetn) begin
		$write("Decoded header info: \n");
		$write("   Horizontal_Size : %d\n",	
			Sequence_Decoder.Header_Decoder.Horizontal_Size);
		$write("   Vertical_Size : %d\n", 
			Sequence_Decoder.Header_Decoder.Vertical_Size);
		$write("   load_seq_intra_quant_matrix : %b\n", 
			Sequence_Decoder.Header_Decoder.load_seq_intra_quant_matrix);
		$write("   load_seq_non_intra_quant_matrix : %b\n", 
			Sequence_Decoder.Header_Decoder.load_seq_non_intra_quant_matrix);
		$write("   progressive_sequence : %b\n", 
			Sequence_Decoder.Header_Decoder.progressive_sequence);
		$write("   chroma_format : %b\n", 
			Sequence_Decoder.Header_Decoder.chroma_format);
		$write("   picture_coding_type : %b\n", 
			Sequence_Decoder.Header_Decoder.picture_coding_type);
		$write("   f_codes : %b\n", 
			Sequence_Decoder.Header_Decoder.f_codes);
		$write("   intra_dc_precision : %b\n", 
			Sequence_Decoder.Header_Decoder.intra_dc_precision);
		$write("   picture_structure : %b\n", 
			Sequence_Decoder.Header_Decoder.picture_structure);
		$write("   top_field_first : %b\n", 
			Sequence_Decoder.Header_Decoder.top_field_first);
		$write("   frame_pred_frame_dct : %b\n", 
			Sequence_Decoder.Header_Decoder.frame_pred_frame_dct);
		$write("   concealment_mv : %b\n", 
			Sequence_Decoder.Header_Decoder.concealment_mv);
		$write("   q_scale_type : %b\n", 
			Sequence_Decoder.Header_Decoder.q_scale_type);
		$write("   intra_vlc_format : %b\n", 
			Sequence_Decoder.Header_Decoder.intra_vlc_format);
		$write("   alternate_scan : %b\n", 
			Sequence_Decoder.Header_Decoder.alternate_scan);
		$write("   progressive_frame : %b\n", 
			Sequence_Decoder.Header_Decoder.progressive_frame);
	end
end
`endif

task Upload_Framestore; 
	integer i, fp;
	reg [31:0] temp_word;
begin
//	$write("Filling Bank 1 from frames/frame0001.YUV4\n");
	$write("Clearing Framestore Bank 1\n");
//	fp = $fopen("frames/frame0001.YUV4", "rb");
	for (i = 0; i < 129600; i = i + 1) begin
//		temp_word[31:24] = $fgetc(fp);
//		temp_word[23:16] = $fgetc(fp);
//		temp_word[15:8] = $fgetc(fp);
//		temp_word[7:0] = $fgetc(fp);
////		Bank_1.memory[i] = temp_word;
		Bank_1.memory[i] = 'd0;
	end
	$fclose(fp);

//	$write("Filling Bank 2 from frames/frame0000.YUV4\n");
	$write("Clearing Framestore Bank 2\n");
//	fp = $fopen("frames/frame0000.YUV4", "rb");
	for (i = 0; i < 129600; i = i + 1) begin
//		temp_word[31:24] = $fgetc(fp);
//		temp_word[23:16] = $fgetc(fp);
//		temp_word[15:8] = $fgetc(fp);
//		temp_word[7:0] = $fgetc(fp);
////		Bank_2.memory[i] = temp_word;
		Bank_2.memory[i] = 'd0;
	end
	$fclose(fp);
end endtask

endmodule
