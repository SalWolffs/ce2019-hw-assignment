----------------------------------------------------------------------------------
-- Summer School on Real-world Crypto & Privacy - Hardware Tutorial 
-- Sibenik, June 11-15, 2018 
-- 
-- Author: Pedro Maat Costa Massolino
--  
-- Module Name: modarithn
-- Description: Modular arithmetic unit (multiplication, addition, subtraction)
----------------------------------------------------------------------------------

-- include the STD_LOGIC_1164 package in the IEEE library for basic functionality
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- include the NUMERIC_STD package for arithmetic operations
use IEEE.NUMERIC_STD.ALL;

-- describe the interface of the module
-- product = a*b mod p or a+b mod p or a-b mod p
entity modarithn is
    generic(
        n: integer := 8;
        log2n: integer := 3);
    port(
        a: in std_logic_vector(n-1 downto 0);
        b: in std_logic_vector(n-1 downto 0);
        p: in std_logic_vector(n-1 downto 0);
        rst: in std_logic;
        clk: in std_logic;
        start: in std_logic;
        command: in std_logic_vector(1 downto 0);
        product: out std_logic_vector(n-1 downto 0);
        done: out std_logic);
end modarithn;


architecture behavioral of modarithn is
    signal addsub_a_reg, addsub_b_reg, addsub_p_reg: std_logic_vector(n-1 downto 0);
    signal mult_out, addsub_out: std_logic_vector(n-1 downto 0);
    signal cmd_reg : std_logic_vector(1 downto 0);
    signal addsub_as_reg, mult_start, mult_done: std_logic;
    signal command_consistent: std_logic;

    component modaddsubn is
        generic(
            n: integer := 8);
        port(
            a, b, p: in std_logic_vector(n-1 downto 0);
            as: in std_logic;
            sum: out std_logic_vector(n-1 downto 0));
    end component;

    component modmultn is
        generic(
            n: integer := 8;
            log2n: integer := 3);
        port(
            a, b, p: in std_logic_vector(n-1 downto 0);
            rst, clk, start: in std_logic;
            product: out std_logic_vector(n-1 downto 0);
            done: out std_logic);
    end component;

begin
    -- mult should only start its expensive calculation on its command
    mult_start <= start and command(0) and not command(1);

    multiplier : modmultn
    generic map (n => n,
                 log2n => log2n)
    port map (a => a,
              b => b,
              p => p,
              rst => rst,
              clk => clk,
              start => mult_start,
              product => mult_out,
              done => mult_done);

    addsubber : modaddsubn
    generic map (n => n)
    port map (a => addsub_a_reg, 
              b => addsub_b_reg,
              p => addsub_p_reg,
              as => addsub_as_reg,
              sum => addsub_out);

    main : process(clk,rst)
    begin
        if rst = '1' then
            addsub_a_reg <= std_logic_vector(to_unsigned(0,n));
            addsub_b_reg <= std_logic_vector(to_unsigned(0,n));
            addsub_p_reg <= std_logic_vector(to_unsigned(0,n));
            addsub_as_reg <= '0';
            cmd_reg <= std_logic_vector(to_unsigned(0,2));
        elsif rising_edge(clk) then
            if start = '1' then
                cmd_reg <= command;
                if command(1) = '1' then -- drive addsubber
                    addsub_a_reg <= a;
                    addsub_b_reg <= b;
                    addsub_p_reg <= p;
                    addsub_as_reg <= command(0);
                end if;
            end if;
        end if;
    end process;


    with command select
        done <= mult_done when "01",
                not start when others;

    with command select
        product <= a when "00",
                   mult_out when "01",
                   addsub_out when others;

end behavioral;
