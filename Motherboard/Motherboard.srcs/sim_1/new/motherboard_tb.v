`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/23/2018 07:28:19 PM
// Design Name: 
// Module Name: motherboard_tb
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

module motherboard_tb;

reg         clk, rst;
reg         encoder_phase_a,encoder_phase_b,encoder_switch;
wire [7:0] led;

integer I;

Motherboard #( .CLOCK_DIVIDER(1)) DUT (
    .clk100Mhz              (clk),
    .rst                    (rst),
    .enc_phase_a            (encoder_phase_a),
    .enc_phase_b            (encoder_phase_b),
    .enc_switch             (encoder_switch),
    .led                    (led)
);

task tick;
begin
    clk = 1'b0; #5; clk = 1'b1; #5; clk = 1'b0; #5;
end
endtask

task rotateRight;
begin
    encoder_phase_a = 1'b0; #5; tick; tick; tick; tick; encoder_phase_b = 1'b0; #5; tick; tick; tick; tick; 
    encoder_phase_a = 1'b1; #5; tick; tick; tick; tick; encoder_phase_b = 1'b1; #5; tick; tick; tick; tick; 
    encoder_phase_a = 1'b0; #5; tick; tick; tick; tick; encoder_phase_b = 1'b0; #5; tick; tick; tick; tick; 
end
endtask

task rotateLeft;
begin
    encoder_phase_b = 1'b0; #5; tick; tick; tick; tick; encoder_phase_a = 1'b0; #5; tick; tick; tick; tick; 
    encoder_phase_b = 1'b1; #5; tick; tick; tick; tick; encoder_phase_a = 1'b1; #5; tick; tick; tick; tick; 
    encoder_phase_b = 1'b0; #5; tick; tick; tick; tick; encoder_phase_a = 1'b0; #5; tick; tick; tick; tick; 
end
endtask

task rotate;
    input [7:0] distance;
    input direction;
    integer K;
    
begin
    for(K=0;K < distance; K = K+1)
        begin
            if(direction)   rotateLeft;
            else            rotateRight;
        end
end
endtask     

initial begin
    encoder_switch = 1'b0; encoder_phase_a = 1'b0; encoder_phase_b = 1'b0;
    rst = 1'b0; #2; rst = 1'b1; #2; rst = 1'b0; #2;
    
    rotate(8'b0011_0000,1);
    for(I=0;I<2**8-1;I=I+1)
        begin
            tick;
        end
        
    rotate(8'b0000_0111,0);
    for(I=0;I<2**8-1;I=I+1)
        begin
            tick;
        end
        
    $finish; 
end
endmodule