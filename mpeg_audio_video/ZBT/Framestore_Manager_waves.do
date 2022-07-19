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

#add wave -radix hex Shift_1_En
#add wave -radix hex Shift_8_En
#add wave -radix hex Sequence_Decoder/Shift_1_En_O
#add wave -radix hex Sequence_Decoder/Shift_8_En_O
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Shift_1_En_O
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Shift_8_En_O
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Shift_1_En_O
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Slice_Decoder/Shift_8_En_O

add wave -radix hex Sequence_Decoder/state
add wave -radix hex Sequence_Decoder/Picture_Done
add wave -radix hex Framestore_Manager/Picture_Start_I
add wave -radix hex Framestore_Manager/Picture_Type_I

add wave -radix unsigned Sequence_Decoder/Picture_Decoder/Macroblock_Row
add wave -radix unsigned Sequence_Decoder/Picture_Decoder/Macroblock_Col
                         
add wave -radix unsigned Framestore_Manager/Display_Write_Address
add wave -radix hex Framestore_Manager/Display_Write_Data
add wave -radix hex Framestore_Manager/Display_Write_En

add wave -radix hex Framestore_Manager/Prediction_pointer
add wave -radix hex Framestore_Manager/Display_pointer
add wave -radix hex Framestore_Manager/Display_Advance_O
add wave -radix hex Framestore_Manager/Backend_Frame_Advance_54
add wave -radix hex Framestore_Manager/Advance_Frame_Flag

add wave -radix hex Framestore_Manager/YUV_Write_En_I
add wave -radix hex Framestore_Manager/YUV_Write_Data_I

add wave -radix hex Framestore_Manager/Framestore0_Address_I
add wave -radix hex Framestore_Manager/Framestore0_Data_O
add wave -radix hex Framestore_Manager/Framestore0_Busy_O

add wave -radix hex Framestore_Manager/Framestore1_Address_I
add wave -radix hex Framestore_Manager/Framestore1_Data_O
add wave -radix hex Framestore_Manager/Framestore1_Busy_O

add wave -radix hex Framestore_Manager/Bank_0_Address_O
add wave -radix hex Framestore_Manager/Bank_1_Address_O
add wave -radix hex Framestore_Manager/Bank_2_Address_O
add wave -radix hex Framestore_Manager/Bank_3_Address_O

add wave -radix hex Framestore_Manager/Bank_0_Write_Data_O
add wave -radix hex Framestore_Manager/Bank_1_Write_Data_O
add wave -radix hex Framestore_Manager/Bank_2_Write_Data_O
add wave -radix hex Framestore_Manager/Bank_3_Write_Data_O

add wave -radix hex Framestore_Manager/Bank_0_Write_En_O
add wave -radix hex Framestore_Manager/Bank_1_Write_En_O
add wave -radix hex Framestore_Manager/Bank_2_Write_En_O
add wave -radix hex Framestore_Manager/Bank_3_Write_En_O

add wave -radix hex Framestore_Manager/Bank_0_Read_Data_I
add wave -radix hex Framestore_Manager/Bank_1_Read_Data_I
add wave -radix hex Framestore_Manager/Bank_2_Read_Data_I
add wave -radix hex Framestore_Manager/Bank_3_Read_Data_I

add wave -radix hex Bank_1_Address
add wave -radix hex Bank_1_Read_data
add wave -radix hex Bank_1_Write_data
add wave -radix hex Bank_1_Write_en
add wave -radix hex Bank_2_Address
add wave -radix hex Bank_2_Read_data
add wave -radix hex Bank_2_Write_data
add wave -radix hex Bank_2_Write_en
add wave -radix hex Bank_3_Address
add wave -radix hex Bank_3_Read_data
add wave -radix hex Bank_3_Write_data
add wave -radix hex Bank_3_Write_en
add wave -radix hex Bank_4_Address
add wave -radix hex Bank_4_Read_data
add wave -radix hex Bank_4_Write_data
add wave -radix hex Bank_4_Write_en

add wave -radix hex Framestore_Manager/backend_unit/v_synch
add wave -radix hex Framestore_Manager/backend_unit/column_count
add wave -radix hex Framestore_Manager/backend_unit/row_count
