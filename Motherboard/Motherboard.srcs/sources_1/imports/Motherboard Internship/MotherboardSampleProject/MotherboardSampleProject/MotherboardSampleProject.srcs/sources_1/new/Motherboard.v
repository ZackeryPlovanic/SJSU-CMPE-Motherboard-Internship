`timescale 1ns / 1ps
`default_nettype none

//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/25/2017 05:38:31 PM
// Design Name:
// Module Name: Motherboard
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module CLOCK_GENERATOR #(parameter DIVIDE = 2)
(
    input  wire rst,
    input  wire fast_clk,
    output reg  slow_clk
);

reg [31:0] counter = 0;

always @(posedge fast_clk or posedge rst)
begin
    if(rst)
        begin
            slow_clk <= 0;
            counter <= 0;
        end
    else
        begin
            if(counter == DIVIDE/2)
                begin
                    slow_clk <= ~slow_clk;
                    counter <= 0;
                end
            else
                begin
                    slow_clk <= slow_clk;
                    counter <= counter + 1;
                end
        end
end
endmodule

module Motherboard #(parameter CLOCK_DIVIDER = 100)
(
    //// input 100 MHz clock
    input  wire        clk100Mhz,
    input  wire        rst,
    input  wire        enc_phase_a, enc_phase_b,enc_switch,
    output wire [7:0] led
);

// ==================================
//// Internal Parameter Field
// ==================================
parameter ROM_SIZE      = 32'h400/4;
`define ROM_PC_RANGE    ($clog2(ROM_SIZE)+2):2
// ==================================
//// Wires
// ==================================
//// Clock Signals
wire cpu_clk;
//// CPU Signals
wire [31:0] AddressBus, DataBus;
wire [31:0] ProgramCounter, ALUResult, RegOut1, RegOut2, RegWriteData, RegWriteAddress;
wire [31:0] Instruction;
wire [3:0]  MemWrite;
wire        MemRead, BusCycle;
//// Address Decoding Signals
wire        cs_io;

wire [3:0]  io_addr_dec_out;
wire        full_addr_dec_out, MemWriteEnable;
wire        cs_input0, cs_input1, cs_output0, cs_output1;
wire        quad_rst;
// ==================================
//// Wire Assignments
// ==================================
// ==================================
//// Modules
// ==================================
CLOCK_GENERATOR #(
    .DIVIDE                     (CLOCK_DIVIDER)
) clock (
    .rst                        (rst),
    .fast_clk                   (clk100Mhz),
    .slow_clk                   (cpu_clk)
);

ROM #(
    .LENGTH                     (ROM_SIZE),
    .WIDTH                      (32),
    .FILE_NAME                  ("rom.mem")
) rom (         
    .a                          (ProgramCounter[`ROM_PC_RANGE]),
    .out                        (Instruction)
);

MIPS mips(
    .clk                        (cpu_clk),
    .rst                        (rst),
    .BusCycle                   (BusCycle),
    .MemWrite                   (MemWrite),
    .MemRead                    (MemRead),
    .AddressBus                 (AddressBus),
    .DataBus                    (DataBus),
    .ProgramCounter             (ProgramCounter),
    .ALUResult                  (ALUResult),
    .RegOut1                    (RegOut1),
    .RegOut2                    (RegOut2),
    .RegWriteData               (RegWriteData),
    .RegWriteAddress            (RegWriteAddress),
    .Instruction                (Instruction)
);

AND #(
    .WIDTH                      (4)
) we_and (
    .in                         (MemWrite),
    .out                        (MemWriteEnable)
);

NOR #(
    .WIDTH                      (17)
) full_addr_dec_nor (
    .in                         ({AddressBus[31:16], ~AddressBus[14]}),
    .out                        (full_addr_dec_out)
);

DECODER #(
    .INPUT_WIDTH                (2)
) io_address_decoder
(
    .enable                     (full_addr_dec_out),
    .in                         (AddressBus[11:10]),
    .out                        (io_addr_dec_out)
);

AND #(
    .WIDTH                      (2)
) cs_input0_and (
    .in                         ({MemRead, io_addr_dec_out[0]}),
    .out                        (cs_input0)
);

AND #(
    .WIDTH                      (2)
) cs_input1_and (
    .in                         ({MemRead, io_addr_dec_out[1]}),
    .out                        (cs_input1)
);

AND #(
    .WIDTH                      (2)
) cs_output0_and (
    .in                         ({MemWriteEnable, io_addr_dec_out[2]}),
    .out                        (cs_output0)
);

AND #(
    .WIDTH                      (2)
) cs_output1_and (
    .in                         ({MemWriteEnable, io_addr_dec_out[3]}),
    .out                        (cs_output1)
);

OR #(
    .WIDTH                      (2)
) quaddecoder_rst_or (
    .in                         ({rst, enc_switch}),
    .out                        (quad_rst)
);


QuadratureDecoder #(
    .BUS_WIDTH                  (32)
 ) QuadDecoder (
    .clk                        (cpu_clk),
    .rst                        (quad_rst),
    .oe                         (cs_input0),
    .we                         (1'b0),
    .ext_phase_a                (enc_phase_a),
    .ext_phase_b                (enc_phase_b),
    //direction
    .data                       (DataBus)
);

TRIBUFFER #(
    .WIDTH                      (32)
) input1 (
    .oe                         (cs_input1),
    .in                         (32'b0),
    .out                        (DataBus)
);

REGISTER #(
    .WIDTH                      (8)
) output0 (
    .rst                        (rst),
    .clk                        (cpu_clk),
    .load                       (cs_output0),
    .D                          (DataBus[7:0]),
    .Q                          (led[7:0])
);

REGISTER #(
    .WIDTH                      (32)
) output1 (
    .rst                        (rst),
    .clk                        (cpu_clk),
    .load                       (cs_output1),
    .D                          (DataBus),
    .Q                          ()
);

endmodule