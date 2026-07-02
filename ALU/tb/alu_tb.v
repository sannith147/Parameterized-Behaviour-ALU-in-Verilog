//==============================================================
// Testbench : Parameterized Behavioral ALU
//
// Description:
//   Directed self-checking testbench developed to verify the
//   functionality of a parameterized N-bit behavioral ALU.
//   The testbench applies representative test vectors,
//   automatically reports PASS/FAIL results, and generates
//   waveforms for analysis using GTKWave.
//
//==============================================================

module alu_tb;

parameter N = 16;

//==============================================================
// Opcode Definitions
//==============================================================
localparam ADD     = 4'b0000;
localparam SUB     = 4'b0001;
localparam AND_OP  = 4'b0010;
localparam OR_OP   = 4'b0011;
localparam XOR_OP  = 4'b0100;
localparam XNOR_OP = 4'b0101;
localparam NOT_A   = 4'b0110;
localparam NOT_B   = 4'b0111;
localparam INC_A   = 4'b1000;
localparam DEC_A   = 4'b1001;
localparam INC_B   = 4'b1010;
localparam DEC_B   = 4'b1011;
localparam LSHIFT  = 4'b1100;
localparam RSHIFT  = 4'b1101;
localparam PASS_A  = 4'b1110;
localparam PASS_B  = 4'b1111;

//==============================================================
// Testbench Signals
//==============================================================
reg  [N-1:0] A;
reg  [N-1:0] B;
reg  [3:0]   opcode;

wire [N-1:0] result;
wire carry;
wire negative;
wire overflow;
wire zero;

//==============================================================
// Statistics
//==============================================================
integer total_pass = 0;
integer total_fail = 0;

//==============================================================
// Device Under Test (DUT)
//==============================================================
alu #(.N(N)) uut(
    .A(A),
    .B(B),
    .opcode(opcode),
    .result(result),
    .carry(carry),
    .negative(negative),
    .overflow(overflow),
    .zero(zero)
);

//==============================================================
// Waveform Dump
//==============================================================
initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, alu_tb);
end

//==============================================================
// Reusable Test Task
//==============================================================
task run_test;

input [N-1:0] test_A;
input [N-1:0] test_B;
input [3:0]   test_opcode;
input [N-1:0] expected;

begin

    A      = test_A;
    B      = test_B;
    opcode = test_opcode;

    #10;

    if(result === expected) begin

        total_pass = total_pass + 1;

        $display(
        "PASS | OPCODE=%b | A=%h | B=%h | RESULT=%h",
        opcode, A, B, result);

    end

    else begin

        total_fail = total_fail + 1;

        $display(
        "FAIL | OPCODE=%b | A=%h | B=%h | EXPECTED=%h | GOT=%h",
        opcode, A, B, expected, result);

    end

end

endtask

//==============================================================
// Test Cases
//==============================================================
initial begin

//---------------------------
// Addition
//---------------------------
run_test(16'd10,   16'd5,    ADD,    16'd15);
run_test(16'hFFFF, 16'd1,    ADD,    16'd0);
run_test(16'h7FFF, 16'd1,    ADD,    16'h8000);
run_test(16'd0,    16'd0,    ADD,    16'd0);

//---------------------------
// Subtraction
//---------------------------
run_test(16'd20,   16'd10,   SUB,    16'd10);
run_test(16'd5,    16'd10,   SUB,    16'hFFFB);
run_test(16'h8000, 16'd1,    SUB,    16'h7FFF);

//---------------------------
// Logical Operations
//---------------------------
run_test(16'hAAAA, 16'h5555, AND_OP, 16'h0000);
run_test(16'hAAAA, 16'h5555, OR_OP,  16'hFFFF);
run_test(16'hAAAA, 16'h5555, XOR_OP, 16'hFFFF);
run_test(16'hAAAA, 16'h5555, NOT_A,  16'h5555);
run_test(16'hAAAA, 16'h5555, NOT_B,  16'hAAAA);

//---------------------------
// Shift Operations
//---------------------------
run_test(16'h000F, 16'd0, LSHIFT, 16'h001E);
run_test(16'h000F, 16'd0, RSHIFT, 16'h0007);

//---------------------------
// Increment / Decrement
//---------------------------
run_test(16'hFFFF, 16'd0, INC_A, 16'd0);
run_test(16'h0000, 16'd0, DEC_A, 16'hFFFF);
run_test(16'd0,    16'hFFFF, INC_B, 16'd0);
run_test(16'd0,    16'h0000, DEC_B, 16'hFFFF);

//---------------------------
// Pass Operations
//---------------------------
run_test(16'h1234, 16'h5678, PASS_A, 16'h1234);
run_test(16'h1234, 16'h5678, PASS_B, 16'h5678);

//==============================================================
// Simulation Summary
//==============================================================
$display("");
$display("======================================");
$display("TOTAL PASS : %0d", total_pass);
$display("TOTAL FAIL : %0d", total_fail);
$display("======================================");

$finish;

end

endmodule