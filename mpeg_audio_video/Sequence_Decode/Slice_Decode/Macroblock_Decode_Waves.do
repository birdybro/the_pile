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

add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Start_Macroblock_Decode_I
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Done_Macroblock_Decode_O

add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Data_In_I
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Shift_En_O

#add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Y_Predictor_I
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Cb_Predictor_I
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Cr_Predictor_I

#add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Update_Y_Predictor_O
#add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Update_Cb_Predictor_O
#add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Update_Cr_Predictor_O

add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Buffer_Value_O
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Buffer_Write_En_O

add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/state
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/cc

add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Vectors_Start
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Vectors_Done
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Vector_Decoder/Coeff_Table_En_O
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Vector_Decoder/Coeff_Table_Addr_O
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Vector_Decoder/Coeff_Table_Data_I
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Vector_Decoder/state
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Vector_Decoder/R
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Vector_Decoder/S
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Vector_Decoder/T
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Vector_Decoder/motion_vert_field_sel
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Vector_Decoder/Vector_Start
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Vector_Decoder/Vector_Shift
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Vector_Decoder/Vector_Code_Valid
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Vector_Decoder/Vector_Symbol
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Vector_Decoder/motion_residual

add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Block_Start
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Addr_Start
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Modes_Start

add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Macroblock_Address_Increment

add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Block_Done
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Block_Shift_En
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Addr_Done
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Addr_Shift_En
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Modes_Done
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Modes_Shift_En

add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Addr_Symbol
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Modes_Symbol

add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Block_Counter
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Block_DC_predictor
add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Block_New_DC_predictor
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Block_Update_DC_predictor
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Block_Luma_Chroma_Sel

add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Block_Buffer_Value
add wave Sequence_Decoder/Picture_Decoder/Slice_Decoder/Macroblock_Decoder/Block_Buffer_Write_En
