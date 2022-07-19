 
  MAC_MPEG2_AV - MPEG-2 hardware implementation for Xilinx multimedia board 
  Copyright (C) 2007 McMaster University
 
==============================================================================

stream_data.c
---------------------

This software is for streaming MPEG-2 files to the Xilinx multimedia board for 
the MAC_MPEG2_AV implementation.

Software version
---------------------

The software is tested using GCC 3.2 under SuSE Linux with 2.4.19 kernel. The
authors do not guarantee compatibility between software versions.

Compilation
---------------------

A Makefile is provided for compilation. Just type 'make' to create the binary.

Using the software
---------------------

Please be sure that root privilege is provided for the software to access the
Ethernet port on the PC. Best results are obtained if the following order is 
used:

1. Connect the PC to the board via an ethernet crossover cable
2. Power on and configure the board
3. Set user input 0 and 1 switches on the board to "ON" and "OFF" respectively
4. Set user input 1 to "OFF"
5. Start the software on the PC by typing: "stream_data <filename>"

To send a new file:
1. Terminate the executable
2. Set user input 1 to "ON"
3. Set user input 1 to "OFF"
4. Start the software

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
