library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ecc_add_double is
    generic(
        n: integer := 8;
        log2n: integer := 3;
        ads: integer := 8);
    port(
        start, rst, clk: in std_logic;
        add_double, m_enable, m_rw: in std_logic;
        m_din: in std_logic_vector(n-1 downto 0);
        m_address: in std_logic_vector(ads-1 downto 0);
        done, busy: out std_logic;
        m_dout: out std_logic_vector(n-1 downto 0));
end ecc_add_double;

architecture behavioral of ecc_add_double is

begin

end behavioral;
