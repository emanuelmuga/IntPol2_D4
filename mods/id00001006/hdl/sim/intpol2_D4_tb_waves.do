onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /intpol2_D4_tb/DUT/clk
add wave -noupdate /intpol2_D4_tb/DUT/rstn
add wave -noupdate /intpol2_D4_tb/DUT/start
add wave -noupdate /intpol2_D4_tb/DUT/Empty_i
add wave -noupdate /intpol2_D4_tb/DUT/Controlpath/next_state_logic/en_M_addr
add wave -noupdate /intpol2_D4_tb/DUT/Controlpath/next_state_logic/M_cnt
add wave -noupdate /intpol2_D4_tb/DUT/Controlpath/next_state_logic/comp_addr
add wave -noupdate /intpol2_D4_tb/DUT/Controlpath/FSM/state
add wave -noupdate /intpol2_D4_tb/DUT/Controlpath/next_state_logic/Y_addr
add wave -noupdate /intpol2_D4_tb/DUT/Controlpath/next_state_logic/M_addr
add wave -noupdate /intpol2_D4_tb/DUT/Afull_i
add wave -noupdate /intpol2_D4_tb/DUT/Write_Enable_fifo
add wave -noupdate /intpol2_D4_tb/DUT/Read_Enable_fifo
add wave -noupdate -radix hexadecimal /intpol2_D4_tb/DUT/I_interp
add wave -noupdate -radix hexadecimal /intpol2_D4_tb/DUT/Q_interp
add wave -noupdate /intpol2_D4_tb/DUT/done
add wave -noupdate /intpol2_D4_tb/DUT/busy
add wave -noupdate /intpol2_D4_tb/DUT/Datapath_I/en_stream
add wave -noupdate /intpol2_D4_tb/DUT/Datapath_I/op_1
add wave -noupdate /intpol2_D4_tb/DUT/Controlpath/FSM/state
add wave -noupdate -divider FIFO_IN
add wave -noupdate /intpol2_D4_tb/FIFO_I_in/Write_enable_i
add wave -noupdate -radix hexadecimal /intpol2_D4_tb/FIFO_Q_in/Write_enable_i
add wave -noupdate /intpol2_D4_tb/FIFO_I_in/Almost_Empty_o
add wave -noupdate -divider FIFO_OUT
add wave -noupdate -format Analog-Step -height 88 -max 2047.0 -min -2048.0 -radix decimal /intpol2_D4_tb/FIFO_I_in/data_output__o
add wave -noupdate -format Analog-Step -height 88 -max 2047.0 -min -2048.0 -radix decimal /intpol2_D4_tb/FIFO_Q_in/data_output__o
add wave -noupdate -format Analog-Step -height 88 -max 2047.0 -min -2048.0 /intpol2_D4_tb/DUT/I_interp
add wave -noupdate -format Analog-Step -height 88 -max 2047.0 -min -2048.0 /intpol2_D4_tb/DUT/Q_interp
add wave -noupdate -format Analog-Step -height 88 -label {Saturated signal} -max 2047.0 -min -2048.0 /intpol2_D4_tb/DUT/Datapath_Q/data_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {7210000 ps} 0} {{Cursor 2} {7182017 ps} 0}
quietly wave cursor active 2
configure wave -namecolwidth 549
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
configure wave -timelineunits ps
update
WaveRestoreZoom {7135270 ps} {7291475 ps}
run 100us