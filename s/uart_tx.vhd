-- uart_tx.vhdl
--
-- Complete TX part of uart
library IEEE;
use IEEE.std_logic_1164.all;

entity uart_tx is
    generic (
        CLKS_PER_SAMPLE : integer;
        OVERSAMPLING    : integer range 1 to 16
    );
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;

        write           : in  std_logic;
        data_in         : in  std_logic_vector (7 downto 0);
        buffer_empty    : out std_logic;

        tx              : out std_logic
    );
end entity uart_tx;


architecture structural of uart_tx is

    component uart_buffer is
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;

        write           : in  std_logic;
        read            : in  std_logic;

        data_in         : in  std_logic_vector (7 downto 0);
        data_out        : out std_logic_vector (7 downto 0);
        data_ready      : out std_logic
    );
    end component uart_buffer;

    component uart_clk is
    generic (
        CLKS_PER_SAMPLE : integer;
        OVERSAMPLING    : integer range 1 to 16
    );
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;

        sample_clk      : out std_logic;
        sample_count    : out std_logic_vector (3 downto 0);

        baud_clk        : out std_logic
    );
    end component uart_clk;

    component tx_fsm is
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
    end component tx_fsm;

    signal buffer_data_out : std_logic_vector (7 downto 0);
    signal buffer_data_read, buffer_data_ready : std_logic;
    signal buffer_data_empty : std_logic;

    signal uart_clk_reset, sample_clk, baud_clk : std_logic;

begin

    buffer_data_empty <= not buffer_data_ready;
    buffer_empty      <= buffer_data_empty;

uart_buffer_map:
    uart_buffer port map (
        clk             => clk,
        reset           => reset,

        write           => write,
        read            => buffer_data_read,

        data_in         => data_in,
        data_out        => buffer_data_out,
        data_ready      => buffer_data_ready
    );

uart_clk_map:
    uart_clk generic map (
        CLKS_PER_SAMPLE => CLKS_PER_SAMPLE,
        OVERSAMPLING    => OVERSAMPLING
    )
    port map (
        clk             => clk,
        reset           => uart_clk_reset,

        sample_clk      => sample_clk,
        --sample_count    =>

        baud_clk        => baud_clk
    );

tx_fsm_map:
    tx_fsm port map (
        clk                     => clk,
        reset                   => reset,

        tx                      => tx,

        uart_clk_reset          => uart_clk_reset,
        baud_clk                => baud_clk,

        tx_buffer               => buffer_data_out,

        input_buffer_empty      => buffer_data_empty,
        input_buffer_read       => buffer_data_read
    );


end architecture structural;
