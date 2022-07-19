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

#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Backward_Prediction_Fetch/write_address_0
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Backward_Prediction_Fetch/write_address_1
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Backward_Prediction_Fetch/ref_write_data_0
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Backward_Prediction_Fetch/ref_write_data_1
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Backward_Prediction_Fetch/write_en_0
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Backward_Prediction_Fetch/write_en_1

#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Fwd_Buffer_Wen_0
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Fwd_Buffer_Addr_0
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Fwd_Buffer_Write_Data_0
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Fwd_Buffer_Read_Data_0
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Fwd_Buffer_Wen_1
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Fwd_Buffer_Addr_1
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Fwd_Buffer_Write_Data_1
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Fwd_Buffer_Read_Data_1

#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Bwd_Buffer_Wen_0
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Bwd_Buffer_Addr_0
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Bwd_Buffer_Write_Data_0
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Bwd_Buffer_Read_Data_0
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Bwd_Buffer_Wen_1
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Bwd_Buffer_Addr_1
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Bwd_Buffer_Write_Data_1
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Bwd_Buffer_Read_Data_1

add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Calculator/Prediction_Indicator_I	
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Calculator/Half_pel_flags

#add wave -radix hex Sequence_Decoder/Picture_Decoder/IDCT_Data
#add wave -radix hex Sequence_Decoder/Picture_Decoder/IDCT_Valid

add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Calculator/FWD_Data_0_I	
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Calculator/BWD_Data_0_I	
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Calculator/Prev_Data_0
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Calculator/Prev_Data_1

#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Calculator/Sum_Data_0
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Calculator/Sum_Data_1
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Calculator/AVG_Data_0
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Calculator/AVG_Data_1

#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Calculator/write_enable
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Calculator/write_address
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Calculator/write_data

#add wave -radix hex Sequence_Decoder/Picture_Decoder/Macroblock_Modes
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/prediction_indicator
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Start_MB_Predict_I
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Done_MB_Predict_O

#add wave -radix hex Sequence_Decoder/Picture_Decoder/Prediction_Address
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Prediction_Data
#add wave -radix hex Sequence_Decoder/Picture_Decoder/IDCT_valid_reg
#add wave -radix hex Sequence_Decoder/Picture_Decoder/IDCT_Data_reg 

#add wave -radix hex Sequence_Decoder/Picture_Decoder/Prediction_Data_En
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Clipped_Mixed_Data

add wave -radix hex Sequence_Decoder/Picture_Decoder/YUV_Address_O
add wave -radix hex Sequence_Decoder/Picture_Decoder/YUV_Data_O
add wave -radix hex Sequence_Decoder/Picture_Decoder/YUV_Write_En_O

#add wave -radix hex Sequence_Decoder/Picture_Decoder/YUV_Data_O
#add wave -radix hex Sequence_Decoder/YUV_Data_O
#add wave -radix hex YUV_Data

add wave -radix hex Bank_Select
add wave -radix hex Sequence_Decoder/framestore_select

add wave -radix hex Bank_1_Address
add wave -radix hex Bank_1_Read_data
add wave -radix hex Bank_1_Write_data
add wave -radix hex Bank_1_Write_en

add wave -radix hex Bank_2_Address
add wave -radix hex Bank_2_Read_data
add wave -radix hex Bank_2_Write_data
add wave -radix hex Bank_2_Write_en

add wave -radix hex Output_bank/Address
add wave -radix hex Output_bank/Read_data
add wave -radix hex Output_bank/Write_data
add wave -radix hex Output_bank/Write_en

add wave -radix hex Sequence_Decoder/Picture_Decoder/Macroblock_in_Row
add wave -radix hex Sequence_Decoder/Picture_Decoder/Macroblock_in_Col
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Current_MB_Row_I
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Current_MB_Column_I
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Fwd_Row_Offset
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Fwd_Column_Offset
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Bwd_Row_Offset
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Bwd_Column_Offset

add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/FWD_Vec_Reset
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/BWD_Vec_Reset
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/PMV_Reset
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Skipped_MB

add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Fwd_Buffer_Wen_0
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Fwd_Buffer_Wen_1
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Fwd_Buffer_Addr_0
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Fwd_Buffer_Addr_1	
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Fwd_Buffer_Write_Data_0
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Fwd_Buffer_Write_Data_1

add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Bwd_Buffer_Wen_0
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Bwd_Buffer_Wen_1
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Bwd_Buffer_Addr_0
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Bwd_Buffer_Addr_1	
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Bwd_Buffer_Write_Data_0
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Bwd_Buffer_Write_Data_1

add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Start_Update_I
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Done_Update_O
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/F_Codes_I
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/PMV_Reset_I
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Index_0_O
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Index_1_O
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Data_0_I
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Data_1_I
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Data_1_O
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Write_En_1_O
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/state
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/counter
add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Current_PMV

#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Prediction_Former/Current_PMV_I
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Prediction_Former/Delta_Sign_I
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Prediction_Former/Delta_Magnitude_I
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Prediction_Former/F_Code_I
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Prediction_Former/New_PMV_O
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Prediction_Former/Pre_range_PMV
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Prediction_Former/Range_small
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Prediction_Former/Range

#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Prediction_Former/adjust_up_check
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Prediction_Former/adjust_down_check

#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Prediction_Former/up_adjust
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Prediction_Former/down_adjust
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Prediction_Former/adjustment_value
#add wave -radix hex Sequence_Decoder/Picture_Decoder/Motion_Compensator/Prediction_Updater/Prediction_Former/adjusted_value
