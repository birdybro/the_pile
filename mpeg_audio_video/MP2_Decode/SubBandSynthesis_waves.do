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

add wave -radix hex Audio_Decoder/SubBandSynthesis_unit/window_write_data
add wave -radix hex Audio_Decoder/SubBandSynthesis_unit/window_address
add wave -radix hex Audio_Decoder/SubBandSynthesis_unit/window_write_en
add wave -radix hex Audio_Decoder/SubBandSynthesis_unit/sum
add wave -radix hex Audio_Decoder/SubBandSynthesis_unit/next_sum
add wave -radix hex Audio_Decoder/SubBandSynthesis_unit/zero
add wave -radix hex Audio_Decoder/SubBandSynthesis_unit/sign

add wave -radix hex Audio_Decoder/SubBandSynthesis_unit/state
add wave -radix hex Audio_Decoder/SubBandSynthesis_unit/k_count
add wave -radix hex Audio_Decoder/SubBandSynthesis_unit/i_count
add wave -radix hex Audio_Decoder/SubBandSynthesis_unit/sum_write
add wave -radix hex Audio_Decoder/SubBandSynthesis_unit/address_reg

add wave -radix hex Audio_Decoder/SubBandSynthesis_unit/Mult_OP_0_O
add wave -radix hex Audio_Decoder/SubBandSynthesis_unit/Mult_OP_1_O
add wave -radix hex Audio_Decoder/SubBandSynthesis_unit/Mult_Result_I

add wave -radix hex Audio_Decoder/SubBandSynthesis_unit/Sample_Data_O
add wave -radix hex Audio_Decoder/SubBandSynthesis_unit/Sample_Write_En_O
