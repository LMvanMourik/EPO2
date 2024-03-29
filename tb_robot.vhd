library IEEE;
use IEEE.std_logic_1164.all;

entity tb_robot is
end entity tb_robot;

architecture structural of tb_robot is

	component robot is
		port (	clk		: in	std_logic;
			reset		: in	std_logic;

			sensor_l_in	: in	std_logic;
			sensor_m_in	: in	std_logic;
			sensor_r_in	: in	std_logic;

			motor_l_pwm	: out	std_logic;
			motor_r_pwm	: out	std_logic;

			rx: in std_logic;
			tx: out std_logic;
			read_data: in std_logic;
			write_data:  in std_logic
		);
	end component robot;

	signal	clk, reset 			: std_logic;
	signal	sensor_l, sensor_m, sensor_r, rx, tx, read_data, write_data	: std_logic;
	signal	sensors				: std_logic_vector(2 downto 0);
	signal	motor_l_pwm, motor_r_pwm	: std_logic;

begin

	lbl0: robot port map	(	clk 			=> clk,
					reset			=> reset,
					sensor_l_in		=> sensor_l,
					sensor_m_in		=> sensor_m,
					sensor_r_in		=> sensor_r,
					motor_l_pwm		=> motor_l_pwm,
					motor_r_pwm		=> motor_r_pwm,
					rx => rx,
					tx => tx,
					read_data => read_data,
					write_data => write_data
				);

	-- 20 ns = 50 MHz
	clk			<=	'0' after 0 ns,
					'1' after 10 ns when clk /= '1' else '0' after 10 ns;

	reset			<=	'1' after 0 ns,
					'0' after 40 ms;

	rx <= '0' after 0 ns;
	read_data <= '0' after 0 ns;
	write_data <= '0' after 0 ns;

	sensors 		<=	"111" after 0 ns,   -- bbb
					"001" after 70 ms,  -- bbw
					"010" after 110 ms, -- bwb
					"011" after 150 ms, -- bww
					"100" after 190 ms, -- wbb
					"101" after 230 ms, -- wbw
					"110" after 270 ms, -- wwb
					"000" after 310 ms; -- bbb

	sensor_l		<= 	sensors(2);
	sensor_m		<= 	sensors(1);
	sensor_r		<= 	sensors(0);

end architecture structural;

