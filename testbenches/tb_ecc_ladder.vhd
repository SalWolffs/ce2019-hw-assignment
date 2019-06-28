
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



-- describe the interface of the module: a testbench does not have any inputs or outputs
entity tb_ecc_ladder is
    generic(
        n: integer := 256;
        log2n: integer := 8);
end tb_ecc_ladder;

architecture behavioral of tb_ecc_ladder is

constant ecc_prime: std_logic_vector(n-1 downto 0) := X"ffffffff00000001000000000000000000000000ffffffffffffffffffffffff";
constant ecc_a: std_logic_vector(n-1 downto 0) := X"ffffffff00000001000000000000000000000000fffffffffffffffffffffffc";
constant ecc_b: std_logic_vector(n-1 downto 0) := X"5ac635d8aa3a93e7b3ebbd55769886bc651d06b0cc53b0f63bce3c3e27d2604b";


-- declare and initialize internal signals to drive the inputs of modarithn
    signal s, Gx, Gy, Gz, sGx, sGy, sGz, p, b: std_logic_vector(n-1 downto 0) := (others => '0');
    signal sGx_true, sGy_true, sGz_true: std_logic_vector(n-1 downto 0) := (others => '0');
    signal rst, clk, start_test, done_test: std_logic := '0';

-- declare a signal to check if values match.
    signal error_comp: std_logic := '0';

-- define the clock period
    constant clk_period: time := 10 ns;

-- define signal to terminate simulation
    signal testbench_finish: boolean := false;

    component ecc_ladder is
        generic(
            n: integer := 256;
            log2n: integer := 8);
        port(
        clk, rst: in std_logic;
        p_i, b_i, k_i: in std_logic_vector(n-1 downto 0);
        Gx_i, Gy_i, Gz_i: in std_logic_vector(n-1 downto 0);
        start_i: in std_logic;
        sGx_o, sGy_o, sGz_o: out std_logic_vector(n-1 downto 0);
        done_o: out std_logic
    );
    end component;
begin

    ecc_unit: ecc_ladder
    generic map(n => n,
                log2n => log2n)
    port map(
        clk => clk,
        rst => rst,
        p_i => p, 
        b_i => b, 
        k_i => s,
        Gx_i => Gx, 
        Gy_i => Gy, 
        Gz_i => Gz,
        start_i => start_test,
        sGx_o => sGx, 
        sGy_o => sGy, 
        sGz_o => sGz, 
        done_o => done_test
    );

-- generate the clock with a duty cycle of 50%
    gen_clk: process
    begin
        while(testbench_finish = false) loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
        end loop;
        wait;
    end process;

-- stimulus process (without sensitivity list, but with wait statements)
stim: process
begin
    wait for clk_period;
    
    rst <= '1';
    
    wait for clk_period;
    
    rst <= '0';
    
    wait for clk_period;
    
    p <= ecc_prime;
    b <= ecc_b;

    s <= X"C03A898C5E674B2CE564F25F96BB8AE944985061ACCE54CAA5554BB508542151";

    Gx       <=
   X"6B17D1F2E12C4247F8BCE6E563A440F277037D812DEB33A0F4A13945D898C296";
    Gy       <=
   X"4FE342E2FE1A7F9B8EE7EB4A7C0F9E162BCE33576B315ECECBB6406837BF51F5";
    Gz       <=
   X"0000000000000000000000000000000000000000000000000000000000000001";
    sGx_true <=
   X"B586EFD756C25F6BC6469AA162BAC531C877C99DF5CBD8F95EEF31CE74226860";
    sGy_true <=
   X"8E5C8AAD3B74642DBF40A6851090A6DB6210C97AFE36CCF65300CC2F6514DE66";
    sGz_true <=
   X"5590FD84B53850234D3CEF495D7DB307470C449A1CA8431F184D4DDDB70B3714";

    error_comp <= '0';
    start_test <= '1';
    
    wait for clk_period;
    
    start_test <= '0';
    
    wait until done_test = '1';
    
    if(sGx_true /= sGx) then
        error_comp <= '1';
    else
        error_comp <= '0';
    end if;

    wait for clk_period;
    
    if(sGy_true /= sGy) then
        error_comp <= '1';
    else
        error_comp <= '0';
    end if;

    wait for clk_period;

    if(sGz_true /= sGz) then
        error_comp <= '1';
    else
        error_comp <= '0';
    end if;

    wait for 3*clk_period/2;
    
    testbench_finish <= true;
    wait;
end process;

end behavioral;
