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


  localparam DATA_WIDTH      = 32;
  localparam DATAPATH_WIDTH  = 12;
  localparam N_bits          = 2;     // Numero de bits parte ++entera
  localparam M_bits          = 11;    // Numero de bits parte fraccional
  localparam CONFIG_WIDTH    = 5;
  localparam FIFO_ADDR_WIDTH = 3; 
  localparam MEM_ADDR_WIDTH  = 4;

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
 
  output wire Write_Enable_o;
  output wire done;
  input wire Afull_I_in;
  input wire Afull_Q_in;
  output wire Afull_I_o;
  output wire Afull_Q_o;
  input wire Write_enable_i;
  input wire [DATAPATH_WIDTH-1:0] data_in_I;
  input wire [DATAPATH_WIDTH-1:0] data_in_Q;
  output wire [DATAPATH_WIDTH-1:0] I_interp;
  output wire [DATAPATH_WIDTH-1:0] Q_interp;

  wire [CONFIG_WIDTH*DATA_WIDTH-1:0] data_ConfigReg; 

  wire Read_Enable_fifo;
  wire Empty_intpol2;
  wire Afull_intpol2;
  wire start_IPcore; //Used to start the IP-core
  wire [DATAPATH_WIDTH-1:0] data_in_from_fifo_I;
  wire [DATAPATH_WIDTH-1:0] data_in_from_fifo_Q;

  wire [8-1:0] status_IPcore; //data of IP-core to set the flags value

  wire statusIPcore_Busy;
  wire intIPCore_Done;
  wire statusIPcore_stop_empty;
  wire statusIPcore_stop_Afull;
  wire statusIPcore_mode;
  wire statusIPcore_bypass;
 
  wire Empty_Indica_I;
  wire Empty_Indica_Q;

  assign intIPCore_Done          = status_IPcore[0];
  assign statusIPcore_Busy       = status_IPcore[1];
  assign statusIPcore_stop_empty = status_IPcore[2];
  assign statusIPcore_stop_Afull = status_IPcore[3];
  assign statusIPcore_mode       = 1'b0;
  assign statusIPcore_bypass     = status_IPcore[5];
  
  assign done = status_IPcore[0];
  
  assign Empty_intpol2 = Empty_Indica_I | Empty_Indica_Q;
  assign Afull_intpol2 = Afull_I_in | Afull_Q_in;


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
    .rdDataConfigReg         ( data_ConfigReg          ),
    .statusIPcore_Busy       ( statusIPcore_Busy       ),
    .statusIPcore_stop_empty ( statusIPcore_stop_empty ),
    .statusIPcore_stop_Afull ( statusIPcore_stop_Afull ),
    .statusIPcore_bypass     ( statusIPcore_bypass     ),
    .intIPCore_Done          ( intIPCore_Done          ),
    .startIPcore             ( start_IPcore            )
);



intpol2_D4_CORE#(
    .DATAPATH_WIDTH      ( DATAPATH_WIDTH      ),
    .MEM_ADDR_WIDTH      ( MEM_ADDR_WIDTH      ),
    .N_bits              ( N_bits              ),
    .M_bits              ( M_bits              )
)CORE(
    .clk                 ( clk                 ),
    .rstn                ( rst_a                ),
    .start               ( start_IPcore        ),
    .Empty_i             ( Empty_intpol2       ),
    .Afull_i             ( Afull_intpol2       ),
    .config_reg          ( data_ConfigReg      ),
    .data_in_from_fifo_I ( data_in_from_fifo_I ),
    .data_in_from_fifo_Q ( data_in_from_fifo_Q ),
    .Write_Enable_fifo   ( Write_Enable_o      ),
    .Read_Enable_fifo    ( Read_Enable_fifo    ),
    .status_reg          ( status_IPcore       ),
    .I_interp            ( I_interp            ),
    .Q_interp            ( Q_interp            )
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
    .data_input___i   (	data_in_Q            ),
    .data_output__o   (	data_in_from_fifo_I  ),
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
    .data_output__o   (	data_in_from_fifo_Q  ),
    .Empty_Indica_o   (	Empty_Indica_Q       ),    // Empty FIFO indicator synchronized with Read clock
    .Full_Indicat_o   (		                 ),    // Set by the write clock and cleared by the reading clock
    .Almost_Full__o   (	Afull_Q_o            ),    
    .Almost_Empty_o   (		                 )
);

endmodule