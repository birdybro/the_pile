## 
##  MAC_MPEG2_AV - MPEG-2 hardware implementation for Xilinx multimedia board 
##  Copyright (C) 2007 McMaster University
## 
##==============================================================================
## 
## This file is part of MAC_MPEG2_AV
## 
## MAC_MPEG2_AV is distributed in the hope that it will be useful for further 
## research, but WITHOUT ANY WARRANTY; without even the implied warranty of 
##	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. MAC_MPEG2_AV is free; you 
## can redistribute it and/or modify it provided that proper reference is provided 
## to the authors. See the documents included in the "doc" folder for further details.
##
##==============================================================================

add wave Sequence_Decoder/Picture_Decoder/Start_Slice_Decode
add wave Sequence_Decoder/Picture_Decoder/Done_Slice_Decode
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Start
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Done

add wave -radix unsigned Sequence_Decoder/Picture_Decoder/in_state
add wave -radix unsigned Sequence_Decoder/Picture_Decoder/out_state
add wave -radix unsigned Sequence_Decoder/Picture_Decoder/Block_Counter
add wave -radix unsigned Sequence_Decoder/Picture_Decoder/Macroblock_Row
add wave -radix unsigned Sequence_Decoder/Picture_Decoder/Macroblock_Col
add wave -radix unsigned Sequence_Decoder/Picture_Decoder/Wait_Counter

add wave -radix unsigned Sequence_Decoder/Picture_Decoder/IDCT_Frame_Start
add wave -radix unsigned Sequence_Decoder/Picture_Decoder/IDCT_Flags

add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Buffer_Address
add wave Sequence_Decoder/Picture_Decoder/Slice_Buffer_Write_En

add wave Sequence_Decoder/Picture_Decoder/Dequantiser/Coeff_Buffer_Empty_I

add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Coeff_Buffer_Address
add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Coeff_Buffer_Address_Offset
add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Coeff_Buffer_Address_O
add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Coeff_Buffer_Data_I
add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Coeff_Buffer_Data

add wave Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Retrieve_Ready_I
#add wave Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Retrieve_Write_En_O
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Retrieve_Address_O
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Retrieve_Data_O
add wave Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Retrieve_Waiting_O

add wave Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Deq_Start
add wave Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Deq_Done
add wave Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Deq_Adv_Coeff

add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Macroblock_Address
add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Macroblock_Count
add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/block_count
add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/state
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/MB_skip_flag

#add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Dequantiser/state_counter
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Dequantiser/Quant_Intermediate 
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Dequantiser/Quant_Scale_Val
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Dequantiser/Quant_Scale 
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Dequantiser/Coeff_Level
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Dequantiser/Coeff_Mult_Data 
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Dequantiser/Scale_x_Data_result 
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Dequantiser/Quant_Scan_Data
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Dequantiser/Scale_x_Data_x_Weight_result
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Dequantiser/Scale_x_Data_x_Weight_Rounded
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Dequantiser/Scale_x_Data_x_Weight_Saturated
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Dequantiser/Block_Retrieve_Write_En_O
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Dequantiser/Block_Dequantiser/Block_Retrieve_Data_O
