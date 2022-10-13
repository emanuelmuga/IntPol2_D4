onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /intpol2_D4_IQ_tb/DUT/clk
add wave -noupdate /intpol2_D4_IQ_tb/DUT/rstn
add wave -noupdate /intpol2_D4_IQ_tb/DUT/start
add wave -noupdate /intpol2_D4_IQ_tb/DUT/Empty_i
add wave -noupdate /intpol2_D4_IQ_tb/DUT/Controlpath/next_state_logic/en_M_addr
add wave -noupdate /intpol2_D4_IQ_tb/DUT/Controlpath/next_state_logic/M_cnt
add wave -noupdate /intpol2_D4_IQ_tb/DUT/Controlpath/next_state_logic/comp_addr
add wave -noupdate /intpol2_D4_IQ_tb/DUT/Controlpath/FSM/state
add wave -noupdate /intpol2_D4_IQ_tb/DUT/Afull_i
add wave -noupdate -radix hexadecimal /intpol2_D4_IQ_tb/DUT/data_in_from_fifo_I
add wave -noupdate -radix hexadecimal /intpol2_D4_IQ_tb/DUT/data_in_from_fifo_Q
add wave -noupdate /intpol2_D4_IQ_tb/DUT/Write_Enable_fifo
add wave -noupdate /intpol2_D4_IQ_tb/DUT/Read_Enable_fifo
add wave -noupdate -radix hexadecimal /intpol2_D4_IQ_tb/DUT/I_interp
add wave -noupdate -radix hexadecimal /intpol2_D4_IQ_tb/DUT/Q_interp
add wave -noupdate /intpol2_D4_IQ_tb/DUT/done
add wave -noupdate /intpol2_D4_IQ_tb/DUT/busy
add wave -noupdate -divider FIFO_IN
add wave -noupdate /intpol2_D4_IQ_tb/FIFO_I_in/Write_enable_i
add wave -noupdate -radix hexadecimal /intpol2_D4_IQ_tb/FIFO_Q_in/Write_enable_i
add wave -noupdate /intpol2_D4_IQ_tb/FIFO_I_in/Almost_Empty_o
add wave -noupdate -divider FIFO_OUT
add wave -noupdate -format Analog-Step -height 88 -max 2047.0 -min -2048.0 -radix decimal /intpol2_D4_IQ_tb/FIFO_I_in/data_output__o
add wave -noupdate -format Analog-Step -height 88 -max 2047.0 -min -2048.0 -radix decimal /intpol2_D4_IQ_tb/FIFO_I_out/data_input___i
add wave -noupdate -format Analog-Step -height 88 -max 2047.0 -min -2048.0 -radix decimal /intpol2_D4_IQ_tb/FIFO_Q_in/data_output__o
add wave -noupdate -format Analog-Step -height 88 -max 2047.0 -min -2048.0 -radix decimal /intpol2_D4_IQ_tb/FIFO_Q_out/data_input___i
add wave -noupdate -format Analog-Step -height 88 -max 2047.0 -min -2048.0 /intpol2_D4_IQ_tb/DUT/Datapath_Q/data_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4348321 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 314
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
WaveRestoreZoom {0 ps} {99565853 ps}
