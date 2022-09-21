`timescale 1ns / 1ps
/*	
   ===================================================================
   Module Name : rightBarrelShifter
         
   Filename    : rightBarrelShifter.v
   Type        : Verilog Module
      
   Description :  Aritmetic right barrel shifter.
                  Input shifts_i controls the number of right shifts.
                  data_i      :  "DATA_WIDTH" length word in 2's complement representation.
                  shifts_i    :  "ceil(log2(DATA_WIDTH))" length word.
   ------------------------------------------------------------------
      clocks   : -
      reset    : -
      enable   : -
      
   Parameters  :
         NAME            Comments                Default
         ---------------------------------------------------
         DATA_WIDTH      input data width          22
      
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
	
rightBarrelShifter
#(
   .DATA_WIDTH ()
)
"MODULE_NAME"
(
   .data_i     (),
   .shifts_i   (),
   .data_o     ()
);

*/


module rightBarrelShifter
#(
   parameter DATA_WIDTH = 22
)
(
	input  signed	[             DATA_WIDTH-1   : 0   ]  data_i,
	input  			[ CeilLog2(DATA_WIDTH) -1    : 0   ]  shifts_i,
	output signed	[          DATA_WIDTH-1      : 0   ]  data_o
);

assign data_o = data_i >>> shifts_i;

//**********************************
function integer CeilLog2;
  input integer data;
  integer i, result;
  	  begin
	  result = 1; 
		  for (i = 0; 2**i < data; i = i + 1)
			result = i + 1; 
			CeilLog2 = result;
	  end 
 endfunction 
//**********************************
endmodule

