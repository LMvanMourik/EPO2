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
	type controll_state is (reset_state,Sleft,Gleft,forward,Gright,Sright,LilForward,Left90,Right90,Turn180,MazeCheck,ForwardTillNonBlack,StationEnd);
	signal state, new_state: controll_state;
	signal checkpoint, new_checkpoint: std_logic;
begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset='1') then
				state <= reset_state;
				checkpoint <= '0';
			else	
				state <= new_state;
				CheckPoint <= new_checkpoint;
			end if;
		end if;
	end process;
	
	process(state,count_in,sensor_l,sensor_m,sensor_r,checkpoint,MazeTurn)
	begin
		case state is
			when reset_state =>
				MazePoint <= '0';
				count_reset <= '1';
				motor_l_reset <= '1';
				motor_l_direction <= '0';
				motor_r_reset <= '1';
				motor_r_direction <= '0';
				if (sensor_l='0') and (sensor_m='1') and (sensor_r='1') then --bww
					new_state <= Sleft;
					new_checkpoint <= checkpoint;
				elsif (sensor_l='0') and (sensor_m='0') and (sensor_r='1') then --bbw
					new_state <= Gleft;
					new_checkpoint <= checkpoint;
				elsif (sensor_l='1') and (sensor_m='0') and (sensor_r='0') then --wbb
					new_state <= Gright;
					new_checkpoint <= checkpoint;
				elsif (sensor_l='1') and (sensor_m='1') and (sensor_r='0') then --wwb
					new_state <= Sright;
					new_checkpoint <= checkpoint;
				elsif (sensor_l='0') and (sensor_m='0') and (sensor_r='0') then --bbb
					new_checkpoint <= not(checkpoint);
					if (checkpoint = '0') then
						if (MazeTurn /= "000") then
							new_state <= LilForward;
						else
							new_state <= MazeCheck;
						end if;
					else
						new_state <= ForwardTillNonblack;
					end if;
				elsif (sensor_l='1') and (sensor_m='1') and (sensor_r='1') then --www
					new_checkpoint <= checkpoint;
					if (checkpoint = '1') then
						new_state <= StationEnd;
					else
						new_state <= forward;
					end if ;
				else --wbw bwb
					new_state <= forward;
					new_checkpoint <= checkpoint;
				end if;
			when Sleft =>
				MazePoint <= '0';
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_l_direction <= '0';
				motor_r_reset <= '0';
				motor_r_direction <= '0';
				new_checkpoint <= checkpoint;
				if (unsigned(count_in) >= to_unsigned(1000000,20)) then
					new_state <= reset_state;
				end if;
			when Gleft =>
				MazePoint <= '0';
				count_reset <= '0';
				motor_l_reset <= '1';
				motor_l_direction <= '0';
				motor_r_reset <= '0';
				motor_r_direction <= '0';
				new_checkpoint <= checkpoint;
				if (unsigned(count_in) >= to_unsigned(1000000,20)) then
					new_state <= reset_state;
				end if;
			when Gright =>
				MazePoint <= '0';
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_l_direction <= '1';
				motor_r_reset <= '1';
				motor_r_direction <= '0';
				new_checkpoint <= checkpoint;
				if (unsigned(count_in) >= to_unsigned(1000000,20)) then
					new_state <= reset_state;
				end if;
			when Sright =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_l_direction <= '1';
				motor_r_reset <= '0';
				motor_r_direction <= '1';
				MazePoint <= '0';
				new_checkpoint <= checkpoint;
				if (unsigned(count_in) >= to_unsigned(1000000,20)) then
					new_state <= reset_state;
				end if;
			when forward =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_l_direction <= '1';
				motor_r_reset <= '0';
				motor_r_direction <= '0';
				MazePoint <= '0';
				new_checkpoint <= checkpoint;
				if (unsigned(count_in) >= to_unsigned(1000000,20)) then
					new_state <= reset_state;
				end if;
			when ForwardTillNonBlack =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_l_direction <= '1';
				motor_r_reset <= '0';
				motor_r_direction <= '0';
				MazePoint <= '0';
				new_checkpoint <= checkpoint;
				if (sensor_l = '1') or (sensor_l = '1') or (sensor_l = '1') then
					new_state <= reset_state;
				else
					new_state <= ForwardTillNonBlack;
				end if;
			when MazeCheck =>
				count_reset <= '1';
				motor_l_reset <= '1';
				motor_l_direction <= '0';
				motor_r_reset <= '1';
				motor_r_direction <= '0';
				MazePoint <= '1';
				new_checkpoint <= checkpoint;
				if (MazeTurn = "000") then
					new_state <= MazeCheck;
				else
					new_state <= LilForward;
				end if;
			when StationEnd =>
				count_reset <= '1';
				motor_l_reset <= '1';
				motor_l_direction <= '0';
				motor_r_reset <= '1';
				motor_r_direction <= '0';
				MazePoint <= '1';
				if (MazeTurn = "111") then
					new_state <= Turn180;
					new_checkpoint <= not(checkpoint);
				else
					new_state <= StationEnd;
					new_checkpoint <= checkpoint;
				end if;
			when LilForward =>
				count_reset <= '1';
				motor_l_reset <= '0';
				motor_l_direction <= '1';
				motor_r_reset <= '0';
				motor_r_direction <= '0';
				MazePoint <= '1';
				new_checkpoint <= checkpoint;
				if (sensor_l='1') or (sensor_m='1') or (sensor_r='1') then
					if (MazeTurn = "100") then
						new_state <= Left90;
					elsif (MazeTurn = "001") then
						new_state <= Right90;
					else
						new_state <= reset_state;
					end if;
				else
					new_state <= LilForward;
				end if;
			when Left90 =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_l_direction <= '0';
				motor_r_reset <= '0';
				motor_r_direction <= '0';
				MazePoint <= '1';
				new_checkpoint <= checkpoint;
				if (sensor_l='0') then
					new_state <= reset_state;
				else 
					new_state <= Left90;
				end if;
				--end if;
			when Right90 =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_l_direction <= '1';
				motor_r_reset <= '0';
				motor_r_direction <= '1';
				MazePoint <= '1';
				new_checkpoint <= checkpoint;
				if (sensor_r='0') then 
					new_state <= reset_state;
				else
					new_state <= Right90;
				end if;
			when Turn180 =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_l_direction <= '1';
				motor_r_reset <= '0';
				motor_r_direction <= '1';
				MazePoint <= '1';
				new_checkpoint <= checkpoint;
				if (sensor_l='0') or (sensor_m='0') or (sensor_r='0') then 
					new_state <= reset_state;
				else
					new_state <= Turn180;
				end if;
		end case;
	end process;
end Architecture behavioural;