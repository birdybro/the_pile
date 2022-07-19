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

add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Start_Slice_Decode_I
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Done_Slice_Decode_O
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Data_In_I

add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Slice_Buffer_Value_O
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Slice_Buffer_Write_En_O
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Slice_Buffer_Full_I

add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/state
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/shift_counter
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Quantiser_Scale

add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Start
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Done
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Shift_En
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Buffer_Value
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Buffer_Write_En
