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

vlog  -sv Sequence_Decode/Slice_Decode/Table_B1toB15.v
vlog  -sv Sequence_Decode/Slice_Decode/Block_Decode_Coeffs.v
vlog  -sv Sequence_Decode/Slice_Decode/Block_Decode_DC_Coeff.v
vlog  -sv Sequence_Decode/Slice_Decode/Block_Decode.v
vlog  -sv Sequence_Decode/Slice_Decode/Vector_Decode.v
vlog  -sv Sequence_Decode/Slice_Decode/Macroblock_Decode.v
vlog  -sv Sequence_Decode/Slice_Decode/Macroblock_Decode_Addr.v
vlog  -sv Sequence_Decode/Slice_Decode/Macroblock_Decode_Modes.v
vlog  -sv Sequence_Decode/Slice_Decode/Macroblock_Decode_Vectors.v
vlog  -sv Sequence_Decode/Slice_Decode/Macroblock_Decode_CBP.v
vlog  -sv Sequence_Decode/Slice_Decode/Slice_Decode.v

vlog  -sv Sequence_Decode/Inverse_Quantisation/Quant_Scan_ROM.v
vlog  -sv Sequence_Decode/Inverse_Quantisation/Block_Inverse_Quantisation.v
vlog  -sv Sequence_Decode/Inverse_Quantisation/Inverse_Quantisation.v

vlog  -sv Sequence_Decode/Motion_Compensation/MB_Fetch_Prediction.v
vlog  -sv Sequence_Decode/Motion_Compensation/MC_Prediction_Buffer.v
vlog  -sv Sequence_Decode/Motion_Compensation/Prediction_Update.v
vlog  -sv Sequence_Decode/Motion_Compensation/New_Prediction.v
vlog  -sv Sequence_Decode/Motion_Compensation/Completed_Prediction_Buffer.v
vlog  -sv Sequence_Decode/Motion_Compensation/MB_Prediction_Calculate.v
vlog  -sv Sequence_Decode/Motion_Compensation/Pred_Calc_Addr_Gen.v
vlog  -sv Sequence_Decode/Motion_Compensation/MB_Prediction.v

vlog  -sv Sequence_Decode/IDCT/bram.v
vlog  -sv Sequence_Decode/IDCT/multiplier.v
vlog  -sv Sequence_Decode/IDCT/idct.v

vlog  -sv Sequence_Decode/Coeff_Buffer.v
vlog  -sv Sequence_Decode/Header_Decode.v
vlog  -sv Sequence_Decode/Picture_Decode.v
vlog  -sv Sequence_Decode/Sequence_Decode.v

vlog  -sv ETHERNET/Bitstream_Parser/Bitstream_Buffer.v
vlog  -sv ETHERNET/Bitstream_Parser/ZBT_bitstream.v
vlog  -sv ETHERNET/Bitstream_Parser/System_Buffer.v
vlog  -sv ETHERNET/Bitstream_Parser/AV_Bitstream.v
vlog  -sv ETHERNET/Bitstream_Parser/Audio_ZBT_Bitstream.v
vlog  -sv ETHERNET/Bitstream_Parser/Video_ZBT_Bitstream.v
vlog  -sv ETHERNET/Bitstream_Parser/System_Parser.v

vlog	-sv backend/SVGA_TIMING.v
vlog	-sv backend/tb_backend.v
vlog	-sv ZBT/ZBT_Video_Interface.v
vlog	-sv ZBT/Framestore_Management.v

vlog  -sv ETHERNET/tb_ETH_ZBT_emulator.v
vlog  -sv Sequence_Decode/tb_Sequence_Decode.v

vsim -voptargs="+acc" -t 1ps -L xilinxcorelib_ver -L unisims_ver -lib work tb_Sequence_Decode glbl

view wave

add wave clock
add wave resetn
add wave Start_Sequence_Decode
add wave Advance_Frame

add wave skip_shift_en
add wave slice_skip_en
add wave picture_counter
add wave slice_skip_count
add wave picture_code
add wave slice_code
add wave -radix hex Bitstream_Data
add wave -radix hex Sequence_Decoder/Bitstream_Data_I

#do {Sequence_Decode/Slice_Decode/Slice_Decode_Waves.do}
#do {Sequence_Decode/Slice_Decode/Macroblock_Decode_Waves.do}
#do {Sequence_Decode/Inverse_Quantisation/Inverse_Quantisation_Waves.do}
#do {Sequence_Decode/Picture_Decode_Waves.do}
#do {Sequence_Decode/Motion_Compensation/MB_Prediction_waves.do}
#do {ZBT/Framestore_Manager_waves.do}

run -all
