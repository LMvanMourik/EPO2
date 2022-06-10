-- tx_fsm.vhdl
--
-- TX fsm implementation
library IEEE;
use IEEE.std_logic_1164.all;

entity tx_fsm is
    port (
        clk                     : in  std_logic;
        reset                   : in  std_logic;

        tx                      : out std_logic;

        uart_clk_reset          : out std_logic;
        baud_clk                : in  std_logic;

        tx_buffer               : in  std_logic_vector (7 downto 0);

        input_buffer_empty      : in  std_logic;
        input_buffer_read       : out std_logic
    );
end entity tx_fsm;

architecture behavioural of tx_fsm is

    type state_type is (idle_state, start_state,
        write_bit_state, next_bit_state, stop_state);

    signal state, new_state       : state_type;
    signal bitcount, new_bitcount : integer range 0 to 7;

begin

reg: process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state    <= idle_state;
                bitcount <= 0;
            else
                state    <= new_state;
                bitcount <= new_bitcount;
            end if;
        end if;
    end process;

comb: process (state, bitcount, baud_clk, tx_buffer, input_buffer_empty)
    begin
        case state is
        when idle_state =>
            tx                <= '1';
            uart_clk_reset    <= '1';
            input_buffer_read <= '0';

            new_bitcount <= 0;
            if input_buffer_empty = '0' then
                new_state <= start_state;
            else
                new_state <= idle_state;
            end if;

        when start_state =>
            tx                <= '0';
            uart_clk_reset    <= '0';
            input_buffer_read <= '1';

            new_bitcount <= 0;
            if baud_clk = '1' then
                new_state <= write_bit_state;
            else
                new_state <= start_state;
            end if;

        when write_bit_state =>
            tx                <= tx_buffer(bitcount);
            uart_clk_reset    <= '0';
            input_buffer_read <= '0';

            new_bitcount <= bitcount;
            if baud_clk = '1' then
                new_state <= next_bit_state;
            else
                new_state <= write_bit_state;
            end if;

        when next_bit_state =>
            tx                <= tx_buffer(bitcount);
            uart_clk_reset    <= '0';
            input_buffer_read <= '0';

            if bitcount = 7 then
                new_bitcount <= 0;
                new_state    <= stop_state;
            else
                new_bitcount <= bitcount + 1;
                new_state    <= write_bit_state;
            end if;

        when stop_state =>
            tx                <= '1';
            uart_clk_reset    <= '0';
            input_buffer_read <= '0';

            new_bitcount <= 0;
            if baud_clk = '1' then
                new_state <= idle_state;
            else
                new_state <= stop_state;
            end if;
        end case;
    end process;

end architecture behavioural;
