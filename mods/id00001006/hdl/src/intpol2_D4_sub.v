module intpol2_D4_sub #(
    parameter  DATAPATH_WIDTH  = 32,
    parameter   N_bits     =  2                   //N <= parte entera
)(
    input       signed [DATAPATH_WIDTH+N_bits-1:0] A,
    input       signed [DATAPATH_WIDTH+N_bits-1:0] B,
    output wire signed [DATAPATH_WIDTH+N_bits-1:0] C
);

    
    assign C = A - B;

endmodule