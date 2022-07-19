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

vlog  -sv ETHERNET/Bitstream_Parser/System_Buffer.v
vlog  -sv ETHERNET/Bitstream_Parser/AV_Bitstream.v
vlog  -sv ETHERNET/Bitstream_Parser/System_Parser.v
vlog  -sv ETHERNET/Bitstream_Parser/Video_ZBT_Bitstream.v
vlog  -sv ETHERNET/Bitstream_Parser/Audio_ZBT_Bitstream.v

vlog  -sv ETHERNET/Bitstream_Parser/Bitstream_Buffer.v
vlog  -sv ETHERNET/Bitstream_Parser/ZBT_bitstream.v

vlog  -sv Sequence_Decode/Header_Decode.v
vlog  -sv Sequence_Decode/Sequence_Decode.v

vlog  -sv ETHERNET/ETH_stream_interface.v
vlog	-sv ETHERNET/ETH_ZBT_interface.v

vlog	-sv ZBT/ZBT_connections.v
vlog	-sv ZBT/ZBT_bank_connections.v
vlog	-sv ZBT/ZBT_Video_Interface.v
vlog	-sv ZBT/Framestore_Management.v

vlog	-sv backend/SVGA_TIMING.v

vlog  -sv ETHERNET/tb_ETH_controller.v
vlog  -sv CLOCKGEN/tb_CLOCKGEN.v
vlog	-sv backend/tb_backend.v

vlog  -sv tb_Picture_Decode_fill.v
vlog  -sv tb_MP2_Decode_16_fill.v

vlog  -sv MPEG_audio_video.v
vlog  -sv tb_MPEG_Audio_Video_fill.v

vsim -voptargs="+acc" -t 1ps -L xilinxcorelib_ver -L unisims_ver -lib work tb_MPEG_Audio_Video glbl

view wave

add wave MPEG_decoder/internal_ZBT_clock
add wave MPEG_decoder/internal_video_clock
add wave MPEG_decoder/audio_decoder_clock
add wave MPEG_decoder/resetn

do {ETHERNET/Ethernet_waves.do}

run -all
