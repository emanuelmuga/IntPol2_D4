`timescale 1ns / 1ps
/*	
   ===================================================================
   Module Name : squareNorm
         
   Filename    : squareNorm.v
   Type        : Verilog Module
      
   Description :  Square Norm operator ( out = real^2 + imag^2 )
   
                  Input    :  "DATA_WIDTH" length word in 2's complement representation.
                  Output   :  "DATA_WIDTH+1" length word in unsigned binary representation.
                  * Example:  
                           If the input fixed-point configuration is  fi{signed, word length, fracc. length} = fi(1,12,11), 
                           then the output will be: fi{signed, word length, fracc. length} = fi(0,13,12), 
   Note: 
         If designer requires other output configuration, ask Programers.
         
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
   Modification Log "please abs all the modifications in this area"
   (D/M/Y)  
   
   ----------------------
   // Instance template
   ----------------------
   
squareNorm  
#(
   .DATA_WIDTH ()
) 
"MODULE_NAME"
(
	.in_re   (),
	.in_im   (),
	.out 	   ()
);

*/


module squareNorm  
#(
   parameter DATA_WIDTH = 12
) 
(
	input  [DATA_WIDTH - 1 : 0] in_re, //fi(1,12,11)
	input  [DATA_WIDTH - 1 : 0] in_im, //fi(1,12,11)
	output [DATA_WIDTH - 0 : 0] out 	  //fi(0,13,12)
);

wire [DATA_WIDTH - 2 : 0] re_;
wire [DATA_WIDTH - 2 : 0] im_;
wire [2*(DATA_WIDTH - 1)-1 : 0] mul_re;
wire [2*(DATA_WIDTH - 1)-1 : 0] mul_im;


wire [2*(DATA_WIDTH - 1)- 0 : 0] add_;

abs #(DATA_WIDTH )
RE
(
	.in(in_re), // 12
	.out(re_)	//11
);

abs #(DATA_WIDTH )
IM
(
	.in(in_im),//12
	.out(im_) //11
);

assign mul_re = re_ * re_;//22
assign mul_im = im_ * im_;//22

assign add_ = mul_re + mul_im;
assign out	= add_[(2*DATA_WIDTH)-4:DATA_WIDTH-4];
endmodule
