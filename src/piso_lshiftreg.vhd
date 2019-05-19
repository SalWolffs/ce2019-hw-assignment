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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity piso_lshiftreg is
    generic(size: integer := 4);
    port(
        data_in: in std_logic_vector(size-1 downto 0);
        rst, clk, start: in std_logic;
        msb_out: out std_logic);
end piso_lshiftreg;

architecture behavioral of piso_lshiftreg is
    signal reg: std_logic_vector(size-1 downto 0);
begin

    update: process(rst, clk)
    begin
        if rst = '1' then
            reg <= std_logic_vector(to_unsigned(0,size));
        elsif rising_edge(clk) then
            if start = '1' then
                reg <= data_in;
            else
                for i in size-2 downto 0 loop
                    reg(i+1) <= reg(i);
                end loop;
            end if;
        end if;
    end process;

    msb_out <= reg(size-1);


end behavioral;
