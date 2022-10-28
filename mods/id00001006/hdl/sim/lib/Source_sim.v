module Source_sim #(
    parameter ADDR_WIDTH = $clog2(100)   
)(
    input clk,
    input rst,
    input en,
    input Afull,
    output reg [ADDR_WIDTH-1:0] addr,
    output reg WE
);

wire write;
reg ff;

assign write = ~Afull;
// assign WE = ~Afull & en;


always @(posedge clk or negedge rst) begin
    if(~rst) begin
        addr <= {ADDR_WIDTH{1'b0}};
        // WE = 1'b0;
    end
    else begin
         if(en) begin
            if(~Afull)
                addr <= addr + 1'b1;
            WE <= ff & ~Afull;
         end

    end
end

always @(write) begin
  ff = write;
end


endmodule