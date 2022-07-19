`timescale 1 ns/ 100 ps

`include "defines.v"
`define DATA_WIDTH 16
`define ADDRESS_WIDTH 9

module ac97_ctr(
	BIT_CLOCK_I,
	SAMPLE_FREQUENCY_I,
	AC97_RESETN_I,
	SOURCE_SELECT_I,
	AC97_SYNCH_O,
	AC97_DATA_IN_I,
	AC97_DATA_OUT_O,
	AC97_BEEP_TONE_O,
	PCM_READ_ADVANCE_EN_I,
	PCM_READ_ADDRESS_O,
	CH0_PCM_DATA_I,
	CH1_PCM_DATA_I,
	STARTUP_O
);	

    input BIT_CLOCK_I;
	 input AC97_RESETN_I;
	 input [1:0] SAMPLE_FREQUENCY_I;
	 input SOURCE_SELECT_I;
    output AC97_SYNCH_O;
    input AC97_DATA_IN_I;
    output AC97_DATA_OUT_O;
    output AC97_BEEP_TONE_O;
    output STARTUP_O;
	 input [`DATA_WIDTH-1:0] CH0_PCM_DATA_I;
	 input [`DATA_WIDTH-1:0] CH1_PCM_DATA_I;
    input PCM_READ_ADVANCE_EN_I;
	 output [`ADDRESS_WIDTH-1:0] PCM_READ_ADDRESS_O;
	 
    wire AC97_SYNCH;
    reg  AC97_SYNCH_buffer, AC97_SYNCH_buffer_buffer;
    wire AC97_DATA_OUT;
    reg  AC97_codec_ready;

    // Serial Output register interface
    reg	[15:0]	out_slt0;
    reg	[19:0]	out_slt1;
    reg	[19:0]	out_slt2;
    reg	[19:0]	out_slt3;
    reg	[19:0]	out_slt4;

    // Serial Input register interface
    wire	[15:0]	in_slt0;
    wire	[19:0]	in_slt1;
    wire	[19:0]	in_slt2;
    wire	[19:0]	in_slt3;
    wire	[19:0]	in_slt4;

    // Serial IO Controller Interface
    wire	ld;
    wire	[4:0] out_le;
    reg [4:0] state;

	 reg [15:0] cur_sample_frequency;

	 wire pause_cnt;

	 reg [`ADDRESS_WIDTH-1:0] sample_counter;

	 parameter reset_reg_set = 1'b1;			// 0 = send setting to codec

	 parameter pc_beep_set = 1'b1;			// 0 = send setting to codec

	 parameter line_out_set = 1'b0;			// 0 = send setting to codec 02h
	 parameter line_out_mute = 1'b0;
	 parameter line_out_left = 5'h08;
	 parameter line_out_right = 5'h08;

	 parameter level_out_set = 1'b1;			// 0 = send setting to codec 04h
	 parameter level_mute = 1'b0;
	 parameter level_left = 5'h08;
	 parameter level_right = 5'h08;

	 parameter mono_out_set = 1'b1;			// 0 = send setting to codec 06h
	 parameter mono_mute = 1'b0;
	 parameter mono_left = 5'h08;
	 parameter mono_right = 5'h08;

	 parameter phone_volume_set = 1'b1;			// 0 = send setting to codec 0Ah
	 parameter phone_mute = 1'b0;
	 parameter phone_volume = 5'h08;

	 parameter mic_volume_set = 1'b0;			// 0 = send setting to codec 0Eh
	 parameter mic_mute = 1'b0;
	 parameter mic_volume = 5'h08;

	 parameter line_in_set = 1'b1;			// 0 = send setting to codec 10h
	 parameter line_in_mute = 1'b0;
	 parameter line_in_left = 5'h08;
	 parameter line_in_right = 5'h08;

	 parameter PCM_set = 1'b0;			// 0 = send setting to codec 18h
	 parameter PCM_mute = 1'b0;
	 parameter PCM_left = 5'h08;		// gain 00 = 12 dB thru PCM
	 parameter PCM_right = 5'h08;		// gain 08 = 0 db

		/*
		0 = mic
		1 = CD
		2 = Video
		3 = Aux
		4 = Line in
		5 = stereo mix
		6 = mono mix
		7 = phone
		*/

	 parameter record_select_set = 1'b0;			// 0 = send setting to codec 
	 parameter record_select_left = 3'h0; 			// change here for record source
	 parameter record_select_right = 3'h0;

	 parameter record_gain_set = 1'b0;			// 0 = send setting to codec
	 parameter record_gain_mute = 1'b0;
	 parameter record_gain_left = 4'h0;			// gain 0 = 0 db, f = 22.5 db
	 parameter record_gain_right = 4'h0;

	 parameter gp_set = 1'b1;			// 0 = send setting to codec
	 parameter gp_pop = 1'b0;		// PCM out path, 0 = pre3d, 1 = post 3d
	 parameter gp_3d = 1'b1;		// 3D: 1 = on
	 parameter gp_mix = 1'b0;		// mono out select: 0 = mix, 1 = mic
	 parameter gp_ms = 1'b0;		// mic select: 0 = mic1, 1 = mic2
	 parameter gp_LPBK = 1'b0;		// adc/dac loop back

 	 parameter extended_audio_set = 1'b0;
	 parameter variable_frequency = 1'b1;

	 parameter sample_set = 1'b0;
	 
	 //OBUF_F_12 BEEP_TONE_BUF (.O(AC97_BEEP_TONE_O), .I(1'b1));
	 assign AC97_BEEP_TONE_O = 1'b1;

    always @(posedge BIT_CLOCK_I or negedge AC97_RESETN_I)
    begin
    		if (AC97_RESETN_I == 1'b0) begin
			AC97_codec_ready <= 1'b0;
			AC97_SYNCH_buffer <= 1'b0;
			AC97_SYNCH_buffer_buffer <= 1'b0;
		end
    		else begin
			if (AC97_SYNCH_buffer_buffer == 1'b0 && AC97_SYNCH_buffer == 1'b1)
				AC97_codec_ready <= AC97_DATA_IN_I;						
			AC97_SYNCH_buffer <= AC97_SYNCH;
			AC97_SYNCH_buffer_buffer <= AC97_SYNCH_buffer;
		end
    end

    // check STARTUP signal
    //OBUF_F_12 STARTUP_BUF (.O(STARTUP_O), .I(AC97_RESETN_I));
	 assign STARTUP_O = AC97_RESETN_I;

	 always @ (state or SAMPLE_FREQUENCY_I) begin
	 	if (state <= 'd15) cur_sample_frequency <= 16'hBB80;
		else begin
			case (SAMPLE_FREQUENCY_I)
				`FREQUENCY_48K: cur_sample_frequency <= 16'hBB80;
				`FREQUENCY_44K: cur_sample_frequency <= 16'hAC44;
				`FREQUENCY_32K: cur_sample_frequency <= 16'h7D00;
				default: cur_sample_frequency <= 16'h1F40;
			endcase
		end
	 end

	 always @(posedge BIT_CLOCK_I or negedge AC97_RESETN_I)
    begin
    	if (AC97_RESETN_I == 1'b0) begin
			state <= 'd0;
			out_slt0 <= 0;
		end
    	else begin
  			if (AC97_SYNCH_buffer == 1'b0 && AC97_SYNCH == 1'b1) begin
				case (state)
		      'd0  : begin
			 		// wait for codec ready signal to 
					// start programming the AC97 registers
			    	out_slt1 <= {1'b1, 19'h00000};		 
			    	out_slt2 <= 20'h00000;		 
					if (AC97_codec_ready) state <= 'd1;	
		      end
				'd1: begin
					// reset register
					out_slt0 <= {1'b1, 2'b11, 2'b00, 11'h0 };
			    	out_slt1 <= {reset_reg_set, 7'h00, 12'h000};		 
			    	out_slt2 <= 20'h00000;

					state <= 'd2;	 
				end
				'd2: begin
					// set LINE_OUT master volume to 0dB attenuation
					out_slt0 <= {1'b1, 2'b11, 2'b00, 11'h0 };
			    	out_slt1 <= {line_out_set, 7'h02, 12'h000};		 
			    	out_slt2 <= {line_out_mute, 2'b00, line_out_left, 3'b000, line_out_right, 4'h0};		
	
					state <= 'd3;	 
				end
				'd3: begin
					// set LINE_LEVEL_OUT master volume to 0dB attenuation
					out_slt0 <= {1'b1, 2'b11, 2'b00, 11'h0 };
			    	out_slt1 <= {level_out_set, 7'h04, 12'h000};		 
			    	out_slt2 <= {level_mute, 2'b00, level_left, 3'b000, level_right, 4'h0};		

					state <= 'd4;	 
				end
				'd4: begin
					// set MONO_OUT master volume to 0dB attenuation
					out_slt0 <= {1'b1, 2'b11, 2'b00, 11'h0 };
			    	out_slt1 <= {mono_out_set, 7'h06, 12'h000};		 
			    	out_slt2 <= {level_mute, 2'b00, 4'h0, 3'b000, mono_right, 4'h0};		

					state <= 'd5;	 
				end
				'd5: begin
					// PC_beep volume
					out_slt0 <= {1'b1, 2'b11, 2'b00, 11'h0 };
			    	out_slt1 <= {pc_beep_set, 7'h0a, 12'h000};		 
			    	out_slt2 <= 20'h00000;

					state <= 'd6;	 
				end
				'd6: begin
					// phone volume
					out_slt0 <= {1'b1, 2'b11, 2'b00, 11'h0 };
			    	out_slt1 <= {phone_volume_set, 7'h0c, 12'h000};		 
			    	out_slt2 <= {phone_mute, 12'h000, phone_volume, 4'h0};		

					state <= 'd7;	 
				end
				'd7: begin
					// mic volume
					out_slt0 <= {1'b1, 2'b11, 2'b00, 11'h0 };
			    	out_slt1 <= {mic_volume_set, 7'h0e, 12'h000};		 
			    	out_slt2 <= {mic_mute, 12'h000, mic_volume, 4'h0};		

					state <= 'd8;	 
				end
				'd8: begin
					// line-in/CD/video/aux volume
					out_slt0 <= {1'b1, 2'b11, 2'b00, 11'h0 };
					// 10 = line in, 12 = CD, 14 = video, 16 = aux
			    	out_slt1 <= {line_in_set, 7'h10, 12'h000};		 
			    	out_slt2 <= {line_in_mute, 2'b00, line_in_left, 3'h0, line_in_right, 4'h0};		

					state <= 'd9;	 
				end
				'd9: begin
					// PCM volume
					out_slt0 <= {1'b1, 2'b11, 2'b00, 11'h0 };
					out_slt1 <= {PCM_set, 7'h18, 12'h000};		 
			    	out_slt2 <= {PCM_mute, 2'b00, PCM_left, 3'h0, PCM_right, 4'h0};		

					state <= 'd10;	 
				end
				'd10: begin
					// record select
					out_slt0 <= {1'b1, 2'b11, 2'b00, 11'h0 };
					out_slt1 <= {record_select_set, 7'h1a, 12'h000};		 
			    	out_slt2 <= {5'h00, record_select_left, 5'h00, record_select_right, 4'h0};		

					state <= 'd11;	 
				end
				'd11: begin
					// record gain
					out_slt0 <= {1'b1, 2'b11, 2'b00, 11'h0 };
					out_slt1 <= {record_gain_set, 7'h1c, 12'h000};		 
			    	out_slt2 <= {record_gain_mute, 3'b00, record_gain_left, 4'h0, record_gain_right, 4'h0};		
					
					state <= 'd12;	 
				end
				'd12: begin
					// general purpose
					out_slt0 <= {1'b1, 2'b11, 2'b00, 11'h0 };
					out_slt1 <= {gp_set, 7'h20, 12'h000};		 
			    	out_slt2 <= {gp_pop, 1'b0, gp_3d, 3'h0, gp_mix, gp_ms, gp_LPBK, 11'h000};
					
					state <= 'd13;	 
				end
				'd13: begin
					// power down/status
					out_slt0 <= {1'b1, 2'b11, 2'b00, 11'h0 };
					out_slt1 <= {1'd1, 7'h26, 12'h000};		 
			    	out_slt2 <= 20'h00000;
						 					
					state <= 'd14;	 
				end
				'd14: begin
					// extended_audio
					out_slt0 <= {1'b1, 2'b11, 2'b00, 11'h0 };
					out_slt1 <= {extended_audio_set, 7'h2a, 12'h000};		 
			    	out_slt2 <= {15'h0, variable_frequency};
					
					state <= 'd15;	 
				end
				'd15: begin
					// sampling frequency for DAC
					out_slt0 <= {1'b1, 2'b11, 2'b11, 11'h0 };
					out_slt1 <= {sample_set, 7'h2c, 12'h000};		 
			    	out_slt2 <= {4'h0, cur_sample_frequency};
					
					if (pause_cnt == 0) state <= 'd16;
				end

				'd16: begin
					// sampling frequency for ADC
					out_slt0 <= {1'b1, 2'b11, 2'b11, 11'h0 };
					out_slt1 <= {sample_set, 7'h32, 12'h000};		 
		    		out_slt2 <= {4'h0, cur_sample_frequency};

					if (pause_cnt == 0) state <= 'd15;	 
				end
				endcase
			end
		end
    end

	 always @(posedge BIT_CLOCK_I or negedge AC97_RESETN_I)
    begin
    	if (AC97_RESETN_I == 1'b0) begin
			out_slt3 <= 0;
			out_slt4 <= 0;
		end
    	else begin
  			if (AC97_SYNCH_buffer == 1'b1 && AC97_SYNCH == 1'b0) begin
				if (state < 'd15) begin
					out_slt3 <= 0;
					out_slt4 <= 0;
				end else begin
					// if user_input1 == 1, it will play sample data, else, it will play from mic
					if (SOURCE_SELECT_I == 1'b1) begin
						out_slt3 <= {CH0_PCM_DATA_I, 4'h0};
						out_slt4 <= {CH1_PCM_DATA_I, 4'h0};
					end
					else begin
						out_slt3 <= in_slt3;
						out_slt4 <= in_slt4;
					end			
				end
			end
		end
	end


	always @(posedge BIT_CLOCK_I or negedge AC97_RESETN_I)
   begin
    	if (AC97_RESETN_I == 1'b0) begin
//			sample_counter <= 10'd448;
			sample_counter <= 10'd0;
		end else begin
				if (state >= 'd15) begin
					if (AC97_SYNCH_buffer == 1'b0 && AC97_SYNCH == 1'b1) 
						if (PCM_READ_ADVANCE_EN_I)
							sample_counter <= sample_counter + 10'd1;
				end
//				end else sample_counter <= 10'd448;
		end
	end

	assign PCM_READ_ADDRESS_O = sample_counter;

    ac97_sout u0(
		.clk(BIT_CLOCK_I),
		.so_ld(ld),
		.slt0(out_slt0),
		.slt1(out_slt1),
		.slt2(out_slt2),
		.slt3(out_slt3),
		.slt4(out_slt4),
		.sdata_out(AC97_DATA_OUT)
		);

    ac97_sin u1(
		.clk(BIT_CLOCK_I),
		.out_le(out_le),
		.slt0(in_slt0),
		.slt1(in_slt1),
		.slt2(in_slt2),
		.slt3(in_slt3),
		.slt4(in_slt4),
		.sdata_in(AC97_DATA_IN_I)
		);

    ac97_soc u2(
    	.clk(BIT_CLOCK_I),
		.rst(AC97_RESETN_I),
		.sample_frequency(cur_sample_frequency),
		.sync(AC97_SYNCH),
		.out_le(out_le),
		.ld(ld),
		.pause_cnt(pause_cnt)
		);

   assign AC97_DATA_OUT_O = AC97_codec_ready && AC97_DATA_OUT;
   assign AC97_SYNCH_O = AC97_SYNCH;

endmodule
