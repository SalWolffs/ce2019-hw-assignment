all: wave/add4.ghw wave/addn.ghw wave/addsubn.ghw \
	wave/ecc_add_double_small.ghw wave/ecc_add_double_nist.ghw \
	wave/ecc_base.ghw wave/modadd4.ghw wave/modaddn_mult5.ghw \
	wave/modaddn_mult.ghw wave/modaddn.ghw wave/modaddsubn.ghw \
	wave/modarithn.ghw wave/modmultn.ghw wave/ram_double.ghw \
	wave/ram_single.ghw

clean:
	rm -rf build wave

.PHONY: all clean

src/rbc_rom.vhd: src/rbc_rom.py
	python3 src/rbc_rom.py > src/rbc_rom.vhd

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

wave/ecc_add_double_%.ghw: src/ecc_add_double.vhd \
	testbenches/tb_ecc_add_double_%.vhd \
	src/ecc_fsm.vhd src/modarithn.vhd src/ram_double.vhd \
	src/modaddn.vhd src/ctr_fsm.vhd src/modlshiftn.vhd src/piso_lshiftreg.vhd \
	src/modmultn.vhd src/modaddsubn.vhd src/rbc_rom.vhd src/ecc_base.vhd
	mkdir -p wave
	ghdl -c $^ -r tb_ecc_add_double_$* --stop-time=1ms --wave=wave/ecc_add_double_$*.ghw

wave/modmultn.ghw: src/modaddn.vhd src/ctr_fsm.vhd src/modlshiftn.vhd src/piso_lshiftreg.vhd
wave/modaddn_mult.ghw: src/modaddn.vhd src/ctr_fsm.vhd 
wave/modaddn_mult5.ghw: src/modaddsubn.vhd
wave/modarithn.ghw: src/modaddn.vhd src/ctr_fsm.vhd src/modlshiftn.vhd src/piso_lshiftreg.vhd src/modmultn.vhd src/modaddsubn.vhd
wave/ecc_base.ghw: src/ecc_fsm.vhd src/modarithn.vhd src/ram_double.vhd \
	src/modaddn.vhd src/ctr_fsm.vhd src/modlshiftn.vhd src/piso_lshiftreg.vhd \
	src/modmultn.vhd src/modaddsubn.vhd
