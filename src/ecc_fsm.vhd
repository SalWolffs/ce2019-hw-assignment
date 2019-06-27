-- The FSM described on page 8 of the assignment.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ecc_fsm is
    port(
        rst, clk, start, a_done: in std_logic;
        reg_comm: in std_logic_vector(2 downto 0);
        free, done, rw, enable, a_start, p_enable: out std_logic);
end ecc_fsm;

architecture behavioral of ecc_fsm is
    type state_t is (
        s_idle,
        s_wait_ram,
        s_load_p,
        s_load_arith,
        s_comp_arith,
        s_write_arith);

    signal state: state_t;

begin

    transitions: process(rst, clk)
    begin
        if rst = '1' then
            state <= s_idle;
        elsif rising_edge(clk) then
            if state = s_idle then
                if start = '1' then
                    state <= s_wait_ram;
                end if;
            elsif state = s_wait_ram then
                if reg_comm = "100" then
                    state <= s_load_p;
                else
                    state <= s_load_arith;
                end if;
            elsif state = s_load_p then
                state <= s_idle;
            elsif state = s_load_arith then
                state <= s_comp_arith;
            elsif state = s_comp_arith then
                if a_done = '1' then
                    state <= s_write_arith;
                end if;
            elsif state = s_write_arith then
                state <= s_idle;
            end if;
        end if;
    end process;

    output: process(state)
    begin
        case state is
            when s_idle =>
                free <= '1';
                done <= '0';
                rw <= '0';
                enable <= '0';
                a_start <= '0';
                p_enable <= '0';
            when s_wait_ram =>
                free <= '0';
                done <= '0';
                rw <= '0';
                enable <= '1';
                a_start <= '0';
                p_enable <= '0';
            when s_load_p =>
                free <= '0';
                done <= '1';
                rw <= '0';
                enable <= '1';
                a_start <= '0';
                p_enable <= '1';
            when s_load_arith =>
                free <= '0';
                done <= '0';
                rw <= '0';
                enable <= '1';
                a_start <= '1';
                p_enable <= '0';
            when s_comp_arith =>
                free <= '0';
                done <= '0';
                rw <= '0';
                enable <= '0';
                a_start <= '0';
                p_enable <= '0';
            when s_write_arith =>
                free <= '0';
                done <= '1';
                rw <= '1';
                enable <= '1';
                a_start <= '0';
                p_enable <= '0';
        end case;
    end process;

end behavioral;
