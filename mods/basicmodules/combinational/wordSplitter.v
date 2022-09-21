/*	
   ===================================================================
   Module Name : wordSplitter
         
   Filename    : wordSplitter.v
   Type        : Verilog Module
      
   Description :  This block divides a WIDTH_IN_WORD" length word into two "WIDTH_IN_WORD/2" length output words.
                  Input concatenates {real, imaginary} into a complex word.
                  First output is interpreted as real part, and second output as imaginary part.
   ------------------------------------------------------------------
      clocks   : -
      reset    : -
      enable   : -
      
   Parameters  :
         NAME              Comments                Default
         ---------------------------------------------------
         WIDTH_IN_WORD      input data width          32
      
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
      
   wordSplitter
   #(
      .WIDTH_IN_WORD =	()
   )
   "MODULE_NAME"
   (	
      .RIword_i  (),	
      .real_o    (),
      .imag_o    ()
   );	
*/


module wordSplitter
#(
	parameter	WIDTH_IN_WORD =	'd32
)
(
	input 	[WIDTH_IN_WORD 			-1: 0]	RIword_i,	
	output	[(WIDTH_IN_WORD >>1) 	-1: 0]	real_o,
	output	[(WIDTH_IN_WORD >>1) 	-1: 0]	imag_o
);	
	
	assign real_o = RIword_i[WIDTH_IN_WORD 			-1: (WIDTH_IN_WORD >>1) ];
	assign imag_o = RIword_i[(WIDTH_IN_WORD >>1)		-1: 0 ];
	
endmodule
