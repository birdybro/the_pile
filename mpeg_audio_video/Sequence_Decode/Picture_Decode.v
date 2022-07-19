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
module Picture_Decode (
   resetn,
   clock,

   Start_Picture_Decode_I,
   Done_Picture_Decode_O,

   Data_In_I,
   Shift_1_En_O,
   Shift_8_En_O,
	Shift_Busy_I,
	Byte_Allign_I,
   Start_Code_I,
   Slice_Start_Code_I,
   Start_Code_Upcoming_I,

   Picture_Type_I,
 	Picture_Structure_I,
	Intra_VLC_Format_I,
	Frame_Pred_Frame_DCT_I,
	Concealment_Vectors_I,
	F_Codes_I,
	Intra_DC_Precision_I,
	Quant_Scale_Type_I,
	Alternate_Scan_I,
	Image_Horizontal_I,  
	Image_Vertical_I,
	Load_Seq_Intra_Quant_I,
	Load_Seq_NIntra_Quant_I,
	
   YUV_Data_O,
   YUV_Write_En_O,
   YUV_Start_O,

	Forward_Framestore_Address_O,
	Forward_Framestore_Data_I,
	Forward_Framestore_Busy_I,
	Forward_Framestore_Busy_O,
	Backward_Framestore_Address_O,
	Backward_Framestore_Data_I,
	Backward_Framestore_Busy_I,
	Backward_Framestore_Busy_O

,debug    
);
input [16:0] debug;

input                resetn;
input                clock;

input                Start_Picture_Decode_I;
output               Done_Picture_Decode_O;

input    [1:0]       Data_In_I;
output               Shift_1_En_O;
output               Shift_8_En_O;
input						Shift_Busy_I;
input						Byte_Allign_I;
input                Start_Code_I;
input                Slice_Start_Code_I;
input                Start_Code_Upcoming_I;

input 	[1:0]		   Picture_Type_I;
input 	[1:0]		 	Picture_Structure_I;
input 					Intra_VLC_Format_I;
input 					Frame_Pred_Frame_DCT_I;
input 					Concealment_Vectors_I;
input 	[15:0]		F_Codes_I;
input 	[1:0]			Intra_DC_Precision_I;
input 					Quant_Scale_Type_I;
input 					Alternate_Scan_I;
input 	[11:0]		Image_Horizontal_I;  
input 	[11:0]		Image_Vertical_I;
input 					Load_Seq_Intra_Quant_I;
input 					Load_Seq_NIntra_Quant_I;

output   [7:0]       YUV_Data_O;
output               YUV_Write_En_O;
output 					YUV_Start_O;

output	[18:0]		Forward_Framestore_Address_O, Backward_Framestore_Address_O;
input 	[31:0]		Forward_Framestore_Data_I, Backward_Framestore_Data_I;
input 					Forward_Framestore_Busy_I, Backward_Framestore_Busy_I;
output 					Forward_Framestore_Busy_O, Backward_Framestore_Busy_O;

wire                 Start_Slice_Decode;
wire                 Done_Slice_Decode;
wire                 Slice_Shift_1_En;
wire                 Slice_Shift_8_En;
wire     [31:0]      Slice_Buffer_Value;
wire                 Slice_Buffer_Write_En;
wire                 Slice_Buffer_Full;
reg [`COEFF_BUFFER_ADDR_WIDTH:0] Slice_Buffer_Address;

wire     [31:0]      Coeff_Buffer_Data;
wire                 Coeff_Buffer_En;
wire                 Coeff_Buffer_Empty;
wire [`COEFF_BUFFER_ADDR_WIDTH:0] Coeff_Buffer_Address;
reg						Coeff_Buffer_Reset_Flag;

reg                  Block_Ready;
wire                 Block_Waiting;
wire                 IDCT_Done;

reg      [2:0]       in_state;

reg 		[4:0]			picture_resetn_reg;
wire 						picture_resetn;
wire 						picture_resetn_delay;
wire 						Code_Scan_1, Code_Scan_8;

always @(posedge clock or negedge resetn) begin
	if (~resetn) picture_resetn_reg <= 5'd0;
	else picture_resetn_reg <= {Start_Picture_Decode_I, picture_resetn_reg[4:1]};
end

FDCE picture_reset_FF1 (.Q(picture_resetn), .C(clock), .CE(1'b1), 
	.CLR(~resetn), .D(~(Start_Picture_Decode_I & ~picture_resetn_reg[4])));
assign picture_resetn_delay = picture_resetn_reg[0];
	
assign Start_Slice_Decode = 
   (in_state == `PICTURE_DECODE_IN_SLICE) & Done_Slice_Decode & Slice_Start_Code_I;

assign Shift_1_En_O = Slice_Shift_1_En | Code_Scan_1;
assign Shift_8_En_O = Slice_Shift_8_En | Code_Scan_8;

assign Code_Scan_1 = ~Shift_Busy_I & ~Byte_Allign_I & 
	((in_state == `PICTURE_DECODE_IN_SLICE) & 
		Done_Slice_Decode & Start_Code_Upcoming_I & ~Start_Code_I);
assign Code_Scan_8 = ~Shift_Busy_I & Byte_Allign_I & 
	((in_state == `PICTURE_DECODE_IN_SLICE) & 
		Done_Slice_Decode & Start_Code_Upcoming_I & ~Start_Code_I);

always @(posedge clock or negedge picture_resetn) begin
   if (~picture_resetn) begin
      in_state <= `PICTURE_DECODE_IN_IDLE;
      Slice_Buffer_Address <= 'd0;
      Coeff_Buffer_Reset_Flag <= 1'b0;
   end else begin
      if (Slice_Buffer_Write_En) begin
      	Slice_Buffer_Address <= Slice_Buffer_Address + 1;
      	Coeff_Buffer_Reset_Flag <= 1'b0;
      end
      case (in_state)
         `PICTURE_DECODE_IN_IDLE : begin
               if (picture_resetn_delay) begin
                  in_state <= `PICTURE_DECODE_IN_SLICE;
                  Coeff_Buffer_Reset_Flag <= 1'b1;
               end
            end
         `PICTURE_DECODE_IN_SLICE : begin
               if (Done_Slice_Decode & Start_Code_I & ~Slice_Start_Code_I)
                  in_state <= `PICTURE_DECODE_IN_IDLE;
            end  
      endcase
   end
end

wire [`COEFF_BUFFER_ADDR_WIDTH:0] Addr_Compare_Full_1, Addr_Compare_Full_2;
wire [`COEFF_BUFFER_ADDR_WIDTH:0] Addr_Compare_Empty_1, Addr_Compare_Empty_2;

assign Addr_Compare_Full_1 = 
   Coeff_Buffer_Address - 
   (Slice_Buffer_Address ^ ('d1 << `COEFF_BUFFER_ADDR_WIDTH));
assign Addr_Compare_Full_2 = 
   (Coeff_Buffer_Address ^ ('d1 << `COEFF_BUFFER_ADDR_WIDTH)) - 
   Slice_Buffer_Address;
assign Addr_Compare_Empty_1 = 
   (Slice_Buffer_Address ^ ('d1 << `COEFF_BUFFER_ADDR_WIDTH)) - 
   (Coeff_Buffer_Address ^ ('d1 << `COEFF_BUFFER_ADDR_WIDTH));
assign Addr_Compare_Empty_2 = 
   Slice_Buffer_Address - 
   Coeff_Buffer_Address;

assign Slice_Buffer_Full = 
   (Coeff_Buffer_Address[`COEFF_BUFFER_ADDR_WIDTH] & 
   ~Slice_Buffer_Address[`COEFF_BUFFER_ADDR_WIDTH]) ?
      (Addr_Compare_Full_1 < `COEFF_BUFFER_SLACK) : (Addr_Compare_Full_2 < `COEFF_BUFFER_SLACK);
assign Coeff_Buffer_Empty = 
   (~Slice_Buffer_Address[`COEFF_BUFFER_ADDR_WIDTH] & 
   Coeff_Buffer_Address[`COEFF_BUFFER_ADDR_WIDTH]) ?
      (Addr_Compare_Empty_1 < `COEFF_BUFFER_SLACK) : (Addr_Compare_Empty_2 < `COEFF_BUFFER_SLACK);

Slice_Decode Slice_Decoder(
   .resetn(picture_resetn),
   .clock(clock),
   .Start_Slice_Decode_I(Start_Slice_Decode),
   .Done_Slice_Decode_O(Done_Slice_Decode),
   .Data_In_I(Data_In_I),
   .Shift_1_En_O(Slice_Shift_1_En),
   .Shift_8_En_O(Slice_Shift_8_En),
   .Start_Code_Upcoming_I(Start_Code_Upcoming_I),
   .Slice_Buffer_Value_O(Slice_Buffer_Value),
   .Slice_Buffer_Write_En_O(Slice_Buffer_Write_En),
   .Slice_Buffer_Full_I(Slice_Buffer_Full),
   .Picture_Type_I(Picture_Type_I),
 	.Picture_Structure_I(Picture_Structure_I),
	.Intra_VLC_Format_I(Intra_VLC_Format_I),
	.Frame_Pred_Frame_DCT_I(Frame_Pred_Frame_DCT_I),
	.Concealment_Vectors_I(Concealment_Vectors_I),
	.F_Codes_I(F_Codes_I)
);

wire Coeff_Buffer_En_mod;
assign Coeff_Buffer_En_mod = Coeff_Buffer_En & 
   ~((Slice_Buffer_Address == Coeff_Buffer_Address) & Slice_Buffer_Write_En);

Coeff_Buffer Decoded_Coeff_Buffer(
   .clock(clock),
   .Address_A_I(Slice_Buffer_Address[`COEFF_BUFFER_ADDR_WIDTH-1:0]),
   .Write_Enable_A_I(Slice_Buffer_Write_En),
   .Data_A_I(Slice_Buffer_Value),
   .Enable_B_I(Coeff_Buffer_En_mod),
   .Address_B_I(Coeff_Buffer_Address[`COEFF_BUFFER_ADDR_WIDTH-1:0]),
   .Data_B_O(Coeff_Buffer_Data)
);

reg      [2:0]       out_state;
reg      [3:0]       Block_Counter;
reg      [4:0]       Macroblock_Row;
reg      [5:0]       Macroblock_Col;
reg      [4:0]       Macroblock_in_Row;
reg      [5:0]       Macroblock_in_Col;
reg      [11:0]      Wait_Counter;

reg                  IDCT_Frame_Start;
reg      [1:0]       IDCT_Flags; // 1 write flag - 0 read flag

assign Done_Picture_Decode_O = 
   (out_state == `PICTURE_DECODE_OUT_IDLE) & 
   (in_state == `PICTURE_DECODE_IN_IDLE);

wire     [5:0]       Num_Macroblocks_per_Row;
wire     [4:0]       Num_Macroblock_Rows;

assign Num_Macroblocks_per_Row = Image_Horizontal_I[9:4];
assign Num_Macroblock_Rows = Image_Vertical_I[8:4];

always @(posedge clock or negedge picture_resetn) begin
   if (~picture_resetn) begin
      out_state <= `PICTURE_DECODE_OUT_IDLE;
      Block_Ready <= 1'b0;
      Block_Counter <= 4'h0;
      Macroblock_Col <= 6'h0;
      Macroblock_Row <= 5'h0;
      Macroblock_in_Col <= 6'h0;
      Macroblock_in_Row <= 5'h0;
      IDCT_Frame_Start <= 1'b0;
      Wait_Counter <= 'd0;
      IDCT_Flags <= 2'b00;
   end else begin
      case (out_state)
         `PICTURE_DECODE_OUT_IDLE : begin
               if (~Coeff_Buffer_Empty & 
               	(in_state != `PICTURE_DECODE_IN_IDLE)
               ) begin
                  out_state <= `PICTURE_DECODE_OUT_SETUP;
                  Wait_Counter <= 'd0;
               end
            end
         `PICTURE_DECODE_OUT_SETUP : begin
               if (Wait_Counter == `PICTURE_DECODE_SETUP_TIME) begin
                  Block_Counter <= 'd0;
                  Macroblock_Col <= 6'h0;
                  Macroblock_Row <= 5'h0;
                  Macroblock_in_Col <= 6'h0;
                  Macroblock_in_Row <= 5'h0;
                  IDCT_Frame_Start <= 1'b1;
                  IDCT_Flags <= 2'b10;
                  if (IDCT_Done) out_state <= `PICTURE_DECODE_OUT_MAIN;
               end else Wait_Counter <= Wait_Counter + 1;
            end
         `PICTURE_DECODE_OUT_MAIN : begin
               if (~Block_Waiting) Block_Ready <= 1'b0;
               if (IDCT_Done) begin
                  IDCT_Frame_Start <= 1'b0;
                  if (IDCT_Flags[1]) Block_Ready <= 1'b1;

                  if (IDCT_Flags[0] & (Block_Counter == `BLOCKS_PER_MACROBLOCK-1)) begin
                     Block_Counter <= 1'b0; 
                     Macroblock_Col <= Macroblock_Col + 1;
                  end else Block_Counter <= Block_Counter + 1;

                  if (Macroblock_Col == (Num_Macroblocks_per_Row - 1)) begin
                     if (Block_Counter == `BLOCKS_PER_MACROBLOCK-1) begin
                        Macroblock_Row <= Macroblock_Row + 1;
                        Macroblock_Col <= 6'h00;
                     end
                     if (Macroblock_Row == (Num_Macroblock_Rows - 1)) begin
                        if (Block_Counter == `BLOCKS_PER_MACROBLOCK-5) begin
									IDCT_Flags[1] <= 1'b0;
									Block_Ready <= 1'b0;
								end
                        if (Block_Counter == `BLOCKS_PER_MACROBLOCK-1) begin
                           IDCT_Flags[0] <= 1'b0;
                           out_state <= `PICTURE_DECODE_OUT_IDLE;
                        end 
                     end
                  end

                  if (~IDCT_Flags[0] & 
                        (Macroblock_Row == 'd0) & 
                        (Macroblock_Col == 'd0) & 
                        (Block_Counter == 'd5)) begin
                     IDCT_Flags[0] <= 1'b1;
                     Block_Counter <= 'd0;
                  end

						if (IDCT_Flags[0] & (Block_Counter == `BLOCKS_PER_MACROBLOCK-5)) begin
							Macroblock_in_Col <= Macroblock_in_Col + 1;
                  	if (Macroblock_in_Col == (Num_Macroblocks_per_Row - 1)) begin
                        Macroblock_in_Row <= Macroblock_in_Row + 1;
                        Macroblock_in_Col <= 6'h00;
                     end
                  end
                  
               end
            end
      endcase
   end
end

wire                 Block_Write_En;
wire     [5:0]       Block_Address;
wire     [11:0]      Block_Data;
wire                 Deq_Coeff_Buffer_Empty;
wire 						Coeff_Buffer_Reset;

assign Deq_Coeff_Buffer_Empty = Coeff_Buffer_Empty & ~Done_Slice_Decode;
assign Coeff_Buffer_Reset = Slice_Buffer_Write_En & Coeff_Buffer_Reset_Flag;

wire 					MB_Start_Predict;
wire 		[4:0]		Macroblock_Modes;
wire 					Prediction_Data_En;

Inverse_Quantisation Dequantiser(
   .resetn(picture_resetn),
   .clock(clock),
   .Intra_DC_Precision_I(Intra_DC_Precision_I),
   .Quant_Scale_Type_I(Quant_Scale_Type_I),
   .Alternate_Scan_I(Alternate_Scan_I),
	.Load_Seq_Intra_Quant_I(Load_Seq_Intra_Quant_I),
	.Load_Seq_NIntra_Quant_I(Load_Seq_NIntra_Quant_I),  
   .Coeff_Buffer_Empty_I(Deq_Coeff_Buffer_Empty),
   .Coeff_Buffer_En_O(Coeff_Buffer_En),
   .Coeff_Buffer_Address_O(Coeff_Buffer_Address),
   .Coeff_Buffer_Data_I(Coeff_Buffer_Data),
	.Coeff_Buffer_Reset_I(Coeff_Buffer_Reset),
	.Coeff_Buffer_Reset_Address_I(Slice_Buffer_Address),
   .Block_Retrieve_Ready_I(Block_Ready),
   .Block_Retrieve_Write_En_O(Block_Write_En),
   .Block_Retrieve_Address_O(Block_Address),
   .Block_Retrieve_Data_O(Block_Data),
   .Block_Retrieve_Waiting_O(Block_Waiting),
	.MB_Start_Predict_O(MB_Start_Predict),
	.Macroblock_Modes_O(Macroblock_Modes),
	.Prediction_Data_En_O(Prediction_Data_En)
);

wire     [8:0]       IDCT_Data;
wire                 IDCT_Valid;

IDCT IDCT_Pipe (
   .CLOCK_I(clock), 
   .RESETN_I(resetn),
   .FRAME_START_I(IDCT_Frame_Start),
   .WRITE_I(Block_Write_En),
   .ADDRESS_I(Block_Address),
   .DATA_I(Block_Data),
   .DATA_O(IDCT_Data),
   .DONE_O(IDCT_Done),
   .VALID_O(IDCT_Valid)
);

reg						Prediction_En;
wire 		[7:0] 		Prediction_Data;
reg 		[10:0]		Prediction_Address;
reg 		[8:0]			IDCT_Data_reg;
reg 						IDCT_valid_reg;

MB_Prediction Motion_Compensator(
	.resetn(picture_resetn),
	.clock(clock),
	.Start_MB_Predict_I(MB_Start_Predict),
	.Done_MB_Predict_O(),
	.Current_MB_Row_I({Macroblock_in_Row,4'h0}),
	.Current_MB_Column_I({Macroblock_in_Col,4'h0}),
	.F_Codes_I(F_Codes_I),
	.Picture_Type_I(Picture_Type_I),
	.Macroblock_Intra_I(Macroblock_Modes[0]),
	.Motion_Forward_I(Macroblock_Modes[3]),
	.Motion_Backward_I(Macroblock_Modes[2]),
	.Image_Horizontal_I(Image_Horizontal_I),  
	.Forward_Address_O(Forward_Framestore_Address_O),
	.Forward_Data_I(Forward_Framestore_Data_I),
	.Forward_Busy_I(Forward_Framestore_Busy_I),
	.Forward_Active_O(Forward_Framestore_Busy_O),
	.Backward_Address_O(Backward_Framestore_Address_O),
	.Backward_Data_I(Backward_Framestore_Data_I),
	.Backward_Busy_I(Backward_Framestore_Busy_I),
	.Backward_Active_O(Backward_Framestore_Busy_O),
	.Coeff_Data_En_I(Prediction_Data_En),
	.Coeff_Data_I(Coeff_Buffer_Data),
	.Prediction_Address_I(Prediction_Address),
	.Prediction_Data_O(Prediction_Data)
);

always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		Prediction_Address <= 11'h000;
		IDCT_Data_reg <= 9'h000;
		Prediction_En <= 1'b0;
	end else begin
		IDCT_valid_reg <= IDCT_Valid & IDCT_Flags[0];
		IDCT_Data_reg <= IDCT_Data;
		if (IDCT_Valid & IDCT_Flags[0]) begin
			if (Prediction_Address[9:0] == 10'd383) 
				Prediction_Address <= {~Prediction_Address[10],10'd0};
			else Prediction_Address <= Prediction_Address + 1;
		end
		if (
			Prediction_Data_En & 
			(Coeff_Buffer_Data[31:18] == `INFO_MACRO_MODES)  
		) Prediction_En <= ~Macroblock_Modes[0];
	end
end

wire 		[9:0] 		Mixed_Data;
wire 		[7:0] 		Clipped_Mixed_Data;

assign Mixed_Data = {IDCT_Data_reg[8],IDCT_Data_reg} +  
	{2'h0,Prediction_Data};
assign Clipped_Mixed_Data = (Mixed_Data[9]) ? 8'h00 : (Mixed_Data[8]) ? 8'hFF : Mixed_Data[7:0];

assign YUV_Data_O = Clipped_Mixed_Data;
assign YUV_Write_En_O = IDCT_valid_reg;
assign YUV_Start_O = ~IDCT_Flags[0]; 

reg [15:0] frame_counter;
always @(posedge clock or negedge resetn) begin
	if (~resetn) begin
		frame_counter <= 16'h0000;
	end else begin
		if (
			Done_Slice_Decode & 
			Start_Code_I & 
			~Slice_Start_Code_I &
			(in_state == `PICTURE_DECODE_IN_SLICE)
		) begin
			frame_counter <= frame_counter + 1;
		end
	end
end

endmodule
