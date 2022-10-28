module intpol2_D4_nxt_ste_lgc#(
    parameter   DATAPATH_WIDTH  =  32,
    parameter   CONFIG_WIDTH    =  32,
     parameter  MEM_ADDR_WIDTH  =  16 
)(
    input                             clk, rstn,
    input                             clear, 
    input                             Empty,
    input                             Afull,
    input                             busy,    
    input                             en_sum,
    input                             Read_Enable,     
    input                             Write_Enable,    
    input                             en_M_addr,
    input                             done,
    input          [CONFIG_WIDTH-1:0] ilen,
    output reg   [MEM_ADDR_WIDTH-1:0] Y_addr,
    output reg   [MEM_ADDR_WIDTH-1:0] Y_addr_bypass,
    output wire  [MEM_ADDR_WIDTH-1:0] M_addr,
	output wire  			          comp_cnt,
	output wire  			          comp_addr,
    output wire                       Ld_M0,
    output wire                       Ld_M1,
    output wire                       Ld_M2,
    output wire             [1:0]     sel_xi2,
	output reg                        Write_bypass_mem,
    output reg                        FIFO_bypass
);

wire                         fifo_bypass_en;

reg                          fifo_bypass_ff;
reg                          Read_Enable_ff;
reg    [MEM_ADDR_WIDTH-1:0]  M_addr_ff; 
reg    [CONFIG_WIDTH:0]      cnt;
reg    [MEM_ADDR_WIDTH-1:0]  M_cnt;             //contador para lectura de memoria M


assign M_addr    =   M_cnt;
assign Ld_M0     =  (M_cnt == 2'b01) ? 1'b1 : 1'b0;
assign Ld_M1     =  (M_cnt == 2'b10) ? 1'b1 : 1'b0;
assign Ld_M2     =  (M_cnt == 2'b11) ? 1'b1 : 1'b0;
assign sel_xi2   =  (cnt < 2'b11) ?  (cnt[1:0]+1) : 2'b11; 
assign comp_cnt  =  (cnt < ilen-1)   ? 1'b0 : 1'b1;
assign comp_addr =   Ld_M2;

assign fifo_bypass_en  = (busy && (~Empty && ~Afull));

always @(posedge clk or negedge rstn or posedge clear) begin
    if(~rstn || clear) begin
        cnt               = {CONFIG_WIDTH{1'b0}};
        M_cnt             = {MEM_ADDR_WIDTH{1'b0}};
        Y_addr           <= {MEM_ADDR_WIDTH{1'b0}};
        Y_addr_bypass    <= {MEM_ADDR_WIDTH{1'b0}};
        FIFO_bypass      <= 1'b0;
        Write_bypass_mem <= 1'b0;
    end
    else begin       

        if(en_M_addr) begin
            M_cnt = M_cnt + 1'b1;
        end

        if(done) begin
            cnt    = {DATAPATH_WIDTH{1'b0}};
        end 
        else begin   
            if(en_sum) 
                cnt      = (cnt + 1'b1);
        end  

        if(Write_Enable) 
            Y_addr <= (Y_addr + 1'b1);

        FIFO_bypass      = fifo_bypass_ff;
        Write_bypass_mem = Read_Enable_ff;
        Y_addr_bypass    = M_addr_ff;
    end
end

always @(fifo_bypass_en) begin
    fifo_bypass_ff <= fifo_bypass_en; 
end

always @(M_cnt) begin
    M_addr_ff <= M_cnt; 
end

always @(Read_Enable) begin
    Read_Enable_ff <= Read_Enable; 
end


endmodule