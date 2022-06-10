library IEEE;
use IEEE.std_logic_1164.all;

entity tb_LocTrack is
end entity tb_LocTrack;

architecture structural of tb_LocTrack is
	component LocationsTracker is 
		port(clk:	in std_logic;
		reset:	in std_logic;
		data_in:	in std_logic_vector (7 downto 0); --out from uatr
		data_ready:	in std_logic;
		MazePoint:	in std_logic;
		MazeTurn:	out std_logic_vector (2 downto 0)
		);
	end component LocationsTracker;

	signal clk, reset, data_ready, MazePoint: std_logic;
	signal data_in: std_logic_vector(7 downto 0);
	signal MazeTurn: std_logic_vector(2 downto 0);

begin
	LocTrack: LocationsTracker port map( clk=>clk,
		reset=>reset,
		data_in => data_in,
		data_ready => data_ready,
		MazePoint => MazePoint,
		MazeTurn => MazeTurn );
	
	clk			<=	'0' after 0 ns,
					'1' after 5 ns when clk /= '1' else '0' after 5 ns;

	reset			<=	'1' after 0 ns,
					'0' after 10 ns;

	MazePoint <= 	'0' after 0 ns,
			'1' after 10 ns,
			'0' after 100 ns,
			'1' after 110 ns,
			'0' after 200 ns,
			'1' after 210 ns,
			'0' after 300 ns,
			'1' after 310 ns;
	
	Data_in <= "00000000" after 0 ns,
			"01100011" after 10 ns, --c10
			"00110001" after 30 ns,
			"00110000" after 50 ns,
			"01100011" after 110 ns, --c11
			"00110001" after 130 ns,
			"00110001" after 150 ns,
			"01100011" after 210 ns, --c21
			"00110010" after 230 ns,
			"00110001" after 250 ns,
			"01100011" after 310 ns, --c22
			"00110010" after 330 ns,
			"00110010" after 350 ns;

	Data_ready <=	'0' after 0 ns,
			'1' after 10 ns when Data_ready /= '1' else '0' after 10 ns;
end architecture structural;