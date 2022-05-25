library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-- Please add necessary libraries:

entity inputbuffer is
	port (	clk		: in	std_logic;

		sensor_l_in	: in	std_logic;
		sensor_m_in	: in	std_logic;
		sensor_r_in	: in	std_logic;

		sensor_l_out	: out	std_logic;
		sensor_m_out	: out	std_logic;
		sensor_r_out	: out	std_logic
	);
end entity inputbuffer;


architecture behavioural of inputbuffer is
	signal lmrsig: std_logic_vector(2 downto 0);
begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			lmrsig(2)<= sensor_l_in;
			lmrsig(1)<= sensor_m_in;
			lmrsig(0)<= sensor_r_in;
		end if;
	end process;
	process(clk)
	begin
		if (rising_edge(clk)) then
			sensor_l_out <= lmrsig(2);
			sensor_m_out <= lmrsig(1);
			sensor_r_out <= lmrsig(0);
		end if;
	end process;
end architecture behavioural;