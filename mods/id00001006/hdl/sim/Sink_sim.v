module Sink_sim #(
    parameter ADDR_WIDTH = $clog2(100),
    parameter CONFIG_WIDTH = 32

)(
    input clk,
    input rstn,
    input start_i,
    input Empty_i,
    input [CONFIG_WIDTH-1:0]ilen,
    output reg [ADDR_WIDTH-1:0] addr,
    output reg Read_Enable_o,
    output reg  Write_Enable_o,
    output reg done
);

reg addr_en;
wire comp_addr;

localparam [1:0] IDLE       = 2'b00,
				 READ_WRITE = 2'b01,
                 DONE       = 2'b10;
       
reg [1:0] next_state, state = 0; 
reg ff;

assign comp_addr = (addr < ilen) ? 1'b0 : 1'b1;

always @(posedge clk or negedge rstn) begin
    if(!rstn) begin
        addr = {ADDR_WIDTH{1'b0}};
        state          <= IDLE;
    end
    else begin
         state          <= next_state;
        if (Write_Enable_o)
             addr = addr + 1'b1;
    end
    Write_Enable_o <= ff;
end

always @(Read_Enable_o) begin
   ff <= Read_Enable_o;
end

always @(*) begin
addr_en        <= 1'b0;
Read_Enable_o  <= 1'b0;
done           <= 1'b0;
    case(state)
        IDLE: begin
                addr_en        <= 1'b0;
                done           <= 1'b0; 
                if(start_i)
                    next_state <= READ_WRITE; 
                else
                    next_state <= IDLE;
              end
    READ_WRITE:begin
                done            <= 1'b0;
                if(comp_addr) begin
                    next_state    <= DONE;
                    addr_en       <= 1'b0;
                    Read_Enable_o <= 1'b0;
                end
                else begin
                    if(Empty_i) begin
                        addr_en       <= 1'b0;
                        Read_Enable_o <= 1'b0;
                    end
                    else begin
                        addr_en       <= 1'b1; //<--
                        Read_Enable_o <= 1'b1; //<--
                    end
                    next_state    <= READ_WRITE; 
                end 
             end
       DONE: begin
                done           <= 1'b1;
                addr_en        <= 1'b0;
                Read_Enable_o  <= 1'b0; 
                next_state    <= IDLE; 
             end  

    endcase
end

endmodule