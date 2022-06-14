`timescale 1ns/1ns

// 
//  port of z8420.vhd to verilog by birdybro
// 
//  Zilog Z80PIO partiality compatible module
//  for MZ-80B on FPGA
// 
//  Port A : Output, mode 0 only
//  Port B : Input, mode 0 only
// 
//  Nibbles Lab. 2005-2014
// 

module z8420
(
    // System
    input        RST_n, // Only Power On Reset

    //Z80 Bus Signals
    input        CLK,
    input        ENA,
    input        BASEL,
    input        CDSEL,
    input        CE,
    input        RD_n,
    input        WR_n,
    input        IORQ_n,
    input        M1_n,
    input  [7:0] DI,
    output [7:0] DO,
    input        IEI,
    output       IEO,
    // output       INTA_n,
    output       INT_n,
    
    // Port
    output [7:0] A,
    input  [7:0] B
);

// Port Selector
wire SELAD;
wire SELBD;
wire SELAC;
wire SELBC;

// Port Register
reg  [7:0] AREG;  // Output Register (Port A)
reg  [7:0] DIRA;  // Data Direction (Port A)
wire       DDWA;  // Prepare for Data Direction (Port A)
reg  [7:0] IMWA;  // Interrupt Mask Word (Port A)
wire       MFA;   // Mask Follows (Port A)
reg  [7:0] VECTA; // Interrupt Vector (Port A)
reg  [1:0] MODEA; // Mode Word (Port A)
wire       HLA;   // High/Low (Port A)
wire       AOA;   // AND/OR (Port A)
reg  [7:0] DIRB;  // Data Direction (Port B)
wire       DDWB;  // Prepare for Data Direction (Port B)
reg  [7:0] IMWB;  // Interrupt Mask Word (Port B)
wire       MFB;   // Mask Follows (Port B)
reg  [7:0] VECTB; // Interrupt Vector (Port B)
reg  [1:0] MODEB; // Mode Word (Port B)
wire       HLB;   // High/Low (Port B)
wire       AOB;   // AND/OR (Port B)

// Interrupt
// wire       VECTENA;
wire       EIA;     // Interrupt Enable (Port A)
// reg  [7:0] MINTA;
// wire       INTA;
wire       VECTENB;
wire       EIB;     // Interrupt Enable (Port B)
reg  [7:0] MINTB;
wire       INTB;

// INT0 instantiation was originally commented out, if errors, disable it
// INT0 Interrupt
// (
//     // System Signal
//     .RESET(RST_n),

//     // CPU Signals
//     .DI(DI),
//     .IORQ_n(IORQ_n),
//     .RD_n(RD_n),
//     .M1_n(M1_n),
//     .IEI(IEI),
//     .IEO(IEO),
//     .INTO_n(INTA_n),

//     // Control Signals
//     .VECTEN(VECTENA),
//     .INTI(INTA),
//     .INTEN(EIA)
// );

INT1 Interrupt
(
    // System Signal
    .RESET(RST_n),

    // CPU Signals
    .DI(DI),
    .IORQ_n(IORQ_n),
    .RD_n(RD_n),
    .M1_n(M1_n),
    .IEI(IEI),
    .IEO(IEO),
    .INTO_n(INT_n), // INTB_n,

    // Control Signals
    .VECTEN(VECTENB),
    .INTI(INTB),
    .INTEN(EIB)
);

// Port select for Output
always @* begin : portSelect
    SELAD <= 0;
    SELBD <= 0;
    SELAC <= 0;
    SELBC <= 0;
    if (~BASEL && ~CDSEL) begin
        SELAD <= 1;
    end
    if (BASEL && ~CDSEL) begin
        SELBD <= 1;
    end
    if (~BASEL && CDSEL) begin
        SELAC <= 1;
    end
    if (BASEL && CDSEL) begin
        SELBC <= 1;
    end
end

// Output
always @(posedge CLK or posedge RST_n or posedge ENA) begin
    if (~RST_n) begin
        AREG  <= {8{8'b0}};
        MODEA <= 2'b01;
        DDWA  <= 0;
        MFA   <= 0;
        EIA   <= 0;
        // B <= {8{8'b0}};
        MODEB <= 2'b01;
        DDWB  <= 0;
        MFB   <= 0;
        EIB   <= 0;
    end else if (~CLK) begin
        if (ENA) begin
            if (~CE && ~WR_n) begin
                if (SELAD) begin
                    AREG <= DI;
                end
                // if (SELBD) begin
                //     B <= DI;
                // end else
                else if (SELAC) begin
                    if (DDWA) begin
                        DIRA <= DI;
                        DDWA <= 0;
                    end else if (MFA) begin
                        IMWA <= DI;
                        MFA  <= 0;
                    end else if (DI[0] == 0) begin
                        VECTA <= DI;
                    end else if (DI[3:0] == 4'b1111) begin
                        MODEA <= DI[7:6];
                        DDWA  <= (DI[7] && DI[6]);
                    end else if (DI[3:0] == 4'b0111) begin
                        MFA <= DI[4];
                        HLA <= DI[5];
                        AOA <= DI[6];
                        EIA <= DI[7];
                    end else if (DI[3:0] == 4'b0011) begin
                        EIA <= DI[7];
                    end
                end
                if (SELBC) begin
                    if (DDWB) begin
                        DIRB <= DI;
                        DDWB <= 0;
                    end else if (MFB) begin
                        IMWB <= DI;
                        MFB  <= 0;
                    end else if (DI[0] == 0) begin
                        VECTB <= DI;
                    end else if (DI[3:0] == 4'b1111) begin
                        MODEB <= DI[7:6];
                        DDWB  <= (DI[7] && DI[6]);
                    end else if (DI[3:0] == 4'b0111) begin
                        MFB <= DI[4];
                        HLB <= DI[5];
                        AOB <= DI[6];
                        EIB <= DI[7];
                    end else if (DI[3:0] == 4'b0011) begin
                        EIB <= DI[7];
                    end
                end
            end
        end
    end
end

assign A = AREG;

// Input Select
always @* begin
    if (~RD_n && ~CE && SELAD) begin
        DO <= AREG;
    end else if (~RD_n && ~CE && SELBD) begin
        DO <= B;
    // end else if (VECTENA) begin
    //     DO <= VECTA;
    end else if (VECTENB == 1'b1) begin
        DO <= VECTB;
    end
end

// Interrupt Select
genvar i;
generate 
    for (i = 0; i < 7; i = i + 1 ) begin : INTMASK
    //need to fill this in with equivalent
endgenerate

// assign INTA = AOA ? (MINTA[7] && MINTA[6] && MINTA[5] && MINTA[4] && MINTA[3] && MINTA[2] && MINTA[1] && MINTA[0]) :
//                     (MINTA[7] || MINTA[6] || MINTA[5] || MINTA[4] || MINTA[3] || MINTA[2] || MINTA[1] || MINTA[0]);

assign INTB = AOB ? (MINTB[7] && MINTB[6] && MINTB[5] && MINTB[4] && MINTB[3] && MINTB[2] && MINTB[1] && MINTB[0]) :
                    (MINTB[7] || MINTB[6] || MINTB[5] || MINTB[4] || MINTB[3] || MINTB[2] || MINTB[1] || MINTB[0]);

// To-Do
//     --
//     -- Interrupt select
//     --
//     INTMASK : for I in 0 to 7 generate
// --      MINTA(I)<=(A(I) xnor HLA) and (not IMWA(I)) when AOA='0' else
// --                   (A(I) xnor HLA) or IMWA(I);
//         MINTB(I)<=(B(I) xnor HLB) and (not IMWB(I)) when AOB='0' else
//                      (B(I) xnor HLB) or IMWB(I);
//     end generate INTMASK;

endmodule
