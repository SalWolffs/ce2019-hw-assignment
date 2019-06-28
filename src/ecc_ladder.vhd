
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


-- wrapper allowing parallel access to sequential ram in ecc_add_double
entity ecc_ladder is
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
end ecc_ladder;

architecture behavioral of ecc_core_wrap is

    subtype data_t is std_logic_vector(n-1 downto 0);
    subtype addr_t is std_logic_vector(4 downto 0);
    subtype index_t is natural range 0 to n-1;
    type state_t is (s_idle, s_step, s_wait, s_done);
    type point_t is
        record 
            X : data_t;
            Y : data_t;
            Z : data_t;
        end record point_t;


    signal G, R0_reg, R1_reg, Pin1, Pout: point_t;
    signal X1, Y1, Z1, X2, Y2, Z2, X3, Y3, Z3, k_reg: data_t;
    signal index_reg, index_nxt: index_t;
    signal state_reg: state_t;
    signal start_alu, done_alu: std_logic;
    signal double_reg, ki, done_reg: std_logic;

    component ecc_core_wrap is
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
    end component;


begin
    X1 <= Pin1.X;
    Y1 <= Pin1.Y;
    Z1 <= Pin1.Z;

    X2 <= R1_reg.X;
    Y2 <= R1_reg.Y;
    Z2 <= R1_reg.Z;
    
    sGx_o <= R0_reg.X;
    sGy_o <= R0_reg.Y;
    sGz_o <= R0_reg.Z;

    G <= (Gx_i, Gy_i, Gz_i);
    
    Pout <= (X3, Y3, Z3);

    ki <= k_reg(index_reg);

    with ki and double select
        Pin1 <= R0_reg when '0',
                R1_reg when '1',
                ((others => 'X'),(others => 'X'),(others => 'X')) when others;

    ecc_alu: ecc_core_wrap
        generic map( n => n,
                     log2n => log2n)
        port map(
            clk => clk,
            rst => rst, 
            p_i => p_i, 
            b_i => b_i, 
            X1_i => X1,
            Y1_i => Y1, 
            Z1_i => Z1,
            X2_i => X2, 
            Y2_i => Y2, 
            Z2_i => Z2,
            start_i => start_alu, 
            double_i => double_reg,
            X_o => X3, 
            Y_o => Y3, 
            Z_o => Z3,
            done_o => done_alu
        );


    regs: process(rst, clk)
    begin
        if rst = '1' then
            R0_reg <= ((others => '0'), (others => '0'), (others => '0'));
            R1_reg <= ((others => '0'), (others => '0'), (others => '0'));
            k_reg <= (others => '0');
        elsif rising_edge(clk) then
            if start_i = '1' then
                R0_reg <= ((others => '0'), std_logic_vector(to_unsigned(1,n)), (others => '0'));
                R1_reg <= G;
                k <= k_i;
            elsif done_alu = '1' then
                case ki xor double_reg is
                    when '1' => 
                        R0_reg <= Pout;
                    when '0' =>
                        R1_reg <= Pout;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;

    double: process(rst, clk)
    begin
        if rst = '1' then 
            double_reg <= '0';
        elsif rising_edge(clk) then
            if done_alu = '1' then
                double_reg <= not double_reg;
            end if;
        end if;
    end process;


    done: process(rst, clk)
    begin
        if rst = '1' then
            done_reg <= '0';
        elsif rising_edge(clk) then
            if done_reg = '1' then
                done_reg <= '0';
            elsif ((done_alu and double_reg) = '1') and index_reg = 0 then
                done_reg <= '1';
            end if;
        end if;
    end process;

    index: process(clk,rst)
    begin
        if rst = '1' then
            index_reg <= n-1;
        elsif rising_edge(clk) then
            if start_i = '1' then
                index_reg <= n-1;
            elsif (done_alu and double_reg) = '1' then
                if index_reg = 0 then
                    null;
                else
                    index_reg <= index_reg-1;
                end if;
            end if;
        end if;
    end process;

    done_o <= done_reg;
end behavioral;
