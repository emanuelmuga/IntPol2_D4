module intpol2_D4_mult_by_add#(
    parameter   DATAPATH_WIDTH  =  32,
    parameter   N_bits      =  2                   //N <= parte entera   
)(
    input                               clk, rstn, clear,
    input                               en,
    input       [DATAPATH_WIDTH+N_bits-1:0] x,
    output reg  [DATAPATH_WIDTH+N_bits-1:0] xi
);

always @(posedge clk, negedge rstn, posedge clear) begin
    if(~rstn || clear)
        xi = {DATAPATH_WIDTH+N_bits{1'b0}};
    else begin
        if(en)
           xi = x + xi; 
    end
end

endmodule 