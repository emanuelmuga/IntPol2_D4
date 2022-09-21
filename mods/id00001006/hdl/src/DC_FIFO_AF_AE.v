`timescale 1ns / 1ps
module DC_FIFO_AF_AE
#(parameter 
DATA_WIDTH= 32,  // Datawidth of data
ADDR_WIDTH= 4    // Address bits
)(
input                       Write_clock__i,     // posedge active
input                       Write_enable_i,     // High active
input                       rst_async_la_i,     // Asynchronous reset low active
input                       Read_clock___i,     // Posedge active 
input                       Read_enable__i,     // High active
input  [(DATA_WIDTH-1):0]   data_input___i,
input  [(ADDR_WIDTH-1):0]   differenceAF_i,     // Difference used for an almost full flag.
input  [(ADDR_WIDTH-1):0]   differenceAE_i,     // Difference used for an almost empty
output [(DATA_WIDTH-1):0]   data_output__o,
output reg                  Empty_Indica_o,
output reg                  Full_Indicat_o,
output                      Almost_Full__o,     // Programmable almost-full flag
output                      Almost_Empty_o      // Programmable almost-empty flag
);
localparam [ADDR_WIDTH:0] MAX_NUM = 2**ADDR_WIDTH; // 

//#################################################################
//  WIRE and REG of Wrinting process
reg             [(ADDR_WIDTH):0]    Write_addres_r;        // Write address pointer Binary
reg             [(ADDR_WIDTH):0]    Wr_Addr_Gray_r;        // Write address pointer Gray Encoded
wire            [(ADDR_WIDTH):0]    Write_addres_w;        // Write address pointer Binary
wire            [(ADDR_WIDTH):0]    Write_address_Gray;    // Write address pointer Gray encoded
reg             [(ADDR_WIDTH):0]    Rd_Addr_Bin_r_Sync2;     // Read address  synchronized from Gray to Binary
wire signed     [ADDR_WIDTH+1:0]    WR_addr_minus_differenceAF_w; // diference between writing address minus difference of the almost-full flag
wire signed     [ADDR_WIDTH+1:0]    RD_addr_minus_differenceAE_w; // diference between writing address minus difference of the almost-full flag value.
wire signed     [ADDR_WIDTH:0]      Value_Difference_AF;        // Difference between RAM Deep - difference AF
wire signed     [ADDR_WIDTH:0]      Value_Difference_AE;        // Difference between RAM Deep - difference AF
//  WIRE and REG of Reading process
reg     [(ADDR_WIDTH):0]    Read_address_r;        // Read address pointer
reg     [(ADDR_WIDTH):0]    Rd_Addr_Gray_r;        // Read address pointer Gray Encoded
wire    [(ADDR_WIDTH):0]    Read_address_w;        // Read address pointer
wire    [(ADDR_WIDTH):0]    Read_address_Gray;     // Read address pointer Gray encoded
reg     [(ADDR_WIDTH):0]    Wr_Addr_Bin_r_Sync2;     // Write address synchronized from Gray to Binary
reg                         Almost_Full__w;
reg                         Almost_Empty_w;
// Cross domaing Flip-flops
reg [(ADDR_WIDTH):0]     Wr_Addr_Gray_r_Sync1;
reg [(ADDR_WIDTH):0]     Wr_Addr_Gray_r_Sync2;
reg [(ADDR_WIDTH):0]     Rd_Addr_Gray_r_Sync1;
reg [(ADDR_WIDTH):0]     Rd_Addr_Gray_r_Sync2;
//#################################################################

//#################################################################
// Write pointer
assign Write_addres_w       = Write_addres_r+1'b1;
assign Write_address_Gray   = (Write_addres_w >> 1) ^ Write_addres_w;

always@(posedge Write_clock__i, negedge rst_async_la_i)
begin
if(!rst_async_la_i)
    Write_addres_r<={ADDR_WIDTH+1{1'b0}};
else if(Write_enable_i & ~Full_Indicat_o)
    Write_addres_r<=Write_addres_w;
end

always@(posedge Write_clock__i, negedge rst_async_la_i)
begin
if(!rst_async_la_i)
    Wr_Addr_Gray_r  <= {ADDR_WIDTH+1{1'b0}};
else if(Write_enable_i & ~Full_Indicat_o)                        // Posiblemente, calarle con el !FULL
    Wr_Addr_Gray_r  <= Write_address_Gray;
end

    // Convert from Gray to Binary
integer i;
always@*
begin
for (i=0; i<ADDR_WIDTH+1; i=i+1)
  Rd_Addr_Bin_r_Sync2[i] = ^(Rd_Addr_Gray_r_Sync2 >> i);
end
//##############################################################

//##############################################################
// Generating the Full Condition
always@*
begin
    if((Write_addres_r[ADDR_WIDTH]!=Rd_Addr_Bin_r_Sync2[ADDR_WIDTH])&& (Write_addres_r[ADDR_WIDTH-1:0]==Rd_Addr_Bin_r_Sync2[ADDR_WIDTH-1:0]))
        Full_Indicat_o<=1'b1;
    else
        Full_Indicat_o<=1'b0;
end
//##############################################################

//##############################################################
// Generating the Almost-Full Condition
// This is a programmable flag wich is controlled via the input port Difference_AF
assign WR_addr_minus_differenceAF_w = Write_addres_r[ADDR_WIDTH:0] - Rd_Addr_Bin_r_Sync2[ADDR_WIDTH:0];
assign Value_Difference_AF =(MAX_NUM-differenceAF_i);

always@*
begin
    if( (Value_Difference_AF<= WR_addr_minus_differenceAF_w[ADDR_WIDTH-1:0])&&~Full_Indicat_o)
        Almost_Full__w<=1'b1;
    else
        Almost_Full__w<=1'b0;
end

assign Almost_Full__o= Almost_Full__w||Full_Indicat_o;
//##############################################################

//##############################################################
// Generating the Almost-Empty Condition
// This is a programmable flag wich is controlled via the input port Difference_AE

assign RD_addr_minus_differenceAE_w = Wr_Addr_Bin_r_Sync2[ADDR_WIDTH:0] - Read_address_r[ADDR_WIDTH:0] ;
assign Value_Difference_AE =(differenceAE_i);

always@*
begin
    if( (Value_Difference_AE>= RD_addr_minus_differenceAE_w[ADDR_WIDTH:0]) && ~Empty_Indica_o )
        Almost_Empty_w<=1'b1;
    else
        Almost_Empty_w<=1'b0;
end

assign Almost_Empty_o= Almost_Empty_w||Empty_Indica_o;
//##############################################################

//##############################################################
// Read pointer Logic
assign Read_address_w=Read_address_r+1'b1;
assign Read_address_Gray = (Read_address_w >> 1) ^ Read_address_w;

always@(posedge Read_clock___i, negedge rst_async_la_i)
begin
if(!rst_async_la_i)
    Read_address_r<={ADDR_WIDTH+1{1'b0}};
else if(Read_enable__i&&!Empty_Indica_o)
    Read_address_r<=Read_address_w;
end

always@(posedge Read_clock___i, negedge rst_async_la_i)
begin
if(!rst_async_la_i)
    Rd_Addr_Gray_r<={ADDR_WIDTH+1{1'b0}};
else if(Read_enable__i&&!Empty_Indica_o)
    Rd_Addr_Gray_r<=Read_address_Gray;
end

// Convert from Gray to Binary
integer j;
always @*
begin
for (j=0; j<ADDR_WIDTH+1; j=j+1)
  Wr_Addr_Bin_r_Sync2[j] = ^(Wr_Addr_Gray_r_Sync2 >> j);
end

// Generating the Empty Condition
// if((Write_addres_r[ADDR_WIDTH]!=Rd_Addr_Bin_r_Sync2[ADDR_WIDTH])&& (Write_addres_r[ADDR_WIDTH-1:0]==Rd_Addr_Bin_r_Sync2[ADDR_WIDTH-1:0]))
//        Full_Indicat_o<=1'b1;
always@*
begin
    if(Read_address_r==Wr_Addr_Bin_r_Sync2)
        Empty_Indica_o<=1'b1;
    else
        Empty_Indica_o<=1'b0;
end
//##############################################################

//##############################################################
// Cross Domain Flip Flips
always@(posedge Write_clock__i, negedge rst_async_la_i)
begin
if(!rst_async_la_i)
    begin
        Rd_Addr_Gray_r_Sync1<={ADDR_WIDTH+1{1'b0}};
        Rd_Addr_Gray_r_Sync2<={ADDR_WIDTH+1{1'b0}};    
    end
else
    begin
        Rd_Addr_Gray_r_Sync1<=Rd_Addr_Gray_r;
        Rd_Addr_Gray_r_Sync2<=Rd_Addr_Gray_r_Sync1;    
    end
end

always@(posedge Read_clock___i, negedge rst_async_la_i)
begin
if(!rst_async_la_i)
    begin
        Wr_Addr_Gray_r_Sync1<={ADDR_WIDTH+1{1'b0}};
        Wr_Addr_Gray_r_Sync2<={ADDR_WIDTH+1{1'b0}};
    end
else
    begin
        Wr_Addr_Gray_r_Sync1<=Wr_Addr_Gray_r;
        Wr_Addr_Gray_r_Sync2<=Wr_Addr_Gray_r_Sync1;
    end
end
//##############################################################

//##############################################################
// RAM Module
//Dual_Port_Dual_Clock_RAM #( 
SP_DC_RAM_SWr_SRd_We_Re #( 
.DATA_WIDTH(DATA_WIDTH),    // Datawidth of data
.ADDR_WIDTH(ADDR_WIDTH)        // Address bits
) Dual_Port_Dual_Clock_RAM_Inst (
.Write_clock__i(Write_clock__i), 
.Write_enable_i(Write_enable_i&~Full_Indicat_o),
.Write_addres_i(Write_addres_r[ADDR_WIDTH-1:0]),
.Read_clock___i(Read_clock___i), 
.Read_enable__i(Read_enable__i&~Empty_Indica_o),
.Read_address_i(Read_address_r[ADDR_WIDTH-1:0]), 
.data_input___i(data_input___i),
.data_output__o(data_output__o)
);
//##############################################################

endmodule
 