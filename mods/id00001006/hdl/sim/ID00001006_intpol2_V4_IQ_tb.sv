module ID00001006_intpol2_V4_IQ_tb();
localparam DATA_WIDTH     = 32;
localparam DATAPATH_WIDTH = 32;

reg clk;
reg rst_a;
reg en_s;
reg [DATA_WIDTH-1:0] data_in;
wire [DATA_WIDTH-1:0] data_out;
reg write;
reg read;
reg start;
reg [4:0] conf_dbus;
wire int_req;

wire Afull_I_in;
wire Afull_Q_in;
wire Write_enable_i;
wire Write_Enable_o;
wire Afull_I_o;
wire Afull_Q_o;

wire Afull_from_DUT;

wire [DATAPATH_WIDTH-1:0] data2interp;

wire [DATAPATH_WIDTH-1:0] I_interp;
wire [DATAPATH_WIDTH-1:0] Q_interp;
wire done;          

assign Afull_from_DUT = Afull_I_o | Afull_Q_o;

reg [128-1:0] config_source;

Source#(
    .DATA_WIDTH ( DATAPATH_WIDTH ),
    .MEM_SIZE_M ( $clog2(100)    )
)Source(
    .clk        ( clk            ),
    .rstn       ( rst_a          ),
    .start_i    ( start          ),
    .Afull_i    ( Afull_from_DUT ),
    .config_reg ( config_source  ),
    .data_in    ( data_in        ),
    .WE_fifo_o  ( WE_fifo_o      ),
    .status_reg ( status_reg     ),
    .addr_Mem_o ( addr_Mem_o     ),
    .data_o     ( data2interp    )
);



ID00001006_intpol2_V4_IQ DUT(
    .clk            ( clk            ),
    .rst_a          ( rst_a          ),
    .en_s           ( en_s           ),
    .data_in        ( data_in        ),
    .data_out       ( data_out       ),
    .write          ( write          ),
    .read           ( read           ),
    .start          ( start          ),
    .conf_dbus      ( conf_dbus      ),
    .int_req        ( int_req        ),
    .Afull_I_in     ( Afull_I_in     ),
    .Afull_Q_in     ( Afull_Q_in     ),
    .Write_enable_i ( Write_enable_i ),
    .Write_Enable_o ( Write_Enable_o ),
    .data_in_I      ( data2interp    ),
    .data_in_Q      ( data2interp    ),
    .Afull_I_o      ( Afull_I_o      ),
    .Afull_Q_o      ( Afull_Q_o      ),
    .I_interp       ( I_interp       ),
    .Q_interp       ( Q_interp       ),
    .done           ( done           )
);


Sink#(
    .DATA_WIDTH     ( DATAPATH_WIDTH ),
    .MEM_SIZE_Y     ( $clog2(256) )
)SINK_I(
    .clk            ( clk            ),
    .rstn           ( rst_a          ),
    .start_i        ( start_i        ),
    .Empty_i        ( Empty_i        ),
    .data_depth     ( data_depth     ),
    .data_in        ( I_interp       ),
    .Read_Enable_o  ( Read_Enable_o  ),
    .addr_Mem_o     ( addr_Mem_o     ),
    .Write_Enable_o ( Write_Enable_o ),
    .data_out       ( data_out       ),
    .done           ( done           )
);

Sink#(
    .DATA_WIDTH     ( DATAPATH_WIDTH ),
    .MEM_SIZE_Y     ( $clog2(256) )
)SINK_Q(
    .clk            ( clk            ),
    .rstn           ( rst_a          ),
    .start_i        ( start_i        ),
    .Empty_i        ( Empty_i        ),
    .data_depth     ( data_depth     ),
    .data_in        ( Q_interp       ),
    .Read_Enable_o  ( Read_Enable_o  ),
    .addr_Mem_o     ( addr_Mem_o     ),
    .Write_Enable_o ( Write_Enable_o ),
    .data_out       ( data_out       ),
    .done           ( done           )
);





  task write_interface;
    input [4:0] write_conf_dbus;
    input [31:0] write_data;
    begin
      conf_dbus = write_conf_dbus;
      data_in = write_data;
      #2
      write = 1'b1;
      #2;
      write = 1'b0;
      #10;
    end
  endtask

  task read_interface;
    input [4:0] read_conf_dbus;
    output [31:0] read_data;
    begin
      conf_dbus = read_conf_dbus;
      #2
      read = 1'b1;
      #2;
      read_data = data_out;
      read = 1'b0;
      #10;
    end
  endtask

  task start_interface;
    begin
      start = 1'b1;
      #2;
      start = 1'b0;
      #10;
    end
  endtask

always begin
    #1 clk = ~clk;
  end

initial
  begin
    rst_a = 0;
    clk = 0;

    conf_dbus = 0;
    read = 0;
    write = 0;
    start = 0;
    data_in = 0;

    en_s = 0;

    //Config Source and Source

    config_source[7:0]    = 'd100;  //data_depth
    config_source[15:8]   = 'd00;   //offset
    config_source[17:16]  =  2'b00; //mode

    // Wait for global reset to finish
    #10;
    rst_a = 1'b1;
    en_s = 1'b1;
    #10;


    // READ IP_ID
    read_interface(5'b11111, tb_data);
    $display ("Read data %h", tb_data);

    // SET PTR MEM IN
    write_interface(5'b00001, 32'h00000000);

    // WRITE MEM IN
    for (int i = 0; i < 2**SIZE_MEM; i++) begin
      dataSet[i] = $urandom();
      write_interface(5'b00000, dataSet[i]);
    end

    // START PROCESS
    start_interface();

    // SET PTR MEM OUT
    write_interface(5'b00011, 32'h00000000);

    // READ MEM OUT
    $display ("\t\t I \t\t O \t\t Result");
    for (int i = 0; i < 2**SIZE_MEM; i++) begin
      read_interface(5'b00010, tb_data);
      $display ("Read data %2d \t %8h \t %8h \t %s", i, dataSet[i], tb_data, (dataSet[i] == tb_data ? "OK": "ERROR"));
    end

    #100;
    $stop;
  end

//==========================End Test Bench =======================================//

//-------------------Memoria de entrada M------------------//

module signal_mem #(
    parameter   DATA_WIDTH = 16,
    parameter   SIGNAL_SIZE  = $clog2(128)
)(
    input      clk,
    input      [SIGNAL_SIZE-1:0] M_addr,
    output reg [DATA_WIDTH-1:0] data_out
);

    reg [DATA_WIDTH-1:0] mem [0:(2**SIGNAL_SIZE)-1];

    always @(posedge clk) begin
        data_out <= mem[M_addr];
    end

integer i;    
initial begin
    for (i = 0; i < 2**SIGNAL_SIZE; i = i + 1) begin
        mem[i] =  i;
    end
end


endmodule