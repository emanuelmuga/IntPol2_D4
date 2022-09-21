`timescale 1ns/100ps
 
module intpol2_D4_tb();
 
localparam   DATA_WIDTH  =  32; 
parameter    N_bits      =  2;                               //N <= parte entera
parameter    M_bits      =  31;                              //M = parte decimal
localparam   MEM_SIZE_Y  =  $clog2(128);
localparam   MEM_SIZE_M  =  $clog2(4);
parameter   FIFO_ADDR_WIDTH = 3;

parameter   MODE            = 0;   //mode     ~Accel./stream
parameter   BYPASS          = 0;   //bypass   ~OFF/ON           


reg                           clk;
reg                           rstn; 
reg                           start;

reg         [DATA_WIDTH-1:0]  config_reg0;
reg         [DATA_WIDTH-1:0]  config_reg1;
reg         [DATA_WIDTH-1:0]  config_reg2;
reg         [DATA_WIDTH-1:0]  config_reg3;

reg                           WE_fifo_in;
reg  signed [DATA_WIDTH-1:0]  data_in_fifo;
reg                           RE_fifo_out;

wire               [128-1:0]  config_reg;

wire signed [DATA_WIDTH-1:0]  data_out_fifo;
wire                          Empty_intpol2;
wire                          Afull_intpol2;
wire signed [DATA_WIDTH-1:0]  data_in_mem;            // entrada Memoria M
wire signed [DATA_WIDTH-1:0]  data_fifo_to_intpol2;
wire signed [DATA_WIDTH-1:0]  data_out_intpol2; 
wire        [MEM_SIZE_M-1:0]  M_addr;                 // dir Memoria M
wire        [MEM_SIZE_Y-1:0]  Y_addr;                 // dir Memoria Y
wire signed [DATA_WIDTH-1:0]  Y;                      // salida memoria Y <- Result
wire                          Write_Enable_Y;         // Write Enable Memoria Y 
wire                          WE_fifo_out;
wire                          RE_fifo_in;
wire                          done;
wire                          busy;
wire        [8-1:0]           status_reg;

assign done = status_reg[0];
assign busy = status_reg[1];

assign config_reg[DATA_WIDTH-1:0]              = config_reg0; 
assign config_reg[DATA_WIDTH*2-1:DATA_WIDTH]   = config_reg1;
assign config_reg[DATA_WIDTH*3-1:DATA_WIDTH*2] = config_reg2;
assign config_reg[DATA_WIDTH*4-1:DATA_WIDTH*3] = config_reg3;

reg                           WE_fifo_out_ff;
reg                           WE_fifo_ff;

intpol2_D4_CORE#(
    .DATA_WIDTH ( DATA_WIDTH ),
    .N_bits     ( N_bits     ),
    .M_bits     ( M_bits     ),
    .MEM_SIZE_Y ( MEM_SIZE_Y ),
    .MEM_SIZE_M ( MEM_SIZE_M )
)DUT(
    .clk               ( clk                  ),
    .rstn              ( rstn                 ),
    .start             ( start                ),
    .Empty_i           ( Empty_intpol2        ),
    .Afull_i           ( Afull_intpol2        ),
    .data_in_from_fifo ( data_fifo_to_intpol2 ),    
    .data_in_mem       ( data_in_mem          ),
    .config_reg        ( config_reg           ),
    .M_addr_o          ( M_addr               ),
    .Y_addr_o          ( Y_addr               ),
    .Write_Enable_Y    ( Write_Enable_Y       ),
    .Write_Enable_fifo ( WE_fifo_out          ),
    .Read_Enable_fifo  ( RE_fifo_in           ),    
    .status_reg        ( status_reg           ),
    .data_out          ( data_out_intpol2     )
);




M_mem#(
    .DATA_WIDTH ( DATA_WIDTH ),
    .MEM_SIZE_M ( MEM_SIZE_M )
)M_mem_inst(
    .clk       ( clk               ),
    .M_addr    ( M_addr            ),
    .data_out  ( data_in_mem       )
);

Y_mem#(
    .DATA_WIDTH ( DATA_WIDTH ),
    .MEM_SIZE_Y ( MEM_SIZE_Y )
)Y_mem_inst(
    .clk        ( clk              ),
    .Y_addr     ( Y_addr           ),
    .WE_Y       ( Write_Enable_Y   ),
    .data_in    ( data_out_intpol2 )
);

//-----------FIFO de entrada-------------------------//

DC_FIFO_AF_AE #(
    .DATA_WIDTH(DATA_WIDTH) ,                      // Datawidth of data
    .ADDR_WIDTH(FIFO_ADDR_WIDTH)                   // Address bits   ( )
) FIFO_I_Data (
    .Write_clock__i   ( clk                  ),    // posedge active
    .Write_enable_i   (	WE_fifo_in           ),    // High active
    .rst_async_la_i   ( rstn		         ),    // Asynchronous reset low active for reader clock
    .Read_clock___i   ( clk                  ),    // Posedge active 
    .Read_enable__i   ( RE_fifo_in           ),    // High active
    .differenceAF_i   (	3'h2                 ),    // Difference (memory locations) between AF & Full flag
    .differenceAE_i   (	3'h2                 ),    // Difference (memory locations) between AE & Empty flag
    .data_input___i   (	data_in_fifo         ),
    .data_output__o   (	data_fifo_to_intpol2 ),
    .Empty_Indica_o   (	Empty_intpol2        ),    // Empty FIFO indicator synchronized with Read clock
    .Full_Indicat_o   (		                 ),    // Set by the write clock and cleared by the reading clock
    .Almost_Full__o   (	                     ),    
    .Almost_Empty_o   (		                 )
);

//-----------FIFO de Salida-------------------------//

DC_FIFO_AF_AE #(
    .DATA_WIDTH(DATA_WIDTH) ,                  // Datawidth of data
    .ADDR_WIDTH(FIFO_ADDR_WIDTH)               // Address bits   ( )
) FIFO_O_Data (
    .Write_clock__i   ( clk              ),    // posedge active
    .Write_enable_i   (	WE_fifo_out      ),    // High active
    .rst_async_la_i   ( rstn		     ),    // Asynchronous reset low active for reader clock
    .Read_clock___i   ( clk              ),    // Posedge active 
    .Read_enable__i   ( RE_fifo_out      ),    // High active
    .differenceAF_i   (	3'h2             ),    // Difference (memory locations) between AF & Full flag
    .differenceAE_i   (	3'h2             ),    // Difference (memory locations) between AE & Empty flag
    .data_input___i   (	data_out_intpol2 ),
    .data_output__o   (	data_out_fifo    ),
    .Empty_Indica_o   (	     	         ),    // Empty FIFO indicator synchronized with Read clock
    .Full_Indicat_o   (		             ),    // Set by the write clock and cleared by the reading clock
    .Almost_Full__o   (	Afull_intpol2    ),    
    .Almost_Empty_o   (		             )
);


localparam SF  = 2.0**-(M_bits);                //scaling factor
// localparam SF2 = 2.0**-(DATA_WIDTH);       //scaling factor2

reg [DATA_WIDTH-1:0] mem_mem_in [0:3-1];
reg [DATA_WIDTH-1:0] mem_config [0:4-1];


// function [DATA_WIDTH-1:0] fixed_variable(input [32-1:0] in_data); //function to move the fixed point
//         reg [32-1:0] temp;
//         begin
//             temp = in_data >> N;
//             fixed_variable = temp[31:(32-DATA_WIDTH)];
//         end
        
// endfunction


initial
    begin
        clk = 0;
        forever clk = #5 ~clk;
    end

// reg        [DATA_WIDTH*2-1:0] M0_F   = {32{1'b0}};                             //m0 = 0
// reg        [DATA_WIDTH*2-1:0] M1_F   = 32'b0_1001011001111010000011111001000;   //m1 = 0.5878
// reg        [DATA_WIDTH*2-1:0] M2_F   = 32'b0_1111001101111011010010100010001;   //m2 = 0.9511 
// reg        [DATA_WIDTH*2-1:0] M3_F   = 32'b0_1111001101111011010010100010001;   //m3 = m2
// reg        [DATA_WIDTH*2-1:0] M4_F   = 32'b0_1001011001111010000011111001000;   //m2 = 0.5878 

// reg        [DATA_WIDTH*2-1:0] M0_F   = 32'h0809850e;
// reg        [DATA_WIDTH*2-1:0] M1_F   = 32'h278dde6e;
// reg        [DATA_WIDTH*2-1:0] M2_F   = 32'h4b3c8c12;

// reg        [DATA_WIDTH*2-1:0] M0_F   = 32'h278dde6e;
// reg        [DATA_WIDTH*2-1:0] M1_F   = 32'h4b3c8c12;
// reg        [DATA_WIDTH*2-1:0] M2_F   = 32'h678dde6e;

// reg        [DATA_WIDTH*2-1:0] M0_F   = 32'h8643c7b3; // m0 = -0.9511
// reg        [DATA_WIDTH*2-1:0] M1_F   = 32'h98722192; // m1 = -0.8090
// reg        [DATA_WIDTH*2-1:0] M2_F   = 32'hb4c373ee; // m2 = -0.5878

initial
begin
    $readmemh("Mem_in.ipd", mem_mem_in);
    $readmemh("config.ipd", mem_config);
    $display("============= Interpolador Cuadratico Design IV V4.2 ============");

    config_reg0 = mem_config[0];
    config_reg1 = mem_config[1];
    config_reg2 = mem_config[2];
    config_reg3 = mem_config[3];  

    // config_reg0[0]     = BYPASS;                                         
    // config_reg0[1]     = MODE;
    // config_reg1[31:0]  = 32'b0_0000100111011000100111011000100; //iX  =  1/26         
    // config_reg2[31:0]  = 32'b0_0000000001100000111100100101100; //iX2 = (1/26)^2   
    //  config_reg3[8:0]   = 9'b0_0001_1010;  

    // config_reg1[31:0]  = 32'b0_0010101010101010101010101010101; //iX  =  1/6  
    // config_reg2[31:0]  = 32'b0_0000011100011100011100011100011; //iX2 = (1/6)^2    
    // config_reg3[8:0]   = 9'b0_0000_0110;  //6 

    // config_reg1[31:0]  = 32'b0_0001100110011001100110011001100;  // 1/10  = 0.1  
    // config_reg2[31:0]  = 32'b0_0000001010001111010111000010100;  // 1/100  = 0.01       
    // config_reg3[8:0]   = 9'b0_0000_1010;                         //10
  


    // config_reg1[31:0]  = 32'b0_0000010100000101000001010000010; //iX  =  1/51  
    // config_reg2[31:0]  = 32'b0_0000000000011001001100100100101; //iX2 = (1/51)^2    
    // config_reg3[8:0]   = 9'b0_0011_0011;  //51 

    // config_reg1[31:0]  = 32'b0_0000001000000100000010000001000; //iX  =  1/127  
    // config_reg2[31:0]  = 32'b0_0000000000000100000100000011000; //iX2 = (1/127)^2    
    // config_reg3[8:0]   = 9'b0_0111_1111;  //127 

    // config_reg1[31:0]  = 32'b0_0000001000000000000000000000000; //iX  =  1/128  
    // config_reg2[31:0]  = 32'b0_0000000000000100000000000000000; //iX2 = (1/128)^2    
    // config_reg3[8:0]   = 9'b0_1000_0000;  //128 

    // config_reg1[31:0]  = 32'b0_0000010000010000010000010000010; //iX  =  1/63  
    // config_reg2[31:0]  = 32'b0_0000000000010000100000110001000; //iX2 = (1/63)^2    
    // config_reg3[8:0]   = 9'b0_0011_1111;  //63 

    // config_reg1[31:0]  = 32'b0_0000011010010000011010010000011; //iX  =  1/39  
    // config_reg2[31:0]  = 32'b0_0000000000101011000101100110001; //iX2 = (1/39)^2    
    // config_reg3[8:0]   = 9'b0_0010_0111;                        //39 
    
    //Inicializacion de Memorias (for testing)
    // M_mem_inst.mem[0] = M0_F;
    // M_mem_inst.mem[1] = M1_F;
    // M_mem_inst.mem[2] = M2_F;

    M_mem_inst.mem[0] = (mem_mem_in[0]);
    M_mem_inst.mem[1] = (mem_mem_in[1]);
    M_mem_inst.mem[2] = (mem_mem_in[2]);

 
        rstn = 1;
        start = 0;
        WE_fifo_in = 0;
        RE_fifo_out = 0;
        #10;
        rstn = 0;
        #10;
        rstn = 1;
        #5;
        if(MODE == 1) begin
            data_in_fifo = (mem_mem_in[0]);
            WE_fifo_in = 1;
            #10;
            data_in_fifo = (mem_mem_in[1]);
            #10;
            data_in_fifo = (mem_mem_in[2]);
            #10;
            WE_fifo_in = 0;
            #10;
            start = 1;
            #10;
            start = 0;
            #50;
            data_in_fifo = (mem_mem_in[0]);
            WE_fifo_in = 1;
            #10;
            data_in_fifo = (mem_mem_in[1]);
            #10;
            WE_fifo_in = 0;
            #500;
            RE_fifo_out = 1;
            #50;
            RE_fifo_out = 0;
            #10;
            RE_fifo_out = 1;
        end
        else begin
            #10;
            start = 1;
            #10;
            start = 0;
        end
    
end


always @(DUT.Controlpath.FSM.state) begin
    if(DUT.Controlpath.FSM.state == 3'h1) begin
        $display("-------------------------Config----------------------------------");
        $display("x: %f, x2: %f, paso: %d", $itor(DUT.Datapath.x*SF), $itor(DUT.Datapath.x2*SF), $itor(DUT.Controlpath.next_state_logic.ilen));
        if(MODE == 0) begin
            $display("MODE   = Accel.");
        end
        else begin
            $display("MODE   = Stream");
        end
        if(config_reg0[0] == 0) begin
            $display("Bypass = OFF");
        end
        else begin
            $display("Bypass = ON");
        end
    end
    if(DUT.Datapath.op_1 == 1) begin
        $display("-----------------------------------------------------------------");
        $display("m0: %f, m1: %f, m2: %f", $itor(DUT.Datapath.m0*SF), $itor(DUT.Datapath.m1*SF), $itor(DUT.Datapath.m2*SF));
        $display("------------------Valores intermedios----------------------------");
        $display("m0 + m2     = %f", $itor(DUT.Datapath.m2_m0*SF));
        $display("(m0 + m2)/2 = %f", $itor(DUT.Datapath.m2_m0_div2*SF));
        $display("2*m1        = %f", $itor(DUT.Datapath.t2_m1*SF));
        $display("2*m1 - m0   = %f", $itor(DUT.Datapath.t2_m1_m0*SF));
        $display("----------------------Coeficientes-------------------------------");
        $display("p0 = %f", $itor(DUT.Datapath.m0*SF));
        $display("p1 = %f", $itor(DUT.Datapath.p1*SF));
        $display("p2 = %f", $itor(DUT.Datapath.p2*SF));
        $display("-----------------------------------------------------------------");
        // $display("----------------------Iteraciones--------------------------------");
    end
end

integer i;
    if(MODE==0) begin
        // always @(posedge clk) begin
        //     if((DUT.FSM.Write_Enable == 1))
        //     $display("p1_x_i  = %f, p2_xi2 = %f, Y = %f", $itor(DUT.Datapath.p1_xi*SF) ,$itor(DUT.Datapath.p2_xi2*SF)   ,$itor(DUT.Datapath.data_out*SF));
        //     // $display("xi_past = %f, dif    = %f , dif_2 = %f, xi2   = %f", $itor(DUT.Datapath.Squared.xi2_past*SF), $itor(DUT.Datapath.Squared.dif*SF) , $itor(DUT.Datapath.Squared.dif_2*SF) ,$itor(DUT.Datapath.Squared.xi2*SF));
        // end
        always @(DUT.done) begin
            if(done == 1'b1) begin
                $display("------------------Guardado en Memoria Y-------------------------");
                for(i=0; i<DUT.Controlpath.next_state_logic.ilen;i=i+1) begin
                    $display("MEM_Y[%D] = %f", i, $signed($itor(Y_mem_inst.mem[i]*SF)));
                end
                #50;
                $stop;
            end
        end
    end
    else begin
        always @(posedge clk) begin
            if(FIFO_O_Data.Write_enable_i == 1)
                 $display("data_out = %f", $signed($itor(FIFO_O_Data.data_input___i*SF)));
            if(DUT.done == 1)
                 $display("Done");    
        end
    end 





endmodule

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

endmodule


//-------------------Memoria de Salida Y------------------//

module Y_mem #(
    parameter   DATA_WIDTH = 16,
    parameter   MEM_SIZE_Y  = $clog2(16)
)(
    input      clk,
    input      [MEM_SIZE_Y-1:0] Y_addr,
    input      WE_Y,
    input signed  [DATA_WIDTH-1:0] data_in
);

    reg signed [DATA_WIDTH-1:0] mem [0:(2**MEM_SIZE_Y)-1];

    always @(posedge clk) begin
        if(WE_Y)
            mem[Y_addr] <= data_in;
    end
    

endmodule