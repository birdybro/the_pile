 
  MAC_MPEG2_AV - MPEG-2 hardware implementation for Xilinx multimedia board 
  Copyright (C) 2007 McMaster University
 
==============================================================================

MAC_MPEG2_AV
---------------------

This design uses the "stream_data" software to send MPEG-2 files to the Xilinx
multimedia board through the Ethernet port from a Linux or Windows machine.

Software version
---------------------

The software for transferring MPEG-2 files via Ethernet is tested using GCC 3.2
under SuSE Linux with 2.4.19 kernel. The hardware implementation is developed
using Xilinx ISE Release version 8.1.03i Application version I.27. 

The testbenches and the script files for simulation are developed and tested 
using Modelsim SE PLUS 6.2c, using the simulation library obtained from Xilinx 
ISE Release version 8.1.03i Application version I.27. 

The authors do not guarantee compatibility between software versions.

Running the simulation
---------------------

The simluation script files are contained in this directory:

"do tb_MPEG_Audio_Video.do" will simulate the entire design
"do tb_MPEG_Audio_Video_fill.do" will emulate the flow of data through
	the front end (the Ethernet and Parsers)
"do tb_Sequence_Decode.do" will simulate just the video decoder
"do tb_MP2_Decode_16.do" will simulate just the audio decoder

Compiling stream_data for sending MPEG-2 files via Ethernet
---------------------

A Makefile is provided for compilation. Just type 'make' to create the binary.
Refer to the README.txt file in the appropriate Ethernet_Software subfolder 
(Linux/Windows) for more details.

Compiling the design
---------------------

A project file is provided for compiling the design using Xilinx ISE. Users can
refer to any documentation from Xilinx to compile and program the design onto
the board.

Using the design
---------------------

After the source code is compiled and the board is programmed, user can start
transferring MPEG-2 files to the board for decoding. Refer to the README.txt 
file in the appropriate Ethernet_Software subfolder (Linux/Windows) for info
on transfering files. Make sure that all the switches (user input 0,1 and
pal/NTSC and component/S-video) are in the "OFF" position (toward the bottom of 
the board). User switch 0 is the master reset, toggle to reset the decoder, but 
it must be in the "OFF" position in order for the decoder to work.

===============================================================================

COPYRIGHT AND AUTHORS

  Please read the `LICENSE.txt' file for copyright and warranty information.
  Also, the file `CREDITS.txt' contains contributors and acknowledgment.

  The main developer is Adam Kinsman, under the supervision of Nicola Nicolici. 
  If you are using this design, please cite the following work:
  
@techreport{cite-key,
	Author = {Kinsman, Adam B. and Nicolici, Nicola},
	Institution = {McMaster University, Canada},
	Title = {{MAC\_MPEG2\_AV: A Low Energy Implementation of an Audio/Video Decoder}},
	Url = {http://www.ece.mcmaster.ca/~nicola/cadt.html},
	Year = {2007}}
  
  If you have decided to further improve this work, please send your 
  comments to:

      Nicola Nicolici <nicola@ece.mcmaster.ca>

  See also the home page on the Web:

      http://www.ece.mcmaster.ca/~nicola/cadt.html

===============================================================================
