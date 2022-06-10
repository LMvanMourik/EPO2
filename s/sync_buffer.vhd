-- sync_buffer.vhdl
--
-- Synchronization buffer for RX signal
library IEEE;
use IEEE.std_logic_1164.all;

entity sync_buffer is
    port (
        clk             : in  std_logic;
        data_in         : in  std_logic;
        data_out        : out std_logic
    );
end entity sync_buffer;

architecture behavioural of sync_buffer is

    signal data_buffered1, data_buffered2 : std_logic;

begin

reg: process (clk)
    begin
        if (rising_edge (clk)) then
            data_buffered1 <= data_in;
            data_buffered2 <= data_buffered1;
        end if;
    end process;

conc: data_out <= data_buffered2;

end architecture behavioural;
