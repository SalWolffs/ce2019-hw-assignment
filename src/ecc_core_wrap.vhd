
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- wrapper allowing parallel access to sequential ram in ecc_add_double
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
    subtype index_t is natural range 0 to 15;
    type state_t is (s_idle, s_init, s_wait, s_read, s_done);

    signal start_core, done_core, busy_core, m_enable, m_write, done: std_logic;
    signal m_din, m_dout: data_t;
    signal X_reg, Y_reg, Z_reg: data_t;
    signal m_address: addr_t;
    signal index_reg, index_nxt: index_t;
    signal state_reg: state_t;

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

    index_nxt <= index_reg+1;
    m_address <= std_logic_vector(to_unsigned(index_reg,5));

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
            m_rw=>m_write,
            m_address=>m_address
        );

    with index_reg select
        m_din <= p_i when 0,
                 (others => 'U') when 1,
                 b_i when 2,
                 X1_i when 3,
                 Y1_i when 4,
                 Z1_i when 5,
                 X2_i when 6,
                 Y2_i when 7,
                 Z2_i when 8,
                 (others => '0') when others;

    with index_reg select
        start_core <= '1' when 8,
                      '0' when others;

                 
    read: process(rst, clk)
    begin
        if rst = '1' then
            X_reg <= (others => '0');
            Y_reg <= (others => '0');
            Z_reg <= (others => '0');
        elsif rising_edge(clk) then
            if (m_enable and not m_write) = '1' then
                case index_reg is
                    when 10 => X_reg <= m_dout;
                    when 11 => Y_reg <= m_dout;
                    when 12 => Z_reg <= m_dout;
                    when others => NULL;
                end case;
            end if;
        end if;
    end process;

    X_o <= X_reg;
    Y_o <= Y_reg;
    Z_o <= Z_reg;

    state: process(rst, clk)
    begin
        if rst = '1' then
            state_reg <= s_idle;
        elsif rising_edge(clk) then
            case state_reg is
                when s_idle => 
                    if start_i = '1' then
                        state_reg <= s_init;
                    end if;
                when s_init => 
                    if index_reg = 8 then
                        state_reg <= s_wait;
                    end if;
                when s_wait => 
                    if done_core = '1' then
                        state_reg <= s_read;
                    end if;
                when s_read => 
                    if index_reg = 12 then
                        state_reg <= s_done;
                    end if;
                when s_done => 
                    state_reg <= s_idle;
            end case;
        end if;
    end process;

    control: process(state_reg)
    begin
        case state_reg is
            when s_idle => 
                    m_write <= '0';
                    m_enable <= '0';
                    done <= '0';
            when s_init => 
                    m_write <= '1';
                    m_enable <= '1';
                    done <= '0';
            when s_wait => 
                    m_write <= '0';
                    m_enable <= '0';
                    done <= '0';
            when s_read => 
                    m_write <= '0';
                    m_enable <= '1';
                    done <= '0';
            when s_done => 
                    m_write <= '0';
                    m_enable <= '0';
                    done <= '1';
        end case;
    end process;

    index: process(clk,rst)
    begin
        if rst = '1' then
            index_reg <= 0;
        elsif rising_edge(clk) then
            if m_enable = '1' then
                index_reg <= index_nxt;
            elsif done = '1' then
                index_reg <= 0;
            end if;
        end if;
    end process;

    done_o <= done;






end behavioral;
