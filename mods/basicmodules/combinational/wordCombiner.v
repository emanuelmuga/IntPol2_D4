/*	
   ===================================================================
   Module Name : wordCombiner
         
   Filename    : wordCombiner.v
   Type        : Verilog Module
      
   Description :  This block concatenates two "WIDTH_IN_WORD" length words into a single "2*WIDTH_IN_WORD" length output word.
                  First input is interpreted as real part, and second input as imaginary part.
                  Output concatenates {real, imaginary} into a complex word.
   ------------------------------------------------------------------
      clocks   : -
      reset    : -
      enable   : -
      
   Parameters  :
         NAME              Comments                Default
         ---------------------------------------------------
         WIDTH_IN_WORD      input data width          17
      
   ------------------------------------------------------------------
   Version     : 1.0
   Data        : 13 Nov 2018
   Revision    : -
   Reviser     : -		
   -------------------------------------------------------------------
   Modification Log "please abs all the modifications in this area"
   (D/M/Y)  
   
   ----------------------
   // Instance template
   ----------------------
      
   wordCombiner
   #(
      .WIDTH_IN_WORD =	()
   )
   "MODULE_NAME"
   (	
      .real_i     (),
      .imag_i     (),
      .RIword_o   ()
   );	
*/

module wordCombiner
#(
	parameter	WIDTH_IN_WORD =	'd17
)
(	
	input 	[WIDTH_IN_WORD 	-1: 0]	real_i,
	input 	[WIDTH_IN_WORD 	-1: 0]	imag_i,
	output	[2*WIDTH_IN_WORD 	-1: 0]	RIword_o
);	
	
	assign RIword_o	= {real_i,imag_i};
	
endmodule
