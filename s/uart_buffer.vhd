-- uart_buffer.vhdl
--
-- generic uart buffer, for buffering rx-buf and tx-buf data
library IEEE;
use IEEE.std_logic_1164.all;

entity uart_buffer is
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;

        write           : in  std_logic;
        read            : in  std_logic;

        data_in         : in  std_logic_vector (7 downto 0);
        data_out        : out std_logic_vector (7 downto 0);
        data_ready      : out std_logic
    );
end entity uart_buffer;

architecture behavioural of uart_buffer is

    signal data_buf, new_data_buf : std_logic_vector (7 downto 0);
    signal ready, new_ready       : std_logic;

begin

reg: process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                data_buf <= (others => '0');
                ready    <= '0';
            else
                data_buf <= new_data_buf;
                ready    <= new_ready;
            end if;
        end if;
    end process;

comb: process (write, read, data_in, data_buf, ready)
    begin
        if write = '1' then
            new_data_buf <= data_in;
            new_ready    <= '1';
        elsif read = '1' then
            new_data_buf <= data_buf;
            new_ready    <= '0';
        else
            new_data_buf <= data_buf;
            new_ready    <= ready;
        end if;
    end process;

    data_out   <= data_buf;
    data_ready <= ready;

end architecture behavioural;
