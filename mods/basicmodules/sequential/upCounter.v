/*	
   ===================================================================
   Module Name  : Synchronous Up Counter MOD N
      
   Filenhme     : upCounter.v
   Type         : Verilog Module
   
   Description  : Synchronous Up Counter MOD N with "hit" signal.

                  This block is an Up counter with parametrizable modulus CNT_MOD.
                  It's maximum count value is defined by the input max_cnt_i.
                  The output hit_o signal will be high when the counter reaches
                  max_cnt_i.
  
   -----------------------------------------------------------------------------
   Clocks      : posedge clock "clk"
   Resets      : async negedge "rstn"
                 sync posedge "clrh"
   enable      : high active "enh" 
   
   Parameters  :   
         NAME                 Comments                   Default
         ------------------------------------------------------------------------------
         CNT_MOD              Modulus of the counter     160 
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
   upCounter 
   #(
      .CNT_MOD    (),
   )
   "MODULE_NAME"
   (
      clk         (),
      rstn        (),
      clrh        (),
      enh         (),
      hit_o       (),
      max_cnt_i   (),
      cnt_o       ()
   );
*/

module upCounter 
#(
   parameter CNT_MOD = 160
)(
   input    clk,
   input    rstn,
   //-------------ctrl signals---------------//
	input    clrh,
   input    enh,
   output   hit_o,
   //-------------data/addr signals-----------//
	input    [CeilLog2(CNT_MOD)-1 : 0]  max_cnt_i,
	output   [CeilLog2(CNT_MOD)-1 : 0]  cnt_o

);

reg hit_;
reg n_hit;
reg [CeilLog2(CNT_MOD)-1 : 0] cnt_;
reg [CeilLog2(CNT_MOD)-1 : 0] n_cnt;

always@(posedge clk, negedge rstn)begin
	if (~rstn) begin
		cnt_ <= 0;
		hit_ <= 1'b0;	
	end
	else if(clrh) begin
		cnt_ <= 0;
		hit_ <= 1'b0;	
	end
	else if (enh) begin 
		cnt_ <= n_cnt;
		hit_ <= n_hit;	
	end
	else begin
		cnt_ <= cnt_ ;
		hit_ <= hit_;
	end
end

always@(*) begin 
	if (cnt_ == (max_cnt_i-1'b1)) begin
		n_hit	= 1'b1;
	end
	else begin
		n_hit	= 1'b0;
	end
	
	if (cnt_ < (max_cnt_i)) begin
		n_cnt = cnt_ + 1'b1;
	end
	else begin
		n_cnt = 0;
	end
end

assign hit_o = hit_;
assign cnt_o = cnt_;

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
  
endmodule
