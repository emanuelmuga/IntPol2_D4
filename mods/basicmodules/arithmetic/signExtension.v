/*	
   ===================================================================
   Module Name  : sign extension
      
   Filename     : signExtension.v
   Type         : Verilog Module
   
   Description  : 
                  This block implements the sign extension to the input word.

                  Input    :  "WIDTH_IN_WORD" length word in 2's complement representation.
                  Output   :  "WIDTH_OUT_WORD" length word in 2's complement representation.
                  
                  WIDTH_OUT_WORD must be greater than WIDTH_IN_WORD
                  
   -----------------------------------------------------------------------------
   Clocks      : -
   Reset       : -
   Parameters  :   
         NAME                         Comments                                            Default
         -------------------------------------------------------------------------------------------
         WIDTH_IN_WORD              Number of data bits for input                            16 
         WIDTH_OUT_WORD             Number of data bits for output                           17
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
  signExtension
   #(
      .WIDTH_IN_WORD    ( ),
      .WIDTH_OUT_WORD   ( )
   )
   "MODULE_NAME"
   (
      .word_i      (),	
      .word_o      ()
   );	
*/

module signExtension
#(
	parameter	WIDTH_IN_WORD =	'd16,
	parameter	WIDTH_OUT_WORD =	'd17
)
(
	input 	[WIDTH_IN_WORD 			-1: 0]	word_i,	
	output	[WIDTH_OUT_WORD			-1: 0]	word_o
);	
	
	assign word_o	= {{(WIDTH_OUT_WORD-WIDTH_IN_WORD){word_i[WIDTH_IN_WORD-1]}} ,word_i};
	
endmodule
