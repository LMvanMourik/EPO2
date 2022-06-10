-- uart_clk.vhdl
--
-- Generates oversampling and baudrate clocks
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity uart_clk is
    generic (
        CLKS_PER_SAMPLE : integer; -- = BAUD_PERIOD/(CLK_PERIOD*OVERSAMPLING)
        OVERSAMPLING    : integer range 1 to 16
    );
    port (
        clk             : in  std_logic;
        reset           : in  std_logic;

        sample_clk      : out std_logic;
        sample_count    : out std_logic_vector (3 downto 0);

        baud_clk        : out std_logic
    );
end entity uart_clk;


architecture behavioural of uart_clk is

    signal clk_cnt, new_clk_cnt       : unsigned (15 downto 0);
    signal sample_cnt, new_sample_cnt : unsigned (3 downto 0);

begin

reg: process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                clk_cnt    <= to_unsigned(0, clk_cnt'length);
                sample_cnt <= to_unsigned(0, sample_cnt'length);
            else
                clk_cnt    <= new_clk_cnt;
                sample_cnt <= new_sample_cnt;
            end if;
        end if;
    end process;

comb: process (clk_cnt, sample_cnt)
    begin
        if clk_cnt = to_unsigned(CLKS_PER_SAMPLE-1, clk_cnt'length) then
            new_clk_cnt <= to_unsigned(0, clk_cnt'length);
            sample_clk  <= '1';

            if sample_cnt = to_unsigned(OVERSAMPLING-1, sample_cnt'length) then
                new_sample_cnt <= to_unsigned(0, sample_cnt'length);
                baud_clk       <= '1';
            else
                new_sample_cnt <= sample_cnt + 1;
                baud_clk       <= '0';
            end if;
        else
            new_clk_cnt    <= clk_cnt + 1;
            new_sample_cnt <= sample_cnt;
            sample_clk     <= '0';
            baud_clk       <= '0';
        end if;
    end process;

    sample_count <= std_logic_vector(sample_cnt);

end architecture behavioural;
