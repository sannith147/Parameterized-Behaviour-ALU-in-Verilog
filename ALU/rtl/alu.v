//==============================================================
// Project : Parameterized Behavioral ALU
// Author  : Sannith Adagoppula
// Description:
//   A parameterized N-bit Arithmetic Logic Unit (ALU)
//   implemented using behavioral modeling in Verilog.
//
// Features:
//   • Parameterizable data width
//   • 16 ALU operations
//   • Status Flags:
//       - Carry
//       - Negative
//       - Overflow
//       - Zero
//
//==============================================================

module alu #(
    parameter N = 16
)(
    //==========================================================
    // INPUTS
    //==========================================================
    input  [N-1:0] A,
    input  [N-1:0] B,
    input  [3:0]   opcode,

    //==========================================================
    // OUTPUTS
    //==========================================================
    output reg [N-1:0] result,
    output reg carry,
    output reg negative,
    output reg overflow,
    output reg zero
);

    //==========================================================
    // OPCODE DEFINITIONS
    //==========================================================
    localparam ADD    = 4'b0000;
    localparam SUB    = 4'b0001;
    localparam AND    = 4'b0010;
    localparam OR     = 4'b0011;
    localparam XOR    = 4'b0100;
    localparam XNOR   = 4'b0101;
    localparam NOT_A  = 4'b0110;
    localparam NOT_B  = 4'b0111;
    localparam INC_A  = 4'b1000;
    localparam DEC_A  = 4'b1001;
    localparam INC_B  = 4'b1010;
    localparam DEC_B  = 4'b1011;
    localparam LSHIFT = 4'b1100;
    localparam RSHIFT = 4'b1101;
    localparam PASS_A = 4'b1110;
    localparam PASS_B = 4'b1111;

    //==========================================================
    // Internal Registers
    // Extra bit is used to capture carry/borrow.
    //==========================================================
    reg [N:0] add;
    reg [N:0] sub;

    //==========================================================
    // Combinational ALU
    //==========================================================
    always @(*) begin

        // Default assignments
        result   = 0;
        carry    = 0;
        negative = 0;
        overflow = 0;
        zero     = 0;

        case (opcode)

        //======================================================
        // Arithmetic Operations
        //======================================================
        ADD : begin
            add      = {1'b0, A} + {1'b0, B};
            carry    = add[N];
            result   = add[N-1:0];
            overflow = (A[N-1] ~^ B[N-1]) &
                       (A[N-1] ^ result[N-1]);
        end

        SUB : begin
            sub      = {1'b0, A} - {1'b0, B};
            carry    = sub[N];
            result   = sub[N-1:0];
            overflow = (A[N-1] ^ B[N-1]) &
                       (A[N-1] ^ result[N-1]);
        end

        //======================================================
        // Bitwise Operations
        //======================================================
        AND   : result = A & B;
        OR    : result = A | B;
        XOR   : result = A ^ B;
        XNOR  : result = A ~^ B;
        NOT_A : result = ~A;
        NOT_B : result = ~B;

        //======================================================
        // Increment / Decrement
        //======================================================
        INC_A : begin
            add      = {1'b0, A} + 1'b1;
            carry    = add[N];
            result   = add[N-1:0];
            overflow = (A[N-1] ~^ 1'b0) &
                       (A[N-1] ^ result[N-1]);
        end

        DEC_A : begin
            sub      = {1'b0, A} - 1'b1;
            carry    = sub[N];
            result   = sub[N-1:0];
            overflow = (A[N-1] ^ 1'b0) &
                       (A[N-1] ^ result[N-1]);
        end

        INC_B : begin
            add      = {1'b0, B} + 1'b1;
            carry    = add[N];
            result   = add[N-1:0];
            overflow = (B[N-1] ~^ 1'b0) &
                       (B[N-1] ^ result[N-1]);
        end

        DEC_B : begin
            sub      = {1'b0, B} - 1'b1;
            carry    = sub[N];
            result   = sub[N-1:0];
            overflow = (B[N-1] ^ 1'b0) &
                       (B[N-1] ^ result[N-1]);
        end

        //======================================================
        // Shift Operations
        //======================================================
        LSHIFT : result = A << 1;
        RSHIFT : result = A >> 1;

        //======================================================
        // Pass Through Operations
        //======================================================
        PASS_A : result = A;
        PASS_B : result = B;

        default : result = 0;

        endcase

        //======================================================
        // Common Status Flags
        //======================================================
        negative = result[N-1];
        zero     = ~|result;

    end

endmodule