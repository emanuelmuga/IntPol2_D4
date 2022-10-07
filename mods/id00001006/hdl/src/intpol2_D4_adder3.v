module intpol2_D4_adder3 #(
    parameter  DATAPATH_WIDTH  = 32,
    parameter  N_bits     =  2                   //N <= parte entera   
)(
    input       signed [DATAPATH_WIDTH+N_bits-1:0] A,
    input       signed [DATAPATH_WIDTH+N_bits-1:0] B,
    input       signed [DATAPATH_WIDTH+N_bits-1:0] C,
    output      signed [DATAPATH_WIDTH+N_bits-1:0] Y

);

    assign Y = A + B + C;


endmodule