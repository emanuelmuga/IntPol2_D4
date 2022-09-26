module Source #(
    parameter DATA_WIDTH = 32,
    parameter MEM_SIZE_M = $clog2(4)
)(    
    input                         clk,
    input                         rstn,
    input                         start_i,
    input                         Afull_i,      //Almost full provenietne de la fifo de entrada
    input              [128-1:0]  config_reg,
    input       [DATA_WIDTH-1:0]  data_in,      //Datos provenientes de la memoria de la interfaz Mem_in
    output reg                    WE_fifo_o,    //Write enable de la fifo de entrada
    output wire            [7:0]  status_reg,
    output reg   [MEM_SIZE_M-1:0] addr_Mem_o,   
    output wire  [DATA_WIDTH-1:0] data_o        //Datos hacía la fifo
);

localparam [1:0] IDLE       = 2'b00,
				 READ_WRITE = 2'b01,
                 DONE       = 2'b10;
                 
wire [7:0] data_depth;
wire [7:0] offset;
wire [1:0] mode;
wire offset_mode;
wire comp_addr;

reg done;
reg busy;
reg stop_Afull;
reg en_addr;
reg en_addr_ff;
reg [MEM_SIZE_M-1:0] addr_save;
reg [MEM_SIZE_M-1:0] addr_ff;
reg [2:0] next_state, state = 0; 
reg [MEM_SIZE_M-1:0] cnt;

assign status_reg[0] = done;
assign status_reg[1] = busy;
assign status_reg[2] = stop_Afull;

assign data_depth  = config_reg[7:0];
assign offset      = config_reg[15:8];
assign mode        = config_reg[17:16];

assign data_o = data_in;
assign comp_addr = (cnt < data_depth) ? 1'b0 : 1'b1;

always @(en_addr) begin
    en_addr_ff <= en_addr;
end

always @(addr_Mem_o) begin
    addr_ff <= addr_Mem_o;
end

always @(posedge clk, negedge rstn) begin
	if(~rstn) begin
		state     <= IDLE;
        cnt       <= {MEM_SIZE_M{1'b0}};
        addr_save <= {MEM_SIZE_M{1'b0}};
	end	
	else begin
        state          <= next_state;
        WE_fifo_o      <= en_addr_ff;
        
        if(en_addr)
            cnt <= cnt + 1;
        if(done)
            cnt <= {DATA_WIDTH{1'b0}};

        if(done && mode[1]) 
            addr_save <= addr_ff;   
	end
end	

always @(*) begin  
    case(mode)
        2'b01: addr_Mem_o = cnt + offset;
        2'b10: addr_Mem_o = cnt + addr_save;
      default: addr_Mem_o = cnt;
    endcase
end

always @(*) begin
en_addr       <= 1'b0;
done          <= 1'b0;
busy          <= 1'b0;
stop_Afull    <= 1'b0;
next_state    <= IDLE;
    case(state)
        IDLE: begin
                en_addr       <= 1'b0;
                done          <= 1'b0;
                busy          <= 1'b0; 
                stop_Afull    <= 1'b0;
                if(start_i)
                    next_state <= READ_WRITE;
                else
                    next_state <= IDLE;
              end          
  READ_WRITE:begin
                done          <= 1'b0;
                busy          <= 1'b1; //<--
                if(start_i) begin
                    en_addr       <= 1'b0;
                    stop_Afull    <= 1'b0;
                    next_state    <= IDLE; 
                end
                else begin 
                    if(Afull_i) begin
                        en_addr       <= 1'b0;   
                        stop_Afull    <= 1'b1;        //<--
                        next_state    <= READ_WRITE;                     
                    end 
                    else begin
                        stop_Afull    <= 1'b0;
                        if(comp_addr) begin
                            en_addr     <= 1'b0; 
                            next_state  <= DONE; 
                        end    
                        else begin 
                            en_addr     <= 1'b1; //<--
                            next_state  <= READ_WRITE; 
                        end    
                    end
                end


             end
        DONE: begin
            stop_Afull <= 1'b0;
            en_addr    <= 1'b0;
            done       <= 1'b1; //<--
            next_state <= IDLE;
        end    
    endcase
end

endmodule


