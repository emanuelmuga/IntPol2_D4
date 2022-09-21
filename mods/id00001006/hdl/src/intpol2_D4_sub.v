module intpol2_D4_sub #(
    parameter  DATA_WIDTH  = 32,
    parameter   N_bits     =  2                   //N <= parte entera
)(
    input       signed [DATA_WIDTH+N_bits-1:0] A,
    input       signed [DATA_WIDTH+N_bits-1:0] B,
    output wire signed [DATA_WIDTH+N_bits-1:0] C
);

    
    assign C = A - B;

endmodule