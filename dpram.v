// Port of darfpga's modified version of Syntiac's Generic VHDL DPRAM module to Verilog
// by birdybro

`timescale 1ns/1ns

module dpram #(parameter dWidth = 8, parameter aWidth = 10)
(
    // Port A
    input  wire              clk_a,
    input  wire              we_a,
    input  wire [aWidth-1:0] addr_a,
    input  wire [dWidth-1:0] d_a,
    output reg  [dWidth-1:0] q_a,

    // Port B
    input  wire              clk_b,
    input  wire              we_b,
    input  wire [aWidth-1:0] addr_b,
    input  wire [dWidth-1:0] d_b,
    output reg  [dWidth-1:0] q_b,
);

// RAM Registers
reg [dWidth-1:0] ram [2 ** aWidth-1:0] /* synthesis ramstyle = "no_rw_check" */;
reg [aWidth-1:0] addr_a_reg;
reg [aWidth-1:0] addr_b_reg;

// Port A
always @(posedge clk_a) begin
    q_a <= ram[addr_a];
    if (we_a) begin
        ram[addr_a] <= d_a;
        q_a <= d_a;
    end
end

// Port B
always @(posedge clk_b) begin
    q_b <= ram[addr_b];
    if (we_b) begin
        ram[addr_b] <= d_b;
        q_b <= d_b;
    end
end

endmodule
