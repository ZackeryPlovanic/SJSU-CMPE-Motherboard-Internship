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
    input  wire        reset,
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

wire [15:0]  io_addr_dec_out;
wire        full_addr_dec_out, MemWriteEnable;
wire        cs_QuadDecoder, cs_freq_reg;
wire [7:0] cs_PWM_Driver;
wire        rst;
wire [7:0] PWM_freq;
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
    .INPUT_WIDTH                (4)
) io_address_decoder
(
    .enable                     (full_addr_dec_out),
    .in                         (AddressBus[10:7]),
    .out                        (io_addr_dec_out)
);

AND #(
    .WIDTH                      (2)
) cs_PWM_Driver0_and (
    .in                         ({MemWriteEnable, io_addr_dec_out[0]}),
    .out                        (cs_PWM_Driver[0])
);

AND #(
    .WIDTH                      (2)
) cs_PWM_Driver1_and (
    .in                         ({MemWriteEnable, io_addr_dec_out[1]}),
    .out                        (cs_PWM_Driver[1])
);

AND #(
    .WIDTH                      (2)
) cs_PWM_Driver2_and (
    .in                         ({MemWriteEnable, io_addr_dec_out[2]}),
    .out                        (cs_PWM_Driver[2])
);

AND #(
    .WIDTH                      (2)
) cs_PWM_Driver3_and (
    .in                         ({MemWriteEnable, io_addr_dec_out[3]}),
    .out                        (cs_PWM_Driver[3])
);

AND #(
    .WIDTH                      (2)
) cs_PWM_Driver4_and (
    .in                         ({MemWriteEnable, io_addr_dec_out[4]}),
    .out                        (cs_PWM_Driver[4])
);

AND #(
    .WIDTH                      (2)
) cs_PWM_Driver5_and (
    .in                         ({MemWriteEnable, io_addr_dec_out[5]}),
    .out                        (cs_PWM_Driver[5])
);

AND #(
    .WIDTH                      (2)
) cs_PWM_Driver6_and (
    .in                         ({MemWriteEnable, io_addr_dec_out[6]}),
    .out                        (cs_PWM_Driver[6])
);

AND #(
    .WIDTH                      (2)
) cs_PWM_Driver7_and (
    .in                         ({MemWriteEnable, io_addr_dec_out[7]}),
    .out                        (cs_PWM_Driver[7])
);

AND #(
    .WIDTH                      (2)
) cs_quaddecoder_and (
    .in                         ({MemRead, io_addr_dec_out[8]}),
    .out                        (cs_QuadDecoder)
);

AND #(
    .WIDTH                      (2)
) cs_freq_reg_and (
    .in                         ({MemWriteEnable, io_addr_dec_out[9]}),
    .out                        (cs_freq_reg)
);

OR #(
    .WIDTH                      (2)
) quaddecoder_rst_or (
    .in                         ({reset, enc_switch}),
    .out                        (rst)
);


QuadratureDecoder #(
    .BUS_WIDTH                  (32)
 ) QuadDecoder (
    .clk                        (cpu_clk),
    .rst                        (rst),
    .oe                         (cs_QuadDecoder),
    .we                         (1'b0),
    .ext_phase_a                (enc_phase_a),
    .ext_phase_b                (enc_phase_b),
    .data                       (DataBus)
);

REGISTER #(
 .WIDTH  (8)
 ) PWM_Frequency (
    .rst                        (rst),
    .clk                        (cpu_clk),
    .load                       (cs_freq_reg),
    .D                          (DataBus),
    .Q                          (PWM_freq)
);

PWMDriver #(
    .INPUT_WIDTH                (8),
    .DATA_WIDTH                 (16)
)PWM_Driver0 (
    .sys_clk                    (cpu_clk),
    .reset                      (rst),
    .load                       (cs_PWM_Driver[0]),
    .data                       ({DataBus[7:0], PWM_freq[7:0]}),
    .signal                     (led[0])
);

PWMDriver #(
    .INPUT_WIDTH                (8),
    .DATA_WIDTH                 (16)
)PWM_Driver1 (
    .sys_clk                    (cpu_clk),
    .reset                      (rst),
    .load                       (cs_PWM_Driver[1]),
    .data                       ({DataBus[7:0], PWM_freq[7:0]}),
    .signal                     (led[1])
);

PWMDriver #(
    .INPUT_WIDTH                (8),
    .DATA_WIDTH                 (16)
)PWM_Driver2 (
    .sys_clk                    (cpu_clk),
    .reset                      (rst),
    .load                       (cs_PWM_Driver[2]),
    .data                       ({DataBus[7:0], PWM_freq[7:0]}),
    .signal                     (led[2])
);

PWMDriver #(
    .INPUT_WIDTH                (8),
    .DATA_WIDTH                 (16)
)PWM_Driver3 (
    .sys_clk                    (cpu_clk),
    .reset                      (rst),
    .load                       (cs_PWM_Driver[3]),
    .data                       ({DataBus[7:0], PWM_freq[7:0]}),
    .signal                     (led[3])
);

PWMDriver #(
    .INPUT_WIDTH                (8),
    .DATA_WIDTH                 (16)
)PWM_Driver4 (
    .sys_clk                    (cpu_clk),
    .reset                      (rst),
    .load                       (cs_PWM_Driver[4]),
    .data                       ({DataBus[7:0], PWM_freq[7:0]}),
    .signal                     (led[4])
);

PWMDriver #(
    .INPUT_WIDTH                (8),
    .DATA_WIDTH                 (16)
)PWM_Driver5 (
    .sys_clk                    (cpu_clk),
    .reset                      (rst),
    .load                       (cs_PWM_Driver[5]),
    .data                       ({DataBus[7:0], PWM_freq[7:0]}),
    .signal                     (led[5])
);

PWMDriver #(
    .INPUT_WIDTH                (8),
    .DATA_WIDTH                 (16)
)PWM_Driver6 (
    .sys_clk                    (cpu_clk),
    .reset                      (rst),
    .load                       (cs_PWM_Driver[6]),
    .data                       ({DataBus[7:0], PWM_freq[7:0]}),
    .signal                     (led[6])
);

PWMDriver #(
    .INPUT_WIDTH                (8),
    .DATA_WIDTH                 (16)
)PWM_Driver7 (
    .sys_clk                    (cpu_clk),
    .reset                      (rst),
    .load                       (cs_PWM_Driver[7]),
    .data                       ({DataBus[7:0], PWM_freq[7:0]}),
    .signal                     (led[7])
);
endmodule