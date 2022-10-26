module intpol2_D4_fsm(
    input       clk, 
    input       rstn, 
    input       start,
    input       mode,
    input       Afull,
    input       Empty, 
    input       bypass,    
    input       comp_cnt, 
    input       comp_addr,
    output reg  busy,
    output reg  Write_Enable,
    output reg  Ld_data,
    output reg  Read_Enable, 
    output reg  Ld_p1_xi, 
    output reg  en_M_addr, 
    output reg  en_sum,
    output reg  en_stream,      
    output reg  op_1,
    output reg  stop_empty,
    output reg  stop_Afull,     
    output reg  done,
    output reg  sel_mult,
    output wire clear 
);

localparam [3:0] IDLE = 4'h0,
				 S1   = 4'h1,
				 S2   = 4'h2,
				 S3   = 4'h3,
				 S4   = 4'h4,
                 S5   = 4'h5,
            S_CLEAR   = 4'h6,
           S_STREAM   = 4'h7,
       S_BYPSS_STRM   = 4'h8,
      S_BYPSS_ACCEL   = 4'h9;
                 


reg [3:0] state, next_state;   
reg Ld_ff;

assign clear = (start || done) ? 1'b1 : 1'b0;

always @(posedge clk or negedge rstn) begin
	if(~rstn) begin
		state <= IDLE;
        Write_Enable <= 1'b0; 
	end	
	else begin
		state <= next_state;
        Write_Enable <= Ld_ff;
	end
end	

always @(Ld_data) begin
    Ld_ff <= Ld_data;
end

always @(*) begin
en_sum        <= 1'b0;
en_M_addr     <= 1'b0;
Ld_p1_xi      <= 1'b0;
Read_Enable   <= 1'b0;
Ld_data       <= 1'b0;
op_1          <= 1'b0;
done          <= 1'b0;
busy          <= 1'b0;
en_stream     <= 1'b0; 
stop_empty    <= 1'b0;
stop_Afull    <= 1'b0;
sel_mult      <= 1'b0;
next_state    <= IDLE;
    case(state)
        IDLE: 
            begin
                en_sum        <= 1'b0;
                en_M_addr     <= 1'b0;
                Ld_p1_xi      <= 1'b0;
                Read_Enable   <= 1'b0;
                Ld_data       <= 1'b0;
                op_1          <= 1'b0;
                done          <= 1'b0;
                busy          <= 1'b0;
                en_stream     <= 1'b0; 
                stop_empty    <= 1'b0;
                stop_Afull    <= 1'b0;                
                sel_mult      <= 1'b0;
                if(start) begin
                     if(bypass)begin
                        if (mode) begin
                            next_state <= S_BYPSS_STRM;  
                        end
                        else begin
                            next_state <= S1;
                        end 
                    end
                    else begin
                        next_state <= S1;
                    end
                end    
                else begin
                    next_state <= IDLE;
                end    
            end
        S_CLEAR: 
            begin
                en_sum        <= 1'b0;
                en_M_addr     <= 1'b0;
                Ld_p1_xi      <= 1'b0;
                Read_Enable   <= 1'b0;
                Ld_data       <= 1'b0;
                op_1          <= 1'b0;
                done          <= 1'b0;
                busy          <= 1'b0;
                en_stream     <= 1'b0; 
                stop_Afull    <= 1'b0;                 
                sel_mult      <= 1'b0;                              
                if(start) begin
                    next_state <= S_CLEAR;
                end    
                else begin
                    if(Empty) begin
                        stop_empty   <= 1'b1; //<--
                        next_state   <= S_CLEAR;
                    end    
                    else begin
                        stop_empty   <= 1'b0;
                        next_state   <= S1;
                    end 
                end    
            end      
        S1:
            begin 
                en_sum        <= 1'b0;
                Ld_p1_xi      <= 1'b0;
                Read_Enable   <= 1'b1; //<--
                Ld_data       <= 1'b0;
                op_1          <= 1'b0;
                done          <= 1'b0;
                busy          <= 1'b1; //<--
                en_stream     <= 1'b0; 
                stop_Afull    <= 1'b0;                 
                sel_mult      <= 1'b0;
                if(start) begin
                    en_M_addr      <= 1'b0;
                    stop_empty     <= 1'b0;
                    next_state     <= S_CLEAR;
                end    
                else begin
                    if(mode) begin
                        if(Empty) begin
                            next_state     <= S1;
                            en_M_addr      <= 1'b0;
                            stop_empty     <= 1'b1; //<--   
                        end
                        else begin
                            en_M_addr      <= 1'b1; //<--
                            stop_empty     <= 1'b0; 
                            if(comp_addr) begin
                                if(bypass)begin
                                    next_state <= S_BYPSS_STRM;
                                end
                                else begin
                                    next_state <= S2;   
                                end
                            end
                            else begin
                                next_state <= S1;
                            end
                        end
                    end
                    else begin
                        en_M_addr      <= 1'b1; //<--
                        stop_empty     <= 1'b0; 
                        if(comp_addr) begin
                            if(bypass)begin
                                next_state <= S_BYPSS_ACCEL;
                            end
                            else begin
                                next_state <= S2;   
                            end
                        end
                        else begin
                            next_state <= S1;
                        end
                    end
                end                 
            end     
        S2:
            begin
                en_sum        <= 1'b0;
                en_M_addr     <= 1'b0;
                Ld_p1_xi      <= 1'b0;
                Read_Enable   <= 1'b0;
                Ld_data       <= 1'b0; 
                op_1          <= 1'b1; //<--
                done          <= 1'b0;
                busy          <= 1'b1; //<--
                en_stream     <= 1'b0; 
                stop_empty    <= 1'b0;
                stop_Afull    <= 1'b0;                 
                sel_mult      <= 1'b0;  
                if(start) begin
                    next_state <= S_CLEAR;
                end    
                else begin
                    next_state <= S3;
                end  
            end  
        S3:
            begin 
                en_sum        <= 1'b0;
                en_M_addr     <= 1'b0;
                Ld_p1_xi      <= 1'b1; //<--
                Read_Enable   <= 1'b0;
                Ld_data       <= 1'b0;
                op_1          <= 1'b0;
                done          <= 1'b0;
                busy          <= 1'b1; //<--
                en_stream     <= 1'b0; 
                stop_empty    <= 1'b0;
                stop_Afull    <= 1'b0;                 
                sel_mult      <= 1'b0; //<--                 
                if(start) begin
                    next_state <= S_CLEAR;
                end    
                else begin
                    next_state <= S4;
                end                  
            end                     
        S4:
            begin
                en_M_addr     <= 1'b0;
                Ld_p1_xi      <= 1'b0;
                Read_Enable   <= 1'b0;
                op_1          <= 1'b0;
                done          <= 1'b0;
                busy          <= 1'b1;   //<--
                en_stream     <= 1'b0; 
                stop_empty    <= 1'b0;
                stop_Afull    <= 1'b0;                 
                sel_mult      <= 1'b1;  //<--
                if(start) begin
                    next_state <= S_CLEAR;
                    en_sum         <= 1'b0;                 
                    Ld_data        <= 1'b0;
                    stop_Afull     <= 1'b0;  
                end    
                else begin
                    if(mode) begin
                        if(Afull) begin 
                            en_sum         <= 1'b0;                 
                            Ld_data        <= 1'b0;
                            stop_Afull     <= 1'b1; //<--
                            next_state     <= S4;
                        end
                        else begin
                            Ld_data        <= 1'b1; //<--
                            stop_Afull     <= 1'b0;
                            if(comp_cnt) begin
                                en_sum     <= 1'b0;
                                next_state <= S5;
                            end  
                            else begin
                                en_sum     <= 1'b1; //<--
                                next_state <= S3;                
                            end   
                        end
                    end
                    else begin
                        Ld_data        <= 1'b1; //<--
                        stop_Afull     <= 1'b0;
                        if(comp_cnt) begin
                            en_sum     <= 1'b0;
                            next_state <= S5;
                        end  
                        else begin
                            en_sum     <= 1'b1; //<--
                            next_state <= S3;                
                        end   
                    end
                end                               
            end  
        S5:
            begin
                en_sum        <= 1'b0;
                en_M_addr     <= 1'b0;
                Ld_p1_xi      <= 1'b0;
                Read_Enable   <= 1'b0;
                Ld_data       <= 1'b0; 
                op_1          <= 1'b0;
                done          <= 1'b1;   //<--
                busy          <= 1'b1;   //<--
                en_stream     <= 1'b0; 
                stop_empty    <= 1'b0;
                stop_Afull    <= 1'b0;                 
                sel_mult      <= 1'b0;  
                if(start) begin
                    next_state <= S_CLEAR;
                end    
                else begin
                    next_state <= S_STREAM;
                end                               
            end 
        S_STREAM:
            begin
                busy          <= 1'b1; //<--
                en_sum        <= 1'b0;
                en_M_addr     <= 1'b0;
                Read_Enable   <= 1'b1; //<--
                Ld_data       <= 1'b0;                 
                op_1          <= 1'b0;
                done          <= 1'b0;
                en_stream     <= 1'b1; //<--
                stop_empty    <= 1'b1;
                stop_Afull    <= 1'b0;
                if(start) begin
                    next_state <= S_CLEAR;
                end    
                else begin
                    if(Empty) begin
                        next_state <= S_STREAM;
                    end    
                    else begin
                        next_state <= S2;
                    end 
                end    
            end          
        S_BYPSS_ACCEL:  
            begin
                en_sum        <= 1'b0;
                en_M_addr     <= 1'b0;
                done          <= 1'b1; //<--
                busy          <= 1'b1; //<--
                Read_Enable   <= 1'b0;
                op_1          <= 1'b0;
                en_stream     <= 1'b0;
                stop_empty    <= 1'b0;
                stop_Afull    <= 1'b0;
                next_state    <= IDLE;                                          
            end                            
        S_BYPSS_STRM:  
            begin
                en_sum        <= 1'b0;
                en_M_addr     <= 1'b0;
                done          <= 1'b0; 
                busy          <= 1'b1; //<--
                Read_Enable   <= 1'b1; //<--  
                Ld_data       <= 1'b0;               
                op_1          <= 1'b0;
                en_stream     <= 1'b0;
                if(Empty) begin
                    stop_empty    <= 1'b1;
                end    
                else begin
                    stop_empty    <= 1'b0;
                end
                if(Afull) begin
                    stop_Afull    <= 1'b1;
                end    
                else begin
                     stop_Afull    <= 1'b0;
                end  
                if(start) begin
                    next_state <= S_CLEAR;
                end    
                else begin
                    next_state <= S_BYPSS_STRM; 
                end                                             
            end                                 
    endcase
end

endmodule 