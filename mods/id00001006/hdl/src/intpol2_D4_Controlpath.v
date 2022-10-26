module intpol2_D4_Controlpath #(
    parameter   DATAPATH_WIDTH  = 32,
    parameter   CONFIG_WIDTH    = 32,
    parameter  MEM_ADDR_WIDTH   = 16
)(
    input                                 clk, 
    input                                 rstn, 
    input                                 start,
    input                                 mode,
    input                                 Empty_i,
    input                                 Afull_i,
    input          [CONFIG_WIDTH-1:0]     ilen,
    input                                 bypass,    
    output wire                           Ld_M0,
    output wire                           Ld_M1,
    output wire                           Ld_M2,
    output wire                           Ld_data,
    output wire             [1:0]         sel_xi2,
    output wire                           FIFO_bypass,
    output wire                           busy,
    output wire                           Write_Enable,
    output wire                           Write_bypass_mem,
    output wire                           Read_Enable,
    output wire  [MEM_ADDR_WIDTH-1:0]     Y_addr,
    output wire  [MEM_ADDR_WIDTH-1:0]     Y_addr_bypass,        
    output wire  [MEM_ADDR_WIDTH-1:0]     M_addr, 
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
    .DATAPATH_WIDTH     ( DATAPATH_WIDTH ),
    .MEM_ADDR_WIDTH     ( MEM_ADDR_WIDTH ),
    .CONFIG_WIDTH       ( CONFIG_WIDTH   )
)next_state_logic(
    .clk              ( clk              ),
    .rstn             ( rstn             ),
    .clear            ( clear            ),
    .Empty            ( Empty_i          ),
    .Afull            ( Afull_i          ),
    .busy             ( busy             ),
    .en_sum           ( en_sum           ),
    .Read_Enable      ( Read_Enable      ),
    .Write_Enable     ( Write_Enable     ),
    .en_M_addr        ( en_M_addr        ),
    .done             ( done             ),
    .ilen             ( ilen             ),
    .comp_cnt         ( comp_cnt         ),
    .comp_addr        ( comp_addr        ),
    .Y_addr           ( Y_addr           ),
    .Y_addr_bypass    ( Y_addr_bypass    ),
    .M_addr           ( M_addr           ),
    .Ld_M0            ( Ld_M0            ),
    .Ld_M1            ( Ld_M1            ),
    .Ld_M2            ( Ld_M2            ),
    .sel_xi2          ( sel_xi2          ),
    .Write_bypass_mem ( Write_bypass_mem ),
    .FIFO_bypass      ( FIFO_bypass      )
);


//------------------------------- FSM ----------------------------//

intpol2_D4_fsm FSM(
    .clk          ( clk            ),
    .rstn         ( rstn           ),
    .start        ( start          ),
    .mode         ( mode           ),
    .Afull        ( Afull_i        ),
    .Empty        ( Empty_i        ),
    .bypass       ( bypass         ),
    .comp_cnt     ( comp_cnt       ),
    .comp_addr    ( comp_addr      ),
    .busy         ( busy           ),
    .Write_Enable ( Write_Enable   ),
    .Ld_data      ( Ld_data        ),
    .Read_Enable  ( Read_Enable    ),
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