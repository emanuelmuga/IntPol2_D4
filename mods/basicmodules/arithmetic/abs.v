`timescale 1ns / 1ps
/*	
   ===================================================================
   Module Name : abs
         
   Filename    : abs.v
   Type        : Verilog Module
      
   Description :  Absolute operator ( output = abs(Input)  )
   
                  Input    :  "DATA_WIDTH" length word in 2's complement representation.
                  Output   :  "DATA_WIDTH-1" length word in unsigned binary representation.
                     * Note:  
                        The output requires only "DATA_WIDTH-1" bits since sign is not needed.
   ------------------------------------------------------------------
      clocks   : -
      reset    : -
      enable   : -
      
   Parameters  :
         NAME            Comments                Default
         ---------------------------------------------------
         DATA_WIDTH      input data width          14
      
   ------------------------------------------------------------------
   Version     : 1.0
   Data        : 13 Nov 2018
   Revision    : -
   Reviser     : -		
   -------------------------------------------------------------------
   Modification Log "please add all the modifications in this area"
   (D/M/Y)  
   
   ----------------------
   // Instance template
   ----------------------
      abs 
      #(
         .DATA_WIDTH ()
      )
      "MODULE_NAME"
      (
         .data_i     (),
         .data_o    ()
      );
*/


module abs 
#(
   parameter DATA_WIDTH = 14
)
(
	input  [DATA_WIDTH - 1 : 0] data_i,
	output [DATA_WIDTH - 2 : 0] data_o
);

wire signed [DATA_WIDTH - 1 : 0] in_;
wire signed [DATA_WIDTH - 1 : 0] out_;
wire signed [DATA_WIDTH - 1 : 0] ZERO = 0;

assign in_ =  data_i;
assign out_ = ( in_ < ZERO) ?  -in_ : in_;
assign data_o = out_[DATA_WIDTH - 2: 0];
endmodule
