module intpol2_D4_squared#(
    parameter  DATAPATH_WIDTH   = 32,
    parameter  N_bits = 2
)(
    input                                      clk, rstn, clear,
    input                                      en_xi2,
    input              [1:0]                   sel_xi2,
    input       signed [DATAPATH_WIDTH+N_bits-1:0] x2,
    output reg  signed [DATAPATH_WIDTH+N_bits-1:0] xi2
);


reg signed [DATAPATH_WIDTH+N_bits-1:0] xi2_ff;
reg signed [DATAPATH_WIDTH+N_bits-1:0] xi2_past;

wire signed [DATAPATH_WIDTH+N_bits-1:0] x2_plus2;
wire signed [DATAPATH_WIDTH+N_bits-1:0] dif;
wire signed [DATAPATH_WIDTH+N_bits-1:0] dif_2;
wire signed [DATAPATH_WIDTH+N_bits-1:0] xi2_shft2;
wire signed [DATAPATH_WIDTH+N_bits-1:0] sum;

wire signed [DATAPATH_WIDTH+N_bits-1:0] C;

assign x2_plus2  = x2 + x2; 
assign dif       = xi2 - xi2_past;
assign dif_2     = dif + x2_plus2;
assign xi2_shft2 = x2 <<< 2; 

assign sum = dif_2 + xi2; 

assign C  = (sel_xi2 == 2'b01) ? x2        :
            (sel_xi2 == 2'b10) ? xi2_shft2 :
            (sel_xi2 == 2'b11) ? sum       : {DATAPATH_WIDTH+N_bits{1'b0}}; 

// always @(sel_xi2) begin
//     case (sel_xi2)
//         2'b01 : C = x;
//         2'b10 : C = xi2_shft2;
//         2'b11 : C = sum;
//         default: C = {DATAPATH_WIDTH{1'b0}};
//     endcase
// end

always @ (posedge clk or negedge rstn or posedge clear) begin
    if(!rstn || clear) begin
        xi2      = {DATAPATH_WIDTH+N_bits{1'b0}};
        xi2_past = {DATAPATH_WIDTH+N_bits{1'b0}};
    end
    else begin
        if(en_xi2) begin 
            xi2 = C;   
            xi2_past = xi2_ff;                                                                                                 
        end
    end
end
  
always @(xi2) begin
    xi2_ff <= xi2;
end


endmodule