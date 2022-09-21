onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label clk /intpol2_D4_tb/DUT/clk
add wave -noupdate -label rstn /intpol2_D4_tb/DUT/rstn
add wave -noupdate -divider Config
add wave -noupdate -label mode /intpol2_D4_tb/DUT/mode
add wave -noupdate -label bypass /intpol2_D4_tb/DUT/bypass
add wave -noupdate -divider input
add wave -noupdate -label start /intpol2_D4_tb/DUT/start
add wave -noupdate -label data_in_mem /intpol2_D4_tb/DUT/data_in_mem
add wave -noupdate -divider Status
add wave -noupdate -color {Sea Green} -label busy /intpol2_D4_tb/busy
add wave -noupdate -color Blue -label done /intpol2_D4_tb/DUT/done
add wave -noupdate -label Afull /intpol2_D4_tb/DUT/Controlpath/FSM/Afull
add wave -noupdate -label Empty /intpol2_D4_tb/DUT/Controlpath/FSM/Empty
add wave -noupdate -divider signals
add wave -noupdate -label m0 -radix decimal /intpol2_D4_tb/DUT/Datapath/m0
add wave -noupdate -color Black -label m1 /intpol2_D4_tb/DUT/Datapath/m1
add wave -noupdate -label m2 -radix decimal /intpol2_D4_tb/DUT/Datapath/m2
add wave -noupdate -label next_state_logic/cnt /intpol2_D4_tb/DUT/Controlpath/next_state_logic/cnt
add wave -noupdate -divider {Control Signals}
add wave -noupdate -label next_state_logic/en_sum /intpol2_D4_tb/DUT/Controlpath/next_state_logic/en_sum
add wave -noupdate -label FSM/en_sum /intpol2_D4_tb/DUT/Controlpath/FSM/en_sum
add wave -noupdate -label FSM/state -radix hexadecimal /intpol2_D4_tb/DUT/Controlpath/FSM/state
add wave -noupdate -label FSM/next_state /intpol2_D4_tb/DUT/Controlpath/FSM/next_state
add wave -noupdate -label FSM/en_M_addr /intpol2_D4_tb/DUT/Controlpath/FSM/en_M_addr
add wave -noupdate -label next_state_logic/comp_addr /intpol2_D4_tb/DUT/Controlpath/next_state_logic/comp_addr
add wave -noupdate -label next_state_logic/comp_cnt /intpol2_D4_tb/DUT/Controlpath/next_state_logic/comp_cnt
add wave -noupdate /intpol2_D4_tb/DUT/Datapath/op_1
add wave -noupdate -divider outputs
add wave -noupdate -label Write_Enable /intpol2_D4_tb/DUT/Controlpath/next_state_logic/Write_Enable
add wave -noupdate -label Y_addr /intpol2_D4_tb/Y_mem_inst/Y_addr
add wave -noupdate -label M_addr /intpol2_D4_tb/M_addr
add wave -noupdate -label Ld_y /intpol2_D4_tb/DUT/Ld_y
add wave -noupdate -label y -radix decimal /intpol2_D4_tb/DUT/Datapath/y
add wave -noupdate -label data_out -radix decimal /intpol2_D4_tb/DUT/data_out
add wave -noupdate /intpol2_D4_tb/DUT/Datapath/Squared/xi2
add wave -noupdate /intpol2_D4_tb/DUT/Datapath/Squared/cnt
add wave -noupdate /intpol2_D4_tb/DUT/Datapath/Squared/en_cnt
add wave -noupdate -divider M_mem
add wave -noupdate -label M_mem_inst/data_out -radix decimal /intpol2_D4_tb/M_mem_inst/data_out
add wave -noupdate -label M_mem_inst/M_addr -radix binary /intpol2_D4_tb/M_mem_inst/M_addr
add wave -noupdate -label M_mem_inst/mem -radix decimal /intpol2_D4_tb/M_mem_inst/mem
add wave -noupdate -label M_mem_inst/RE_M -radix decimal /intpol2_D4_tb/M_mem_inst/RE_M
add wave -noupdate -divider Y_MEM
add wave -noupdate /intpol2_D4_tb/Y_mem_inst/WE_Y
add wave -noupdate -label Y_mem_inst/Y_addr /intpol2_D4_tb/Y_mem_inst/Y_addr
add wave -noupdate -label Y_mem_inst/data_in /intpol2_D4_tb/Y_mem_inst/data_in
add wave -noupdate -label Y_mem_inst/mem -radix decimal -childformat {{{/intpol2_D4_tb/Y_mem_inst/mem[0]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[1]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[2]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[3]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[4]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[5]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[6]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[7]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[8]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[9]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[10]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[11]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[12]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[13]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[14]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[15]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[16]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[17]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[18]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[19]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[20]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[21]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[22]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[23]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[24]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[25]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[26]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[27]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[28]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[29]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[30]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[31]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[32]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[33]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[34]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[35]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[36]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[37]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[38]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[39]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[40]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[41]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[42]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[43]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[44]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[45]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[46]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[47]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[48]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[49]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[50]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[51]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[52]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[53]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[54]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[55]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[56]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[57]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[58]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[59]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[60]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[61]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[62]} -radix decimal} {{/intpol2_D4_tb/Y_mem_inst/mem[63]} -radix decimal}} -subitemconfig {{/intpol2_D4_tb/Y_mem_inst/mem[0]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[1]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[2]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[3]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[4]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[5]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[6]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[7]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[8]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[9]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[10]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[11]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[12]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[13]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[14]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[15]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[16]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[17]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[18]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[19]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[20]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[21]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[22]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[23]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[24]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[25]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[26]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[27]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[28]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[29]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[30]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[31]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[32]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[33]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[34]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[35]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[36]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[37]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[38]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[39]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[40]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[41]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[42]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[43]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[44]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[45]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[46]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[47]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[48]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[49]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[50]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[51]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[52]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[53]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[54]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[55]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[56]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[57]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[58]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[59]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[60]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[61]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[62]} {-height 15 -radix decimal} {/intpol2_D4_tb/Y_mem_inst/mem[63]} {-height 15 -radix decimal}} /intpol2_D4_tb/Y_mem_inst/mem
add wave -noupdate -divider FIFO_IN
add wave -noupdate -label Data_in_FIFO -radix decimal /intpol2_D4_tb/DUT/data_in_fifo
add wave -noupdate -radix decimal /intpol2_D4_tb/FIFO_I_Data/Almost_Full__o
add wave -noupdate -radix decimal /intpol2_D4_tb/FIFO_I_Data/data_input___i
add wave -noupdate -radix decimal /intpol2_D4_tb/FIFO_I_Data/data_output__o
add wave -noupdate -radix decimal /intpol2_D4_tb/FIFO_I_Data/Empty_Indica_o
add wave -noupdate -radix decimal /intpol2_D4_tb/FIFO_I_Data/Read_enable__i
add wave -noupdate -radix decimal /intpol2_D4_tb/FIFO_I_Data/Write_enable_i
add wave -noupdate -radix decimal /intpol2_D4_tb/FIFO_I_Data/Dual_Port_Dual_Clock_RAM_Inst/RAM_Structure
add wave -noupdate -divider FIFO_OUT
add wave -noupdate -radix decimal /intpol2_D4_tb/FIFO_O_Data/Almost_Full__o
add wave -noupdate -radix decimal /intpol2_D4_tb/FIFO_O_Data/data_input___i
add wave -noupdate -radix decimal /intpol2_D4_tb/FIFO_O_Data/data_output__o
add wave -noupdate -radix decimal /intpol2_D4_tb/FIFO_O_Data/Empty_Indica_o
add wave -noupdate -radix decimal /intpol2_D4_tb/FIFO_O_Data/Read_enable__i
add wave -noupdate -radix decimal /intpol2_D4_tb/FIFO_O_Data/Write_enable_i
add wave -noupdate -radix decimal -childformat {{{/intpol2_D4_tb/FIFO_O_Data/Dual_Port_Dual_Clock_RAM_Inst/RAM_Structure[7]} -radix decimal} {{/intpol2_D4_tb/FIFO_O_Data/Dual_Port_Dual_Clock_RAM_Inst/RAM_Structure[6]} -radix decimal} {{/intpol2_D4_tb/FIFO_O_Data/Dual_Port_Dual_Clock_RAM_Inst/RAM_Structure[5]} -radix decimal} {{/intpol2_D4_tb/FIFO_O_Data/Dual_Port_Dual_Clock_RAM_Inst/RAM_Structure[4]} -radix decimal} {{/intpol2_D4_tb/FIFO_O_Data/Dual_Port_Dual_Clock_RAM_Inst/RAM_Structure[3]} -radix decimal} {{/intpol2_D4_tb/FIFO_O_Data/Dual_Port_Dual_Clock_RAM_Inst/RAM_Structure[2]} -radix decimal} {{/intpol2_D4_tb/FIFO_O_Data/Dual_Port_Dual_Clock_RAM_Inst/RAM_Structure[1]} -radix decimal} {{/intpol2_D4_tb/FIFO_O_Data/Dual_Port_Dual_Clock_RAM_Inst/RAM_Structure[0]} -radix decimal}} -subitemconfig {{/intpol2_D4_tb/FIFO_O_Data/Dual_Port_Dual_Clock_RAM_Inst/RAM_Structure[7]} {-height 15 -radix decimal} {/intpol2_D4_tb/FIFO_O_Data/Dual_Port_Dual_Clock_RAM_Inst/RAM_Structure[6]} {-height 15 -radix decimal} {/intpol2_D4_tb/FIFO_O_Data/Dual_Port_Dual_Clock_RAM_Inst/RAM_Structure[5]} {-height 15 -radix decimal} {/intpol2_D4_tb/FIFO_O_Data/Dual_Port_Dual_Clock_RAM_Inst/RAM_Structure[4]} {-height 15 -radix decimal} {/intpol2_D4_tb/FIFO_O_Data/Dual_Port_Dual_Clock_RAM_Inst/RAM_Structure[3]} {-height 15 -radix decimal} {/intpol2_D4_tb/FIFO_O_Data/Dual_Port_Dual_Clock_RAM_Inst/RAM_Structure[2]} {-height 15 -radix decimal} {/intpol2_D4_tb/FIFO_O_Data/Dual_Port_Dual_Clock_RAM_Inst/RAM_Structure[1]} {-height 15 -radix decimal} {/intpol2_D4_tb/FIFO_O_Data/Dual_Port_Dual_Clock_RAM_Inst/RAM_Structure[0]} {-height 15 -radix decimal}} /intpol2_D4_tb/FIFO_O_Data/Dual_Port_Dual_Clock_RAM_Inst/RAM_Structure
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4894466 ps} 0} {{Cursor 2} {23407 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 201
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {260800 ps}
