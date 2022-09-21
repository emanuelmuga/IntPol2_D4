/*	
   ===================================================================
   Module Name : complexRegister
         
   Filename    : complexRegister.v
   Type        : Verilog Module
      
   Description : A parametrizable register for real and imag parts, with async reset
   ------------------------------------------------------------------
      clocks   : posedge clock "clk"
      reset    : async negedge "rstn"
               : sync posedge "clrh"
      enable   : high active enable "enh" 
      
   Parameters  :
         NAME            Comments                Default
         ---------------------------------------------------
         DATA_WIDTH      Register's data width     8
      
   ------------------------------------------------------------------
   Version     : 1.0
   Data        : 13 Nov 2018
   Revision    : -
   Reviser     : -		
   -------------------------------------------------------------------
   Modification Log "please register all the modifications in this area"
   (D/M/Y)  
   
   ----------------------
   // Instance template
   ----------------------
complexRegister 
#(
   .DATA_WIDTH ()
)
"MODULE_NAME"
(
   .clk     	(),
   .rstn    	(),
   .clrh    	(),   
   .enh     	(),
   .dataRe_i  	(),
	.dataIm_i	(),
	.dataRe_o  	(),
	.dataIm_o	()
);

*/

module complexRegister
#(
	parameter DATA_WIDTH =  8
)(
	input wire                     clk,
	input wire                     rstn,
   input wire                     clrh,   
   //--------Control signals----------//
	input wire                     enh,
   //--------Data/addr signals--------//
	input wire 	[DATA_WIDTH-1:0]   dataRe_i,
	input wire 	[DATA_WIDTH-1:0]   dataIm_i,
	output wire [DATA_WIDTH-1:0]   dataRe_o,
	output wire [DATA_WIDTH-1:0]   dataIm_o
);

register 
#(
   .DATA_WIDTH (DATA_WIDTH)
)
R_REAL
(
   .clk     (clk),
   .rstn    (rstn),
   .clrh    (clrh),   
   .enh     (enh),
   .data_i  (dataRe_i),
   .data_o  (dataRe_o)
);
		


register 
#(
   .DATA_WIDTH (DATA_WIDTH)
)
R_IMAG
(
   .clk     (clk),
   .rstn    (rstn),
   .clrh    (clrh),   
   .enh     (enh),
   .data_i  (dataIm_i),
   .data_o  (dataIm_o)
);
endmodule

