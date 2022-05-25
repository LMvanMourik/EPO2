library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-- Please add necessary libraries:


entity controller is
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
		MazePoint			: out	std_logic
	);
end entity controller;

Architecture behavioural of controller is
	type controll_state is (reset_state, Sleft, Gleft, forward, Gright, Sright, MazeCheck, LilForward, Left90, Right90); --Turn180);
	signal state, new_state: controll_state;
begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset='1') then
				state <= reset_state;
			else	
				state <= new_state;
			end if;
		end if;
	end process;
	
	process(state,count_in,sensor_l,sensor_m,sensor_r)
	begin
		case state is
			when reset_state =>
				MazePoint <= '0';
				count_reset <= '1';
				motor_l_reset <= '1';
				motor_l_direction <= '0';
				motor_r_reset <= '1';
				motor_r_direction <= '0';
				if (sensor_l='0') and (sensor_m='1') and (sensor_r='1') then
					new_state <= Sleft;
				elsif (sensor_l='0') and (sensor_m='0') and (sensor_r='1') then
					new_state <= Gleft;
				elsif (sensor_l='1') and (sensor_m='0') and (sensor_r='0') then
					new_state <= Gright;
				elsif (sensor_l='1') and (sensor_m='1') and (sensor_r='0') then
					new_state <= Sright;
				elsif (sensor_l='0') and (sensor_m='0') and (sensor_r='0') then
					new_state <= MazeCheck;
				else
					new_state <= forward;
				end if;
			when Sleft =>
				MazePoint <= '0';
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_l_direction <= '0';
				motor_r_reset <= '0';
				motor_r_direction <= '0';
				if (unsigned(count_in) = to_unsigned(1000000,20)) then
					new_state <= reset_state;
				end if;
			when Gleft =>
				MazePoint <= '0';
				count_reset <= '0';
				motor_l_reset <= '1';
				motor_l_direction <= '0';
				motor_r_reset <= '0';
				motor_r_direction <= '0';
				if (unsigned(count_in) = to_unsigned(1000000,20)) then
					new_state <= reset_state;
				end if;
			when Gright =>
				MazePoint <= '0';
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_l_direction <= '1';
				motor_r_reset <= '1';
				motor_r_direction <= '0';
				if (unsigned(count_in) = to_unsigned(1000000,20)) then
					new_state <= reset_state;
				end if;
			when Sright =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_l_direction <= '1';
				motor_r_reset <= '0';
				motor_r_direction <= '1';
				MazePoint <= '0';
				if (unsigned(count_in) = to_unsigned(1000000,20)) then
					new_state <= reset_state;
				end if;
			when forward =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_l_direction <= '1';
				motor_r_reset <= '0';
				motor_r_direction <= '0';
				MazePoint <= '0';
				if (unsigned(count_in) = to_unsigned(1000000,20)) then
					new_state <= reset_state;
				end if;
			when MazeCheck =>
				count_reset <= '1';
				motor_l_reset <= '1';
				motor_l_direction <= '0';
				motor_r_reset <= '1';
				motor_r_direction <= '0';
				MazePoint <= '1';
				--if (MazeTurn = "000") then
					--new_state <= MazeCheck;
				if (MazeTurn = "010") then --straight
					new_state <= forward;
				elsif (MazeTurn = "100") or (MazeTurn = "001") or (MazeTurn = "111") then --left right 180
					new_state <= LilForward;
				else
					new_state <= MazeCheck;
				end if;
			
			when LilForward =>
				count_reset <= '1';
				motor_l_reset <= '0';
				motor_l_direction <= '1';
				motor_r_reset <= '0';
				motor_r_direction <= '0';
				MazePoint <= '1';
				if (sensor_l='1') or (sensor_m='1') or (sensor_r='1') then
					if (MazeTurn = "100") then
						new_state <= Left90;
					elsif (MazeTurn = "001") then
						new_state <= Right90;
					--elsif (MazeTurn = "111") then
						--new_state <= Turn180;
					else
						new_state <= MazeCheck;
					end if;
				end if;
			when Left90 =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_l_direction <= '0';
				motor_r_reset <= '0';
				motor_r_direction <= '0';
				MazePoint <= '1';
				if (unsigned(count_in) = to_unsigned(1000000,20)) then
					if (sensor_l='1') or (sensor_m='1') or (sensor_r='1') then
						new_state <= reset_state;
					end if;
				end if;
			when Right90 =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_l_direction <= '1';
				motor_r_reset <= '0';
				motor_r_direction <= '1';
				MazePoint <= '1';
				if (unsigned(count_in) = to_unsigned(1000000,20)) then
					if (sensor_l='1') or (sensor_m='1') or (sensor_r='1') then
						new_state <= reset_state;
					end if;
				end if;
			--when Turn180 =>
		end case;
	end process;
end Architecture behavioural;