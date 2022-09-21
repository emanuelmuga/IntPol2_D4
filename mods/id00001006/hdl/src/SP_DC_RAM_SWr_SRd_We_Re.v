`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:59:05 03/23/2017 
// Design Name: 
// Module Name:    Dual_Port_Dual_Clock_RAM 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//module Dual_Port_Dual_Clock_RAM
module SP_DC_RAM_SWr_SRd_We_Re
#(parameter 
DATA_WIDTH=12,        // Datawidth of data
ADDR_WIDTH=12        // Address bits
)(
input                           Write_clock__i, 
input                           Write_enable_i,
input [(ADDR_WIDTH-1):0]        Write_addres_i,
input                           Read_clock___i, 
input                           Read_enable__i,
input [(ADDR_WIDTH-1):0]        Read_address_i, 
input [(DATA_WIDTH-1):0]        data_input___i,
output reg [(DATA_WIDTH-1):0]   data_output__o
);


reg [(DATA_WIDTH-1):0] RAM_Structure [2**ADDR_WIDTH-1:0];

always @(posedge Write_clock__i)
    if (Write_enable_i)
            RAM_Structure[Write_addres_i] <= data_input___i;
      
always @(posedge Read_clock___i)
      if (Read_enable__i)
         data_output__o <= RAM_Structure[Read_address_i];

endmodule 
