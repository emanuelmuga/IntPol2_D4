module intpol2_D4_sub_sync #(
    parameter  DATA_WIDTH  = 32,
    parameter  N_bits     =  2                   //N <= parte entera
)(
    input                                      clk, rstn, en,
    input       signed [DATA_WIDTH+N_bits-1:0] A,
    input       signed [DATA_WIDTH+N_bits-1:0] B,
    output reg  signed [DATA_WIDTH+N_bits-1:0] C
);


always @(posedge clk or negedge rstn) begin
	 if(!rstn)begin
		 C = {DATA_WIDTH+N_bits{1'b0}};
	 end
	 else begin
         if(en)
		    C = (A - B);
	 end
end


endmodule