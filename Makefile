wave/%.ghw: src/%.vhd testbenches/tb_%.vhd
	mkdir -p wave 
	ghdl -c $^ -r tb_$* --stop-time=1ms --wave=wave/$*.ghw

wave/modmultn.ghw: src/modaddn.vhd src/ctr_fsm.vhd src/modlshiftn.vhd src/piso_lshiftreg.vhd
wave/modaddn_mult.ghw: src/modaddn.vhd src/ctr_fsm.vhd 
wave/modarithn.ghw: src/modaddn.vhd src/ctr_fsm.vhd src/modlshiftn.vhd src/piso_lshiftreg.vhd src/modmultn.vhd src/modaddsubn.vhd
