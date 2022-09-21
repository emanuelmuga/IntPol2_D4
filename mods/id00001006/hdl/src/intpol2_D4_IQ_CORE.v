/*
==============================================================================================
    Programer     : Emanuel Murillo García
    Contact       : emanuel.murillo@cinvestav.mx
                    emanuel.muga13@gmail.com

    Module Name   : intpol2_D4_IQ (TOP), Interpolador Cuadratico Diseño IV IQ
    Type          : Verilog module
    
    Description   : Obtine los valores interpolados entre tres datos de entrada, M0, M1, M2.
                    Utilizando solo un multiplicador.
                    Realiza la aproximación con: y = p0 + p1*xi + p2*(xi)^2.
                    Se tiene dos entradas, una en Fase (I) y otra en cuadratura (Q).
-----------------------------------------------------------------------------------------------                    
    Clocks        : posedge "clk"
    Reset         : Async posedge "rstn"
    Parameters    :

                    NAME                          Comments                             
                    -------------------------------------------------------------
                    DATA_WIDTH                    Tamaño de palabra
                    N_bits                        No. bits parte entera
                    M_bits                        No. bits parte frac. 
                    MEM_SIZE_Y                    Tamaño de memoria de salida
                    MEM_SIZE_M                    Tamaño de memoria de entrada
                    -------------------------------------------------------------
    Config_reg    : bypass = config_reg0[0];                                  
                    mode   = config_reg0[1];                            
                    iX     = config_reg1[31:0];  Factor de interpolacion  
                    iX     = config_reg2[31:0];  Factor de interpolacion^2          
                    ilen   = config_reg3[7:0];   Duración de iteración LENGHT 
                                        
                    -------------------------------------------------------------

    status_reg    :  status_reg[0] = done;
                     status_reg[1] = busy;
                     status_reg[2] = stop_empty;
                     status_reg[3] = stop_Afull;
                     status_reg[4] = mode;
                     status_reg[5] = bypass;                      
-------------------------------------------------------------------------------------------------
    Version        : 1.0
    Date           : 21 Sep 2022
=================================================================================================            
*/

module intpol2_D4_IQ_CORE #(
    parameter   DATA_WIDTH  =  32, 
    parameter   N_bits      =  2,                               //N <= parte entera
    parameter   M_bits      =  31                               //M <= parte decimal
)
(     
    input                               clk,
    input                               rstn, 
    input                               start,
    input                               Empty_i,                //Fifo empty
    input                               Afull_i,                //Almost full  
    input              [128-1:0]        config_reg,   
    input       signed [DATA_WIDTH-1:0] data_in_from_fifo_I,    // entrada desde FIFO_I   
    input       signed [DATA_WIDTH-1:0] data_in_from_fifo_Q,    // entrada desde FIFO_Q   
    output wire                         Write_Enable_fifo,  
    output wire                         Read_Enable_fifo,      
    output wire        [8-1:0]          status_reg,
    output wire signed [DATA_WIDTH-1:0] I_interp,               // Result I   
    output wire signed [DATA_WIDTH-1:0] Q_interp                // Result Q                                            
);

wire        [MEM_SIZE_Y:0]   ilen;
wire        [DATA_WIDTH-1:0] iX;  
wire        [DATA_WIDTH-1:0] iX2;  

//-----------------------Control signals-----------------------//
wire                         en_sum;                           //enable del cnt y de la multi por sumatoria.
wire                         en_stream;
wire                         op_1;                       
wire                         sel_mult;                         //selector de entradas del multi_mux
wire                         Ld_y;                             //Load result y
wire                         Ld_M0;
wire                         Ld_M1;
wire                         Ld_M2;
wire                         Ld_p1_xi;
wire                         Read_Enable_w;
wire                         Write_Enable_w; 
wire                         done;
wire                         bypass;                           
wire                         busy; 
wire                         clear; 
wire                         stop_empty;
wire                         stop_Afull; 
wire          [1:0]          sel_xi2;
wire                         FIFO_bypass;

//-------------------------------------------------------------//
wire        [DATA_WIDTH-1:0] config_reg0;
wire        [DATA_WIDTH-1:0] config_reg1;
wire        [DATA_WIDTH-1:0] config_reg2;
wire        [DATA_WIDTH-1:0] config_reg3;

assign config_reg0 = config_reg[DATA_WIDTH-1:0]; 
assign config_reg1 = config_reg[DATA_WIDTH*2-1:DATA_WIDTH];
assign config_reg2 = config_reg[DATA_WIDTH*3-1:DATA_WIDTH*2];
assign config_reg3 = config_reg[DATA_WIDTH*4-1:DATA_WIDTH*3];

assign bypass        = config_reg0[0];
assign mode          = config_reg0[1];
assign iX            = config_reg1[31:0];
assign iX2           = config_reg2[31:0];
assign ilen          = config_reg3[MEM_SIZE_Y:0];

assign status_reg[0] = done;
assign status_reg[1] = busy;
assign status_reg[2] = stop_empty;
assign status_reg[3] = stop_Afull;
assign status_reg[4] = mode;
assign status_reg[5] = bypass;  

//-------------------------------------------------------------//

assign Read_Enable_fifo  = Read_Enable_w;                
assign Write_Enable_fifo = bypass  ? FIFO_bypass         : Write_Enable_w;                          
assign I_interp          = bypass  ? data_in_from_fifo_I : data_I;
assign Q_interp          = bypass  ? data_in_from_fifo_Q : data_Q;

//-------------------------------------------------------------//

intpol2_D4_Datapath#(
    .DATA_WIDTH      ( DATA_WIDTH ),
    .N_bits          ( N_bits     ),
    .M_bits          ( M_bits     ),
    .MEM_SIZE_Y      ( MEM_SIZE_Y )
)Datapath_I(
    .clk             ( clk                 ),
    .rstn            ( rstn                ),
    .clear           ( clear               ),
    .Ld_y            ( Ld_y                ),
    .Ld_M0           ( Ld_M0               ),
    .Ld_M1           ( Ld_M1               ),
    .Ld_M2           ( Ld_M2               ),
    .Ld_p1_xi        ( Ld_p1_xi            ),
    .en_sum          ( en_sum              ),
    .en_stream       ( en_stream           ),
    .sel_mult        ( sel_mult            ),
    .op_1            ( op_1                ),
    .sel_xi2         ( sel_xi2             ), 
    .data_to_process ( data_in_from_fifo_I ),
    .x               ( iX                  ),
    .x2              ( iX2                 ),
    .data_out        ( data_I              )
);

intpol2_D4_Datapath#(
    .DATA_WIDTH      ( DATA_WIDTH ),
    .N_bits          ( N_bits     ),
    .M_bits          ( M_bits     ),
    .MEM_SIZE_Y      ( MEM_SIZE_Y )
)Datapath_Q(
    .clk             ( clk                 ),
    .rstn            ( rstn                ),
    .clear           ( clear               ),
    .Ld_y            ( Ld_y                ),
    .Ld_M0           ( Ld_M0               ),
    .Ld_M1           ( Ld_M1               ),
    .Ld_M2           ( Ld_M2               ),
    .Ld_p1_xi        ( Ld_p1_xi            ),
    .en_sum          ( en_sum              ),
    .en_stream       ( en_stream           ),
    .sel_mult        ( sel_mult            ),
    .op_1            ( op_1                ),
    .sel_xi2         ( sel_xi2             ), 
    .data_to_process ( data_in_from_fifo_Q ),
    .x               ( iX                  ),
    .x2              ( iX2                 ),
    .data_out        ( data_Q              )
);
    

intpol2_D4_Controlpath#(
    .DATA_WIDTH     ( DATA_WIDTH     ),
    .MEM_SIZE_Y     ( MEM_SIZE_Y     ),
    .MEM_SIZE_M     ( MEM_SIZE_M     )
)Controlpath(
    .clk            ( clk            ),
    .rstn           ( rstn           ),
    .start          ( start          ),
    .mode           ( mode           ),
    .Empty_i        ( Empty_i        ),
    .Afull_i        ( Afull_i        ),
    .ilen           ( ilen           ),
    .bypass         ( bypass         ),
    .Y_addr         ( Y_addr         ),
    .Y_addr_bypass  ( Y_addr_bypass  ),
    .Ld_M0          ( Ld_M0          ),
    .Ld_M1          ( Ld_M1          ),
    .Ld_M2          ( Ld_M2          ),
    .sel_xi2        ( sel_xi2        ),
    .Write_bypass_Y ( Write_bypass_Y ),
    .FIFO_bypass    ( FIFO_bypass    ),
    .busy           ( busy           ),
    .Write_Enable_w ( Write_Enable_w ),
    .Read_Enable_w  ( Read_Enable_w  ),
    .Ld_y           ( Ld_y           ),
    .Ld_p1_xi       ( Ld_p1_xi       ),
    .en_sum         ( en_sum         ),
    .en_stream      ( en_stream      ),
    .op_1           ( op_1           ),
    .stop_empty     ( stop_empty     ),
    .stop_Afull     ( stop_Afull     ),
    .done           ( done           ),
    .sel_mult       ( sel_mult       ),
    .clear          ( clear          )
);


endmodule