 
  MAC_MPEG2_AV - MPEG-2 hardware implementation for Xilinx multimedia board 
  Copyright (C) 2007 McMaster University
 
==============================================================================

Ethernet Software
---------------------

This folder contains software is for streaming MPEG-2 files to the Xilinx 
multimedia board for the MAC_MPEG2_AV implementation. Both linux and windows
versions have been provided. The windows version is based on code by Jeremiah 
Clark, which was obtained from: 
http://www.codeproject.com/cs/internet/sendrawpacket.asp

Using the software
---------------------

Be sure that the four switches: user input 0,1 and pal/ntsc and 
composite/s-video are set to the "OFF" position (toward the bottom of the 
board). Toggle user input 0 (ON then OFF) to reset the board. Specific 
instructions for each platform are provided in the README.txt in each folder.

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
