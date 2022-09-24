module intpol2_D4_Controlpath #(
    parameter   DATA_WIDTH  =  32
)(
    input                                 clk, 
    input                                 rstn, 
    input                                 start,
    input                                 Empty_i,
    input                                 Afull_i,
    input              [DATA_WIDTH:0]     ilen,
    input                                 bypass,    
    output wire                           Ld_M0,
    output wire                           Ld_M1,
    output wire                           Ld_M2,
    output wire                           Ld_data,
    output wire             [1:0]         sel_xi2,
    output wire                           FIFO_bypass,
    output wire                           busy,
    output wire                           Write_Enable_w,
    output wire                           Read_Enable_w, 
    output wire                           Ld_p1_xi, 
    output wire                           en_sum,
    output wire                           en_stream,      
    output wire                           op_1,
    output wire                           stop_empty,
    output wire                           stop_Afull,     
    output wire                           done,
    output wire                           sel_mult,
    output wire                           clear 
);

wire comp_cnt;
wire comp_addr;
wire en_M_addr;

//----------Next state Logic, and counters----------------//


intpol2_D4_nxt_ste_lgc#(
    .DATA_WIDTH     ( DATA_WIDTH     )
)next_state_logic(
    .clk            ( clk            ),
    .rstn           ( rstn           ),
    .clear          ( clear          ),
    .Empty          ( Empty_i        ),
    .Afull          ( Afull_i        ),
    .busy           ( busy           ),
    .en_sum         ( en_sum         ),
    .Read_Enable    ( Read_Enable_w  ),
    .Write_Enable   ( Write_Enable_w ),
    .en_M_addr      ( en_M_addr      ),
    .done           ( done           ),
    .ilen           ( ilen           ),
    .comp_cnt       ( comp_cnt       ),
    .comp_addr      ( comp_addr      ),
    .Ld_M0          ( Ld_M0          ),
    .Ld_M1          ( Ld_M1          ),
    .Ld_M2          ( Ld_M2          ),
    .sel_xi2        ( sel_xi2        ),
    .FIFO_bypass    ( FIFO_bypass    )
);


//------------------------------- FSM ----------------------------//

intpol2_D4_fsm FSM(
    .clk          ( clk            ),
    .rstn         ( rstn           ),
    .start        ( start          ),
    .Afull        ( Afull_i        ),
    .Empty        ( Empty_i        ),
    .bypass       ( bypass         ),
    .comp_cnt     ( comp_cnt       ),
    .comp_addr    ( comp_addr      ),
    .busy         ( busy           ),
    .Write_Enable ( Write_Enable_w ),
    .Ld_data      ( Ld_data        ),
    .Read_Enable  ( Read_Enable_w  ),
    .Ld_p1_xi     ( Ld_p1_xi       ),
    .en_M_addr    ( en_M_addr      ),
    .en_sum       ( en_sum         ),
    .en_stream    ( en_stream      ),
    .op_1         ( op_1           ),
    .stop_empty   ( stop_empty     ),
    .stop_Afull   ( stop_Afull     ),
    .done         ( done           ),
    .sel_mult     ( sel_mult       ),
    .clear        ( clear          )
);



endmodule