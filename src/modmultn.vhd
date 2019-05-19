----------------------------------------------------------------------------------
-- Summer School on Real-world Crypto & Privacy - Hardware Tutorial 
-- Sibenik, June 11-15, 2018 
-- 
-- Author: Nele Mentens
-- Updated by Pedro Maat Costa Massolino
--  
-- Module Name: modmultn
-- Description: n-bit modular multiplier (through the left-to-right double-and-add algorithm)
----------------------------------------------------------------------------------

-- include the STD_LOGIC_1164 package in the IEEE library for basic functionality
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- include the NUMERIC_STD package for arithmetic operations
use IEEE.NUMERIC_STD.ALL;

-- describe the interface of the module
-- product = b*a mod p
entity modmultn is
    generic(
        n: integer := 8;
        log2n: integer := 3);
    port(
        a, b, p: in std_logic_vector(n-1 downto 0);
        rst, clk, start: in std_logic;
        product: out std_logic_vector(n-1 downto 0);
        done: out std_logic);
end modmultn;

-- describe the behavior of the module in the architecture
architecture behavioral of modmultn is

-- declare internal signals
    signal a_reg, a_masked, p_reg, prod_reg: std_logic_vector(n-1 downto 0);
    signal prod_shift, prod_new, b_msb_wide: std_logic_vector(n-1 downto 0);
    signal n_sig: std_logic_vector(log2n downto 0);
    signal b_msb, enable: std_logic;

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

    component piso_lshiftreg is
        generic(size: integer := 4);
        port(
            data_in: in std_logic_vector(size-1 downto 0);
            rst, clk, start: in std_logic;
            msb_out: out std_logic);
    end component;

    component modlshiftn is
        generic(size : integer := 8);
        port(a, p: in std_logic_vector(n-1 downto 0);
              result: out std_logic_vector(n-1 downto 0));
    end component;

begin

    b_shiftreg : piso_lshiftreg 
    generic map(size => n)
    port map(data_in => b,
             rst => rst,
             clk => clk,
             start => start,
             msb_out => b_msb);

    n_sig <= std_logic_vector(to_unsigned(n,log2n+1));

    fsm : ctr_fsm
    generic map (size => log2n+1)
    port map (count => n_sig,
              rst => rst,
              clk => clk,
              start => start,
              enable => enable,
              done => done);

    shifter : modlshiftn
    generic map (size => n)
    port map (a => prod_reg,
              p => p,
              result => prod_shift);
    
    b_msb_wide <= (others => b_msb);
    a_masked <= a_reg and b_msb_wide;
    adder : modaddn
    generic map (n => n)
    port map (a => a_masked,
              b => prod_shift,
              p => p_reg,
              sum => prod_new);

    main : process(rst,clk)
    begin
        if rst = '1' then
           a_reg <= std_logic_vector(to_unsigned(0,n));
           p_reg <= std_logic_vector(to_unsigned(0,n));
           prod_reg <= std_logic_vector(to_unsigned(0,n));
       elsif rising_edge(clk) then
           if start = '1' then
               a_reg <= a;
               p_reg <= p;
               prod_reg <= std_logic_vector(to_unsigned(0,n));
           elsif enable = '1' then
               prod_reg <= prod_new;
           end if;
       end if;
   end process;

   product <= prod_reg;




end behavioral;
