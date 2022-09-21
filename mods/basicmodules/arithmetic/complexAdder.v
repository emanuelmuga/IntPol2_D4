`timescale 1ns / 1ps
/*	
   ===================================================================
   Module Name  : complex adder
      
   Filename     : complexAdder.v
   Type         : Verilog Module
   
   Description  : 
                  Complex adder with independent buses for real and imaginary parts.
                  Input    :  "DATA_WIDTH" length word in 2's complement representation.
                  Output   :  "DATA_WIDTH" length word in 2's complement representation.
                  
                  Designer must take care of overflow. 
                  We recommend to instantiate a "DATA WIDTH" length adder for "DATA WIDTH-1" length inputs.
                  
   -----------------------------------------------------------------------------
   Clocks      : -
   Reset       : -
   Parameters  :   
         NAME                         Comments                                            Default
         -------------------------------------------------------------------------------------------
         DATA_WIDTH              Number of data bits for inputs and outputs               18 
         -------------------------------------------------------------------------------------------
   Version     : 1.0
   Data        : 14 Nov 2018
   Revision    : -
   Reviser     : -		
   ------------------------------------------------------------------------------
      Modification Log "please register all the modifications in this area"
      (D/M/Y)  
      
   ----------------------
   // Instance template
   ----------------------
   complexAdder
   #(
      .DATA_WIDTH    ()
   )
   "MODULE_NAME"
   (
       .re_A      (),
       .im_A      (),
       .re_B      (),
       .im_B      (),
       .re_out    (),
       .im_out    ()
   );
*/

module complexAdder
#(
   parameter DATA_WIDTH = 18
)
(
    input  [DATA_WIDTH-1 : 0] re_A,
	 input  [DATA_WIDTH-1 : 0] im_A,
	 input  [DATA_WIDTH-1 : 0] re_B,
	 input  [DATA_WIDTH-1 : 0] im_B,
    output [DATA_WIDTH-1 : 0] re_out,
	 output [DATA_WIDTH-1 : 0] im_out
);
	
	reg signed [DATA_WIDTH -1: 0] temp_RA;
	reg signed [DATA_WIDTH -1: 0] temp_IA;
	reg signed [DATA_WIDTH -1: 0] temp_RB;
	reg signed [DATA_WIDTH -1: 0] temp_IB;
	
	wire signed [DATA_WIDTH-1: 0] temp_RE;
	wire signed [DATA_WIDTH-1: 0] temp_IM;
	
	always@(re_A, re_B, im_A, im_B)
	begin
		temp_RA = re_A;
		temp_IA = im_A;
		temp_RB = re_B;
		temp_IB = im_B;
	end 
	
	assign temp_RE = temp_RA + temp_RB;
	assign temp_IM = temp_IA + temp_IB;
	
	assign re_out = temp_RE;
	assign im_out = temp_IM;
endmodule
