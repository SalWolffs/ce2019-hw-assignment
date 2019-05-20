-------------------------------------------------------------------------------
-- May 2019
--
-- Author: Sal Wolffs, adapted from Nele Mentens & Pedro Maat Costa Massolino
--
-- Module Name: ctr_fsm
-- Description: Counting finite state machine. Holds "done" after "count" number
-- of cycles after start, until rst or start is given. Holds "enable" between
-- start and done. 
-------------------------------------------------------------------------------

-- Standard libraries
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ctr_fsm is
    generic(size: integer := 4);
    port(
        count: in std_logic_vector(size-1 downto 0);
        rst, clk, start: in std_logic;
        enable, done: out std_logic);
end ctr_fsm;

architecture behavioral of ctr_fsm is
    type state_t is (s_idle, s_live, s_done);

    signal state: state_t;
    signal ctr_reg: std_logic_vector(size-1 downto 0);
    signal nxt: std_logic_vector(size-1 downto 0);


begin

    nxt <= std_logic_vector(unsigned(ctr_reg) - to_unsigned(1,size));
    -- Priority in conditions means we end up with nested if statements, rather
    -- than a case, since rst > start > s_live in determining what to do with
    -- state and ctr_reg.
    transitions: process(rst, clk)
    begin
        if rst = '1' then
            state <= s_idle;
            ctr_reg <= std_logic_vector(to_unsigned(0,size));
        elsif rising_edge(clk) then
            if start = '1' then
                ctr_reg <= count;
                if count = std_logic_vector(to_unsigned(0,size)) then
                    state <= s_done; -- special case: 0 cycles live
                else
                    state <= s_live;
                end if;
            elsif state = s_live then
                if nxt = std_logic_vector(to_unsigned(0,size)) then
                    state <= s_done;
                end if;
                ctr_reg <= nxt;
            end if;
        end if;
    end process;

    output: process(state)
    begin
        case state is
            when s_idle =>
                enable <= '0';
                done <= '0';
            when s_live =>
                enable <= '1';
                done <= '0';
            when s_done =>
                enable <= '0';
                done <= '1';
        end case;
    end process;

end behavioral;
