`timescale 1ns / 1ps
import Types::*;
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/29/2026 03:33:14 PM
// Design Name: 
// Module Name: tb_alu
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


module tb_alu;
  logic [7:0] Result;
  logic       Equal;
  logic [3:0] Op1, Op2;
  logic       C_In;
  sel_t       Sel;
  mode_t      Mode;
  
  ALU dut (
  .Result(Result), .Equal(Equal), .Op1(Op1), .Op2(Op2), .Sel(Sel), .C_In(C_In), .Mode(Mode)
  );
  
  initial begin
  Op1 = 4'd3; 
  Op2 = 4'd4;
  Sel = ADD;
  Mode = NO_CARRY;
  C_In = 0;
  #1;
  assert (Result == 8'd7);
  
  #1;
  Sel = SUBTRACT;
  
  #1;
  assert (Result == -1);
  
  #1;
  Sel = MULTIPLY;
  
  #1;
  assert (Result == 12);
  
  $finish;
  end
  
endmodule
