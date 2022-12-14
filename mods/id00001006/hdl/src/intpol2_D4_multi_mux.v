module intpol2_D4_multi_mux#(
    parameter   DATAPATH_WIDTH  =  32,
    parameter   N_bits      =  2,
    parameter   M_bits      =  31
    
)(
    input                                        sel_mult,
    input       signed [DATAPATH_WIDTH+N_bits-1:0]   xi,
    input       signed [DATAPATH_WIDTH+N_bits-1:0]   xi2,
    input       signed [DATAPATH_WIDTH+N_bits-1:0]   p1,
    input       signed [DATAPATH_WIDTH+N_bits-1:0]   p2,
    output wire signed [DATAPATH_WIDTH+N_bits-1:0]   data_out
);


wire signed [DATAPATH_WIDTH+N_bits-1:0]       A;
wire signed [DATAPATH_WIDTH+N_bits-1:0]       B;
wire signed [(DATAPATH_WIDTH+N_bits)*2-1:0]   R;


assign A = sel_mult ? p2  : p1;
assign B = sel_mult ? xi2 : xi;


assign R = A * B;
assign data_out = R[(DATAPATH_WIDTH+N_bits)*2-1:M_bits];

// always @ (posedge clk or negedge rstn) begin
//     if(~rstn)
//         data_out = {DATAPATH_WIDTH+1{1'b0}};
//     else
//         data_out = R[DATAPATH_WIDTH*2-N:M];
// end


endmodule