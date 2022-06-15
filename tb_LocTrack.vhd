library IEEE;
use IEEE.std_logic_1164.all;

entity tb_LocTrack is
end entity tb_LocTrack;

architecture structural of tb_LocTrack is
	component TurnChecker is 
		port(clk:	in std_logic;
		reset:	in std_logic;
		data_in:	in std_logic_vector (7 downto 0); --out from uatr
		data_ready:	in std_logic;
		MazePoint:	in std_logic;
		MazeTurn:	out std_logic_vector (2 downto 0)
		);
	end component TurnChecker;

	signal clk, reset, data_ready, MazePoint: std_logic;
	signal data_in: std_logic_vector(7 downto 0);
	signal MazeTurn: std_logic_vector(2 downto 0);

begin
	TurnCheck: TurnChecker port map( clk=>clk,
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
			'0' after 170 ns,
			'1' after 220 ns,
			'0' after 340 ns,
			'1' after 360 ns,
			'0' after 400 ns,
			'1' after 410 ns;
	
	Data_in <= 
			--"00000000" after 0 ns,
			"01100110" after 0 ns, --f
			"01101100" after 90 ns, --l
			"01110010" after 190 ns, --r
			"01110101" after 300 ns, --u
			"01101110" after 400 ns, --n
			"00000000" after 430 ns;

	Data_ready <=	
			--'0' after 0 ns,
			'1' after 0 ns,
			'0' after 30 ns,
			'1' after 100 ns,
			'0' after 120 ns,
			'1' after 190 ns,
			'0' after 230 ns,
			'1' after 300 ns,
			'0' after 355 ns,
			'1' after 400 ns,
			'0' after 430 ns;
end architecture structural;