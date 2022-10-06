`timescale 1ns/100ps
 
module intpol2_D4_IQ_tb();

localparam   CONFIG_WIDTH = 32;
localparam   ADDR_WIDTH = $clog2(2**20);
// localparam   ADDR_WIDTH = 32;
 
localparam   DATA_WIDTH  =  12; 
localparam    N_bits      =  4;                               //N <= parte entera
localparam    M_bits      =  11;                              //M = parte decimal
localparam   FIFO_ADDR_WIDTH = 3;
localparam SF  = 2.0**-(M_bits);                //scaling factor

localparam   BYPASS          = 0;   //bypass   ~OFF/ON           


reg                           clk;
reg                           rstn; 
reg                           start;

reg         [CONFIG_WIDTH-1:0]  config_reg0;
reg         [CONFIG_WIDTH-1:0]  config_reg1;
reg         [CONFIG_WIDTH-1:0]  config_reg2;
reg         [CONFIG_WIDTH-1:0]  config_reg3;

wire               [128-1:0]  config_reg;
wire                          WE_fifo_in;
wire                          RE_fifo_out;
wire signed [DATA_WIDTH-1:0]  data_in_fifo;
wire signed [DATA_WIDTH-1:0]  data_out_fifo;
wire                          Empty_intpol2;
wire                          Afull_intpol2;

wire signed [DATA_WIDTH-1:0]  data_out_intpol2; 
wire                          WE_fifo_out;
wire                          RE_fifo_in;
wire                          done;
wire                          busy;
wire        [8-1:0]           status_reg;

wire signed [DATA_WIDTH-1:0] data_in_from_fifo_I;
wire signed [DATA_WIDTH-1:0] data_in_from_fifo_Q;
wire signed [DATA_WIDTH-1:0] I_interp;
wire signed [DATA_WIDTH-1:0] Q_interp;
wire signed [DATA_WIDTH-1:0] data_out_from_fifo_I;
wire signed [DATA_WIDTH-1:0] data_out_from_fifo_Q;


wire Empty_Indica_I;
wire Empty_Indica_Q;
wire Almost_Full_I;
wire Almost_Full_Q;
wire Empty_fifo_out;
reg en;
wire [ADDR_WIDTH-1:0] M_addr;
wire Afull_fifo_in;
wire [ADDR_WIDTH-1:0] Y_addr;
wire WE_Y;

wire Almost_Empty_FIFO_in;
wire [ADDR_WIDTH-1:0] ilen;
wire comp_len;
wire done_sink;
wire [ADDR_WIDTH-1:0] total_len;

assign Empty_intpol2 = Empty_Indica_I | Empty_Indica_Q;
assign Afull_intpol2 = Almost_Full_I | Almost_Full_Q;

assign done = status_reg[0];
assign busy = status_reg[1];

assign config_reg[CONFIG_WIDTH-1:0]              = config_reg0; 
assign config_reg[CONFIG_WIDTH*2-1:CONFIG_WIDTH]   = config_reg1;
assign config_reg[CONFIG_WIDTH*3-1:CONFIG_WIDTH*2] = config_reg2;
assign config_reg[CONFIG_WIDTH*4-1:CONFIG_WIDTH*3] = config_reg3;

assign ilen = config_reg3[ADDR_WIDTH-1:0];


intpol2_D4_IQ_CORE#(
    .CONFIG_WIDTH        ( CONFIG_WIDTH        ),
    .DATA_WIDTH          ( DATA_WIDTH          ),
    .N_bits              ( N_bits              ),
    .M_bits              ( M_bits              )
)DUT(
    .clk                 ( clk                 ),
    .rstn                ( rstn                ),
    .start               ( start               ),
    .Empty_i             ( Empty_intpol2       ),
    .Afull_i             ( Afull_intpol2       ),
    .config_reg          ( config_reg          ),
    .data_in_from_fifo_I ( data_in_from_fifo_I ),
    .data_in_from_fifo_Q ( data_in_from_fifo_Q ),
    .Write_Enable_fifo   ( WE_fifo_out         ),
    .Read_Enable_fifo    ( RE_fifo_in          ),
    .status_reg          ( status_reg          ),
    .I_interp            ( I_interp            ),
    .Q_interp            ( Q_interp            )
);


Source_sim#(
    .ADDR_WIDTH ( ADDR_WIDTH )
)Source_sim(
    .clk   ( clk           ),
    .rst   ( rstn          ),
    .en    ( en            ),
    .Afull ( Afull_fifo_in ),
    .addr  ( M_addr          ),
    .WE    ( WE_fifo_in    )
);

M_mem#(
    .DATA_WIDTH ( DATA_WIDTH ),
    .MEM_SIZE_M ( ADDR_WIDTH )
)M_MEM(
    .clk        ( clk            ),
    .M_addr     ( M_addr         ),
    .data_out   ( data_in_fifo   )
);

Sink_sim#(
    .ADDR_WIDTH     ( ADDR_WIDTH ),
    .CONFIG_WIDTH   ( CONFIG_WIDTH  )
)Sink_sim(
    .clk            ( clk            ),
    .rstn           ( rstn           ),
    .start_i        ( start          ),
    .Empty_i        ( Empty_fifo_out ),
    .ilen           ( total_len      ),
    .addr           ( Y_addr         ),
    .Read_Enable_o  ( RE_fifo_out    ),
    .Write_Enable_o ( WE_Y           ),
    .done           ( done_sink      )
);


Y_mem#(
    .DATA_WIDTH ( DATA_WIDTH ),
    .MEM_SIZE_Y ( ADDR_WIDTH )
)Y_mem(
    .clk        ( clk                   ),
    .Y_addr     ( Y_addr                ),
    .WE         ( WE_Y                  ),
    .data_in    ( data_out_from_fifo_I  )
);


//-----------FIFOs de entrada-------------------------//

DC_FIFO_AF_AE #(
    .DATA_WIDTH(DATA_WIDTH) ,                      // Datawidth of data
    .ADDR_WIDTH(FIFO_ADDR_WIDTH)                   // Address bits   ( )
) FIFO_I_in (
    .Write_clock__i   ( clk                  ),    // posedge active
    .Write_enable_i   (	WE_fifo_in           ),    // High active
    .rst_async_la_i   ( rstn		         ),    // Asynchronous reset low active for reader clock
    .Read_clock___i   ( clk                  ),    // Posedge active 
    .Read_enable__i   ( RE_fifo_in           ),    // High active
    .differenceAF_i   (	3'h2                 ),    // Difference (memory locations) between AF & Full flag
    .differenceAE_i   (	3'h2                 ),    // Difference (memory locations) between AE & Empty flag
    .data_input___i   (	data_in_fifo         ),
    .data_output__o   (	data_in_from_fifo_I  ),
    .Empty_Indica_o   (	Empty_Indica_I       ),    // Empty FIFO indicator synchronized with Read clock
    .Full_Indicat_o   (		                 ),    // Set by the write clock and cleared by the reading clock
    .Almost_Full__o   (	Afull_fifo_in        ),    
    .Almost_Empty_o   (	Almost_Empty_FIFO_in )
);

DC_FIFO_AF_AE #(
    .DATA_WIDTH(DATA_WIDTH) ,                      // Datawidth of data
    .ADDR_WIDTH(FIFO_ADDR_WIDTH)                   // Address bits   ( )
) FIFO_Q_in (
    .Write_clock__i   ( clk                  ),    // posedge active
    .Write_enable_i   (	WE_fifo_in           ),    // High active
    .rst_async_la_i   ( rstn		         ),    // Asynchronous reset low active for reader clock
    .Read_clock___i   ( clk                  ),    // Posedge active 
    .Read_enable__i   ( RE_fifo_in           ),    // High active
    .differenceAF_i   (	3'h2                 ),    // Difference (memory locations) between AF & Full flag
    .differenceAE_i   (	3'h2                 ),    // Difference (memory locations) between AE & Empty flag
    .data_input___i   (	data_in_fifo         ),
    .data_output__o   (	data_in_from_fifo_Q  ),
    .Empty_Indica_o   (	Empty_Indica_Q       ),    // Empty FIFO indicator synchronized with Read clock
    .Full_Indicat_o   (		                 ),    // Set by the write clock and cleared by the reading clock
    .Almost_Full__o   (	                     ),    
    .Almost_Empty_o   (		                 )
);

//-----------FIFOs de Salida-------------------------//

DC_FIFO_AF_AE #(
    .DATA_WIDTH(DATA_WIDTH) ,                  // Datawidth of data
    .ADDR_WIDTH(FIFO_ADDR_WIDTH)               // Address bits   ( )
) FIFO_I_out (
    .Write_clock__i   ( clk              ),    // posedge active
    .Write_enable_i   (	WE_fifo_out      ),    // High active
    .rst_async_la_i   ( rstn		     ),    // Asynchronous reset low active for reader clock
    .Read_clock___i   ( clk              ),    // Posedge active 
    .Read_enable__i   ( RE_fifo_out      ),    // High active
    .differenceAF_i   (	3'h2             ),    // Difference (memory locations) between AF & Full flag
    .differenceAE_i   (	3'h2             ),    // Difference (memory locations) between AE & Empty flag
    .data_input___i   (	I_interp         ),
    .data_output__o   (	data_out_from_fifo_I ),
    .Empty_Indica_o   (	Empty_fifo_out   ),    // Empty FIFO indicator synchronized with Read clock
    .Full_Indicat_o   (		             ),    // Set by the write clock and cleared by the reading clock
    .Almost_Full__o   (	Almost_Full_I    ),    
    .Almost_Empty_o   (		             )
);

DC_FIFO_AF_AE #(
    .DATA_WIDTH(DATA_WIDTH) ,                  // Datawidth of data
    .ADDR_WIDTH(FIFO_ADDR_WIDTH)               // Address bits   ( )
) FIFO_Q_out (
    .Write_clock__i   ( clk              ),    // posedge active
    .Write_enable_i   (	WE_fifo_out      ),    // High active
    .rst_async_la_i   ( rstn		     ),    // Asynchronous reset low active for reader clock
    .Read_clock___i   ( clk              ),    // Posedge active 
    .Read_enable__i   ( RE_fifo_out      ),    // High active
    .differenceAF_i   (	3'h2             ),    // Difference (memory locations) between AF & Full flag
    .differenceAE_i   (	3'h2             ),    // Difference (memory locations) between AE & Empty flag
    .data_input___i   (	Q_interp         ),
    .data_output__o   (	data_out_from_fifo_Q  ),
    .Empty_Indica_o   (	     	         ),    // Empty FIFO indicator synchronized with Read clock
    .Full_Indicat_o   (		             ),    // Set by the write clock and cleared by the reading clock
    .Almost_Full__o   (	Almost_Full_Q    ),    
    .Almost_Empty_o   (		             )
);




// reg [DATA_WIDTH-1:0] mem_signal [0:100];
reg [CONFIG_WIDTH-1:0] mem_config [0:4-1];
reg [CONFIG_WIDTH-1:0] signal_len [0:1];
assign total_len = signal_len[0]*(ilen)-(2*ilen);
integer fd;
integer i;


initial
    begin
        clk = 1;
        forever clk = #5 ~clk;
    end

// task write_fifo_in_cc_delay (input [DATA_WIDTH-1:0] data_in, input [5:0] cc_delay);
//     begin
//         #(cc_delay*10)
//         WE_fifo_in = 1'b1;
//         data_in_fifo = data_in;
//         #10;
//         WE_fifo_in = 1'b0;
//     end
// endtask

initial
begin 
   
    $readmemh("../config.ipd", mem_config);
    $readmemh("../signal_len.txt", signal_len);
    $display("============= Interpolador Cuadratico Design IV v1.0 IQ ============");

    config_reg0 = mem_config[0];
    config_reg1 = mem_config[1];
    config_reg2 = mem_config[2];
    config_reg3 = mem_config[3];  
    $display("total len: %s", total_len);
    // Wait for global reset to finish
    rstn = 1;
    en = 0;
    start = 0;
    #10;
    rstn = 0;
    #10;
    rstn = 1;
    #50;
    start = 1;
    #10;
    en = 1;
    start = 0;

end

always @(done_sink) begin
    if(done_sink) begin
        fd = $fopen("data_out_sim.txt","w");
        for(i=0; i<= total_len; i = i+1) begin
            $fdisplay(fd, "%h", Y_mem.mem[i]);
        end
        $fclose(fd);
        $stop;
    end
end

always @(DUT.Controlpath.FSM.state) begin
    if(DUT.Controlpath.FSM.state == 3'h1) begin
        $display("-------------------------Config----------------------------------");
        $display("x: %f, x2: %f, paso: %d", $itor(DUT.Datapath_I.x*SF), $itor(DUT.Datapath_I.x2*SF), $itor(DUT.Controlpath.next_state_logic.ilen));
        if(config_reg0[0] == 0) begin
            $display("Bypass = OFF");
        end
        else begin
            $display("Bypass = ON");
        end
    end
    if(DUT.Datapath_I.op_1 == 1) begin
        $display("-----------------------------------------------------------------");
        $display("m0: %f, m1: %f, m2: %f", $itor(DUT.Datapath_I.m0*SF), $itor(DUT.Datapath_I.m1*SF), $itor(DUT.Datapath_I.m2*SF));
        $display("------------------Valores intermedios----------------------------");
        $display("m0 + m2     = %f", $itor(DUT.Datapath_I.m2_m0*SF));
        $display("(m0 + m2)/2 = %f", $itor(DUT.Datapath_I.m2_m0_div2*SF));
        $display("2*m1        = %f", $itor(DUT.Datapath_I.t2_m1*SF));
        $display("2*m1 - m0   = %f", $itor(DUT.Datapath_I.t2_m1_m0*SF));
        $display("----------------------Coeficientes-------------------------------");
        $display("p0 = %f", $itor(DUT.Datapath_I.m0*SF));
        $display("p1 = %f", $itor(DUT.Datapath_I.p1*SF));
        $display("p2 = %f", $itor(DUT.Datapath_I.p2*SF));
        $display("-----------------------------------------------------------------");
    end
end


always @(posedge clk) begin
    if(DUT.Write_Enable_fifo == 1)
            $display("I_interp = %f    Q_interp = %f ", $signed($itor(DUT.I_interp*SF)), $signed($itor(DUT.Q_interp*SF)));
    if(DUT.done == 1)
            $display("Done");  
end

//-------------------Memoria de entrada M------------------//

module M_mem #(
    parameter   DATA_WIDTH = 16,
    parameter   MEM_SIZE_M  = $clog2(3)
)(
    input      clk,
    input      [MEM_SIZE_M-1:0] M_addr,
    output reg [DATA_WIDTH-1:0] data_out
);

    reg [DATA_WIDTH-1:0] mem [0:(2**MEM_SIZE_M)-1];

    always @(posedge clk) begin
            data_out <= mem[M_addr];
    end

    initial begin
        // $readmemh("../signal_test.ipd", mem);
         $readmemh("../OutputSine.txt", mem);
    end

endmodule

//-------------------Memoria de Salida Y------------------//

module Y_mem #(
    parameter   DATA_WIDTH = 16,
    parameter   MEM_SIZE_Y  = $clog2(16)
)(
    input      clk,
    input      [MEM_SIZE_Y-1:0] Y_addr,
    input      WE,
    input signed  [DATA_WIDTH-1:0] data_in
);

    reg signed [DATA_WIDTH-1:0] mem [0:(2**MEM_SIZE_Y)-1];

    always @(posedge clk) begin
        if(WE)
            mem[Y_addr] <= data_in;
    end
    

endmodule




endmodule
