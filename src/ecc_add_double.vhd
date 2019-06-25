library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ecc_add_double is
    generic(
        n: integer := 8;
        log2n: integer := 3;
        ads: integer := 5);
    port(
        start, rst, clk: in std_logic;
        add_double, m_enable, m_rw: in std_logic;
        m_din: in std_logic_vector(n-1 downto 0);
        m_address: in std_logic_vector(ads-1 downto 0);
        done, busy: out std_logic;
        m_dout: out std_logic_vector(n-1 downto 0));
end ecc_add_double;

architecture behavioral of ecc_add_double is
    type state_t is (
        s_idle,
        s_busy,
        s_done);

    signal state: state_t;
    signal ip, ip_start, ip_next: std_logic_vector(6 downto 0);
    signal instruction: std_logic_vector(17 downto 0);
    signal base_busy, base_done: std_logic;


    component ecc_base is
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
    end component;

    component rbc_rom is
        generic(
            ws: integer := 18;
            ads: integer := 7);
        port(
            address: in std_logic_vector(ads-1 downto 0);
            dout: out std_logic_vector(ws-1 downto 0));
    end component;

begin

    ip_start <= "0000000" when add_double = '0' else "0101100";
    ip_next <= std_logic_vector(unsigned(ip) + 1);

    rom: rbc_rom
    port map (address => ip,
              dout => instruction);

    ecc_base_instance: ecc_base
    generic map (n => n,
                 log2n => log2n,
                 ads => ads)
    port map (start => start,
              rst => rst,
              clk => clk,
              oper_a => instruction(4 downto 0),
              oper_b => instruction(9 downto 5),
              oper_o => instruction(14 downto 10),
              command => instruction(17 downto 15),
              busy => base_busy,
              done => base_done,
              m_enable => m_enable,
              m_din => m_din,
              m_dout => m_dout,
              m_rw => m_rw,
              m_address => m_address);

    transitions: process(rst, clk)
    begin
        if rst = '1' then
            state <= s_idle;
        elsif rising_edge(clk) then
            if state = s_idle then
                if start = '1' then
                    state <= s_busy;
                end if;
                ip <= ip_start;
            elsif state = s_busy then
                if base_done = '1' then
                    ip <= ip_next;
                end if;
            elsif state = s_done then
                state <= s_idle;
            end if;
        elsif falling_edge(clk) then
            if state = s_busy then
                if instruction(17 downto 15) = "000" then
                    state <= s_done;
                end if;
            end if;
        end if;
    end process;

    output: process(state)
    begin
        case state is
            when s_idle =>
                busy <= '0';
                done <= '0';
            when s_busy =>
                busy <= '1';
                done <= '0';
            when s_done =>
                busy <= '0';
                done <= '1';
        end case;
    end process;

end behavioral;
