/*
==============================================================================================
    Programer     : Emanuel Murillo García
    Contact       : emanuel.murillo@cinvestav.mx
                    emanuel.muga13@gmail.com

    Module Name   : intpol2_D4_IQ_CORE (TOP), Interpolador Cuadratico Diseño IV IQ
    Type          : Verilog module
    
    Description   : Obtine los valores interpolados entre tres datos de entrada, M0, M1, M2.
                    Utilizando solo un multiplicador.
                    Realiza la aproximación con: y = p0 + p1*xi + p2*(xi)^2. Donde pi son los
                    coeficientes calculados "On-the-fly" y xi el factor de interpolación.
                    Se tiene dos entradas, una en Fase (I) y otra en cuadratura (Q).
-----------------------------------------------------------------------------------------------                    
    Clocks        : posedge "clk"
    Reset         : Async negedge "rstn"
    Parameters    :

                    NAME                          Comments                             
                    -------------------------------------------------------------
                    DATAPATH_WIDTH                Tamaño de palabra
                    CONFIG_WIDTH                  Tamaño de palabra del config_reg/4
                    N_bits                        No. bits de aumento del datapath
                    M_bits                        No. bits parte frac. 
                    -------------------------------------------------------------
    Config_reg    : bypass = config_reg0[0];                                  
                    iX     = config_reg1[31:0];  Factor de interpolacion  
                    iX2    = config_reg2[31:0];  Factor de interpolacion^2          
                    ilen   = config_reg3[31:0];   Duración de iteración LENGHT 
                                        
                    -------------------------------------------------------------
    status_reg    :  status_reg[0] = done;
                     status_reg[1] = busy;
                     status_reg[2] = stop_empty;
                     status_reg[3] = stop_Afull;
                     status_reg[5] = bypass;                      
-------------------------------------------------------------------------------------------------
    Version        : 1.0
    Date           : 21 Sep 2022
    Last update    : 7 Oct 2022
=================================================================================================            
*/

module intpol2_D4_IQ_CORE #(
    parameter   CONFIG_WIDTH   =  32,                          // tamaño de palabra de config reg
    parameter   DATAPATH_WIDTH =  12,                          // tamaño datapath
    parameter   N_bits         =  2,                           // Aumento de datapath
    parameter   M_bits         =  11                           // Parte decimal
)
(     
    input                                   clk,
    input                                   rstn, 
    input                                   start,
    input                                   Empty_i,                //Fifo empty
    input                                   Afull_i,                //Almost full  
    input              [128-1:0]            config_reg,   
    input       signed [DATAPATH_WIDTH-1:0] data_in_from_fifo_I,    // entrada desde FIFO_I   
    input       signed [DATAPATH_WIDTH-1:0] data_in_from_fifo_Q,    // entrada desde FIFO_Q   
    output wire                             Write_Enable_fifo,      
    output wire                             Read_Enable_fifo,       
    output wire        [8-1:0]              status_reg,
    output wire signed [DATAPATH_WIDTH-1:0] I_interp,               // Result I   
    output wire signed [DATAPATH_WIDTH-1:0] Q_interp                // Result Q                                            
);

wire  signed [DATAPATH_WIDTH-1:0] max_Thold;
wire  signed [DATAPATH_WIDTH-1:0] min_Thold;

//-----------------------Connection signals--------------------//
wire  [CONFIG_WIDTH-1:0]   ilen;
wire  [DATAPATH_WIDTH-1:0] iX;  
wire  [DATAPATH_WIDTH-1:0] iX2;  
wire  [DATAPATH_WIDTH-1:0] data_I;
wire  [DATAPATH_WIDTH-1:0] data_Q;
// wire  [DATAPATH_WIDTH-1:0] s_I;
// wire  [DATAPATH_WIDTH-1:0] data_Q;

wire  [CONFIG_WIDTH-1:0]   config_reg0;
wire  [CONFIG_WIDTH-1:0]   config_reg1;
wire  [CONFIG_WIDTH-1:0]   config_reg2;
wire  [CONFIG_WIDTH-1:0]   config_reg3;
//-----------------------Control signals-----------------------//
wire                       en_sum;                           //enable del cnt y de la multi por sumatoria.
wire                       en_stream;
wire                       op_1;                       
wire                       sel_mult;                         //selector de entradas del multi_mux
wire                       Ld_M0;
wire                       Ld_M1;
wire                       Ld_M2;
wire                       Ld_data;
wire                       Ld_p1_xi;
wire                       Read_Enable_w;
wire                       Write_Enable_w;

//-----------------------Status signals------------------------//
wire                       done;
wire                       bypass;                           
wire                       busy; 
wire                       clear; 
wire                       stop_empty;
wire                       stop_Afull; 
wire          [1:0]        sel_xi2;
wire                       FIFO_bypass;

//-------------------------------------------------------------//

assign config_reg0   = config_reg[CONFIG_WIDTH-1:0]; 
assign config_reg1   = config_reg[CONFIG_WIDTH*2-1:CONFIG_WIDTH];
assign config_reg2   = config_reg[CONFIG_WIDTH*3-1:CONFIG_WIDTH*2];
assign config_reg3   = config_reg[CONFIG_WIDTH*4-1:CONFIG_WIDTH*3];

assign bypass        = config_reg0[0];
assign iX            = config_reg1[DATAPATH_WIDTH-1:0];
assign iX2           = config_reg2[DATAPATH_WIDTH-1:0];
assign ilen          = config_reg3[CONFIG_WIDTH-1:0];

assign status_reg[0] = done;
assign status_reg[1] = busy;
assign status_reg[2] = stop_empty;
assign status_reg[3] = stop_Afull;
assign status_reg[5] = bypass;  

//--------------------------Bypass Muxes------------------------//

assign Read_Enable_fifo  = Read_Enable_w;                
assign Write_Enable_fifo = bypass            ? FIFO_bypass         : Write_Enable_w;                          
assign I_interp          = bypass            ? data_in_from_fifo_I : data_I;
assign Q_interp          = bypass            ? data_in_from_fifo_Q : data_Q;

//-------------------------------------------------------------//

assign min_Thold = {1'b1,{DATAPATH_WIDTH-1{1'b0}}};
assign max_Thold = {1'b0,{DATAPATH_WIDTH-1{1'b1}}};

//-------------------------------------------------------------//
intpol2_D4_Datapath#(
    .DATAPATH_WIDTH  ( DATAPATH_WIDTH      ),
    .N_bits          ( N_bits              ),
    .M_bits          ( M_bits              )
)Datapath_I(
    .clk             ( clk                 ),
    .rstn            ( rstn                ),
    .clear           ( clear               ),
    .Ld_M0           ( Ld_M0               ),
    .Ld_M1           ( Ld_M1               ),
    .Ld_M2           ( Ld_M2               ),
    .Ld_p1_xi        ( Ld_p1_xi            ),
    .en_sum          ( en_sum              ),
    .Ld_data         ( Ld_data             ),
    .en_stream       ( en_stream           ),
    .sel_mult        ( sel_mult            ),
    .op_1            ( op_1                ),
    .sel_xi2         ( sel_xi2             ), 
    .min_Thold       ( min_Thold           ),
    .max_Thold       ( max_Thold           ),
    .data_to_process ( data_in_from_fifo_I ),
    .x               ( iX                  ),
    .x2              ( iX2                 ),
    .data_out        ( data_I              )
);

intpol2_D4_Datapath#(
    .DATAPATH_WIDTH  ( DATAPATH_WIDTH      ),
    .N_bits          ( N_bits              ),
    .M_bits          ( M_bits              )
)Datapath_Q(
    .clk             ( clk                 ),
    .rstn            ( rstn                ),
    .clear           ( clear               ),
    .Ld_M0           ( Ld_M0               ),
    .Ld_M1           ( Ld_M1               ),
    .Ld_M2           ( Ld_M2               ),
    .Ld_p1_xi        ( Ld_p1_xi            ),
    .en_sum          ( en_sum              ),
    .en_stream       ( en_stream           ),
    .Ld_data         ( Ld_data             ),
    .sel_mult        ( sel_mult            ),
    .op_1            ( op_1                ),
    .sel_xi2         ( sel_xi2             ),
    .min_Thold       ( min_Thold           ),
    .max_Thold       ( max_Thold           ), 
    .data_to_process ( data_in_from_fifo_Q ),
    .x               ( iX                  ),
    .x2              ( iX2                 ),
    .data_out        ( data_Q              )
);
    

intpol2_D4_Controlpath#(
    .DATAPATH_WIDTH ( DATAPATH_WIDTH        ),
    .CONFIG_WIDTH   ( CONFIG_WIDTH          )
)Controlpath(
    .clk            ( clk                   ),
    .rstn           ( rstn                  ),
    .start          ( start                 ),
    .Empty_i        ( Empty_i               ),
    .Afull_i        ( Afull_i               ),
    .ilen           ( ilen                  ),
    .bypass         ( bypass                ),
    .Ld_M0          ( Ld_M0                 ),
    .Ld_M1          ( Ld_M1                 ),
    .Ld_M2          ( Ld_M2                 ),
    .sel_xi2        ( sel_xi2               ),
    .FIFO_bypass    ( FIFO_bypass           ),
    .busy           ( busy                  ),
    .Write_Enable_w ( Write_Enable_w        ),
    .Ld_data        ( Ld_data               ),
    .Read_Enable_w  ( Read_Enable_w         ),
    .Ld_p1_xi       ( Ld_p1_xi              ),
    .en_sum         ( en_sum                ),
    .en_stream      ( en_stream             ),
    .op_1           ( op_1                  ),
    .stop_empty     ( stop_empty            ),
    .stop_Afull     ( stop_Afull            ),
    .done           ( done                  ),
    .sel_mult       ( sel_mult              ),
    .clear          ( clear                 )
);


endmodule