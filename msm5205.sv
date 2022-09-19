// https://console5.com/techwiki/images/f/f8/MSM5205.pdf

module msm5205
(
    input  logic       clk,           // Prefer 384kHz or 768kHz / pin 16 / XT
    input  logic       reset,         // Active high, synced with vck, reset takes effect if high for 2x vck
    input  logic [1:0] sample_select, // If clk=384kHz then 00 = 4kHz, 01 = 6 kHz, 10 = 8kHz, 11 = x, 768kHz clk can double
    input  logic       adpcm_select,  // 4B/3B - Selects whether 4-bit (1) or 3-bit (0) ADPCM
    input  logic [3:0] data_in,       // Data Inputs - if 3-bit ADPCM, di[0] is GND'd
    output logic [9:0] audio_out,     // Original was one pin, typically sent directly into an LPF, more bits maybe needed
    output logic       out_vck,       // Frequency equal to sampling frequency selected by sample_select
    output logic       out_clk        // clk output / pin 17 / XT
);

always_ff @(posedge clk) if (~adpcm_select) data_in[0] <= 0;

// clock counter for use in timing
logic [1:0] clk_cnt;
always_ff @(posedge clk) begin
    if (reset) clk_cnt <= 0;
    else clk_cnt <= clk_cnt + 1;
end

// reset timing, internal reset only valid if held high for more than 2 clk cycles
logic reset_trig;
always_ff @(posedge clk) begin
    reset_trig <= 0;
    if (reset) begin
        if (clk_cnt > 2) reset_trig <= 1;
    end
end

// setup sample frequency
logic sample_freq;
always_comb begin
    case (sample_select)
        2'b00   : sample_freq = clk / 96;
        2'b01   : sample_freq = clk / 64;
        2'b10   : sample_freq = clk / 48;
        default : sample_freq = 0;
    endcase
end

// Take 4 internal inputs and send them to adpcm synth, outputs to 12-bits afterwards
logic [11:0] adpcm_synth;

// take adpcm synth 12-bit output send to 12-bit shift register

// take the 10-bit output of the 12-bit shift register and send it to DAOUT

always_ff @(posedge clk) if (reset_trig) audio_out <= 0;

endmodule
