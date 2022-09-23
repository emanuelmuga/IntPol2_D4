module intpol2_D4_squared#(
    parameter  DATA_WIDTH   = 32
)(
    input                               clk, rstn, clear,
    input                               en_xi2,
    input              [1:0]            sel_xi2,
    input       signed [DATA_WIDTH-1:0] x2,
    output reg  signed [DATA_WIDTH-1:0] xi2
);


reg signed [DATA_WIDTH-1:0] xi2_ff;
reg signed [DATA_WIDTH-1:0] xi2_past;

wire signed [DATA_WIDTH-1:0] x2_plus2;
wire signed [DATA_WIDTH-1:0] dif;
wire signed [DATA_WIDTH-1:0] dif_2;
wire signed [DATA_WIDTH-1:0] xi2_shft2;
wire signed [DATA_WIDTH-1:0] sum;

wire signed [DATA_WIDTH-1:0] C;

assign x2_plus2  = x2 + x2; 
assign dif       = xi2 - xi2_past;
assign dif_2     = dif + x2_plus2;
assign xi2_shft2 = x2 << 2; 

assign sum = dif_2 + xi2; 

assign C  = (sel_xi2 == 2'b01) ? x2        :
            (sel_xi2 == 2'b10) ? xi2_shft2 :
            (sel_xi2 == 2'b11) ? sum       : {DATA_WIDTH{1'b0}}; 

// always @(sel_xi2) begin
//     case (sel_xi2)
//         2'b01 : C = x;
//         2'b10 : C = xi2_shft2;
//         2'b11 : C = sum;
//         default: C = {DATA_WIDTH{1'b0}};
//     endcase
// end

always @ (posedge clk or negedge rstn or posedge clear) begin
    if(!rstn || clear) begin
        xi2      = {DATA_WIDTH{1'b0}};
        xi2_past = {DATA_WIDTH{1'b0}};
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