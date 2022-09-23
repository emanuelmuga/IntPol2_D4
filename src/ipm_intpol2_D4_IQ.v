module ipm_intpol2_D4_IQ
#(
  parameter DATA_WIDTH = 32,
  parameter DATAPATH_WIDTH = 32,
  parameter CONF_WIDTH = 5
)
(
  // Main
  input clk,
  input rst,
  input [3:0] addressMCU,
  input rstMCU,
  input rdMCU,
  input wrMCU,
  inout [7:0] dataMCU,
  output wire intMCU,
  // IP
  input Afull_I_in,
  input Afull_Q_in,
  input Write_enable_i,
  input [DATAPATH_WIDTH-1:0] data_in_I,
  input [DATAPATH_WIDTH-1:0] data_in_Q,
  output wire Write_Enable_o,
  output wire Afull_I_o,
  output wire Afull_Q_o,
  output wire [DATAPATH_WIDTH-1:0] I_interp,
  output wire [DATAPATH_WIDTH-1:0] Q_interp,
  output wire done          
);

  wire wireReset;
  wire [DATA_WIDTH-1:0] wireDataIPtoMCU;
  wire [DATA_WIDTH-1:0] wireDataMCUtoIP;
  wire [CONF_WIDTH-1:0] wireConf;
  wire wireReadIP;
  wire wireWriteIP;
  wire wireStartIP;
  wire wireINT;

  assign wireReset = rst & rstMCU;

  ipm
  IPM
  (
    .clk_n_Hz(clk),
    .ipm_RstIn(wireReset),

    // MCU
    .ipmMCUDataInout(dataMCU),
    .ipmMCUAddrsIn(addressMCU),
    .ipmMCURdIn(rdMCU),
    .ipmMCUWrIn(wrMCU),
    .ipmMCUINTOut(intMCU),

    // IP
    .ipmPIPDataIn(wireDataIPtoMCU),
    .ipmPIPConfOut(wireConf),
    .ipmPIPReadOut(wireReadIP),
    .ipmPIPWriteOut(wireWriteIP),
    .ipmPIPStartOut(wireStartIP),
    .ipmPIPDataOut(wireDataMCUtoIP),
    .ipmPIPINTIn(wireINT)
);

// ID00001006_intpol2_V4 IP_MODULE(
//     .clk                 ( clk                 ),
//     .rst_a               ( wireReset           ),
//     .en_s                ( 1'b1                ),
//     .data_in             ( wireDataMCUtoIP     ),
//     .data_out            ( wireDataIPtoMCU     ),
//     .write               ( wireWriteIP         ),
//     .read                ( wireReadIP          ),
//     .start               ( wireStartIP         ),
//     .conf_dbus           ( wireConf            ),
//     .int_req             ( wireINT             ),
//     .Afull_i             ( Afull_i             ),
//     .Afull_o             ( Afull_o             ),
//     .Write_Enable_fifo_i ( Write_Enable_fifo_i ),
//     .data_in_fifo        ( data_in_fifo        )
// );

ID00001006_intpol2_V4_IQ IP_MODULE(
    .clk            ( clk              ),
    .rst_a          ( rst              ),
    .en_s           ( 1'b1             ),
    .data_in        ( wireDataMCUtoIP  ),
    .data_out       ( wireDataIPtoMCU  ),
    .write          ( wireWriteIP      ),
    .read           ( wireReadIP       ),
    .start          ( wireStartIP      ),
    .conf_dbus      ( wireConf         ),
    .int_req        ( wireINT          ),
    .Afull_I_in     ( Afull_I_in       ),
    .Afull_Q_in     ( Afull_Q_in       ),
    .Write_enable_i ( Write_enable_i   ),
    .Write_Enable_o ( Write_Enable_o   ),
    .data_in_I      ( data_in_I        ),
    .data_in_Q      ( data_in_Q        ),
    .Afull_I_o      ( Afull_I_o        ),
    .Afull_Q_o      ( Afull_Q_o        ),
    .I_interp       ( I_interp         ),
    .Q_interp       ( Q_interp         ),
    .done           ( done             )
);



endmodule