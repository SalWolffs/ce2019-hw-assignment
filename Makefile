wave/%.ghw: src/%.vhd testbenches/tb_%.vhd
	mkdir -p wave
	ghdl -c src/$*.vhd testbenches/tb_$*.vhd -r tb_$* --wave=wave/$*.ghw
