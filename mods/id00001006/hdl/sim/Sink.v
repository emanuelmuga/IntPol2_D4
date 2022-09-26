module Sink #(
    parameter DATA_WIDTH = 32,
    parameter MEM_SIZE_Y = $clog2(128)
)(
    input                        clk,
    input                        rstn,
    input                        start_i,          //Start Global
    input                        Empty_i,          //Estado Empty de la fifo
    input       [7:0]            data_depth,       //Numero de datos esperados
    input       [DATA_WIDTH-1:0] data_in,          //Datos provenientes de la fifo
    output reg                   Read_Enable_o,    //Leer FIFO
    output reg  [MEM_SIZE_Y-1:0] addr_Mem_o,       
    output reg                   Write_Enable_o,   //Escribir en memoria de salida                    
    output reg  [DATA_WIDTH-1:0] data_out,
    output reg                   done

);

localparam [1:0] IDLE       = 2'b00,
				 READ       = 2'b01,
				 WRITE_MEM  = 2'b10,
                 DONE       = 2'b11;
       
reg [1:0] next_state, state = 0; 

reg [DATA_WIDTH-1:0] mem [0:((2**MEM_SIZE_Y)-1)];

reg [MEM_SIZE_Y-1:0] addr_local;
reg [MEM_SIZE_Y-1:0] addr_local_WR;
reg [MEM_SIZE_Y-1:0] addr_local_ff;
reg [MEM_SIZE_Y-1:0] addr_out, addr_out_ff;
reg en_addr_local;
reg RE_ff;
reg addr_en;


reg WE_local;
wire comp_addr;
wire comp_addr_local;

assign comp_addr       = (addr_out < data_depth) ? 1'b0 : 1'b1;
assign comp_addr_local = (addr_local < data_depth) ? 1'b0 : 1'b1;

always @(Read_Enable_o) begin
    RE_ff <= Read_Enable_o;
end

always @(addr_out) begin
    addr_out_ff <= addr_out;
end

always @(addr_local) begin
    addr_local_ff <= addr_local;
end

always @(posedge clk) begin
    data_out <= mem[addr_out];
    if(WE_local)
        mem[addr_local_WR] <= data_in;
end

always @(posedge clk, negedge rstn) begin
	if(~rstn) begin
		state          <= IDLE;
        addr_out <= {DATA_WIDTH{1'b0}};
        addr_local <= {DATA_WIDTH{1'b0}};
	end	
	else begin
        state          <= next_state;
        addr_local_WR  <= addr_local_ff;
        WE_local       <= RE_ff;
        addr_Mem_o     <= addr_out_ff;
        if(addr_en)
            addr_out <= addr_out + 1'b1;
        if(en_addr_local)
            addr_local <= addr_local + 1'b1;            
	end
end	


always @(*) begin
addr_en        <= 1'b0;
Read_Enable_o  <= 1'b0;
en_addr_local  <= 1'b0;
Write_Enable_o <= 1'b0;
done           <= 1'b0;
    case(state)
        IDLE: begin
                addr_en        <= 1'b0;
                en_addr_local  <= 1'b0;
                Write_Enable_o <= 1'b0; 
                done           <= 1'b0; 
                if(start_i)
                    next_state <= READ; 
                else
                    next_state <= IDLE;
              end
        READ:begin
                Write_Enable_o  <= 1'b0;
                addr_en         <= 1'b0;
                done            <= 1'b0;
                if(comp_addr_local) begin
                    next_state    <= WRITE_MEM;
                    Read_Enable_o <= 1'b0; 
                    en_addr_local <= 1'b0; 
                end
                else begin
                    if(Empty_i) begin
                        Read_Enable_o <= 1'b0;
                        en_addr_local <= 1'b0;
                    end
                    else begin
                        Read_Enable_o <= 1'b1; //<--
                        en_addr_local <= 1'b1; //<-- 
                    end
                    next_state    <= READ; 
                end 
             end
  WRITE_MEM:begin
                addr_en         <= 1'b1; //<--
                Read_Enable_o   <= 1'b0;
                en_addr_local   <= 1'b0; 
                Write_Enable_o  <= 1'b1; //<--
                done            <= 1'b0;
                if(comp_addr) begin
                    next_state    <= DONE; 
                end    
                else begin 
                    next_state    <= WRITE_MEM; 
                end    
             end
       DONE: begin
                done           <= 1'b1;
                addr_en        <= 1'b0;
                en_addr_local  <= 1'b0;
                Write_Enable_o <= 1'b0; 
                Read_Enable_o  <= 1'b0; 
                next_state    <= IDLE; 
             end  

    endcase
end

endmodule