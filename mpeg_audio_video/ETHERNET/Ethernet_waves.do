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

add wave -radix hex MPEG_decoder/Ethernet_unit/initial_fill_flag
add wave -radix hex MPEG_decoder/Ethernet_unit/partial_fill_flag
add wave -radix hex MPEG_decoder/Ethernet_unit/ZBT_Write_en_O
add wave -radix hex MPEG_decoder/Ethernet_unit/ZBT_Address_O
add wave -radix hex MPEG_decoder/Ethernet_unit/same_segment
add wave -radix hex MPEG_decoder/Ethernet_unit/init_counter
add wave -radix hex MPEG_decoder/Ethernet_unit/init_ready
add wave -radix hex MPEG_decoder/Ethernet_unit/request_burst
add wave -radix hex MPEG_decoder/Ethernet_unit/ZBT_busy
add wave -radix hex MPEG_decoder/Ethernet_unit/ZBT_ready
add wave -radix hex MPEG_decoder/Ethernet_unit/ETH_active
add wave -radix hex MPEG_decoder/Ethernet_unit/System_shift
add wave -radix hex MPEG_decoder/Ethernet_unit/System_empty

add wave -radix hex MPEG_decoder/Ethernet_unit/ZBT_buffer_interface/In_Buffer_Full
add wave -radix hex MPEG_decoder/Ethernet_unit/ZBT_buffer_interface/Out_Buffer_Empty
add wave -radix hex MPEG_decoder/Ethernet_unit/ZBT_buffer_interface/ZBT_Address_O
add wave -radix hex MPEG_decoder/Ethernet_unit/ZBT_buffer_interface/In_Buffer_Write_En
add wave -radix hex MPEG_decoder/Ethernet_unit/ZBT_buffer_interface/In_Buffer_Address
add wave -radix hex MPEG_decoder/Ethernet_unit/ZBT_buffer_interface/Out_Buffer_Address

add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Shift_8_En_O
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/System_Buffer_Empty_I
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Bitstream_Data_I
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Video_Empty_O
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Video_Shift_1_En_I
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Video_Shift_8_En_I
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Video_Byte_Allign_O
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Video_Data_O
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Audio_Shift_En_I
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Audio_Shift_Busy_O
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Audio_Byte_Allign_O
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Audio_Data_O
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/parse_mode
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/state
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/counter
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/parse_end
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/start_code
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/pack_start_code
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/video_start_code
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/audio_start_code
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/video_write 
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/audio_write
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/video_full 
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/audio_full

############################################

add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_Address_O
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_Write_Data_O
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_Write_En_O

add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/In_Buffer_Full
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_to_ZBT_Empty
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/In_Buffer_Address
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/In_Buffer_Write_En
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/In_Buffer_Data
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_to_ZBT_Address
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_to_ZBT_Data

add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/ZBT_Address_O
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/ZBT_Write_Data_O
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/ZBT_Write_En_O
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/ZBT_Read_Data_I

add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/ZBT_Write_Address
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/ZBT_Read_Address
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/ZBT_Full
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/ZBT_Empty

add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/ZBT_read_en
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/ZBT_read_en_reg
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/ZBT_to_Video_Address
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/ZBT_to_Video_Write_En
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/ZBT_to_Video_Data

add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/ZBT_to_Video_Full
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Out_Buffer_Empty
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/ZBT_to_Video_Address
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/ZBT_to_Video_Write_En
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/ZBT_to_Video_Data
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Out_Buffer_Address
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Out_Buffer_Data

add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_Shift_1_En_I
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_Shift_8_En_I
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Buffer_Empty_O
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_Data_O
add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_Byte_Allign_O

#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_to_ZBT_Buffer/in_clock
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_to_ZBT_Buffer/out_clock
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_to_ZBT_Buffer/Address_A_I
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_to_ZBT_Buffer/Write_Enable_A_I
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_to_ZBT_Buffer/Data_A_I
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_to_ZBT_Buffer/Enable_B_I
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_to_ZBT_Buffer/Address_B_I
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_to_ZBT_Buffer/Data_B_O

#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_to_ZBT_Buffer/System_Buffer_RAM_L/DOB
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_to_ZBT_Buffer/System_Buffer_RAM_L/ADDRA
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_to_ZBT_Buffer/System_Buffer_RAM_L/ADDRB
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_to_ZBT_Buffer/System_Buffer_RAM_L/DIA
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_to_ZBT_Buffer/System_Buffer_RAM_L/ENB
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/AV_External_Buffer/Video_Bitstream_unit/Video_to_ZBT_Buffer/System_Buffer_RAM_L/WEA

############################################

#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Audio_Bitstream_Buffer/In_Buffer_Full 
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Audio_Bitstream_Buffer/Out_Buffer_Empty 
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Audio_Bitstream_Buffer/In_Buffer_Address
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Audio_Bitstream_Buffer/In_Buffer_Write_En
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Audio_Bitstream_Buffer/Out_Buffer_Address

#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Video_Bitstream_Buffer/In_Buffer_Full 
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Video_Bitstream_Buffer/Out_Buffer_Empty 
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Video_Bitstream_Buffer/In_Buffer_Address
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Video_Bitstream_Buffer/In_Buffer_Write_En
#add wave -radix hex MPEG_decoder/Ethernet_unit/System_Parser_unit/Video_Bitstream_Buffer/Out_Buffer_Address

add wave -radix hex MPEG_decoder/sequence_start_count
add wave -radix hex MPEG_decoder/Video_start
add wave -radix hex MPEG_decoder/Audio_start

#add wave -radix hex MPEG_decoder/Sequence_Decoder/Picture_Decoder/Start_Picture_Decode_I
#add wave -radix hex MPEG_decoder/Sequence_Decoder/Picture_Decoder/Done_Picture_Decode_O
#add wave -radix hex MPEG_decoder/Sequence_Decoder/Picture_Decoder/active
#add wave -radix hex MPEG_decoder/Sequence_Decoder/Picture_Decoder/counter
#add wave -radix hex MPEG_decoder/Sequence_Decoder/Picture_Decoder/Shift_1_En_O
#add wave -radix hex MPEG_decoder/Sequence_Decoder/Picture_Decoder/Shift_8_En_O
#add wave -radix hex MPEG_decoder/Sequence_Decoder/Picture_Decoder/Slice_Start_Code_I
#add wave -radix hex MPEG_decoder/Sequence_Decoder/Picture_Decoder/Start_Code_I

#add wave -radix hex MPEG_decoder/Sequence_Decoder/Advance_Frame_I
#add wave -radix hex MPEG_decoder/Sequence_Decoder/Headers_Start
#add wave -radix hex MPEG_decoder/Sequence_Decoder/Headers_Done
#add wave -radix hex MPEG_decoder/Sequence_Decoder/Bitstream_Data_I

#add wave -radix hex MPEG_decoder/Audio_Sync_AtoV
#add wave -radix hex MPEG_decoder/Audio_Sync_VtoA

#add wave -radix hex MPEG_decoder/Audio_Decoder/Sample_wen
#add wave -radix hex MPEG_decoder/Audio_Decoder/Sample_address
#add wave -radix hex MPEG_decoder/Audio_Decoder/PCM_read_address
