/*
==============================================================================================
    Programer     : Emanuel Murillo García
    Contact       : emanuel.murillo@cinvestav.mx
                    emanuel.muga13@gmail.com

    Module Name   : intpol2_D4_CORE (TOP), Interpolador Cuadratico Diseño IV Dual datapath (IQ) Macro. 
    Type          : Verilog module
    
    Description   : Obtine los valores interpolados entre tres datos de entrada, M0, M1, M2.
                    Utilizando solo un multiplicador.
                    Realiza la aproximación con: y = p0 + p1*xi + p2*(xi)^2. Donde pi son los
                    coeficientes calculados "On-the-fly" y xi el factor de interpolación.
                    Se tiene dos entradas y dos salidas, en Fase (I) y en cuadratura (Q).
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
                    mode   = config_reg0[1];      Modo de operacion Accel/streaming                           
                    iX     = config_reg1[31:0];   Factor de interpolacion  
                    iX2    = config_reg2[31:0];   Factor de interpolacion^2          
                    ilen   = config_reg3[31:0];   Duración de iteración LENGHT 
                                        
                    -------------------------------------------------------------
    status_reg    :  status_reg[0] = done;
                     status_reg[1] = busy;
                     status_reg[2] = stop_empty;
                     status_reg[3] = stop_Afull;
                     status_reg[4] = Current_Mode; 
                     status_reg[5] = bypass;                      
-------------------------------------------------------------------------------------------------
    Version        : 2.3
    Date           : 21 Sep 2022
    Last update    : 10 Jan 2023
=================================================================================================            
*/

`define DUAL_DATAPATH 1			// <--- Descomentar para activar el doble datapath

module intpol2_D4_CORE #(
    parameter   CONFIG_WIDTH       =  32,                          // tamaño de palabra de config reg
    parameter   DATAPATH_WIDTH     =  12,                          // tamaño datapath
    parameter   N_bits             =  2,                           // Aumento de datapath
    parameter   M_bits             =  11,                          // Parte decimal
    parameter   MEM_ADDR_WIDTH     =  16
)
(     
    input                                   clk,
    input                                   rstn, 
    input                                   start,
    input                                   Empty_i,            // Fifo_in empty
    input                                   Afull_i,            // Fifo_out Almost full  
    input              [128-1:0]            config_reg,         // Configuracion
    input       signed [DATAPATH_WIDTH-1:0] data_from_mem_1,    // Data from Mem_I
    input       signed [DATAPATH_WIDTH-1:0] data_from_fifo_1,   // entrada desde FIFO_I   
`ifdef DUAL_DATAPATH
    input       signed [DATAPATH_WIDTH-1:0] data_from_mem_2,    // Data from Mem_I
    input       signed [DATAPATH_WIDTH-1:0] data_from_fifo_2,   // entrada desde FIFO_Q
`endif
    output wire        [MEM_ADDR_WIDTH-1:0] Read_addr_mem,      // Addr Mem_in
    output wire        [MEM_ADDR_WIDTH-1:0] Write_addr_mem,     // Addr Mem_out
    output wire                             Write_Enable_mem,   // Write Enable Mem_out   
    output wire                             Write_Enable_fifo,  
    output wire                             Read_Enable_fifo,   
    output wire        [8-1:0]              status_reg,         
    output wire signed [DATAPATH_WIDTH-1:0] data_out_1,           // Result I  
`ifdef DUAL_DATAPATH 
    output wire signed [DATAPATH_WIDTH-1:0] data_out_2            // Result Q   
`endif                                         
);

//-----------------------Connection signals--------------------//
wire                       mode;                               // Selección de modo Accel./Stream  
wire  [CONFIG_WIDTH-1:0]   ilen;
wire  [DATAPATH_WIDTH-1:0] iX;  
wire  [DATAPATH_WIDTH-1:0] iX2;  ;
wire  [CONFIG_WIDTH-1:0]   config_reg0;
wire  [CONFIG_WIDTH-1:0]   config_reg1;
wire  [CONFIG_WIDTH-1:0]   config_reg2;
wire  [CONFIG_WIDTH-1:0]   config_reg3;
wire  [DATAPATH_WIDTH-1:0] data_to_process_1;                // Select data to process MEM/FIFO 
wire  [DATAPATH_WIDTH-1:0] data_1;

`ifdef DUAL_DATAPATH
    wire  [DATAPATH_WIDTH-1:0] data_to_process_2;                // Select data to process MEM/FIFO
    wire  [DATAPATH_WIDTH-1:0] data_2     
`endif

wire                       en_sum;                           // enable del cnt y de la multi por sumatoria.
wire  [MEM_ADDR_WIDTH-1:0] M_addr;                           // Addr for Mem_in.
wire  [MEM_ADDR_WIDTH-1:0] Y_addr;                           // Addr for Mem_out.
wire  [MEM_ADDR_WIDTH-1:0] Y_addr_bypass;                    // Addr bypass for Mem_out.
wire                       en_stream;                        // stream flow control.
wire                       op_1;                             // calculo de coeficientes flag.   
wire                       sel_mult;                         // selector de entradas del multi_mux (reutilizacion del mult)
wire                       Ld_M0;                            // carga muestra 0.
wire                       Ld_M1;                            // carga muestra 1.  
wire                       Ld_M2;                            // carga muestra 2. 
wire                       Ld_data;                          // carga resultado.
wire                       Ld_p1_xi;                         // carga el valor p1*xi
wire                       Write_bypass_mem;                 // Write enable signal to Mem_out
wire                       Read_Enable;
wire                       Write_Enable;

//-----------------------Status signals------------------------//
wire                       done;
wire                       bypass;                           
wire                       busy; 
wire                       clear; 
wire                       stop_empty;
wire                       stop_Afull; 
wire          [1:0]        sel_xi2;
wire                       FIFO_bypass;

wire  signed [DATAPATH_WIDTH-1:0] max_Thold;
wire  signed [DATAPATH_WIDTH-1:0] min_Thold;

assign config_reg0   = config_reg[CONFIG_WIDTH-1:0]; 
assign config_reg1   = config_reg[CONFIG_WIDTH*2-1:CONFIG_WIDTH];
assign config_reg2   = config_reg[CONFIG_WIDTH*3-1:CONFIG_WIDTH*2];
assign config_reg3   = config_reg[CONFIG_WIDTH*4-1:CONFIG_WIDTH*3];

assign bypass        = config_reg0[0];
assign mode          = config_reg0[1];
assign iX            = config_reg1[DATAPATH_WIDTH-1:0];
assign iX2           = config_reg2[DATAPATH_WIDTH-1:0];
assign ilen          = config_reg3[CONFIG_WIDTH-1:0];

assign status_reg[0] = done;
assign status_reg[1] = busy;
assign status_reg[2] = stop_empty;
assign status_reg[3] = stop_Afull;
assign status_reg[4] = mode;
assign status_reg[5] = bypass;  

//--------------------------Input Muxes-----------------------//
assign data_to_process_1 = (mode)  ? data_from_fifo_1    : data_from_mem_1;
`ifdef DUAL_DATAPATH
    assign data_to_process_2 = (mode)  ? data_from_fifo_2    : data_from_mem_2;
`endif
//--------------------------Output Muxes-----------------------//
assign Read_addr_mem     = M_addr;
assign Write_addr_mem    = bypass  ? Y_addr_bypass       :  Y_addr;
assign Write_Enable_mem  = bypass  ? 
                           (~mode) ? Write_bypass_mem    : 1'b0   :
                           (~mode) ? Write_Enable        : 1'b0;
assign Write_Enable_fifo = bypass  ? FIFO_bypass         : Write_Enable; 
assign Read_Enable_fifo  = (mode)  ? Read_Enable         : 1'b0;                
assign data_out_1        = bypass  ? 
                           (mode)  ? data_from_fifo_1    : data_from_mem_1 
                                                         : data_1;
`ifdef 
    assign data_out_2    = bypass  ? 
                           (mode)  ? data_from_fifo_2    : data_from_mem_2 
                                                         : data_2;   
`endif                                                         

//---------------------Saturation threshold--------------------//

assign min_Thold = {1'b1,{DATAPATH_WIDTH-1{1'b0}}};
assign max_Thold = {1'b0,{DATAPATH_WIDTH-1{1'b1}}};

//-------------------------------------------------------------//
intpol2_D4_Datapath#(
    .DATAPATH_WIDTH  ( DATAPATH_WIDTH      ),
    .N_bits          ( N_bits              ),
    .M_bits          ( M_bits              )
)Datapath_1(
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
    .data_to_process ( data_to_process_1   ),
    .x               ( iX                  ),
    .x2              ( iX2                 ),
    .data_out        ( data_1              )
);

`ifdef DUAL_DATAPATH
intpol2_D4_Datapath#(
    .DATAPATH_WIDTH  ( DATAPATH_WIDTH      ),
    .N_bits          ( N_bits              ),
    .M_bits          ( M_bits              )
)Datapath_2(
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
    .data_to_process ( data_to_process_2   ),
    .x               ( iX                  ),
    .x2              ( iX2                 ),
    .data_out        ( data_2              )
);
`endif
    

intpol2_D4_Controlpath#(
    .DATAPATH_WIDTH   ( DATAPATH_WIDTH    ),
    .CONFIG_WIDTH     ( CONFIG_WIDTH      ),
    .MEM_ADDR_WIDTH   ( MEM_ADDR_WIDTH    )
)Controlpath(
    .clk              ( clk               ),
    .rstn             ( rstn              ),
    .start            ( start             ),
    .mode             ( mode              ),
    .Empty_i          ( Empty_i           ),
    .Afull_i          ( Afull_i           ),
    .ilen             ( ilen              ),
    .bypass           ( bypass            ),
    .Ld_M0            ( Ld_M0             ),
    .Ld_M1            ( Ld_M1             ),
    .Ld_M2            ( Ld_M2             ),
    .sel_xi2          ( sel_xi2           ),
    .FIFO_bypass      ( FIFO_bypass       ),
    .busy             ( busy              ),
    .Write_Enable     ( Write_Enable      ),
    .Ld_data          ( Ld_data           ),
    .Read_Enable      ( Read_Enable       ),
    .Y_addr           ( Y_addr            ),
    .Y_addr_bypass    ( Y_addr_bypass     ),
    .Write_bypass_mem ( Write_bypass_mem  ),
    .M_addr           ( M_addr            ),
    .Ld_p1_xi         ( Ld_p1_xi          ),
    .en_sum           ( en_sum            ),
    .en_stream        ( en_stream         ),
    .op_1             ( op_1              ),
    .stop_empty       ( stop_empty        ),
    .stop_Afull       ( stop_Afull        ),
    .done             ( done              ),
    .sel_mult         ( sel_mult          ),
    .clear            ( clear             )
);


endmodule