all: wave/add4.ghw wave/addn.ghw wave/addsubn.ghw \
	wave/ecc_base.ghw wave/modadd4.ghw wave/modaddn_mult5.ghw \
	wave/modaddn_mult.ghw wave/modaddn.ghw wave/modaddsubn.ghw \
	wave/modarithn.ghw wave/modmultn.ghw wave/ram_double.ghw \
	wave/ram_single.ghw

.PHONY: all

build/tb_%_stitched.vhd: testbenches/tb_%.vhd
	mkdir -p build
	gcc -E -P -x c testbenches/tb_$*.vhd -o build/tb_$*_stitched.vhd

build/%_stitched.vhd: src/%.vhd 
	mkdir -p build
	gcc -E -P -x c src/$*.vhd -o build/$*_stitched.vhd

# wave/%.ghw: build/tb_%_stitched.vhd build/%_stitched.vhd
# 	mkdir -p wave 
# 	ghdl -c build/$*_stitched.vhd build/tb_$*_stitched.vhd -r tb_$* --wave=wave/$*.ghw

wave/%.ghw: src/%.vhd testbenches/tb_%.vhd
	mkdir -p wave 
	ghdl -c $^ -r tb_$* --stop-time=1ms --wave=wave/$*.ghw

wave/modmultn.ghw: src/modaddn.vhd src/ctr_fsm.vhd src/modlshiftn.vhd src/piso_lshiftreg.vhd
wave/modaddn_mult.ghw: src/modaddn.vhd src/ctr_fsm.vhd 
wave/modaddn_mult5.ghw: src/modaddsubn.vhd
wave/modarithn.ghw: src/modaddn.vhd src/ctr_fsm.vhd src/modlshiftn.vhd src/piso_lshiftreg.vhd src/modmultn.vhd src/modaddsubn.vhd
