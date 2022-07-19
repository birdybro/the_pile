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

add wave -radix hex Audio_Decoder/state
add wave -radix hex Audio_Decoder/initial_fill
add wave -radix hex Audio_Decoder/read_seg
add wave -radix hex Audio_Decoder/read_seg_12
add wave -radix hex Audio_Decoder/write_seg
add wave -radix hex Audio_Decoder/sample_counter
add wave -radix hex Audio_Decoder/Sample_DP_full
add wave -radix hex Audio_Decoder/Sample_address
add wave -radix hex Audio_Decoder/Sample_wen

add wave -radix hex Audio_Decoder/ac97_module/sample_clock_en
add wave -radix hex Audio_Decoder/ac97_module/sample_clock_counter
add wave -radix hex Audio_Decoder/ac97_module/CH0_PCM_DATA_I
add wave -radix hex Audio_Decoder/ac97_module/CH1_PCM_DATA_I
add wave -radix hex Audio_Decoder/ac97_module/PCM_READ_ADVANCE_EN_I
add wave -radix hex Audio_Decoder/ac97_module/PCM_READ_ADDRESS_O
