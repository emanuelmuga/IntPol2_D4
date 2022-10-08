module intpol2_D4_Datapath #(
    parameter   DATAPATH_WIDTH  =  32, 
    parameter   N_bits      =  2,                               //N <= parte entera
    parameter   M_bits      =  31,                              //M <= parte decimal
    parameter   MEM_SIZE_Y  = $clog2(64)

)(
    input                                   clk, rstn, clear,
    input                                   Ld_data,
    input                                   Ld_M0,
    input                                   Ld_M1,
    input                                   Ld_M2,
    input                                   en_sum,
    input                                   Ld_p1_xi,
    input                                   en_stream,
    input                                   sel_mult,
    input                                   op_1,
    input       signed [DATAPATH_WIDTH-1:0] min_Thold,
    input       signed [DATAPATH_WIDTH-1:0] max_Thold,
    input                 [1:0]             sel_xi2,
    input       signed [DATAPATH_WIDTH-1:0] data_to_process,     
    input       signed [DATAPATH_WIDTH-1:0] x,
    input       signed [DATAPATH_WIDTH-1:0] x2,
    output wire signed [DATAPATH_WIDTH-1:0] data_out 
);
    
reg  signed [DATAPATH_WIDTH+N_bits-1:0] m0;
reg  signed [DATAPATH_WIDTH+N_bits-1:0] m1;
reg  signed [DATAPATH_WIDTH+N_bits-1:0] m2;

reg  signed [DATAPATH_WIDTH-1:0] out_ff;
reg  signed [DATAPATH_WIDTH-1:0] data_reg;

//-------------------------Coeficientes------------------------//                    
wire signed [DATAPATH_WIDTH+N_bits-1:0] p1;                           
wire signed [DATAPATH_WIDTH+N_bits-1:0] p2;  

//-----------------------Valores intermedios-------------------//
wire signed [DATAPATH_WIDTH+N_bits-1:0] m2_m0;                            // m2 + m0
wire signed [DATAPATH_WIDTH+N_bits-1:0] m2_m0_div2;                       // (m2 + m0)/2
wire signed [DATAPATH_WIDTH+N_bits-1:0] t2_m1;                            // 2*m1
wire signed [DATAPATH_WIDTH+N_bits-1:0] t2_m1_m0;                         // 2*m1 - m0
wire signed [DATAPATH_WIDTH+N_bits-1:0] xi;                               // x * i
wire signed [DATAPATH_WIDTH+N_bits-1:0] data_y;                           //result de la mult
wire signed [DATAPATH_WIDTH+N_bits-1:0] p2_xi2;                           // p2 * x^2 * i^2 

wire signed [DATAPATH_WIDTH+N_bits-1:0] multi_val;                        //resultado del multiplicador reutilizado.                   
wire signed [DATAPATH_WIDTH+N_bits-1:0] xi2_w;
wire signed [DATAPATH_WIDTH-1:0] xi2;

wire signed [DATAPATH_WIDTH+N_bits-1:0] x_w;
wire signed [DATAPATH_WIDTH+N_bits-1:0] x2_w;
wire signed [DATAPATH_WIDTH+N_bits-1:0] data_to_process_w;


wire saturation_min;
wire saturation_max;
wire SbA; // Saturation bit A dato pasado
wire SbB; // Saturation bit B dato pasado
wire SbC; // Saturation bit C dato actual
wire SbD; // Saturation bit D dato actual

reg signed  [DATAPATH_WIDTH+N_bits-1:0] p1_xi;                           // p1 * x * i

assign x_w   = {{N_bits{1'b0}},x};
assign x2_w  = {{N_bits{1'b0}},x2};

//---------------------Saturation Stage-------------------------------------------------
assign SbA   = out_ff[DATAPATH_WIDTH-1];
assign SbB   = out_ff[DATAPATH_WIDTH-2];
assign SbC   = data_reg[DATAPATH_WIDTH-1];
assign SbD   = data_reg[DATAPATH_WIDTH-2];

assign data_to_process_w = {{N_bits{data_to_process[DATAPATH_WIDTH-1]}},data_to_process};
assign saturation_max    = ~SbA  &  SbB &  SbC & ~SbD; //A'BCD'  | 01 -> 10
assign saturation_min    =  SbA  & ~SbB & ~SbC &  SbD; //AB'C'D  | 10 -> 01

assign data_out = saturation_min ? min_Thold   : 
                  saturation_max ? max_Thold   : data_reg;
//-------------------------------------------------------------------------------------
always @(posedge clk, negedge rstn) begin
    if(!rstn) begin
        p1_xi      <=  {DATAPATH_WIDTH+N_bits{1'b0}};
        m0          =  {DATAPATH_WIDTH+N_bits{1'b0}};
        m1          =  {DATAPATH_WIDTH+N_bits{1'b0}};
        m2          =  {DATAPATH_WIDTH+N_bits{1'b0}};
        out_ff      <=  {DATAPATH_WIDTH{1'b0}};
        data_reg    <=  {DATAPATH_WIDTH{1'b0}};
    end    
    else begin
        // if(Ld_y)      
        //     data_reg <= y;
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
            data_reg <= data_y[DATAPATH_WIDTH-1:0];
        if(~(saturation_min | saturation_max)) begin
            out_ff <= data_reg;     
        end
    end
end


//--------------------------M2 + M0-----------------------------//
intpol2_D4_adder#(
    .DATAPATH_WIDTH ( DATAPATH_WIDTH ),
    .N_bits(N_bits)
)ADDER(
    .A  ( m2  ),
    .B  ( m0  ),
    .C  ( m2_m0  )
);
//----------------------- (M2 + M0)/2 --------------------------//
intpol2_D4_shift#(
    .DATAPATH_WIDTH ( DATAPATH_WIDTH ),
    .N_bits(N_bits)
)SHIFT_DIV(
    .OP        (  1'b1      ),
    .data_in   (  m2_m0     ),
    .data_out  ( m2_m0_div2 )
);


//---------------- p2 = (M2 + M0)/2 - m1 -----------------------//
intpol2_D4_sub_sync#(
    .DATAPATH_WIDTH ( DATAPATH_WIDTH ),
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
    .DATAPATH_WIDTH ( DATAPATH_WIDTH ),
    .N_bits(N_bits)
)SHIFT_Mult(
    .OP        (  1'b0   ),
    .data_in   (  m1     ),
    .data_out  ( t2_m1   )
);

//------------------------ (2*m1 - m0) ------------------------//

intpol2_D4_sub#(
    .DATAPATH_WIDTH ( DATAPATH_WIDTH ),
    .N_bits(N_bits)
)SUB_2(
    .A  ( t2_m1  ),
    .B  ( m0  ),
    .C  ( t2_m1_m0  )
);

//--------------- p1 = (t2_m1 - m0) - m2_m0_div2) ------------------//

intpol2_D4_sub_sync#(
    .DATAPATH_WIDTH ( DATAPATH_WIDTH ),
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
    .DATAPATH_WIDTH ( DATAPATH_WIDTH ),
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
//     .DATAPATH_WIDTH ( DATAPATH_WIDTH ),
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
    .DATAPATH_WIDTH ( DATAPATH_WIDTH ),
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
    .DATAPATH_WIDTH ( DATAPATH_WIDTH ),
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
    .DATAPATH_WIDTH ( DATAPATH_WIDTH ),
    .N_bits(N_bits)
)ADDER3(
    .A ( m0        ),
    .B ( p1_xi     ),
    .C ( multi_val ),
    .Y ( data_y    )
);



endmodule