`timescale 1ns / 1ps
/*	
   ===================================================================
   Module Name : signInverter
         
   Filename    : signInverter.v
   Type        : Verilog Module
      
   Description :  Sign inversion ( output = -(Input)  )
   
                  Input    :  "DATA_WIDTH" length word in 2's complement representation.
                  Output   :  "DATA_WIDTH" length word in 2's complement representation.
                  Control  :
                              if sel_i is high, then output = -(Input). 
                              Otherwise, output = (Input). 
   ------------------------------------------------------------------
      clocks   : -
      reset    : -
      enable   : -
      
   Parameters  :
         NAME            Comments                Default
         ---------------------------------------------------
         DATA_WIDTH      input data width          12
      
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
      signInverter 
      #(
         .DATA_WIDTH ()
      )
      "MODULE_NAME"
      (
         .data_i     (),
         .data_o     (),
         .sel_i      ()
      );
*/


module signInverter 
#(
   parameter DATA_WIDTH = 12     //[12]
)
(
	input  [DATA_WIDTH-1:0] data_i,
	output [DATA_WIDTH-1:0] data_o,
	input sel_i
);
	
	reg signed [DATA_WIDTH-1:0] temp_data;
	
	always@(data_i)
	begin
		temp_data = data_i;
	end
		 
	assign data_o = (!sel_i) ? data_i : - temp_data;

endmodule
