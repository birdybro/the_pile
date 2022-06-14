// Port of darfpga's modified version of Syntiac's Generic VHDL DPRAM module to SystemVerilog
// by birdybro

`timescale 1ns/1ns

module dpram #(parameter dWidth = 8, parameter aWidth = 10)
(
    // Port A
    input  logic              clk_a,
    input  logic              we_a,
    input  logic [aWidth-1:0] addr_a,
    input  logic [dWidth-1:0] d_a,
    output logic [dWidth-1:0] q_a,

    // Port B
    input  logic              clk_b,
    input  logic              we_b,
    input  logic [aWidth-1:0] addr_b,
    input  logic [dWidth-1:0] d_b,
    output logic [dWidth-1:0] q_b,
);

// RAM Registers
logic [dWidth-1:0] ram [2 ** aWidth-1:0] /* synthesis ramstyle = "no_rw_check" */;
logic [aWidth-1:0] addr_a_reg;
logic [aWidth-1:0] addr_b_reg;

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
