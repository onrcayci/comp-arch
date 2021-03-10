proc AddWaves {} {
	add wave -position end sim:/cache_tb/clock
	add wave -position end sim:/cache_tb/reset
	add wave -position end sim:/cache_tb/s_addr
	add wave -position end sim:/cache_tb/s_read
	add wave -position end sim:/cache_tb/s_readdata
	add wave -position end sim:/cache_tb/s_write
	add wave -position end sim:/cache_tb/s_writedata
	add wave -position end sim:/cache_tb/s_waitrequest
	add wave -position end sim:/cache_tb/m_addr
	add wave -position end sim:/cache_tb/m_read
	add wave -position end sim:/cache_tb/m_readdata
	add wave -position end sim:/cache_tb/m_write
	add wave -position end sim:/cache_tb/m_writedata
	add wave -position end sim:/cache_tb/m_waitrequest

}

vlib work

vcom cache.vhd
vcom cache_tb.vhd

vsim cache_tb

force -deposit clock 0 0 ns, 2 1ns -repeat 2ns

AddWaves

run 250ns