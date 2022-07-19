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

add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/state
add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/sample_counter
add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/state_counter
add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/shift_counter

add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/RAM_Address_O
add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/RAM_Data_I
add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/RAM_Wen_O
add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/RAM_Data_O

add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/bit_alloc_reg
add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/Alloc_index_i_O
add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/Alloc_index_j_O
add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/Alloc_steps_MSB_I
add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/Alloc_steps_I
add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/Alloc_bits_I
add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/Alloc_group_I
add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/Alloc_quant_I

add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/c_sample_reg
add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/c_div_lev
add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/temp1

add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/multiple_address
add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/c_address
add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/d_address

add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/Mult_OP_0_O
add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/Mult_OP_1_O
add wave -radix hex Audio_Decoder/Buffer_Deq_Denorm_unit/Mult_Result_I
