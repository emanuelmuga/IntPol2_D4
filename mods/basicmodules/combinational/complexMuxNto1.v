/*	
   ===================================================================
   Module Name  : Complex Multiplexer N to 1
      
   Filename     : complexMuxNto1.v
   Type         : Verilog Module
   
   Description  : Parametrizable complex multiplexor 
                  The number of inputs must be power of two!
                  
                  -data_i signal distribution:
                     
                  data_i  [                      DATA_WIDTH-1:0] -> input 0
                  data_i  [         (2*DATA_WIDTH)-1:DATA_WIDTH] -> input 1
                  data_i  [     (3*DATA_WIDTH)-1:(2*DATA_WIDTH)] -> input 2
                  ...
                  data_i  [ (N*DATA_WIDTH)-1:((N-1)*DATA_WIDTH)] -> input N-1
               * where  N = (2^SEL_WIDTH)
   -----------------------------------------------------------------------------
   Clocks      : -
   Reset       : -
   Parameters  :   
         NAME                         Comments                   Default
         ------------------------------------------------------------------------------
         SEL_WIDTH               Number bits for mux selector        2
         DATA_WIDTH              Number of data bits                33 
         ------------------------------------------------------------------------------
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
complexMuxNto1 
#(
   .DATA_WIDTH   (),
   .SEL_WIDTH    ("ceil_log2(N)")
)
"MODULE_NAME"
(
   .sel_i    (),
   .dataRe_i   ({
                  ,  // Re:N-1
                  ,  // Re: ...
                  ,  // Re:1
                     // Re:0
                  }),
	.dataIm_i   ({
                  ,  // Im:N-1
                  ,  // Im: ...
                  ,  // Im:1
                     // Im:0
                  }),
   .dataRe_o   (),
	.dataIm_o   ()
);
*/


module complexMuxNto1 
#(
		parameter  DATA_WIDTH   = 'd1,
      parameter  SEL_WIDTH    = 'd1
)(
    //-------------ctrl signals---------------//
    input   wire [   SEL_WIDTH -1                  :0 ]  sel_i,
    //-------------data/addr signals-----------//
    input   wire [( (2**SEL_WIDTH) *DATA_WIDTH)-1  :0 ]  dataRe_i,
	 input   wire [( (2**SEL_WIDTH) *DATA_WIDTH)-1  :0 ]  dataIm_i,
    output  wire [             DATA_WIDTH-1        :0 ]  dataRe_o,
	 output  wire [             DATA_WIDTH-1        :0 ]  dataIm_o
);

// -----------------------------------------------------------

  muxNto1 
   #(
      .DATA_WIDTH   (DATA_WIDTH),
      .SEL_WIDTH    (SEL_WIDTH)
   )
   MuxRe
   (
      .sel_i    (sel_i),
      .data_i   (dataRe_i),
      .data_o   (dataRe_o)
   );
	
	muxNto1 
   #(
      .DATA_WIDTH   (DATA_WIDTH),
      .SEL_WIDTH    (SEL_WIDTH)
   )
   MuxIm
   (
      .sel_i    (sel_i),
      .data_i   (dataIm_i),
      .data_o   (dataIm_o)
   );
endmodule
