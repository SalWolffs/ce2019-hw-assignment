----------------------------------------------------------------------------------
-- Summer School on Real-world Crypto & Privacy - Hardware Tutorial 
-- Sibenik, June 11-15, 2018 
-- 
-- Author: Nele Mentens
--  
-- Module Name: modaddn_mult
-- Description: n-bit modular multiplier (through consecutive additions)
----------------------------------------------------------------------------------

-- include the STD_LOGIC_1164 package in the IEEE library for basic functionality
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- include the NUMERIC_STD package for arithmetic operations
use IEEE.NUMERIC_STD.ALL;

-- describe the interface of the module
-- product = b*a mod p
entity modaddn_mult is
    generic(
        n: integer := 4);
    port(
        a, b, p: in std_logic_vector(n-1 downto 0);
        rst, clk, start: in std_logic;
        product: out std_logic_vector(n-1 downto 0);
        done: out std_logic);
end modaddn_mult;

-- describe the behavior of the module in the architecture
architecture behavioral of modaddn_mult is
    signal enable: std_logic;
    signal a_reg, p_reg, prod_old, prod_new: std_logic_vector(n-1 downto 0);

    component modaddn
        generic(n: integer := 8);
        port(a, b, p: in std_logic_vector(n-1 downto 0);
             sum: out std_logic_vector(n-1 downto 0));
    end component;

    component ctr_fsm
        generic(size: integer := 4);
        port(count: in std_logic_vector(size-1 downto 0);
             rst, clk, start: in std_logic;
             enable, done: out std_logic);
    end component;

begin

    adder: modaddn
    generic map(n => n)
    port map(a => a_reg,
             b => prod_old,
             p => p_reg,
             sum => prod_new);

    counter: ctr_fsm
    generic map(size => n)
    port map(count => b,
             rst => rst,
             clk => clk,
             start => start,
             enable => enable,
             done => done);

    main: process(rst,clk)
    begin
        if rst = '1' then
            a_reg <= std_logic_vector(to_unsigned(0,n));
            p_reg <= std_logic_vector(to_unsigned(0,n));
            prod_old <= std_logic_vector(to_unsigned(0,n));
        elsif rising_edge(clk) then
            if start = '1' then
                a_reg <= a;
                p_reg <= p;
                prod_old <= std_logic_vector(to_unsigned(0,n));
            elsif enable = '1' then
                prod_old <= prod_new;
            end if;
        end if;
    end process;

    product <= prod_old;
             

end behavioral;
