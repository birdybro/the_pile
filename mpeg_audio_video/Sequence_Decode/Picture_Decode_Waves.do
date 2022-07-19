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

add wave Sequence_Decoder/Picture_Decoder/in_state
add wave Sequence_Decoder/Picture_Decoder/out_state

add wave Sequence_Decoder/Picture_Decoder/Start_Picture_Decode_I
add wave Sequence_Decoder/Picture_Decoder/Done_Picture_Decode_O

add wave Sequence_Decoder/Picture_Decoder/Slice_Buffer_Full
add wave Sequence_Decoder/Picture_Decoder/Coeff_Buffer_Empty
add wave Sequence_Decoder/Picture_Decoder/Slice_Buffer_Write_En

add wave -radix unsigned Sequence_Decoder/Picture_Decoder/Slice_Buffer_Address
add wave -radix unsigned Sequence_Decoder/Picture_Decoder/Coeff_Buffer_Address

add wave Sequence_Decoder/Picture_Decoder/Start_Slice_Decode
add wave Sequence_Decoder/Picture_Decoder/Done_Slice_Decode
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Start
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Done
#add wave Sequence_Decoder/Picture_Decoder/Slice_Shift_1_En
#add wave Sequence_Decoder/Picture_Decoder/Slice_Shift_8_En
#add wave Sequence_Decoder/Picture_Decoder/Start_Code_Upcoming_I

add wave -radix unsigned Sequence_Decoder/Picture_Decoder/out_state
add wave -radix unsigned Sequence_Decoder/Picture_Decoder/Block_Counter
add wave -radix unsigned Sequence_Decoder/Picture_Decoder/Macroblock_Row
add wave -radix unsigned Sequence_Decoder/Picture_Decoder/Macroblock_Col
add wave -radix unsigned Sequence_Decoder/Picture_Decoder/Wait_Counter

add wave -radix unsigned Sequence_Decoder/Picture_Decoder/IDCT_Frame_Start
add wave -radix unsigned Sequence_Decoder/Picture_Decoder/IDCT_Flags
