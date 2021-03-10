proc AddWaves {} {
	add wave -position end sim:/cache_tb/clk
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

force -deposit clk 0 0 ns, 1 1 ns -repeat 2 ns

AddWaves

run 250ns