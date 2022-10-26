module Y_mem #(
    parameter   DATA_WIDTH = 16,
    parameter   MEM_SIZE_Y  = $clog2(256)
)(
    input      clk,
    input      [MEM_SIZE_Y-1:0] Y_addr,
    input      Write_Enable_Y,
    input signed  [DATA_WIDTH-1:0] data_in
);

    reg signed [DATA_WIDTH-1:0] mem [0:(2**MEM_SIZE_Y)-1];

    always @(posedge clk) begin
        if(Write_Enable_Y)
            mem[Y_addr] <= data_in;
    end
    

endmodule