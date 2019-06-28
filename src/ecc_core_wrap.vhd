
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ecc_core_wrap is
    generic(
        n: integer := 256;
        log2n: integer := 8);
    port(
        clk, rst: in std_logic;
        p_i, b_i: in std_logic_vector(n-1 downto 0);
        X1_i, Y1_i, Z1_i: in std_logic_vector(n-1 downto 0);
        X2_i, Y2_i, Z2_i: in std_logic_vector(n-1 downto 0);
        start_i, double_i: in std_logic;
        X_o, Y_o, Z_o: out std_logic_vector(n-1 downto 0);
        done_o: out std_logic
    );
end ecc_core_wrap;

architecture behavioral of ecc_core_wrap is

    subtype data_t is std_logic_vector(n-1 downto 0);
    subtype addr_t is std_logic_vector(4 downto 0);

    signal start_core, done_core, busy_core, m_enable, m_rw: std_logic;
    signal m_din, m_dout: data_t;
    signal m_address: addr_t;
    signal index_reg, index_nxt: natural;

-- declare the ecc_base component
component ecc_add_double
    generic(
        n: integer := 8;
        log2n: integer := 3);
    port(
        start: in std_logic;
        rst: in std_logic;
        clk: in std_logic;
        add_double: in std_logic;
        done: out std_logic;
        busy: out std_logic;
        m_enable: in std_logic;
        m_din:in data_t;
        m_dout:out data_t;
        m_rw:in std_logic;
        m_address:in std_logic_vector(4 downto 0));
end component;


begin

    m_address <= std_logic_vector(to_unsigned(index_reg,5));
    index_nxt <= index_reg+1;

    ecc_core: ecc_add_double
        generic map(n=>n,
                    log2n=>log2n)
        port map(
            start=>start_core,
            rst=>rst,
            clk=>clk,
            add_double=>double_i,
            done=>done_core,
            busy=>busy_core,
            m_enable=>m_enable,
            m_din=>m_din,
            m_dout=>m_dout,
            m_rw=>m_rw,
            m_address=>m_address
        );

    with index_reg select
        m_din <= p_i when 0,
                 (others => '0') when 1,
                 b_i when 2,
                 X1_i when 3,
                 Y1_i when 4,
                 Z1_i when 5,
                 X2_i when 6,
                 Y2_i when 7,
                 Z2_i when 8,
                 (others => '0') when others;
                 






end behavioral;
