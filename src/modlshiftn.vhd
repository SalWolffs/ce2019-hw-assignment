----------------------------------------------------------------------------------
-- Summer School on Real-world Crypto & Privacy - Hardware Tutorial 
-- Sibenik, June 11-15, 2018 
-- 
-- Author: Nele Mentens
-- Updated by Pedro Maat Costa Massolino
--  
-- Module Name: modaddn 
-- Description: n-bit modular adder
----------------------------------------------------------------------------------

-- include the STD_LOGIC_1164 package in the IEEE library for basic functionality
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- include the NUMERIC_STD package for arithmetic operations
use IEEE.NUMERIC_STD.ALL;

-- describe the interface of the module
-- sum = (a + b) mod p
entity modlshiftn is
    generic( size : integer := 8);
    port( a, p: in std_logic_vector(size-1 downto 0);
          result: out std_logic_vector(size-1 downto 0));
end modlshiftn;

-- describe the behavior of the module in the architecture
architecture behavioral of modlshiftn is
    signal a_long, c, d: std_logic_vector(size downto 0);

begin
    -- extend a and b with one bit because the "+" operator expects the inputs and output to be of equal length
    a_long <= '0' & a;

    -- add two binary numbers
    c <= std_logic_vector(shift_left(unsigned(a_long),1));

    -- subtract p from the intermediate result
    d <= std_logic_vector(unsigned(c) - unsigned(p));

    -- assign d to the sum output if d is a positive number
    -- assign c to the sum output if d is a negative number
    -- leave the MSB out of the assignment because it is always '0'
    mux: process(c, d)
    begin
        if d(size) = '0' then
            result <= d(size-1 downto 0);
        else
            result <= c(size-1 downto 0);
        end if;
    end process;

end behavioral;
