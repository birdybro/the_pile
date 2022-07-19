 
  MAC_MPEG2_AV - MPEG-2 hardware implementation for Xilinx multimedia board 
  Copyright (C) 2007 McMaster University
 
==============================================================================

RawEthernet
---------------------

This software is for streaming MPEG-2 files to the Xilinx multimedia board for 
the MAC_MPEG2_AV implementation.

Software version
---------------------

The software was developed using Microsoft Visual Studio (Visual C#):

	Microsoft Visual Studio 2005
	Version 8.0.50727.42  (RTM.050727-4200)
	Microsoft .NET Framework
	Version 2.0.50727

	Installed Edition: Professional

	Microsoft Visual C# 2005   77626-009-0000007-41359

	Crystal Reports    AAC60-G0CSA4B-V7000AY
	Crystal Reports for Visual Studio 2005

Running Windows XP:

	Microsoft Windows XP
	Professional
	Version 2002
	Service Pack 2
	
	55274-OEM-0011903-00107

The authors do not guarantee compatibility between software versions.

The software has been adapted from the excellent RawEthernet software 
developed by Jeremiah Clark, which was obtained from: 
http://www.codeproject.com/cs/internet/sendrawpacket.asp

Compilation
---------------------

A pre-compiled binary is available in the distribution which can be used 
according to the procedure below. Otherwise, the provided project 
(in the /SendRawPacket folder) can be opened and built in Visual Studio.

Installing the Driver
---------------------

Under an account with administrative rights, install the NDIS driver provided.
You can install the NDIS Driver by opening your network adapter properties and 
clicking the "Install" button, selecting "Protocol", and then choosing 
"Have Disk". Then browse to the .inf file and click "OK". This will then load 
the driver onto every adapter that you have in your system.

Important - Make sure that it is enabled, there should be a check in the box 
next to "Raw Packet NDIS Protocol Driver".

Important - Open a command prompt and type "net start ndisprot" to start the 
driver service.

Using the software
---------------------

Be sure that an account with administrative rights is being used (as this is
the only way to have full access to the Ethernet port).  Follow the instructions 
provided in the /SendRawPacket/privilege is provided for the software to access 
the Ethernet port on the PC. Best results are obtained if the following order is 
used:

1. Connect the PC to the board via an ethernet crossover cable
2. Power on and configure the board
3. Set user input 0 and 1 switches on the board to "ON" and "OFF" respectively
4. Set user input 1 to "OFF"
5. Start the software on the PC by typing: "RawEthernet <filename>"
	note: you will have to select the adapter to which the Xilinx board is 
		   connected

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
