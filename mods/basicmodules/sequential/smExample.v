/*	
   ===================================================================
   Module Name : States machine example
         
   Filename    : smExample.v
   Type        : Verilog Module
      
   Description : A 4 states Moore machine example.
                 
   ------------------------------------------------------------------
      clocks   : posedge clock "clk"
      reset    : async negedge "rstn"
     
   ------------------------------------------------------------------
   Version     : 1.0
   Data        : 26 Nov 2018
   Revision    : -
   Reviser     : -		
   -------------------------------------------------------------------
   Modification Log "please register all the modifications in this area"
   (D/M/Y)  
   
   ----------------------
   // Instance template
   ----------------------
      smExample "MODULE_NAME"
      (
           .clk  (),
           .rstn (),
           .a_i  (),
           .b_i  (),
           .c_i  (),
           .y1_o (),
           .y2_o ()
      );
*/

module smExample
(
	input wire     clk,
	input wire     rstn,
   
   //--------Control signals----------//
   input wire     a_i,
   input wire     b_i,
   input wire     c_i,
   
   output reg     y1_o,
   output reg     y2_o

);
// Declare your defined values-----------------
localparam       DEF_BIT_LOW  = 1'b0,
                 DEF_BIT_HIGH = 1'b1;

// States declaration--------------------------
localparam [1:0] S0   = 2'b00,
                 S1   = 2'b01,
                 S2   = 2'b10,
                 S3   = 2'b11;
                 
reg [1:0] state;   //present state              
reg [1:0] nstate;  //next state
//---------------------------------------------

//Signal declaration---------------------------
reg ny1;          //next value for y1_o
reg ny2;          //next value for y2_o

//================================================================
// State register and registered outputs
//================================================================
always@(posedge clk, negedge rstn) begin
	if(~rstn) begin
		state <= S0;
      y1_o  <= DEF_BIT_LOW;
      y2_o  <= DEF_BIT_LOW;
   end
	else begin
      state <= nstate;	
      y1_o  <= ny1;
      y2_o  <= ny2;
   end
end

//================================================================
// Next state logic
//================================================================
always@(*) begin

		case (state) 
      
         S0: begin
               if(a_i)
                  nstate=S1;
               else
                  nstate=S0;
         end
         
         S1: begin
               if(c_i & b_i)
                  nstate=S2;
               else
                  nstate=S1;
         end
         
         S2: begin
               nstate=S3;
         end
         
         S3: begin
            if(~b_i)
                  nstate=S0;
               else
                  nstate=S3;
         end
         
         default: begin
            nstate = S0;
         end
         
      endcase
end

//================================================================
// Moore outputs 
//(The outputs are only a function of the present state)
//================================================================
always@(*) begin

		case (state) 
      
         S0: begin
            ny1 = DEF_BIT_LOW;
            ny2 = DEF_BIT_LOW;
         end
         
         S1: begin
            ny1 = DEF_BIT_HIGH;
            ny2 = DEF_BIT_LOW;
         end
         
         S2: begin
            ny1 = DEF_BIT_HIGH;
            ny2 = DEF_BIT_HIGH;
         end
         
         S3: begin
            ny1 = DEF_BIT_HIGH;
            ny2 = DEF_BIT_LOW;
         end
         
      endcase
end


endmodule