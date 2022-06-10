library IEEE;
use IEEE.std_logic_1164.all;

entity tb_controller is
end entity tb_controller;

architecture structural of tb_controller is
	component timebase is
		port (	clk			: in	std_logic;
			reset			: in	std_logic;

			count_out		: out	std_logic_vector (19 downto 0)
		);
	end component timebase;
	
	component controller is
		port (	clk			: in	std_logic;
			reset			: in	std_logic;

			sensor_l		: in	std_logic;
			sensor_m		: in	std_logic;
			sensor_r		: in	std_logic;

			count_in		: in	std_logic_vector (19 downto 0);  -- Please enter upper bound
			count_reset		: out	std_logic;

			motor_l_reset		: out	std_logic;
			motor_l_direction	: out	std_logic;

			motor_r_reset		: out	std_logic;
			motor_r_direction	: out	std_logic;
			MazeTurn		: in std_logic_vector (2 downto 0);
			MazePoint		: out std_logic
		);
	end component controller;
	
	signal	clk, reset, sensor_l,sensor_m,sensor_r,count_reset, MazePoint: std_logic;
	signal	count	: std_logic_vector (19 downto 0);
	signal 	sensors, MazeTurn: std_logic_vector(2 downto 0);
	signal	motor_l_reset, motor_r_reset,motor_l_direction,motor_r_direction: std_logic;
begin
	lbl0: timebase port map	(	clk			=> clk,
					reset			=> reset,
					count_out		=> count
				);
					
	lbl1: controller port map (	clk			=> clk,
					reset			=> reset,
					sensor_l		=> sensor_l,
					sensor_m		=> sensor_m,
					sensor_r		=> sensor_r,
					count_in		=> count,
					count_reset		=> count_reset,
					motor_l_reset		=> motor_l_reset,
					motor_l_direction 	=> motor_l_direction,
					motor_r_reset 		=> motor_r_reset,
					motor_r_direction 	=> motor_r_direction,
					MazeTurn 		=> MazeTurn,
					MazePoint 		=> MazePoint
				);
	clk			<=	'0' after 0 ns,
					'1' after 10 ns when clk /= '1' else '0' after 10 ns;

	reset			<=	'1' after 0 ns,
					'0' after 40 ms;

	sensors 		<=	"101" after 0 ns, --110 ms, -- bwb
					"000" after 80 ms,  -- bbb left test
					"100" after 140 ms,
					"000" after 200 ms, -- checkpoint test
					"110" after 240 ms,
					"000" after 280 ms, -- right test
					"001" after 300 ms,
					"000" after 360 ms, -- checkpoint
					"101" after 400 ms,
					"000" after 440 ms, --straight test
					"101" after 460 ms,
					"110" after 490 ms;
					--"101" after 480 ms,
					--"000" after 520 ms, -- left test
					--"101" after 560 ms,
					--"110" after 600 ms,
					--"111" after 640 ms,
					--"011" after 680 ms,
					--"101" after 720 ms;

	MazeTurn <= "000" after 0 ns,
		"100" after 120 ms, --left
		"000" after 160 ms,
		"010" after 200 ms,
		"000" after 320 ms,
		"001" after 460 ms,
		"000" after 470 ms;
		

	sensor_l		<= 	sensors(2);
	sensor_m		<= 	sensors(1);
	sensor_r		<= 	sensors(0);
end architecture structural;
