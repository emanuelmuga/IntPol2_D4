module ID00001006_intpol2_V4(
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
  Afull_i,
  Afull_o,
  Write_Enable_fifo_i,
  data_in_fifo
);


  localparam DATA_WIDTH      = 32;
  localparam N_bits          = 2;     // Numero de bits parte entera
  localparam MEM_SIZE_M      = 4;     //define Memory In depth
  localparam MEM_SIZE_Y      = 128;   //define Memory Out depth
  localparam CONFIG_WIDTH    = 5;
  localparam FIFO_ADDR_WIDTH = 3; 

  input wire clk;
  input wire rst_a;
  input wire en_s;
  input wire [DATA_WIDTH-1:0] data_in; //different data in information types
  output wire [DATA_WIDTH-1:0] data_out; //different data out information types
  input wire write; //Used for protocol to write different information types
  input wire read; //Used for protocol to read different information types
  input wire start; //Used to start the IP-core
  input wire [4:0] conf_dbus; //Used for protocol to determine different actions types
  output wire int_req; //Interruption request

  input wire Afull_i;
  output wire Afull_o;
  input wire Write_Enable_fifo_i;
  input wire [DATA_WIDTH-1:0] data_in_fifo;

  wire [DATA_WIDTH-1:0] data_MemIn0; //data readed for memory in 0
  wire [MEM_SIZE_M-1:0] rd_addr_MemIn0; //address read for memory in 0

  wire [CONFIG_WIDTH*DATA_WIDTH-1:0] data_ConfigReg; 

  wire [DATA_WIDTH-1:0] data_MemOut0; //data to write for memory out 0
  wire [MEM_SIZE_Y-1:0] wr_addr_MemOut0; //address write for memory out 0
  wire wr_en_MemOut0; //enable write for memory out 0

  wire                         Read_Enable_fifo;
  wire                         Empty_intpol2;
  wire signed [DATA_WIDTH-1:0] data_fifo_to_intpol2;

  wire start_IPcore; //Used to start the IP-core

  wire [8-1:0] status_IPcore; //data of IP-core to set the flags value

  wire statusIPcore_Busy;
  wire intIPCore_Done;
  wire statusIPcore_stop_empty;
  wire statusIPcore_stop_Afull;
  wire statusIPcore_mode;
  wire statusIPcore_bypass;
 
  assign intIPCore_Done          = status_IPcore[0];
  assign statusIPcore_Busy       = status_IPcore[1];
  assign statusIPcore_stop_empty = status_IPcore[2];
  assign statusIPcore_stop_Afull = status_IPcore[3];
  assign statusIPcore_mode       = status_IPcore[4];
  assign statusIPcore_bypass     = status_IPcore[5];


ID00001006_aip INTERFACE(
    .clk                     ( clk                     ),
    .rst                     ( rst_a                   ),
    .en                      ( en_s                    ),
    .dataInAIP               ( data_in                 ),
    .dataOutAIP              ( data_out                ),
    .configAIP               ( conf_dbus               ),
    .readAIP                 ( read                    ),
    .writeAIP                ( write                   ),
    .startAIP                ( start                   ),
    .intAIP                  ( int_req                 ),
    .rdDataMemIn_0           ( data_MemIn0             ),
    .rdAddrMemIn_0           ( rd_addr_MemIn0          ),
    .wrDataMemOut_0          ( data_MemOut0            ),
    .wrAddrMemOut_0          ( wr_addr_MemOut0         ),
    .wrEnMemOut_0            ( wr_en_MemOut0           ),
    .rdDataConfigReg         ( data_ConfigReg          ),
    .statusIPcore_Busy       ( statusIPcore_Busy       ),
    .statusIPcore_stop_empty ( statusIPcore_stop_empty ),
    .statusIPcore_stop_Afull ( statusIPcore_stop_Afull ),
    .statusIPcore_mode       ( statusIPcore_mode       ),
    .statusIPcore_bypass     ( statusIPcore_bypass     ),
    .intIPCore_Done          ( intIPCore_Done          ),
    .startIPcore             ( start_IPcore            )
);


intpol2_D4_CORE#(
    .DATA_WIDTH              ( DATA_WIDTH            ),
    .N_bits                  ( N_bits                ),
    .M_bits                  ( 31                    ),
    .MEM_SIZE_Y              ( $clog2(MEM_SIZE_Y)    ),
    .MEM_SIZE_M              ( MEM_SIZE_M            )
)CORE(
    .clk                     ( clk                   ),
    .rstn                    ( rst_a                 ),
    .start                   ( start_IPcore          ),
    .Afull_i                 ( Afull_i               ),
    .Empty_i                 ( Empty_intpol2         ),
    .data_in_from_fifo       ( data_fifo_to_intpol2  ),
    .data_in_mem             ( data_MemIn0           ),
    .config_reg              ( data_ConfigReg        ),
    .M_addr_o                ( rd_addr_MemIn0        ),
    .Y_addr_o                ( wr_addr_MemOut0       ),
    .Read_Enable_fifo        ( Read_Enable_fifo      ),
    .Write_Enable_Y          ( wr_en_MemOut0         ),
    .status_reg              ( status_IPcore         ),
    .data_out                ( data_MemOut0          )
);


//-----------FIFO de entrada-------------------------//

DC_FIFO_AF_AE #(
    .DATA_WIDTH(DATA_WIDTH) ,                      // Datawidth of data
    .ADDR_WIDTH(FIFO_ADDR_WIDTH)                   // Address bits   ( )
) FIFO_IN (
    .Write_clock__i   ( clk                  ),    // posedge active
    .Write_enable_i   (	Write_Enable_fifo_i  ),    // High active
    .rst_async_la_i   ( rst_a		         ),    // Asynchronous reset low active for reader clock
    .Read_clock___i   ( clk                  ),    // Posedge active 
    .Read_enable__i   ( Read_Enable_fifo     ),    // High active
    .differenceAF_i   (	3'h2                 ),    // Difference (memory locations) between AF & Full flag
    .differenceAE_i   (	3'h2                 ),    // Difference (memory locations) between AE & Empty flag
    .data_input___i   (	data_in_fifo         ),
    .data_output__o   (	data_fifo_to_intpol2 ),
    .Empty_Indica_o   (	Empty_intpol2        ),    // Empty FIFO indicator synchronized with Read clock
    .Full_Indicat_o   (		                 ),    // Set by the write clock and cleared by the reading clock
    .Almost_Full__o   (	Afull_o              ),    
    .Almost_Empty_o   (		                 )
);

endmodule