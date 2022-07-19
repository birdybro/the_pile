 
  MAC_MPEG2_AV - MPEG-2 hardware implementation for Xilinx multimedia board 
  Copyright (C) 2007 McMaster University
 
==============================================================================

This file contains information regarding additional software not provided in
this release which has been/can be used with this project. Specific details 
(if any) are provided in accompanying .txt files.

RawEthernet - An application for sending raw packets from the ethernet port 
	under windows. Oringially developed by Jeremiah Clark and obtained from:
	http://www.codeproject.com/cs/internet/sendrawpacket.asp, this code has
	been adapted to support streaming to the ethernet port on the Xilinx board.
	
MPEG Video Validation Software - This code produced by the MPEG Software 
	Simulation Group (MSSG) has been used to provide validation data. It was 
	obtained at ftp://ftp.mpeg.org/pub/mpeg/mssg/mpeg2v12.zip, with descriptions
	provided at http://www.mpeg.org/MPEG/MSSG/#source. This software will have 
	to be modified by anyone who wishes to produce validation data for use with
	the testbenches for video.

MPEG Audio Validation Software - This code is a floating point implementation
	of MPEG audio coding, layers 1,2 and 3. The layer 2 portion was used as a 
	reference in this project to produce a 16- bit fixed point implementation.
	A random sampling of some clips has produced an SNR of ~90dB for our fixed 
	point implementation measured against the floating point one. The software
	was obtained from http://www.mp3-tech.org/programmer/sources/dist10.tgz with
	a description at http://www.mp3-tech.org/programmer/decoding.html. 
	
MPEG Transcoding Software - This software called "MediaCoder" proved very
	versatile and valuable in converting streams to MPEG-2 format for use in 
	testing and verifying our design. It was obtained from the "Downloads" 
	section of http://mediacoder.sourceforge.net/.  

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
