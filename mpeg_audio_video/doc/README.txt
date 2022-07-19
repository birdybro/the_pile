 
  MAC_MPEG2_AV - MPEG-2 hardware implementation for Xilinx multimedia board 
  Copyright (C) 2007 McMaster University
 
==============================================================================

INTRODUCTION

This project provides a low-energy implementation of the MPEG-2 video decoding 
algorithm as well as the accompanying layer 2 audio decoder. It has been tested 
on the Xilinx multimedia board.

For the Xilinx multimedia implementation of MPEG-2, .mpg files are sent to the 
board via the Ethernet port using a software developed together with the project. 

===============================================================================

REQUIREMENTS

For the Xilinx implementation:

- Hardware:
-- Speakers
-- SVGA monitor
-- Xilinx multimedia board
-- Ethernet crossover cable
-- A Linux box with root privilege or:
	A PC running Windows XP with administrative rights

- Software:
-- Xilinx ISE

Detailed instructions on installation can be found in the README file in each
project folder.

===============================================================================

DIRECTORY STRUCTURE

/doc 
- contains the README.txt, documents about copyright and license issues.

/Additional_Software
- contains information on support software for this project not bundled within

/Ethernet_Software
- contains the both the linux and windows versions of the Ethernet 
  streaming software

/MPEG_Audio_Video
- Contains the Verilog code for the MAC_MPEG2_AV implementation on the Xilinx 
  Multimedia board, as well as the scripts for simulation using ModelSim.

/Validation_Data
- Contains a sample clip for simulation/on the board as well as some data files 
  for use in simulation, and a few software tools used for validation
  
/Xilinx_Flash
- Contains a SystemACE configuration for use with a Flash card for programming
  the Xilinx Multimedia Board on power-up

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
  
  If you have decided to further improve this work, please send your comments to:

      Nicola Nicolici <nicola@ece.mcmaster.ca>

  See also the home page on the Web:

      http://www.ece.mcmaster.ca/~nicola/cadt.html

===============================================================================
