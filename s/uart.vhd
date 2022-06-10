-- uart.vhdl
--
-- complete uart
library IEEE;
use IEEE.std_logic_1164.all;

entity uart is
    generic (
        CLK_SCALE       : integer
    );
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;

        rx              : in  std_logic;
        tx              : out std_logic;

        data_in         : in  std_logic_vector (7 downto 0);
        buffer_empty    : out std_logic;
        write           : in  std_logic;

        data_out        : out std_logic_vector (7 downto 0);
        data_ready      : out std_logic;
        read            : in  std_logic
    );
end entity uart;


architecture structural of uart is

    component uart_rx is
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
    end component uart_rx;

    component uart_tx is
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
    end component uart_tx;

    constant CLKS_PER_SAMPLE_1    : integer := 325;
    constant CLKS_PER_SAMPLE_5000 : integer := 13;

    constant OVERSAMPLING : integer := 16;

begin

    assert (CLK_SCALE = 1) or (CLK_SCALE = 5000 )
        report "CLK_SCALE must be 1 or 5000" severity failure;

    --------------------------------------
    -- For use with real-time frequency --
    --------------------------------------
    HIGH_FREQ: if CLK_SCALE = 1 generate

    uart_rx_map_1:
        uart_rx generic map (
            CLKS_PER_SAMPLE => CLKS_PER_SAMPLE_1,
            OVERSAMPLING    => OVERSAMPLING
        )
        port map (
            clk             => clk,
            reset           => reset,
            rx              => rx,
            read            => read,
            data_ready      => data_ready,
            data_out        => data_out
        );

    uart_tx_map_1:
        uart_tx generic map (
            CLKS_PER_SAMPLE => CLKS_PER_SAMPLE_1,
            OVERSAMPLING    => OVERSAMPLING
        )
        port map (
            clk             => clk,
            reset           => reset,
            write           => write,
            data_in         => data_in,
            buffer_empty    => buffer_empty,
            tx              => tx
        );

    end generate;

    ----------------------------------------------
    -- For use with matlab simulation frequency --
    ----------------------------------------------
    LOW_FREQ: if CLK_SCALE = 5000 generate

    uart_rx_map_5000:
        uart_rx generic map (
            CLKS_PER_SAMPLE => CLKS_PER_SAMPLE_5000,
            OVERSAMPLING    => OVERSAMPLING
        )
        port map (
            clk             => clk,
            reset           => reset,
            rx              => rx,
            read            => read,
            data_ready      => data_ready,
            data_out        => data_out
        );

    uart_tx_map_5000:
        uart_tx generic map (
            CLKS_PER_SAMPLE => CLKS_PER_SAMPLE_5000,
            OVERSAMPLING    => OVERSAMPLING
        )
        port map (
            clk             => clk,
            reset           => reset,
            write           => write,
            data_in         => data_in,
            buffer_empty    => buffer_empty,
            tx              => tx
        );

    end generate;

end architecture structural;
