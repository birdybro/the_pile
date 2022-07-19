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

add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/state
add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/counter
add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/sb_limit_flag
add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/shift_disable

add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/Alloc_index_i_O
add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/Alloc_index_j_O
add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/Alloc_bits_I	
add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/Table_Enable_I
add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/Table_Address_I
add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/Table_Data_O
add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/ROM_Enable_O
add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/ROM_Address_O
add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/ROM_Data_I
add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/RAM_Wen_O
add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/RAM_Address_O
add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/RAM_Data_I
add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/RAM_Data_O

add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/shift_counter
add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/bit_alloc_reg
add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/scfsi_reg
add wave -radix hex Audio_Decoder/Decode_Bitalloc_Scale_unit/write_enable
