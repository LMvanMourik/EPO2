library IEEE;
use IEEE.std_logic_1164.all;


entity inputbuffer is
	port (	clk		: in	std_logic;
		reset		: in	std_logic;

		sensor_l_in	: in	std_logic;
		sensor_m_in	: in	std_logic;
		sensor_r_in	: in	std_logic;

		sensor_l_out	: out	std_logic;
		sensor_m_out	: out	std_logic;
		sensor_r_out	: out	std_logic
	);
end entity inputbuffer;

library IEEE;
use IEEE.std_logic_1164.all;

entity dff is
port (	D	: in std_logic;
	clk	: in std_logic;
	Q	: out std_logic);
end entity dff;

architecture behavior_dff of dff is
begin
	process(clk)
	begin
	if (rising_edge(clk)) then
		Q <= D;
	end if;
	end process;
end behavior_dff;

architecture behavior_inputbuffer of inputbuffer is
	component dff is
		port (	D, clk	: in std_logic;
			Q	: out std_logic);
	end component dff;

	signal s1, s2, s3, s4, s5, s6: std_logic;
begin
	
	process (reset, s4, s5, s6)
	begin
		if (reset = '1') then
			sensor_l_out <= '1';
			sensor_m_out <= '1';
			sensor_r_out <= '1';
		else
			sensor_l_out <= s4;
			sensor_m_out <= s5;
			sensor_r_out <= s6;
		end if;
	end process;

	register1_l_one:	dff port map(D=>sensor_l_in, clk=>clk, Q=>s1);
	register1_m_one:	dff port map(D=>sensor_m_in, clk=>clk, Q=>s2);
	register1_r_one:	dff port map(D=>sensor_r_in, clk=>clk, Q=>s3);

	register1_l_two:	dff port map(D=>s1, clk=>clk, Q=>s4);
	register1_m_two:	dff port map(D=>s2, clk=>clk, Q=>s5);
	register1_r_two:	dff port map(D=>s3, clk=>clk, Q=>s6);				
end behavior_inputbuffer;
