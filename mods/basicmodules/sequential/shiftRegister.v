/*	
   ===================================================================
   Module Name : Shift Register
         
   Filename    : shiftRegister.v
   Type        : Verilog Module
      
   Description : A parametrizable shift register.
                 
                 This register has four distinct modes of operation
                 according the 2-bit control signal "ctrl_i":
                 
                 Value        Function                                  Description  
                 --------------------------------------------------------------------------------
                 00           q_o = q_o                                 Remain in the same state 
                                                                        of the register
                 01           q_o = {serialR_i,q_o[DATA_WIDTH-1:1]}     Shift Right                              
                 10           q_o = {q_o[DATA_WIDTH-2:0],serialL_i}     Shift left
                 11           q_o = d_i                                 Parallel load            
                 
   
   ------------------------------------------------------------------
      clocks   : posedge clock "clk"
      reset    : async negedge "rstn"
     
   Parameters  :
         NAME            Comments                Default
         ---------------------------------------------------
         DATA_WIDTH      Register's data width     8
      
   ------------------------------------------------------------------
   Version     : 1.0
   Data        : 23 Nov 2018
   Revision    : -
   Reviser     : -		
   -------------------------------------------------------------------
   Modification Log "please register all the modifications in this area"
   (D/M/Y)  
   
   ----------------------
   // Instance template
   ----------------------
      shiftRegister 
      #(
         .DATA_WIDTH ()
      )
      "MODULE_NAME"
      (
         .clk        (),
         .rstn       (),
         .ctrl_i     (),
         .serialR_i  (),
         .serialL_i  (),
         .d_i        (),
         .q_o        ()
);
*/

module shiftRegister 
#(
	parameter DATA_WIDTH =  8
)(
	input wire                    clk,
	input wire                    rstn,
   
   //--------Control signals----------//
	input wire [           1:0]   ctrl_i,
   
   //--------Data/addr signals--------//
	input wire                    serialR_i, //right shift serial input
	input wire                    serialL_i, //left shift serial input
	input wire [DATA_WIDTH-1:0]   d_i,       //parallel input
	output reg [DATA_WIDTH-1:0]   q_o        //parallel output
);

// ---------------------------------------------
localparam [1:0] IDLE   = 2'b00,
                 RIGHT  = 2'b01,
                 LEFT   = 2'b10,
                 LOAD   = 2'b11;

reg [DATA_WIDTH-1:0] q_next;

always@(posedge clk, negedge rstn) begin
	if(~rstn) 
		q_o <= {DATA_WIDTH{1'b0}};
	else 
      q_o <= q_next;
end

always@(*)begin
   case(ctrl_i)
         IDLE  : q_next = q_o;
         RIGHT : q_next = {serialR_i,q_o[DATA_WIDTH-1:1]};
         LEFT  : q_next = {q_o[DATA_WIDTH-2:0],serialL_i};
         LOAD  : q_next = d_i;
   endcase
end


endmodule