`timescale 1ns/100ps

`define DUAL_DATAPATH 1				// <--- Descomentar para activar el doble datapath	

module intpol2_D4_tb();

localparam   DATAPATH_WIDTH    = 16; 
localparam   M_bits            = DATAPATH_WIDTH-1; //M = parte decimal
localparam   N_bits            = 2;                //N <= parte entera
localparam   CONFIG_WIDTH      = 32;
localparam   FIFO_ADDR_WIDTH   = 3;
localparam   MEM_ADDR_WIDTH    = 4;                //2**4
localparam   SIGNAL_ADDR_WIDTH = $clog2(2**20);    // Tamaño de memoria de almacenamiento de la señal
localparam   SF                = 2.0**-(M_bits);   //scaling factor (printing matters)
localparam   DELAY_WIDTH       = 13;

localparam   DELAY_MODE        = 0;
localparam   DEBUGMODE         = 0;   //~OFF/ON (imprime las operaciones en Modelsim)
localparam   BYPASS            = 0;   //bypass   ~OFF/ON           


reg                              clk;
reg                              rstn; 
reg                              start;
reg                              en;
reg         [CONFIG_WIDTH-1:0]   config_reg0;
reg         [CONFIG_WIDTH-1:0]   config_reg1;
reg         [CONFIG_WIDTH-1:0]   config_reg2;
reg         [CONFIG_WIDTH-1:0]   config_reg3;

wire       [CONFIG_WIDTH*4-1:0] config_reg; // 4 Palabras
wire                             WE_fifo_in;
wire                             RE_fifo_out;
wire signed [DATAPATH_WIDTH-1:0] data_in_fifo_1;
wire signed [DATAPATH_WIDTH-1:0] data_in_fifo_2;
wire signed [DATAPATH_WIDTH-1:0] data_out_fifo;
wire                             Empty_intpol2;
wire                             Afull_intpol2;

wire signed [DATAPATH_WIDTH-1:0] data_out_intpol2; 
wire                             WE_fifo_out;
wire                             RE_fifo_in;
wire                             done;
wire                             busy;
wire        [8-1:0]              status_reg;

wire signed [DATAPATH_WIDTH-1:0] data_in_from_fifo_1;
wire signed [DATAPATH_WIDTH-1:0] data_out_1;
wire signed [DATAPATH_WIDTH-1:0] data_out_from_fifo_1;
wire signed [DATAPATH_WIDTH-1:0] data_from_mem_1;
wire signed [MEM_ADDR_WIDTH-1:0] Write_addr_mem;
wire signed [MEM_ADDR_WIDTH-1:0] Read_addr_mem;
wire Write_Enable_mem;
wire Empty_Indica_1;
wire Almost_Full_1;


`ifdef DUAL_DATAPATH
    wire signed [DATAPATH_WIDTH-1:0] data_in_from_fifo_2;
    wire signed [DATAPATH_WIDTH-1:0] data_out_2;
    wire signed [DATAPATH_WIDTH-1:0] data_out_from_fifo_2;
    wire signed [DATAPATH_WIDTH-1:0] data_from_mem_2;
    wire Empty_Indica_2;
    wire Almost_Full_2;
`endif  

wire Empty_fifo_out;
wire Afull_fifo_in;
wire [SIGNAL_ADDR_WIDTH-1:0] M_addr;
wire [SIGNAL_ADDR_WIDTH-1:0] Y_addr;
wire WE_Y;                         // Write Enable Y Mem

wire Almost_Empty_FIFO_in;
wire [SIGNAL_ADDR_WIDTH-1:0] ilen;
wire comp_len;
wire done_sink;
wire [SIGNAL_ADDR_WIDTH-1:0] total_len;


reg [CONFIG_WIDTH-1:0] mem_config [0:4-1];
reg [CONFIG_WIDTH-1:0] signal_len [0:1];   // size del TXT matlab gen
reg [DELAY_WIDTH-1:0] delay_cc;
reg nop;


integer fd;
integer i;
integer j;


// assign Empty_intpol2 = Empty_Indica_1 | Empty_Indica_2;
// assign Afull_intpol2 = Almost_Full_1 | Almost_Full_2;
assign Empty_intpol2 = Empty_Indica_1;
assign Afull_intpol2 = Almost_Full_1;

assign done = status_reg[0];
assign busy = status_reg[1];

assign config_reg[CONFIG_WIDTH-1:0]                = config_reg0; 
assign config_reg[CONFIG_WIDTH*2-1:CONFIG_WIDTH]   = config_reg1;
assign config_reg[CONFIG_WIDTH*3-1:CONFIG_WIDTH*2] = config_reg2;
assign config_reg[CONFIG_WIDTH*4-1:CONFIG_WIDTH*3] = config_reg3;

assign ilen = config_reg3[SIGNAL_ADDR_WIDTH-1:0];
assign total_len = signal_len[0]*(ilen)-(2*ilen);  // Calculo del tamano total de senal de salida.
// assign total_len = 'h80; 
// assign total_len = 'd35; 

intpol2_D4_CORE#(
    .CONFIG_WIDTH      ( CONFIG_WIDTH       ),
    .DATAPATH_WIDTH    ( DATAPATH_WIDTH     ),
    .N_bits            ( N_bits             ),
    .M_bits            ( M_bits             ),
    .MEM_ADDR_WIDTH    ( MEM_ADDR_WIDTH     )
)DUT(
    .clk               ( clk                ),
    .rstn              ( rstn               ),
    .start             ( start              ),
    .Empty_i           ( Empty_intpol2      ),
    .Afull_i           ( Afull_intpol2      ),
    .config_reg        ( config_reg         ),
    .data_from_mem_1   ( data_from_mem_1    ),
    .data_from_fifo_1  ( data_in_from_fifo_1),
    .Read_addr_mem     ( Read_addr_mem      ),
    .Write_addr_mem    ( Write_addr_mem     ),
    .Write_Enable_mem  ( Write_Enable_mem   ),
    .Write_Enable_fifo ( WE_fifo_out        ),
    .Read_Enable_fifo  ( RE_fifo_in         ),
    .status_reg        ( status_reg         ),
`ifdef DUAL_DATAPATH
    .data_from_fifo_2  ( data_in_from_fifo_2),
    .data_from_mem_2   ( data_from_mem_2    ),
    .data_out_2        ( data_out_2         ),
`endif
    .data_out_1        ( data_out_1         )
);


// Memoria de interfaz de entrada
M_mem#(
    .DATA_WIDTH ( DATAPATH_WIDTH ),
    .MEM_SIZE_M ( MEM_ADDR_WIDTH )
)IF_mem_in_1(
    .clk           ( clk             ),
    .M_addr        ( Read_addr_mem   ),
    .data_out      ( data_from_mem_1 )
);

M_mem#(
    .DATA_WIDTH ( DATAPATH_WIDTH ),
    .MEM_SIZE_M ( MEM_ADDR_WIDTH )
)IF_mem_in_2(
    .clk           ( clk             ),
    .M_addr        ( Read_addr_mem   ),
    .data_out      ( data_from_mem_2 )
);

Source_sim#(
    .ADDR_WIDTH ( SIGNAL_ADDR_WIDTH )
)Source_sim(
    .clk   ( clk           ),
    .rst   ( rstn          ),
    .en    ( en            ),
    .Afull ( Afull_fifo_in ),
    .addr  ( M_addr        ),
    .WE    ( WE_fifo_in    )
);

M_mem#(
    .DATA_WIDTH ( DATAPATH_WIDTH ),
    .MEM_SIZE_M ( SIGNAL_ADDR_WIDTH)
)Signal_in_1(
    .clk        ( clk            ),
    .M_addr     ( M_addr         ),
    .data_out   ( data_in_fifo_1 )
);

M_mem#(
    .DATA_WIDTH ( DATAPATH_WIDTH ),
    .MEM_SIZE_M ( SIGNAL_ADDR_WIDTH)
)Signal_in_2(
    .clk        ( clk            ),
    .M_addr     ( M_addr         ),
    .data_out   ( data_in_fifo_2 )
);

Sink_sim#(
    .ADDR_WIDTH     ( SIGNAL_ADDR_WIDTH ),
    .CONFIG_WIDTH   ( CONFIG_WIDTH  )
)Sink_sim(
    .clk            ( clk            ),
    .rstn           ( rstn           ),
    .start_i        ( start          ),
    .nop            (nop             ),
    .Empty_i        ( Empty_fifo_out ),
    .ilen           ( total_len      ),
    .addr           ( Y_addr         ),
    .Read_Enable_o  ( RE_fifo_out    ),
    .Write_Enable_o ( WE_Y           ),
    .done           ( done_sink      )
);


Y_mem#(
    .DATA_WIDTH ( DATAPATH_WIDTH       ),
    .MEM_SIZE_Y ( SIGNAL_ADDR_WIDTH  )
)Signal_out_I(
    .clk            ( clk                   ),
    .Y_addr         ( Y_addr                ),
    .Write_Enable_Y ( WE_Y                  ),
    .data_in        ( data_out_from_fifo_1  )
);

Y_mem#(
    .DATA_WIDTH ( DATAPATH_WIDTH       ),
    .MEM_SIZE_Y ( SIGNAL_ADDR_WIDTH  )
)Signal_out_2(
    .clk            ( clk                   ),
    .Y_addr         ( Y_addr                ),
    .Write_Enable_Y ( WE_Y                  ),
    .data_in        ( data_out_from_fifo_2  )
);

// Memoria de Interfaz de salida

Y_mem#(
    .DATA_WIDTH ( DATAPATH_WIDTH ),
    .MEM_SIZE_Y ( MEM_ADDR_WIDTH )
)IF_mem_out_1(
    .clk            ( clk              ),
    .Y_addr         ( Write_addr_mem   ),
    .Write_Enable_Y ( Write_Enable_mem ),
    .data_in        ( data_out_1         )
);

Y_mem#(
    .DATA_WIDTH ( DATAPATH_WIDTH ),
    .MEM_SIZE_Y ( MEM_ADDR_WIDTH )
)IF_mem_out_2(
    .clk            ( clk              ),
    .Y_addr         ( Write_addr_mem   ),
    .Write_Enable_Y ( Write_Enable_mem ),
    .data_in        ( data_out_2         )
);

//-----------FIFOs de entrada-------------------------//

DC_FIFO_AF_AE #(
    .DATA_WIDTH(DATAPATH_WIDTH) ,                      // Datawidth of data
    .ADDR_WIDTH(FIFO_ADDR_WIDTH)                   // Address bits   ( )
) FIFO_1_in (
    .Write_clock__i   ( clk                  ),    // posedge active
    .Write_enable_i   (	WE_fifo_in           ),    // High active
    .rst_async_la_i   ( rstn		         ),    // Asynchronous reset low active for reader clock
    .Read_clock___i   ( clk                  ),    // Posedge active 
    .Read_enable__i   ( RE_fifo_in           ),    // High active
    .differenceAF_i   (	3'h2                 ),    // Difference (memory locations) between AF & Full flag
    .differenceAE_i   (	3'h2                 ),    // Difference (memory locations) between AE & Empty flag
    .data_input___i   (	data_in_fifo_1       ),
    .data_output__o   (	data_in_from_fifo_1  ),
    .Empty_Indica_o   (	Empty_Indica_1       ),    // Empty FIFO indicator synchronized with Read clock
    .Full_Indicat_o   (		                 ),    // Set by the write clock and cleared by the reading clock
    .Almost_Full__o   (	Afull_fifo_in        ),    
    .Almost_Empty_o   (	Almost_Empty_FIFO_in )
);

`ifdef DUAL_DATAPATH
DC_FIFO_AF_AE #(
    .DATA_WIDTH(DATAPATH_WIDTH) ,                  // Datawidth of data
    .ADDR_WIDTH(FIFO_ADDR_WIDTH)                   // Address bits   ( )
) FIFO_2_in (
    .Write_clock__i   ( clk                  ),    // posedge active
    .Write_enable_i   (	WE_fifo_in           ),    // High active
    .rst_async_la_i   ( rstn		         ),    // Asynchronous reset low active for reader clock
    .Read_clock___i   ( clk                  ),    // Posedge active 
    .Read_enable__i   ( RE_fifo_in           ),    // High active
    .differenceAF_i   (	3'h2                 ),    // Difference (memory locations) between AF & Full flag
    .differenceAE_i   (	3'h2                 ),    // Difference (memory locations) between AE & Empty flag
    .data_input___i   (	data_in_fifo_2       ),
    .data_output__o   (	data_in_from_fifo_2  ),
    .Empty_Indica_o   (	Empty_Indica_2       ),    // Empty FIFO indicator synchronized with Read clock
    .Full_Indicat_o   (		                 ),    // Set by the write clock and cleared by the reading clock
    .Almost_Full__o   (	                     ),    
    .Almost_Empty_o   (		                 )
);
`endif

//-----------FIFOs de Salida-------------------------//

DC_FIFO_AF_AE #(
    .DATA_WIDTH(DATAPATH_WIDTH) ,                  // Datawidth of data
    .ADDR_WIDTH(FIFO_ADDR_WIDTH)               // Address bits   ( )
) FIFO_I_out (
    .Write_clock__i   ( clk                  ),    // posedge active
    .Write_enable_i   (	WE_fifo_out          ),    // High active
    .rst_async_la_i   ( rstn		         ),    // Asynchronous reset low active for reader clock
    .Read_clock___i   ( clk                  ),    // Posedge active 
    .Read_enable__i   ( RE_fifo_out          ),    // High active
    .differenceAF_i   (	3'h2                 ),    // Difference (memory locations) between AF & Full flag
    .differenceAE_i   (	3'h2                 ),    // Difference (memory locations) between AE & Empty flag
    .data_input___i   (	data_out_1             ),
    .data_output__o   (	data_out_from_fifo_1 ),
    .Empty_Indica_o   (	Empty_fifo_out       ),    // Empty FIFO indicator synchronized with Read clock
    .Full_Indicat_o   (		                 ),    // Set by the write clock and cleared by the reading clock
    .Almost_Full__o   (	Almost_Full_1        ),    
    .Almost_Empty_o   (		                 )
);

`ifdef DUAL_DATAPATH
DC_FIFO_AF_AE #(
    .DATA_WIDTH(DATAPATH_WIDTH) ,              // Datawidth of data
    .ADDR_WIDTH(FIFO_ADDR_WIDTH)               // Address bits   ( )
) FIFO_2_out (
    .Write_clock__i   ( clk                   ),    // posedge active
    .Write_enable_i   (	WE_fifo_out           ),    // High active
    .rst_async_la_i   ( rstn		          ),    // Asynchronous reset low active for reader clock
    .Read_clock___i   ( clk                   ),    // Posedge active 
    .Read_enable__i   ( RE_fifo_out           ),    // High active
    .differenceAF_i   (	3'h2                  ),    // Difference (memory locations) between AF & Full flag
    .differenceAE_i   (	3'h2                  ),    // Difference (memory locations) between AE & Empty flag
    .data_input___i   (	data_out_2              ),
    .data_output__o   (	data_out_from_fifo_2  ),
    .Empty_Indica_o   (	     	              ),    // Empty FIFO indicator synchronized with Read clock
    .Full_Indicat_o   (		                  ),    // Set by the write clock and cleared by the reading clock
    .Almost_Full__o   (	Almost_Full_2         ),    
    .Almost_Empty_o   (		                  )
);
`endif


initial
    begin
        clk = 1;
        forever clk = #5 ~clk;
    end

task DO_delay (input [DELAY_WIDTH-1:0] delay_cc);
    begin
        nop = 1'b1;
        #(delay_cc*10)
        nop = 1'b0;
    end
endtask

task DO_start();
    begin
        start = 1'b1;
        #10;
        start = 1'b0;
    end
endtask

//------------------Ejemplo del registro de Configuracion----------------
// localparam   CONFIG_WIDTH    =  32;
// localparam   DATAPATH_WIDTH  =  12; 
// localparam   N_bits          =  2;                    //N <= parte entera++
// localparam   M_bits          =  11;                   //M = parte decimal

// config_reg0[0]     = 0;                                           //bypass                      
// config_reg1[31:0]  = {20'b00000000000000000000,12'b000110011001}; //iX  =  1/10        
// config_reg2[31:0]  = {20'b00000000000000000000,12'b000010100011}; //iX2 = (1/10)^2   
// config_reg3[31:0]  = 32'b0_00000000000000000000000001010;         //len = 10
//--------------------------------------------------------------------------

initial
begin 
    $display("============= Interpolador Cuadratico Design IV v1.0 IQ ============");
    $readmemh("C:/Users/emanu/Documents/HDL/IntPol2_D4/mods/id00001006/hdl/sim/signal_len.txt", signal_len);  
    $readmemh("C:/Users/emanu/Documents/HDL/IntPol2_D4/mods/id00001006/hdl/sim/OutputCos.txt", Signal_in_1.mem);
    $readmemh("C:/Users/emanu/Documents/HDL/IntPol2_D4/mods/id00001006/hdl/sim/OutputSine.txt", Signal_in_2.mem);
    $readmemh("C:/Users/emanu/Documents/HDL/IntPol2_D4/mods/id00001006/hdl/sim/config.txt", mem_config);
    // Filling Input IF Memory 

    for(i = 0; i <= 49988; i = i + 1)begin	// <--- Longitud del archivo txt
	
	    Signal_in_1.mem[i] = {Signal_in_1.mem[i][11:0],{(DATAPATH_WIDTH-12){1'd0}}}; // Ajustar al formato punto fijo del archivo txt de la entrada de datos
		
    `ifdef DUAL_DATAPATH 
         Signal_in_2.mem[i] = {Signal_in_2.mem[i][11:0],{(DATAPATH_WIDTH-12){1'd0}}}; // Ajustar al formato punto fijo del archivo txt de la entrada de datos
     `endif
	end

    // Signal_in_1.mem[0] = 12'h6d9;
    // Signal_in_1.mem[1] = 12'h5fe;
    // Signal_in_1.mem[2] = 12'h4f0;
    // Signal_in_2.mem[0] = 12'h6d9;
    // Signal_in_2.mem[1] = 12'h5fe;
    // Signal_in_2.mem[2] = 12'h4f0;

    config_reg0 = mem_config[0];
    config_reg1 = mem_config[1];
    config_reg2 = mem_config[2];
    config_reg3 = mem_config[3];  
    
    rstn = 1;
    en = 0;
    nop = 1'b0;
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
    if (DELAY_MODE==1) begin
        #($urandom%(2**DELAY_WIDTH)*10);
        DO_delay($urandom%(2**DELAY_WIDTH));
        #($urandom%(2**DELAY_WIDTH)*10);
        DO_delay($urandom%(2**DELAY_WIDTH));
        #($urandom%(2**DELAY_WIDTH)*10);
        DO_delay($urandom%(2**DELAY_WIDTH));
        #($urandom%(2**DELAY_WIDTH)*10);

        #10;
        start = 1'b1;
        #10;
        start = 1'b0;

        #($urandom%(2**DELAY_WIDTH)*10); 
        fork 
        DO_delay(1000);
        #(500*10) DO_start(); 
        join
    end
end

// always @(done_sink) begin
//     if(done_sink) begin
//         fd = $fopen("../interp_cos.txt","w");
//         for(i=0; i<= total_len; i = i+1) begin
//             $fdisplay(fd, "%h", Signal_out_I.mem[i]);
//         end
//         $fclose(fd);
//         fd = $fopen("../interp_sine.txt","w");
//         for(i=0; i<= total_len; i = i+1) begin
//             $fdisplay(fd, "%h", Signal_out_2.mem[i]);
//         end
//         $fclose(fd);
//         $stop;
//     end
// end

always @(done_sink) begin
    if(done_sink) begin
        $stop;
    end
end

always @(DUT.Controlpath.FSM.state) begin
    if(DEBUGMODE == 1) begin
        if(DUT.Controlpath.FSM.state == 3'h1) begin
            $display("-------------------------Config----------------------------------");
            $display("total len: %s", total_len);
            $display("x: %f, x2: %f, paso: %d", $itor(DUT.Datapath_1.x*SF), $itor(DUT.Datapath_1.x2*SF), $itor(DUT.Controlpath.next_state_logic.ilen));
            if(config_reg0[0] == 0) begin
                $display("Bypass = OFF");
            end
            else begin
                $display("Bypass = ON");
            end
        end
        if(DUT.Datapath_1.op_1 == 1) begin
            $display("-----------------------------------------------------------------");
            $display("m0: %f, m1: %f, m2: %f", $itor(DUT.Datapath_1.m0*SF), $itor(DUT.Datapath_1.m1*SF), $itor(DUT.Datapath_1.m2*SF));
            $display("------------------Valores intermedios----------------------------");
            $display("m0 + m2     = %f", $itor(DUT.Datapath_1.m2_m0*SF));
            $display("(m0 + m2)/2 = %f", $itor(DUT.Datapath_1.m2_m0_div2*SF));
            $display("2*m1        = %f", $itor(DUT.Datapath_1.t2_m1*SF));
            $display("2*m1 - m0   = %f", $itor(DUT.Datapath_1.t2_m1_m0*SF));
            $display("----------------------Coeficientes-------------------------------");
            $display("p0 = %f", $itor(DUT.Datapath_1.m0*SF));
            $display("p1 = %f", $itor(DUT.Datapath_1.p1*SF));
            $display("p2 = %f", $itor(DUT.Datapath_1.p2*SF));
            $display("-----------------------------------------------------------------");
        end
    end
end


always @(posedge clk) begin
    if(DUT.Write_Enable_fifo == 1)
            $display("data_out_1 = %f", $signed($itor(DUT.data_out_1*SF)));
`ifdef DUAL_DATAPATH 
    if(DUT.Write_Enable_fifo == 1)
            $display("data_out_1 = %f", $signed($itor(DUT.data_out_1*SF)));
`endif
    if(DUT.done == 1)
            $display("Done");  
end

endmodule
