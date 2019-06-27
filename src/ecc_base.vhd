----------------------------------------------------------------------------------
-- Summer School on Real-world Crypto & Privacy - Hardware Tutorial
-- Sibenik, June 11-15, 2018
--
-- Author: Pedro Maat Costa Massolino
--
-- Module Name: ecc_base
-- Description: Base unit that is able to run all necessary commands.
----------------------------------------------------------------------------------

-- include the STD_LOGIC_1164 package in the IEEE library for basic functionality
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- include the NUMERIC_STD package for arithmetic operations
use IEEE.NUMERIC_STD.ALL;

entity ecc_base is
    generic(
        n: integer := 8;
        log2n: integer := 3;
        ads: integer := 8);
    port(
        start: in std_logic;
        rst: in std_logic;
        clk: in std_logic;
        oper_a: in std_logic_vector(ads-1 downto 0);
        oper_b: in std_logic_vector(ads-1 downto 0);
        oper_o: in std_logic_vector(ads-1 downto 0);
        command: in std_logic_vector(2 downto 0);
        busy: out std_logic;
        done: out std_logic;
        m_enable: in std_logic;
        m_din:in std_logic_vector(n-1 downto 0);
        m_dout:out std_logic_vector(n-1 downto 0);
        m_rw:in std_logic;
        m_address:in std_logic_vector(ads-1 downto 0));
end ecc_base;

-- describe the behavior of the module in the architecture
architecture behavioral of ecc_base is
    signal a, b, p, product: std_logic_vector(n-1 downto 0);
    signal reg_comm: std_logic_vector(2 downto 0);
    signal free, rw, enable, a_start, p_enable: std_logic;
    signal a_done: std_logic;
    signal ram_enable, ram_rw: std_logic;
    signal address_a, address_b, address_o: std_logic_vector(ads-1 downto 0);
    signal ram_address_a: std_logic_vector(ads-1 downto 0);
    signal ram_din_a: std_logic_vector(n-1 downto 0);

    component modarithn is
        generic(
            n: integer := n;
            log2n: integer := log2n);
        port(
            a, b, p: in std_logic_vector(n-1 downto 0);
            rst, clk, start: in std_logic;
            command: in std_logic_vector(1 downto 0);
            product: out std_logic_vector(n-1 downto 0);
            done: out std_logic);
    end component;

    component ram_double is
        generic(
            ws: integer := n;
            ads: integer := ads);
        port(
            enable: in std_logic;
            clk: in std_logic;
            din_a: in std_logic_vector(ws-1 downto 0);
            address_a: in std_logic_vector(ads-1 downto 0);
            address_b: in std_logic_vector(ads-1 downto 0);
            rw: in std_logic;
            dout_a: out std_logic_vector(ws-1 downto 0);
            dout_b: out std_logic_vector(ws-1 downto 0));
    end component;

    component ecc_fsm is
        port(
            rst, clk, start, a_done: in std_logic;
            reg_comm: in std_logic_vector(2 downto 0);
            free, done, rw, enable, a_start, p_enable: out std_logic);
    end component;

begin

    busy <= not free;
    m_dout <= a;

    ram_din_a     <= m_din     when free = '1' else product;
    ram_rw        <= m_rw      when free = '1' else rw;
    ram_enable    <= m_enable  when free = '1' else enable;

    ram_address_a <= m_address when free = '1' else
                     address_o when rw   = '1' else
                     address_a;

    alu: modarithn
    generic map (n => n,
                 log2n => log2n)
    port map (a => a,
              b => b,
              p => p,
              rst => rst,
              clk => clk,
              start => a_start,
              command => command(1 downto 0),
              product => product,
              done => a_done);

    ram: ram_double
    generic map (ws => n,
                 ads => ads)
    port map (enable => ram_enable,
              clk => clk,
              din_a => ram_din_a,
              address_a => ram_address_a,
              address_b => address_b,
              rw => ram_rw,
              dout_a => a,
              dout_b => b);

    fsm: ecc_fsm
    port map (rst => rst,
              clk => clk,
              start => start,
              a_done => a_done,
              reg_comm => reg_comm,
              free => free,
              done => done,
              rw => rw,
              enable => enable,
              a_start => a_start,
              p_enable => p_enable);

    update: process(rst, clk)
    begin
        if rst = '1' then
        elsif rising_edge(clk) then
            if p_enable = '1' then
                p <= b;
            end if;
            if start = '1' then
                reg_comm <= command;
                address_a <= oper_a;
                address_b <= oper_b;
                address_o <= oper_o;
            end if;
        end if;
    end process;

end behavioral;
