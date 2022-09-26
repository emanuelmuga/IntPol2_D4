module intpol2_D4_nxt_ste_lgc#(
    parameter   DATA_WIDTH  =  32 
)(
    input                                 clk, rstn,
    input                                 clear, 
    input                                 Empty,
    input                                 Afull,
    input                                 busy,    
    input                                 en_sum,
    input                                 Read_Enable,     
    input                                 Write_Enable,    
    input                                 en_M_addr,
    input                                 done,
    input              [DATA_WIDTH:0]     ilen,
	output wire			                  comp_cnt,
	output wire			                  comp_addr,
    output wire                           Ld_M0,
    output wire                           Ld_M1,
    output wire                           Ld_M2,
    output wire             [1:0]         sel_xi2,
    output reg                            FIFO_bypass
);

localparam   SIZE_M  = $clog2(4);

wire                    fifo_bypass_en;

reg    [DATA_WIDTH:0]   cnt;
reg    [SIZE_M-1:0]     M_cnt;             //contador para lectura de memoria M
reg                     fifo_bypass_ff;

assign comp_cnt  =  (cnt < ilen-1)              ? 1'b0 : 1'b1;

assign Ld_M0     =  (M_cnt == 2'b01) ? 1'b1 : 1'b0;
assign Ld_M1     =  (M_cnt == 2'b10) ? 1'b1 : 1'b0;
assign Ld_M2     =  (M_cnt == 2'b11) ? 1'b1 : 1'b0;

assign comp_addr = Ld_M2;

assign sel_xi2   =  (cnt < 2'b11) ?  (cnt[1:0]+1) : 2'b11; 

assign fifo_bypass_en  = (busy && (~Empty && ~Afull));

always @(posedge clk or negedge rstn or posedge clear) begin
    if(~rstn || clear) begin
        cnt             = {DATA_WIDTH{1'b0}};
        M_cnt           = {SIZE_M{1'b0}};
        FIFO_bypass    <= 1'b0;
    end
    else begin       

        if(en_M_addr) begin
            M_cnt = M_cnt + 1'b1;
        end
        // else begin
        //     M_cnt = 1'b0;
        // end

        if(done) begin
            cnt    = {DATA_WIDTH{1'b0}};
        end 
        else begin   
            if(en_sum) 
                cnt    = (cnt + 1'b1);
        end  

        FIFO_bypass    = fifo_bypass_ff;
    end
end

always @(fifo_bypass_en) begin
    fifo_bypass_ff <= fifo_bypass_en; 
end


endmodule