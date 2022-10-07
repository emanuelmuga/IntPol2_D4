module intpol2_D4_shift #(
    parameter	DATAPATH_WIDTH = 32,
    parameter   N_bits     =  2                   //N <= parte entera   

)(
    input   wire                                    OP,
    input   wire signed [DATAPATH_WIDTH+N_bits-1:0]  	data_in,
    output	wire signed [DATAPATH_WIDTH+N_bits-1:0]  	data_out
);

assign	data_out = (OP == 1'd1) ? data_in >>> 1 : data_in <<< 1;

endmodule