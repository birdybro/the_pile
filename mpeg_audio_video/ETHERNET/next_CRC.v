// 
//  MAC_MPEG2_AV - MPEG-2 hardware implementation for Xilinx multimedia board 
//  Copyright (C) 2007 McMaster University
// 
//==============================================================================
// 
// This file is part of MAC_MPEG2_AV
// 
// MAC_MPEG2_AV is distributed in the hope that it will be useful for further 
// research, but WITHOUT ANY WARRANTY; without even the implied warranty of 
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. MAC_MPEG2_AV is free; you 
// can redistribute it and/or modify it provided that proper reference is provided 
// to the authors. See the documents included in the "doc" folder for further details.
//
//==============================================================================

module next_CRC(
   curr_CRC,
   data,
   next_CRC
);

input  [31:0] curr_CRC;
input  [3:0]  data;
output [31:0] next_CRC;

assign next_CRC = {  
	curr_CRC[27],
   curr_CRC[26],                      
	curr_CRC[25] ^ curr_CRC[31],                 
	curr_CRC[24] ^ curr_CRC[30],                 
	curr_CRC[23] ^ curr_CRC[29],                 
	curr_CRC[22] ^ curr_CRC[31] ^ curr_CRC[28],                 
	curr_CRC[21] ^ curr_CRC[31] ^ curr_CRC[30],            
	curr_CRC[20] ^ curr_CRC[30] ^ curr_CRC[29],            
	curr_CRC[19] ^ curr_CRC[29] ^ curr_CRC[28],            
	curr_CRC[18] ^ curr_CRC[28],                 
	curr_CRC[17], 
	curr_CRC[16], 
	curr_CRC[15] ^ curr_CRC[31],                 
	curr_CRC[14] ^ curr_CRC[30],                 
	curr_CRC[13] ^ curr_CRC[29],                 
	curr_CRC[12] ^ curr_CRC[28],                 
	curr_CRC[11] ^ curr_CRC[31],                 
	curr_CRC[10] ^ curr_CRC[31] ^ curr_CRC[30],            
	curr_CRC[ 9] ^ curr_CRC[31] ^ curr_CRC[30] ^ curr_CRC[29],       
	curr_CRC[ 8] ^ curr_CRC[30] ^ curr_CRC[29] ^ curr_CRC[28],       
	curr_CRC[ 7] ^ curr_CRC[31] ^ curr_CRC[29] ^ curr_CRC[28],       
	curr_CRC[ 6] ^ curr_CRC[31] ^ curr_CRC[30] ^ curr_CRC[28],       
	curr_CRC[ 5] ^ curr_CRC[30] ^ curr_CRC[29],            
	curr_CRC[ 4] ^ curr_CRC[31] ^ curr_CRC[29] ^ curr_CRC[28],       
	curr_CRC[ 3] ^ curr_CRC[31] ^ curr_CRC[30] ^ curr_CRC[28],       
	curr_CRC[ 2] ^ curr_CRC[30] ^ curr_CRC[29],            
	curr_CRC[ 1] ^ curr_CRC[31] ^ curr_CRC[29] ^ curr_CRC[28],       
	curr_CRC[ 0] ^ curr_CRC[31] ^ curr_CRC[30] ^ curr_CRC[28],       
	curr_CRC[31] ^ curr_CRC[30] ^ curr_CRC[29] ^ data[0],  
	curr_CRC[30] ^ curr_CRC[29] ^ curr_CRC[28] ^ data[1],  
	curr_CRC[29] ^ curr_CRC[28] ^ data[2],  
	curr_CRC[28] ^ data[3] };

endmodule            
