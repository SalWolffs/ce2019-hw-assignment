----------------------------------------------------------------------------------
-- Summer School on Real-world Crypto & Privacy - Hardware Tutorial 
-- Sibenik, June 11-15, 2018 
-- 
-- Author: Nele Mentens
-- Updated by Pedro Maat Costa Massolino
--  
-- Module Name: tb_modaddn 
-- Description: testbench for the modaddn module
----------------------------------------------------------------------------------

-- include the IEEE library and the STD_LOGIC_1164 package for basic functionality
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- describe the interface of the module: a testbench does not have any inputs or outputs
entity tb_modaddn is
    generic(width: integer := 128);
end tb_modaddn;

architecture behavioral of tb_modaddn is

-- declare and initialize internal signals to drive the inputs of modaddn
signal a_i, b_i, p_i: std_logic_vector(width-1 downto 0) := (others => '0');

-- declare internal signals to read out the outputs of modaddn
signal sum_i: std_logic_vector(width-1 downto 0);

-- declare the expected output from the component under test
signal sum_true: std_logic_vector(width-1 downto 0) := (others => '0');

-- declare a signal to check if values match.
signal error_comp: std_logic := '0';

-- declare the modaddn component
component modaddn
    generic(n: integer := 8);
    port(   a, b, p: in std_logic_vector(n-1 downto 0);
            sum: out std_logic_vector(n-1 downto 0));
end component;

begin

-- instantiate the modaddn component
-- map the generic parameter in the testbench to the generic parameter in the component  
-- map the signals in the testbench to the ports of the component
inst_modaddn: modaddn
    generic map(n => width)
    port map(   a => a_i,
                b => b_i,
                p => p_i,
                sum => sum_i);

-- stimulus process (without sensitivity list, but with wait statements)
stim: process
begin
    wait for 10 ns;
    
    a_i <= x"39D21165E93802DD935F2A16CDCB9E47";
    b_i <= x"9D57F9331AC4F83DDC9F71F83B55C72B";
    p_i <= x"BA31A890FE7D735366E6E53D1F30ABBB";
    sum_true <= x"1CF86208057F87C80917B6D1E9F0B9B7";
    error_comp <= '0';
    
    wait for 10 ns;
    
    if(sum_true /= sum_i) then
        error_comp <= '1';
    else
        error_comp <= '0';
    end if;
    
    wait for 10 ns;
    
    a_i <= x"81C9483F18795F2E7939D1A7634B99DA";
    b_i <= x"2D5F5A65996B85401C4B9708D2DBAE79";
    sum_true <= x"AF28A2A4B1E4E46E958568B036274853";
    error_comp <= '0';
    
    wait for 10 ns;
    
    if(sum_true /= sum_i) then
        error_comp <= '1';
    else
        error_comp <= '0';
    end if;
    
    wait for 10 ns;
    
    wait;
end process;

end behavioral;
