module intpol2_D4_Datapath #(
    parameter   DATA_WIDTH  =  32, 
    parameter   N_bits      =  2,                               //N <= parte entera
    parameter   M_bits      =  31,                              //M <= parte decimal
    parameter   MEM_SIZE_Y  = $clog2(64)

)(
    input                               clk, rstn, clear,
    input                               Ld_data,
    input                               Ld_M0,
    input                               Ld_M1,
    input                               Ld_M2,
    input                               en_sum,
    input                               Ld_p1_xi,
    input                               en_stream,
    input                               sel_mult,
    input                               op_1,
    input                 [1:0]         sel_xi2,
    input       signed [DATA_WIDTH-1:0] data_to_process,     
    input       signed [DATA_WIDTH-1:0] x,
    input       signed [DATA_WIDTH-1:0] x2,
    output reg signed [DATA_WIDTH-1:0]  data_out 
);
    
reg  signed [DATA_WIDTH+N_bits-1:0] m0;
reg  signed [DATA_WIDTH+N_bits-1:0] m1;
reg  signed [DATA_WIDTH+N_bits-1:0] m2;

reg cnt_clk;
wire Ld_lv;

//-------------------------Coeficientes------------------------//                    
wire signed [DATA_WIDTH+N_bits-1:0] p1;                           
wire signed [DATA_WIDTH+N_bits-1:0] p2;  

//-----------------------Valores intermedios-------------------//
wire signed [DATA_WIDTH+N_bits-1:0] m2_m0;                            // m2 + m0
wire signed [DATA_WIDTH+N_bits-1:0] m2_m0_div2;                       // (m2 + m0)/2
wire signed [DATA_WIDTH+N_bits-1:0] t2_m1;                            // 2*m1
wire signed [DATA_WIDTH+N_bits-1:0] t2_m1_m0;                         // 2*m1 - m0
wire signed [DATA_WIDTH+N_bits-1:0] xi;                               // x * i
wire signed [DATA_WIDTH+N_bits-1:0] data_y;                           //result de la mult
wire signed [DATA_WIDTH+N_bits-1:0] p2_xi2;                           // p2 * x^2 * i^2 

wire signed [DATA_WIDTH+N_bits-1:0] multi_val;                        //resultado del multiplicador reutilizado.                   
wire signed [DATA_WIDTH+N_bits-1:0] xi2_w;
wire signed [DATA_WIDTH-1:0] xi2;

wire signed [DATA_WIDTH+N_bits-1:0] x_w;
wire signed [DATA_WIDTH+N_bits-1:0] x2_w;
wire signed [DATA_WIDTH+N_bits-1:0] data_to_process_w;

reg signed  [DATA_WIDTH+N_bits-1:0] p1_xi;                           // p1 * x * i

assign x_w    = {{N_bits{1'b0}},x};
assign x2_w    = {{N_bits{1'b0}},x2};
// assign xi2_w  = {{N_bits{1'b0}},xi2};

assign data_to_process_w = {{N_bits{data_to_process[DATA_WIDTH-1]}},data_to_process};

always @(posedge clk, negedge rstn) begin
    if(!rstn) begin
        p1_xi      <=  {DATA_WIDTH+N_bits{1'b0}};
        m0          =  {DATA_WIDTH+N_bits{1'b0}};
        m1          =  {DATA_WIDTH+N_bits{1'b0}};
        m2          =  {DATA_WIDTH+N_bits{1'b0}};
        data_out    <=  {DATA_WIDTH{1'b0}};
    end    
    else begin
        // if(Ld_y)      
        //     data_out <= y;
        if(Ld_M0)
            m0   = {data_to_process_w}; 
        if(Ld_M1)
            m1   = {data_to_process_w}; 
        if(Ld_M2)
            m2   = {data_to_process_w};  
        if(en_stream) begin
            m0 = m1;
            m1 = m2;
            m2 = {data_to_process_w};
        end
        if(Ld_p1_xi)
            p1_xi = multi_val; 
        if(Ld_data)
            data_out <= data_y[DATA_WIDTH-1:0];     
    end
end

//--------------------------M2 + M0-----------------------------//
intpol2_D4_adder#(
    .DATA_WIDTH ( DATA_WIDTH ),
    .N_bits(N_bits)
)ADDER(
    .A  ( m2  ),
    .B  ( m0  ),
    .C  ( m2_m0  )
);
//----------------------- (M2 + M0)/2 --------------------------//
intpol2_D4_shift#(
    .DATA_WIDTH ( DATA_WIDTH ),
    .N_bits(N_bits)
)SHIFT_DIV(
    .OP        (  1'b1      ),
    .data_in   (  m2_m0     ),
    .data_out  ( m2_m0_div2 )
);


//---------------- p2 = (M2 + M0)/2 - m1 -----------------------//
intpol2_D4_sub_sync#(
    .DATA_WIDTH ( DATA_WIDTH ),
    .N_bits(N_bits)
)SUB_1(
    .clk        ( clk         ),
    .rstn       ( rstn        ),
    .en         ( op_1        ),
    .A          ( m2_m0_div2  ),
    .B          ( m1          ),
    .C          ( p2          )
);

//--------------------------- 2*m1 -----------------------------//
intpol2_D4_shift#(
    .DATA_WIDTH ( DATA_WIDTH ),
    .N_bits(N_bits)
)SHIFT_Mult(
    .OP        (  1'b0   ),
    .data_in   (  m1     ),
    .data_out  ( t2_m1   )
);

//------------------------ (2*m1 - m0) ------------------------//

intpol2_D4_sub#(
    .DATA_WIDTH ( DATA_WIDTH ),
    .N_bits(N_bits)
)SUB_2(
    .A  ( t2_m1  ),
    .B  ( m0  ),
    .C  ( t2_m1_m0  )
);

//--------------- p1 = (t2_m1 - m0) - m2_m0_div2) ------------------//

intpol2_D4_sub_sync#(
    .DATA_WIDTH ( DATA_WIDTH ),
    .N_bits(N_bits)
)SUB_3(
    .clk        ( clk        ),
    .rstn       ( rstn       ),
    .en         ( op_1       ),
    .A          ( t2_m1_m0   ),
    .B          ( m2_m0_div2 ),
    .C          ( p1         )
);

//--------------------------- x*i -----------------------//

intpol2_D4_mult_by_add#(
    .DATA_WIDTH ( DATA_WIDTH ),
    .N_bits(N_bits)
)MULTI_BY_ADD(
    .clk     ( clk     ),
    .rstn    ( rstn    ),
    .clear   ( clear   ),
    .en      ( en_sum  ),
    .x       ( x_w     ),
    .xi      ( xi      )
);

//--------------------------- xi^2 -----------------------//
// intpol2_D4_squared#(
//     .DATA_WIDTH ( DATA_WIDTH ),
//     .MEM_SIZE_Y ( MEM_SIZE_Y )
// )Squared(
//     .clk        ( clk        ),
//     .rstn       ( rstn       ),
//     .clear      ( clear      ),
//     .en_cnt     ( en_sum     ),
//     .cnt        ( cnt        ),
//     .x2         ( x2         ),
//     .xi2        ( xi2        )
// );

intpol2_D4_squared#(
    .DATA_WIDTH ( DATA_WIDTH ),
    .N_bits(N_bits)
)Squared(
    .clk     ( clk     ),
    .rstn    ( rstn    ),
    .clear   ( clear   ),
    .en_xi2  ( en_sum  ),
    .sel_xi2 ( sel_xi2 ),
    .x2      ( x2_w      ),
    .xi2     ( xi2_w     )
);

//--------------------- p1 * xi  OR  p2 * xi^2  -----------------------//

intpol2_D4_multi_mux#(
    .DATA_WIDTH ( DATA_WIDTH ),
    .N_bits     ( N_bits     ),
    .M_bits     ( M_bits     )
)MULTI_MUX(
    .sel_mult   ( sel_mult   ),
    .xi         ( xi         ),
    .xi2        ( xi2_w      ),
    .p1         ( p1         ),
    .p2         ( p2         ),
    .data_out   ( multi_val  )
);


//---------- Y = p0 + M_p1_x_cnt + p2_x2_cnt2 ---------------------//

intpol2_D4_adder3#(
    .DATA_WIDTH ( DATA_WIDTH ),
    .N_bits(N_bits)
)ADDER3(
    .A ( m0        ),
    .B ( p1_xi     ),
    .C ( multi_val ),
    .Y ( data_y    )
);



endmodule