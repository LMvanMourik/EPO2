-- rx_fsm.vhdl
--
-- uart receiver
library IEEE;
use IEEE.std_logic_1164.all;

entity rx_fsm is
    port (
        clk                     : in  std_logic;
        reset                   : in  std_logic;

        rx                      : in  std_logic;
        oversampler_reset       : out std_logic;
        rx_sampled              : in  std_logic;

        uart_clk_reset          : out std_logic;
        baud_clk                : in  std_logic;

        rx_data                 : out std_logic_vector (7 downto 0);
        output_buffer_write     : out std_logic
    );
end entity rx_fsm;


architecture behavioural of rx_fsm is

    type state_type is (break_state, idle_state, start_state,
        store_state, next_bit_state, copy_data_state, stop_state);

    signal state, new_state       : state_type;
    signal data, new_data         : std_logic_vector (7 downto 0);
    signal bitcount, new_bitcount : integer range 0 to 7;

begin

    rx_data <= data;

reg: process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                state    <= idle_state;
                data     <= (others => '0');
                bitcount <= 0;
            else
                state    <= new_state;
                data     <= new_data;
                bitcount <= new_bitcount;
            end if;
        end if;
    end process;

comb: process (state, bitcount, rx, baud_clk)
    begin
        case state is
        when break_state => -- break while rx=0 after reset
            oversampler_reset   <= '1';
            uart_clk_reset      <= '1';
            output_buffer_write <= '0';

            new_bitcount <= 0;
            new_data     <= (others => '0');

            if rx = '1' then
                new_state <= idle_state;
            else
                new_state <= break_state;
            end if;

        when idle_state => -- idle while rx=1
            oversampler_reset   <= '1';
            uart_clk_reset      <= '1';
            output_buffer_write <= '0';

            new_bitcount <= 0;
            new_data     <= (others => '0');

            if rx = '0' then
                new_state <= start_state;
            else
                new_state <= idle_state;
            end if;

        when start_state => -- start bit, wait for 1 baud period
            oversampler_reset   <= '0';
            uart_clk_reset      <= '0';
            output_buffer_write <= '0';

            new_bitcount <= 0;
            new_data     <= (others => '0');

            if baud_clk = '1' then
                if rx_sampled = '0' then
                    new_state <= store_state;
                else
                    new_state <= break_state;
                end if;
            else
                new_state <= start_state;
            end if;

        when store_state => -- store bit
            oversampler_reset   <= '0';
            uart_clk_reset      <= '0';
            output_buffer_write <= '0';

            new_bitcount <= bitcount;

            if baud_clk = '1' then
                new_data  <= rx_sampled & data(7 downto 1);
                new_state <= next_bit_state;
            else
                new_data  <= data;
                new_state <= store_state;
            end if;

        when next_bit_state => -- increment bit counter
            oversampler_reset   <= '1';
            uart_clk_reset      <= '0';
            output_buffer_write <= '0';

            new_data <= data;

            if bitcount = 7 then
                new_bitcount <= 0;
                new_state    <= copy_data_state;
            else
                new_bitcount <= bitcount + 1;
                new_state    <= store_state;
            end if;

        when copy_data_state => -- copy data to output buffer
            oversampler_reset   <= '0';
            uart_clk_reset      <= '0';
            output_buffer_write <= '1';

            new_bitcount <= 0;
            new_data     <= data;
            new_state    <= stop_state;

        when stop_state => -- wait for stop bit to pass
            oversampler_reset   <= '0';
            uart_clk_reset      <= '0';
            output_buffer_write <= '0';

            new_bitcount <= 0;
            new_data     <= data;

            if baud_clk = '1' then
                new_state <= idle_state;
            else
                new_state <= stop_state;
            end if;

        end case;
    end process;

end architecture behavioural;
