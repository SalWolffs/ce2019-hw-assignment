-------------------------------------------------------------------------------
-- May 2019
--
-- Author: Sal Wolffs, adapted from Nele Mentens & Pedro Maat Costa Massolino
--
-- Module Name: ctr_fsm
-- Description: Counting finite state machine. Holds "done" after "count" number
-- of cycles after start, until rst or start is given. Holds "enable" between
-- start and done. Does *not* store count internally. 
-------------------------------------------------------------------------------

-- Standard libraries
library IEEE;
use IEEE.STD_LOGIC1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ctr_fsm is
    generic(size: integer := 4);
    port(
        count: in std_logic_vector(size-1 downto 0);
        rst, clk, start: in std_logic;
        enable, done: out std_logic);
end ctr_fsm;

architecture behavioral of ctr_fsm is
    type state_t is (s_idle, s_live, s_done)

    signal state: state_t;
    signal ctr: std_logic_vector(size-1 downto 0);

    -- Priority in conditions means we end up with nested if statements, rather
    -- than a case, since rst > start > s_live in determining what to do with
    -- state and ctr.
    transitions: process(rst, clk)
    begin
        if rst = '1' then
            state <= s_idle;
            ctr <= std_logic_vector(to_unsigned(0,size));
        elsif rising_edge(clk) then
            if start = '1' then
                state <= s_live;
                ctr <= std_logic_vector(to_unsigned(0,size));
            elsif state = s_live then
                if ctr = count then
                    state <= s_done;
                else
                    ctr <= std_logic_vector(unsigned(ctr) +
                           to_unsigned(1,size));
                end if;
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
