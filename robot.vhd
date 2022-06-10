library IEEE;
use IEEE.std_logic_1164.all;

entity robot is
	port (  clk             : in    std_logic;
		reset           : in    std_logic;

		sensor_l_in     : in    std_logic;
		sensor_m_in     : in    std_logic;
		sensor_r_in     : in    std_logic;

		motor_l_pwm     : out   std_logic;
		motor_r_pwm     : out   std_logic;

		mine_sensor	: in std_logic;
		
		rx: in std_logic;
		tx: out std_logic ;
		read_data: in std_logic;
		write_data:  in std_logic
	);
end entity robot;

Architecture structural of robot is
	component timebase is
		port (	clk			: in	std_logic;
			reset			: in	std_logic;

			count_out		: out	std_logic_vector (19 downto 0));
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
			
			MazePoint		: out std_logic;
			MazeTurn		: in std_logic_vector (2 downto 0));
	end component controller;

	component motorcontrol is
		port (	clk		: in	std_logic;
			reset		: in	std_logic;
			direction	: in	std_logic;
			count_in	: in	std_logic_vector (19 downto 0);  -- Please enter upper bound

			pwm		: out	std_logic);
	end component motorcontrol;

	component inputbuffer is
		port (	clk		: in	std_logic;

			sensor_l_in	: in	std_logic;
			sensor_m_in	: in	std_logic;
			sensor_r_in	: in	std_logic;

			sensor_l_out	: out	std_logic;
			sensor_m_out	: out	std_logic;
			sensor_r_out	: out	std_logic);
	end component inputbuffer;

	component uart is
		port (clk             : in  std_logic;
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
	end component uart;

	component LocationsTracker is
		port(	clk:	in std_logic;
				reset:	in std_logic;
				data_in:	in std_logic_vector (7 downto 0); --out from uatr
				data_ready:	in std_logic;
				MazeTurn:	out std_logic_vector (2 downto 0);
				MazePoint:	in std_logic
		);
	end component LocationsTracker;
	
	signal sensor_l, sensor_m, sensor_r, count_reset, MazePoint, data_ready, buffer_empty: std_logic;
	--signal read_data, write_data: std_logic; --maybe comment out
	signal MazeTurn: std_logic_vector(2 downto 0);
	signal data, data_in: std_logic_vector (7 downto 0);
	signal count: std_logic_vector (19 downto 0);
	signal motor_l_reset, motor_l_direction, motor_r_reset, motor_r_direction: std_logic;
begin
	inbuff: inputbuffer port map (	clk => clk,
					sensor_l_in => sensor_l_in,
					sensor_m_in => sensor_m_in,
					sensor_r_in => sensor_r_in,
					sensor_l_out => sensor_l,
					sensor_m_out => sensor_m,
					sensor_r_out => sensor_r);
	
	control: controller port map (	clk => clk, 
					reset => reset,
					sensor_l => sensor_l,
					sensor_m => sensor_m,
					sensor_r => sensor_r,
					count_in => count,
					count_reset => count_reset,
					motor_l_reset => motor_l_reset,
					motor_l_direction => motor_l_direction,
					motor_r_reset => motor_r_reset,
					motor_r_direction => motor_r_direction,
					MazePoint => MazePoint,
					MazeTurn => MazeTurn);
					
	timer: timebase 
			port map (	clk			=> clk,
					reset			=> count_reset,
					count_out		=> count);
					
	motor_l: motorcontrol port map (clk			=> clk,
					reset			=> motor_l_reset, 
					direction		=> motor_l_direction,
					count_in		=> count,
					pwm			=> motor_l_pwm);

	motor_r: motorcontrol port map (clk			=> clk,
					reset			=> motor_r_reset, --??
					direction		=> motor_r_direction,
					count_in		=> count,
					pwm			=> motor_r_pwm);

	Xblee: uart port map ( clk => clk, 
			rx => rx,
			tx => tx,
			data_in => data_in,
			reset => reset,
			buffer_empty => buffer_empty,
       			write => write_data,
			read => read_data,
			data_out => data,
			data_ready => data_ready );

	Locs: LocationsTracker port map( clk => clk, 
			reset => reset,
			data_in => data,
			data_ready => data_ready,
			Mazepoint => MazePoint,
			MazeTurn => MazeTurn);

			
end architecture structural;