names = list('pab')
names += [c + n for n in '123' for c in 'XYZ']
names += ['t' + n for n in '01234567']
addr = dict(zip(names, range(32)))
opcode = dict(zip(' *+-', range(4)))

addition_asm = '''
t0=X1*X2
t1=Y1*Y2
t2=Z1*Z2
t3=X1+Y1
t4=X2+Y2
t3=t3*t4
t4=t0+t1
t3=t3-t4
t4=Y1+Z1
t5=Y2+Z2
t4=t4*t5
t5=t1+t2
t4=t4-t5
t5=X1+Z1
t6=X2+Z2
t5=t5*t6
t6=t0+t2
t6=t5-t6
t7=b*t2
t5=t6-t7
t7=t5+t5
t5=t5+t7
t7=t1-t5
t5=t1+t5
t6=b*t6
t1=t2+t2
t2=t1+t2
t6=t6-t2
t6=t6-t0
t1=t6+t6
t6=t1+t6
t1=t0+t0
t0=t1+t0
t0=t0-t2
t1=t4*t6
t2=t0*t6
t6=t5*t7
Y3=t6+t2
t5=t3*t5
X3=t5-t1
t7=t4*t7
t1=t3*t0
Z3=t7+t1
'''.split()

doubling_asm = '''
t0=X1*X1
t1=Y1*Y1
t2=Z1*Z1
t3=X1*Y1
t3=t3+t3
t6=X1*Z1
t6=t6+t6
t5=b*t2
t5=t5-t6
t4=t5+t5
t5=t4+t5
t4=t1-t5
t5=t1+t5
t5=t4*t5
t4=t4*t3
t3=t2+t2
t2=t2+t3
t6=b*t6
t6=t6-t2
t6=t6-t0
t3=t6+t6
t6=t6+t3
t3=t0+t0
t0=t3+t0
t0=t0-t2
t0=t0*t6
t2=Y1*Z1
t2=t2+t2
Y3=t5+t0
t6=t2*t6
X3=t4-t6
t6=t2*t1
t6=t6+t6
Z3=t6+t6
'''.split()

ret = (0, 0, 0, 0)
load_p = (4, 0, 0, 0)

vhdl = '''
-- unclocked ROM containing VLIW instructions from page 9
-- generated with python

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rbc_rom is
    generic(
        ws: integer := 18;
        ads: integer := 7);
    port(
        address: in std_logic_vector(ads-1 downto 0);
        dout: out std_logic_vector(ws-1 downto 0));
end rbc_rom;

architecture behavioral of rbc_rom is
type rom is array(0 to 2**ads-1) of std_logic_vector(ws-1 downto 0);
constant data: rom := (
    {});

begin
    dout <= data(to_integer(to_01(unsigned(address))));
end behavioral;
'''.strip()

instructions = []

def parse(s):
    return opcode[s[-3]], addr[s[0:2]], addr[s[-2:]], addr[s[3:-3]]

for func in [addition_asm, doubling_asm]:
    instructions += [load_p]
    instructions += [parse(line) for line in func]
    instructions += [ret]

instructions += [ret] * (128 - len(instructions))

rom_vhdl = ',\n    '.join(
    '{:03} => "{:03b}{:05b}{:05b}{:05b}"'.format(i, *p)
    for i, p in enumerate(instructions))

print(vhdl.format(rom_vhdl))
