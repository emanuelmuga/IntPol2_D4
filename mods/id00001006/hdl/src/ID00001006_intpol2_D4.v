module ID00001006_intpol2_D4(
  clk,
  rst_a,
  en_s,
  data_in, //different data in information types
  data_out, //different data out information types
  write, //Used for protocol to write different information types
  read, //Used for protocol to read different information types
  start, //Used to start the IP-core
  conf_dbus, //Used for protocol to determine different actions types
  int_req, //Interruption request
  Afull_I_in,
  Afull_Q_in,
  Write_enable_i,
  Write_Enable_o,
  data_in_I,
  data_in_Q,
  Afull_I_o,
  Afull_Q_o,
  I_interp,
  Q_interp,
  done
);


  localparam DATA_WIDTH         = 32;
  localparam DATAPATH_WIDTH     = 12;
  localparam N_bits             = 2;     // Numero de bits parte ++entera
  localparam M_bits             = 11;    // Numero de bits parte fraccional
  localparam CONFIG_WIDTH       = 5;
  localparam FIFO_ADDR_WIDTH    = 3; 
  localparam MEM_ADDR_MAX_WIDTH = 16;     // Interface Memory lenght

  input  wire clk;
  input  wire rst_a;
  input  wire en_s;
  input  wire [DATA_WIDTH-1:0] data_in;   //different data in information types 
  input  wire write;                      //Used for protocol to write different information types
  input  wire read;                       //Used for protocol to read different information types
  input  wire start;                      //Used to start the IP-core
  input  wire [4:0] conf_dbus;            //Used for protocol to determine different actions types
  output wire int_req;                   //Interruption request
  output wire [DATA_WIDTH-1:0] data_out; //different data out information types
  output wire Write_Enable_o;
  output wire done;
  input  wire Afull_I_in;
  input  wire Afull_Q_in;
  output wire Afull_I_o;
  output wire Afull_Q_o;
  input  wire Write_enable_i;
  input  wire [DATAPATH_WIDTH-1:0] data_in_I;
  input  wire [DATAPATH_WIDTH-1:0] data_in_Q;
  output wire [DATAPATH_WIDTH-1:0] I_interp;
  output wire [DATAPATH_WIDTH-1:0] Q_interp;

  wire [CONFIG_WIDTH*DATA_WIDTH-1:0]  data_ConfigReg; 
  wire [DATA_WIDTH-1:0]               data_MemIn0;     //data readed for memory in 0
  wire [DATA_WIDTH-1:0]               data_MemIn1;     //data readed for memory in 0
  wire [MEM_ADDR_MAX_WIDTH-1:0]       wr_addr_MemOut; //address write for memory out 
  wire [MEM_ADDR_MAX_WIDTH-1:0]       rd_addr_MemIn;   //address read for memory in |
  wire wr_en_MemOut;                                   //enable write for memory out 0
  wire Read_Enable_fifo;
  wire Empty_intpol2;
  wire Afull_intpol2;
  wire start_IPcore; //Used to start the IP-core
  wire [DATAPATH_WIDTH-1:0] data_from_fifo_I;
  wire [DATAPATH_WIDTH-1:0] data_from_fifo_Q;

  wire [8-1:0] status_IPcore; //data of IP-core to set the flags value

  wire statusIPcore_Busy;
  wire intIPCore_Done;
  wire statusIPcore_Empty;
  wire statusIPcore_Afull;
  wire statusIPcore_Current_Mode;
  wire statusIPcore_Bypass;
 
  wire Empty_Indica_I;
  wire Empty_Indica_Q;

  assign intIPCore_Done            = status_IPcore[0];
  assign statusIPcore_Busy         = status_IPcore[1];
  assign statusIPcore_Empty        = status_IPcore[2];
  assign statusIPcore_Afull        = status_IPcore[3];
  assign statusIPcore_Current_Mode = status_IPcore[4];
  assign statusIPcore_Bypass       = status_IPcore[5];
  
  assign done = status_IPcore[0];
  
  assign Empty_intpol2 = Empty_Indica_I | Empty_Indica_Q;
  assign Afull_intpol2 = Afull_I_in     | Afull_Q_in;

ID00001006_aip INTERFACE(
    .clk                       ( clk                       ),
    .rst                       ( rst_a                     ),
    .en                        ( en_s                      ),
    .dataInAIP                 ( data_in                   ),
    .dataOutAIP                ( data_out                  ),
    .configAIP                 ( conf_dbus                 ),
    .readAIP                   ( read                      ),
    .writeAIP                  ( write                     ),
    .startAIP                  ( start                     ),
    .intAIP                    ( int_req                   ),
    .rdDataMemIn_0             ( data_MemIn0               ),
    .rdDataMemIn_1             ( data_MemIn1               ),
    .rdAddrMemIn_0             ( rd_addr_MemIn             ),
    .rdAddrMemIn_1             ( rd_addr_MemIn             ),
    .wrDataMemOut_0            ( I_interp                  ),
    .wrDataMemOut_1            ( Q_interp                  ),
    .wrAddrMemOut_0            ( wr_en_MemOut              ),
    .wrAddrMemOut_1            ( wr_en_MemOut              ),
    .wrEnMemOut_0              ( wrEnMemOut                ),
    .wrEnMemOut_1              ( wrEnMemOut                ),
    .rdDataConfigReg           ( data_ConfigReg            ),
    .statusIPcore_Busy         ( statusIPcore_Busy         ),
    .statusIPcore_Empty        ( statusIPcore_Empty        ),
    .statusIPcore_Afull        ( statusIPcore_Afull        ),
    .statusIPcore_Current_Mode ( statusIPcore_Current_Mode ),
    .statusIPcore_Bypass       ( statusIPcore_Bypass       ),
    .intIPCore_Done            ( intIPCore_Done            ),
    .startIPcore               ( start_IPcore              )
);

intpol2_D4_CORE#(
    .CONFIG_WIDTH      ( DATA_WIDTH        ),
    .DATAPATH_WIDTH    ( DATAPATH_WIDTH    ),
    .N_bits            ( N_bits            ),
    .M_bits            ( M_bits            ),
    .MEM_ADDR_WIDTH    ( $clog2(MEM_ADDR_MAX_WIDTH) )
)CORE(
    .clk               ( clk               ),
    .rstn              ( rst_a             ),
    .start             ( start_IPcore      ),
    .Empty_i           ( Empty_intpol2     ),
    .Afull_i           ( Afull_intpol2     ),
    .config_reg        ( data_ConfigReg    ),
    .data_from_mem_I   ( data_MemIn0       ),
    .data_from_mem_Q   ( data_MemIn1       ), 
    .data_from_fifo_I  ( data_from_fifo_I  ),
    .data_from_fifo_Q  ( data_from_fifo_Q  ),
    .Read_addr_mem     ( rd_addr_MemIn     ),
    .Write_addr_mem    ( wr_addr_MemOut    ),
    .Write_Enable_mem  ( wr_en_MemOut      ),
    .Write_Enable_fifo ( Write_Enable_o    ),
    .Read_Enable_fifo  ( Read_Enable_fifo  ),
    .status_reg        ( status_IPcore     ),
    .I_interp          ( I_interp          ),
    .Q_interp          ( Q_interp          )
);

//-----------FIFOs de entrada-------------------------//

DC_FIFO_AF_AE #(
    .DATA_WIDTH(DATAPATH_WIDTH) ,                      // Datawidth of data
    .ADDR_WIDTH(FIFO_ADDR_WIDTH)                   // Address bits   ( )
) FIFO_I (
    .Write_clock__i   ( clk                  ),    // posedge active
    .Write_enable_i   (	Write_enable_i       ),    // High active
    .rst_async_la_i   ( rst_a		         ),    // Asynchronous reset low active for reader clock
    .Read_clock___i   ( clk                  ),    // Posedge active 
    .Read_enable__i   ( Read_Enable_fifo     ),    // High active
    .differenceAF_i   (	3'h2                 ),    // Difference (memory locations) between AF & Full flag
    .differenceAE_i   (	3'h2                 ),    // Difference (memory locations) between AE & Empty flag
    .data_input___i   (	data_in_I            ),
    .data_output__o   (	data_from_fifo_I     ),
    .Empty_Indica_o   (	Empty_Indica_I       ),    // Empty FIFO indicator synchronized with Read clock
    .Full_Indicat_o   (		                 ),    // Set by the write clock and cleared by the reading clock
    .Almost_Full__o   (	Afull_I_o            ),    
    .Almost_Empty_o   (		                 )
);

DC_FIFO_AF_AE #(
    .DATA_WIDTH(DATAPATH_WIDTH) ,                  // Datawidth of data
    .ADDR_WIDTH(FIFO_ADDR_WIDTH)                   // Address bits   ( )
) FIFO_Q (
    .Write_clock__i   ( clk                  ),    // posedge active
    .Write_enable_i   (	Write_enable_i       ),    // High active
    .rst_async_la_i   ( rst_a		         ),    // Asynchronous reset low active for reader clock
    .Read_clock___i   ( clk                  ),    // Posedge active 
    .Read_enable__i   ( Read_Enable_fifo     ),    // High active
    .differenceAF_i   (	3'h2                 ),    // Difference (memory locations) between AF & Full flag
    .differenceAE_i   (	3'h2                 ),    // Difference (memory locations) between AE & Empty flag
    .data_input___i   (	data_in_Q            ),
    .data_output__o   (	data_from_fifo_Q     ),
    .Empty_Indica_o   (	Empty_Indica_Q       ),    // Empty FIFO indicator synchronized with Read clock
    .Full_Indicat_o   (		                 ),    // Set by the write clock and cleared by the reading clock
    .Almost_Full__o   (	Afull_Q_o            ),    
    .Almost_Empty_o   (		                 )
);

endmodule