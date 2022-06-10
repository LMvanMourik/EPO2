-- uart_rx.vhdl
--
-- complete rx part of the uart
library IEEE;
use IEEE.std_logic_1164.all;

entity uart_rx is
    generic (
        CLKS_PER_SAMPLE : integer;
        OVERSAMPLING    : integer range 1 to 16
    );
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;

        rx              : in  std_logic;

        read            : in  std_logic;
        data_ready      : out std_logic;
        data_out        : out std_logic_vector (7 downto 0)
    );
end entity uart_rx;


architecture structural of uart_rx is

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

    component sync_buffer is
    port (
        clk             : in  std_logic;
        data_in         : in  std_logic;
        data_out        : out std_logic
    );
    end component sync_buffer;

    component oversampler is
    generic (
        OVERSAMPLING    : integer range 1 to 16
    );
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;

        rx              : in  std_logic;

        sample_clk      : in  std_logic;
        rx_sampled      : out std_logic
    );
    end component oversampler;

    component rx_fsm is
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
    end component rx_fsm;

    signal rx_data : std_logic_vector (7 downto 0);
    signal output_buffer_write : std_logic;

    signal uart_clk_reset, sample_clk, baud_clk : std_logic;

    signal rx_sync, oversampler_reset, rx_sampled : std_logic;


begin

uart_buffer_map:
    uart_buffer port map (
        clk             => clk,
        reset           => reset,

        write           => output_buffer_write,
        read            => read,

        data_in         => rx_data,
        data_out        => data_out,
        data_ready      => data_ready
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

sync_buffer_map:
    -- sync asynchronous rx signal
    sync_buffer port map (
        clk             => clk,
        data_in         => rx,
        data_out        => rx_sync
    );

oversampler_map:
    oversampler generic map (
        OVERSAMPLING    => OVERSAMPLING
    )
    port map (
        clk             => clk,
        reset           => oversampler_reset,

        rx              => rx_sync,

        sample_clk      => sample_clk,
        rx_sampled      => rx_sampled
    );

rx_fsm_map:
    rx_fsm port map (
        clk                     => clk,
        reset                   => reset,

        rx                      => rx_sync,
        oversampler_reset       => oversampler_reset,
        rx_sampled              => rx_sampled,

        uart_clk_reset          => uart_clk_reset,
        baud_clk                => baud_clk,

        rx_data                 => rx_data,
        output_buffer_write     => output_buffer_write
    );

end architecture structural;
