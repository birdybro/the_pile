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

.main clear
vmap XilinxCoreLib_ver C:/Xilinx/verilog/mti_se/XilinxCoreLib_ver
vmap unisims_ver C:/Xilinx/verilog/mti_se/unisims_ver
vlib work

vlog  -sv "C:/Xilinx/verilog/src/glbl.v"

vlog  -sv MP2_Decode/Bitalloc_Table.v
vlog  -sv MP2_Decode/Const_ROM_Sample_RAM.v
vlog  -sv MP2_Decode/Decode_Bitalloc_Scale.v
vlog  -sv MP2_Decode/Buffer_Deq_Denorm.v
vlog  -sv MP2_Decode/Window_Buffer_RAM.v
vlog  -sv MP2_Decode/SubBandSynthesis.v
vlog  -sv MP2_Decode/Header_Decode.v
vlog  -sv MP2_Decode/MP2_Decode_16.v

vlog  -sv ETHERNET/Bitstream_Parser/Bitstream_Buffer.v
vlog  -sv ETHERNET/Bitstream_Parser/ZBT_bitstream.v
vlog  -sv ETHERNET/Bitstream_Parser/System_Buffer.v
#vlog  -sv ETHERNET/Bitstream_Parser/Audio_bitstream.v
#vlog  -sv ETHERNET/Bitstream_Parser/Video_bitstream.v
vlog  -sv ETHERNET/Bitstream_Parser/AV_Bitstream.v
vlog  -sv ETHERNET/Bitstream_Parser/Audio_ZBT_Bitstream.v
vlog  -sv ETHERNET/Bitstream_Parser/Video_ZBT_Bitstream.v
vlog  -sv ETHERNET/Bitstream_Parser/System_Parser.v

vlog  -sv ETHERNET/tb_ETH_ZBT_emulator.v
vlog	-sv AC97/tb_ac97_emulator.v
vlog  -sv MP2_Decode/tb_MP2_Decode_16.v

vsim -voptargs="+acc" -t 1ps -L xilinxcorelib_ver -L unisims_ver -lib work tb_MP2_Decode_16 glbl

view wave

add wave clock
add wave resetn
add wave Audio_start

add wave -radix hex Audio_data
add wave -radix hex Audio_byte_allign
add wave -radix hex Audio_shift_busy
add wave -radix hex Audio_shift

add wave Audio_Decoder/Header_done
add wave Audio_Decoder/DBS_done
add wave Audio_Decoder/BDD_done
add wave Audio_Decoder/Synth_done

add wave -radix hex Audio_Decoder/Scale_block
add wave -radix hex Audio_Decoder/Synth_counter

#do {MP2_Decode/Decode_Bitalloc_Scale_waves.do}
#do {MP2_Decode/Buffer_Deq_Denorm_waves.do}
#do {MP2_Decode/SubBandSynthesis_waves.do}
#do {MP2_Decode/AC97_waves.do}

run -all
