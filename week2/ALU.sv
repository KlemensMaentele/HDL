import Types::*;

//package Types;
//  typedef enum logic [1:0] {
//    ADD      = 2'b00,
//    SUBTRACT = 2'b01,
//    MULTIPLY = 2'b10
//  } sel_t;

//  typedef enum logic {
//    WITH_CARRY = 1'b1,
//    NO_CARRY   = 1'b0
//  } mode_t;
//endpackage : Types


module ALU (
    output logic [7:0] Result,
    output logic Equal,
    input logic [3:0] Op1,
    input logic [3:0] Op2,
    input sel_t Sel,
    input logic C_In,
    input mode_t Mode
);

  timeunit 1ns; timeprecision 100ps;

// your code goes here
  always_comb
  begin
    case(Sel)
    ADD: if(Mode == WITH_CARRY)
         Result <= Op1+Op2+C_In;
         else
         Result <= Op1+Op2;
    SUBTRACT:
         Result <= Op1-Op2;
    MULTIPLY:
         Result <= Op1*Op2;
    default: Result = 0;// in case input is b11
    endcase
    Equal <= Op1 == Op2;
  end
  

endmodule : ALU