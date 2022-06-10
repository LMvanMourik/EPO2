-- oversampler.vhdl
--
-- Oversamples input and returns majority value
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity oversampler is
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
end entity oversampler;


architecture behavioural of oversampler is

    signal count, new_count : unsigned (3 downto 0);

begin

reg: process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                count <= to_unsigned(0, count'length);
            else
                count <= new_count;
            end if;
        end if;
    end process;

comb: process (count, rx, sample_clk)
    begin
        if count >= OVERSAMPLING/2 then
            rx_sampled <= '1';
        else
            rx_sampled <= '0';
        end if;

        if sample_clk = '1' and rx = '1' and count /= to_unsigned(OVERSAMPLING-1, count'length) then
            new_count <= count + 1;
        else
            new_count <= count;
        end if;
    end process;

end architecture behavioural;
