module M_mem #(
    parameter   DATA_WIDTH  = 16,
    parameter   MEM_SIZE_M  = $clog2(3)
)(
    input      clk,
    input      [MEM_SIZE_M-1:0] M_addr,
    output reg [DATA_WIDTH-1:0] data_out
);

    reg [DATA_WIDTH-1:0] mem [0:(2**MEM_SIZE_M)-1];

    always @(posedge clk) begin
            data_out <= mem[M_addr];
    end

endmodule