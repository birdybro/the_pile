//
// port of Interrupt.vhd to verilog by birdybro
//
// Z80 Daisy-Chain Interrupt Logic for FPGA
//
// Nibbles Lab. 2013-2014
//

module Interrupt
(
    // System Signal
    input        RESET,  // : in  std_logic;
    // CPU Signals
    input  [7:0] DI,     // : in  std_logic_vector(7 downto 0);
    input        IORQ_n, // : in  std_logic; -- same as Z80
    input        RD_n,   // : in  std_logic; -- same as Z80
    input        M1_n,   // : in  std_logic; -- same as Z80
    input        IEI,    // : in  std_logic; -- same as Z80
    output       IEO,    // : out std_logic; -- same as Z80
    output       INTO_n, // : out std_logic;
    // Control Signals
    output       VECTEN, // : out std_logic;
    input        INTI,   // : in  std_logic;
    input        INTEN   // : in  std_logic
);

wire IREQ;
wire IRES;
wire INTR;
wire IAUTH;
wire AUTHRES;
wire IED1;
wire IED2;
wire ICB;
wire I4D;
wire FETCH;
wire INTA;
wire IENB;
wire iINT;
wire iIEO;

// External Signals
assign INTO_n = iINT;
assign IEO = iIEO;

// Internal Signals
assign iINT    = (IEI && IREQ && ~IAUTH) ? 0 : 1;
assign iIED    = (((!IED1) && IREQ) || IAUTH || (!IEI));
assign INTA    = ((!M1_n) && (!IORQ_n) && IEI);
assign AUTHRES = RESET || (IEI && IED2 && I4D);
assign FETCH   = M1_n || RD_n;
assign IRES    = RESET || INTA;
assign INTR    = M1_n && (INTI && INTENT);
assign VECTEN  = (INTA && IEI && IAUTH) ? 1 : 0;

// Keep Interrupt Request
always @(IRES or INTR) begin
    if (IRES) begin
        IREQ <= 0;
    end else if (INTR) begin
        IREQ <= 1;
    end
end

// Interrupt Authentication
always @(AUTHRES or INTA) begin
    if (AUTHRES) begin
        IAUTH <= 0;
    end else if (INTA) begin
        IAUTH <= IREQ;
    end
end

// Fetch 'RETI'
always @(RESET or FETCH) begin
    if (RESET) begin
        IED1 <= 0;
        IED2 <= 0;
        ICB <= 0;
        I4D <= 0;
    end else if (FETCH) begin
        IED2 <= IED1;
        if ((DI == 'hED) && ~ICB) begin
            IED1 <= 1;
        else
            IED1 <= 0;
        end else if (DI == 'hCB) begin
            ICB <= 1;
        else
            ICB <= 0;
        end else if (DI == 'h4D) begin
            I4D <= IEI;
        else
            I4D <= 0;
        end
    end
end



endmodule
