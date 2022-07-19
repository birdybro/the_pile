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

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <linux/if_packet.h>
#include <linux/if_ether.h>
#include <linux/if_arp.h>

#include <stdio.h>
#include <stdlib.h>

#define packet_size 1024

int main(int argc, char *argv[])
{
	int i, j, k;
	long int data_length, range_begin, range_end, pad_flag;
	long int total_length, num_packets, last_packet_length;
	long int recv_length, req_ID = 0;
	int s; // socketdescriptor
	char temp_str[3];
	FILE *infile;

	if (argc < 2) {
		printf("Usage: stream_data <mpeg file>\n");
		exit(1);
	}   

	s = socket(AF_PACKET, SOCK_RAW, htons(ETH_P_ALL));

	if (s == -1) printf("Cannot open socket ...\n");

	struct sockaddr_ll socket_address;						
	void* buffer = (void*)malloc(ETH_FRAME_LEN);			// ethernet send frame buffer
	void* recv_buffer = (void*)malloc(ETH_FRAME_LEN);	// ethernet recieve frame buffer
	unsigned char* etherhead = buffer;						// pointer to ethenet header
	unsigned char* data = buffer + 12;						// userdata in ethernet frame
	unsigned char* recv_data = recv_buffer;				// userdata in received ethernet frame
	struct ethhdr *eh = (struct ethhdr *)etherhead;	
	int send_result = 0;

	unsigned char src_mac[6] = {0x00, 0x01, 0x02, 0xFA, 0x70, 0xAA};	// our MAC address
	unsigned char dest_mac[6] = {0x5F, 0x43, 0xD4, 0xEA, 0x7B, 0x13};	// other host MAC address

	socket_address.sll_family   = PF_PACKET;	
	socket_address.sll_protocol = htons(ETH_P_IP);	
	socket_address.sll_ifindex  = 2;

	socket_address.sll_hatype   = ARPHRD_ETHER;			// ARP hardware identifier is ethernet
	socket_address.sll_pkttype  = PACKET_OTHERHOST;		// target is another host
	socket_address.sll_halen    = ETH_ALEN;				// address length

	socket_address.sll_addr[0]  = 0x00;					// MAC - begin
	socket_address.sll_addr[1]  = 0x04;		
	socket_address.sll_addr[2]  = 0x75;
	socket_address.sll_addr[3]  = 0xC8;
	socket_address.sll_addr[4]  = 0x28;
	socket_address.sll_addr[5]  = 0xE5;					// MAC - end

	socket_address.sll_addr[6]  = 0x00;					// not used
	socket_address.sll_addr[7]  = 0x00;					// not used

	/*set the frame header*/
	memcpy((void*)buffer, (void*)dest_mac, ETH_ALEN);
	memcpy((void*)(buffer+ETH_ALEN), (void*)src_mac, ETH_ALEN);
	eh->h_proto = 0x00;

	if ((infile = fopen(argv[1], "rb")) == NULL) {
		printf("Problem with file %s\n", argv[1]);
		exit(0);
	}

	range_end = -1;
	req_ID = -1;
	pad_flag = 0;

	while (pad_flag < 2*1024*1024) {
		// wait for request packet
		printf("Waiting for request ");
		if (req_ID != -1) printf("- (%d) ", req_ID);  
		fflush(NULL);

		do {
			while ((recv_length = recvfrom(s, recv_buffer, 1514, 0, NULL, NULL)) < 0);	          

//printf("\ncaptured length = %d, waiting for ID %d\n", recv_length, req_ID);
//for (i = 0; i < 6; i++) printf("%x ", recv_data[i]); printf("\n");
//for (i = 6; i < 12; i++) printf("%x ", recv_data[i]); printf("\n");
//for (i = 12; i < 14; i++) printf("%x ", recv_data[i]);	   
//for (i = 0; i < 64; i++) printf("%x ", recv_data[i]);	   
//for (i = 6; i < 14; i++) printf("%x ", recv_data[i]);	   
//for (i = 20; i < 24; i++) printf("%x ", recv_data[i]);	   
//printf("\n-------------------------------------------------------\n");

		} while (!(
			(recv_data[6] == dest_mac[0]) &&
			(recv_data[7] == dest_mac[1]) &&
			(recv_data[8] == dest_mac[2]) &&
			(recv_data[9] == dest_mac[3]) &&
			(recv_data[10] == dest_mac[4]) &&
			(recv_data[11] == dest_mac[5]) &&

			(
				(recv_data[14] == (unsigned char)((req_ID >>  8) & 0x000000FF)) &&
				(recv_data[15] == (unsigned char)((req_ID >>  0) & 0x000000FF))
			) || ((recv_data[14] == 0) && (recv_data[15] == 0))
		)); 

//if ((recv_data[14] == 0) && (recv_data[15] == 0)) req_ID = 0;

//printf("captured length = %d\n", recv_length);
//for (i = 0; i < 64; i++) printf("%x ", recv_data[i]);	   
//for (i = 6; i < 16; i++) printf("%x ", recv_data[i]);	   
//for (i = 20; i < 24; i++) printf("%x ", recv_data[i]);	   
//printf(" - expect %x\n-------------------------------------------------------\n", req_ID);

		if ((recv_data[14] == 0) && (recv_data[15] == 0)) {
			printf("\n--- Reset request received, re-opening file ---\n");
			req_ID = 0;
			fclose(infile);
			if ((infile = fopen(argv[1], "rb")) == NULL) {
				printf("Problem with file %s\n", argv[1]);
				exit(0);
			}
		} else req_ID = (recv_data[14] << 8) | recv_data[15];

		// send 1024 packets
		printf("Received ID %d, Sending burst\n", req_ID);
		for (i = 0; i < num_packets; i++) {
			num_packets = 1024;
			data_length = packet_size/4;   // number of 32 bit words to be sent = number of addresses

			if (i == num_packets-1) {
//				printf("Request ID %d - ", req_ID);
				req_ID++;
			}

			// Type
			data[0] = (unsigned char)((req_ID >> 8) & 0x000000FF);
			data[1] = (unsigned char)((req_ID >> 0) & 0x000000FF);

			// Range begin
			range_begin = range_end + 1;
			data[2] = (range_begin >> 16) & 0xFF;
			data[3] = (range_begin >> 8) & 0xFF;
			data[4] = range_begin & 0xFF;

			// Range end
			range_end = range_begin + data_length - 1;
			data[5] = (range_end >> 16) & 0xFF;
			data[6] = (range_end >> 8) & 0xFF; 
			data[7] = range_end & 0xFF;        

			// read packet data
			for (j = 0; j < 4*data_length; j++)    	      
				if (feof(infile)) {
					data_length = j/4;
					if (j % 4) data_length++;
					if (data_length < 16) data_length = 16;
					for (k = j; k < 4*data_length; k++) data[k+8] = 0x00;
					req_ID++;
					data[0] = (unsigned char)((req_ID >> 8) & 0x000000FF);
					data[1] = (unsigned char)((req_ID >> 0) & 0x000000FF);
					range_end = range_begin + data_length - 1;
					data[5] = (range_end >> 16) & 0xFF;
					data[6] = (range_end >> 8) & 0xFF; 
					data[7] = range_end & 0xFF;        
					j = 4*data_length-1;
					i = num_packets-1;

					// restart the file
					printf("\n--- End of file reached - re-opening ---\n");
					fclose(infile);
					if ((infile = fopen(argv[1], "rb")) == NULL) {
						printf("Problem with file %s\n", argv[1]);
						exit(0);
					}
				} else fscanf(infile, "%c", &(data[j+8]));
			}
   	   
			// send the packet
			do {
				send_result = sendto(s, buffer, 4*data_length+20, 0, 
					(struct sockaddr*)&socket_address, sizeof(socket_address));
			} while (send_result == -1);
		}
	}
	fclose(infile);
}
