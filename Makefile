build/tb_%_stitched.vhd: testbenches/tb_%.vhd
	mkdir -p build
	gcc -E -P -x c testbenches/tb_$*.vhd -o build/tb_$*_stitched.vhd

build/%_stitched.vhd: src/%.vhd 
	mkdir -p build
	gcc -E -P -x c src/$*.vhd -o build/$*_stitched.vhd

wave/%.ghw: build/tb_%_stitched.vhd build/%_stitched.vhd
	mkdir -p wave 
	ghdl -c build/$*_stitched.vhd build/tb_$*_stitched.vhd -r tb_$* --wave=wave/$*.ghw

