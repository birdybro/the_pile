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

module extend_CRC(
   next_CRC,
	extend_CRC
);

input  [31:0] 	next_CRC;
output [31:0] 	extend_CRC;

wire	 [31:0]	temp_CRC1, temp_CRC2, 
					temp_CRC3, temp_CRC4, 
					temp_CRC5, temp_CRC6, 
					temp_CRC7, temp_CRC8;

next_CRC CRC1 (.curr_CRC(next_CRC),  .data(4'h0), .next_CRC(temp_CRC1));
next_CRC CRC2 (.curr_CRC(temp_CRC1), .data(4'h0), .next_CRC(temp_CRC2));
next_CRC CRC3 (.curr_CRC(temp_CRC2), .data(4'h0), .next_CRC(temp_CRC3));
next_CRC CRC4 (.curr_CRC(temp_CRC3), .data(4'h0), .next_CRC(temp_CRC4));
next_CRC CRC5 (.curr_CRC(temp_CRC4), .data(4'h0), .next_CRC(temp_CRC5));
next_CRC CRC6 (.curr_CRC(temp_CRC5), .data(4'h0), .next_CRC(temp_CRC6));
next_CRC CRC7 (.curr_CRC(temp_CRC6), .data(4'h0), .next_CRC(temp_CRC7));
next_CRC CRC8 (.curr_CRC(temp_CRC7), .data(4'h0), .next_CRC(temp_CRC8));

assign extend_CRC = ~{  temp_CRC8[24], temp_CRC8[25], temp_CRC8[26], temp_CRC8[27],
                        temp_CRC8[28], temp_CRC8[29], temp_CRC8[30], temp_CRC8[31],
                        temp_CRC8[16], temp_CRC8[17], temp_CRC8[18], temp_CRC8[19], 
                        temp_CRC8[20], temp_CRC8[21], temp_CRC8[22], temp_CRC8[23], 
                        temp_CRC8[ 8], temp_CRC8[ 9], temp_CRC8[10], temp_CRC8[11], 
                        temp_CRC8[12], temp_CRC8[13], temp_CRC8[14], temp_CRC8[15], 
                        temp_CRC8[ 0], temp_CRC8[ 1], temp_CRC8[ 2], temp_CRC8[ 3],
                        temp_CRC8[ 4], temp_CRC8[ 5], temp_CRC8[ 6], temp_CRC8[ 7]}; 

endmodule            
