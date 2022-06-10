library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

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
		motor_r_direction	: out	std_logic
	);
end entity controller;

architecture behaviour of controller is
	
	type controller_state is (reset_state, forward, gentle_left, sharp_left, gentle_right, sharp_right);
	signal state, new_state: controller_state;
	signal count_int: unsigned(19 downto 0);

begin
	process (clk)
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				state <= reset_state;
			else
				state <= new_state;
			end if;
		end if;
	end process;

	count_int <= unsigned(count_in);

	process (state, count_int, clk)
	begin
		case state is
			when reset_state =>
				count_reset <= '1';
				if (sensor_l = '0' and sensor_m = '0' and sensor_r = '0') then
					new_state <= forward;
				end if;
				if (sensor_l = '0' and sensor_m = '0' and sensor_r = '1') then
					new_state <= gentle_left;
				end if;
				if (sensor_l = '0' and sensor_m = '1' and sensor_r = '0') then
					new_state <= forward;
				end if;
				if (sensor_l = '0' and sensor_m = '1' and sensor_r = '1') then
					new_state <= sharp_left;
				end if;
				if (sensor_l = '1' and sensor_m = '0' and sensor_r = '0') then
					new_state <= gentle_right;
				end if;
				if (sensor_l = '1' and sensor_m = '0' and sensor_r = '1') then
					new_state <= forward;
				end if;
				if (sensor_l = '1' and sensor_m = '1' and sensor_r = '0') then
					new_state <= sharp_right;
				end if;
				if (sensor_l = '1' and sensor_m = '1' and sensor_r = '1') then
					new_state <= forward;
				end if;

			when forward =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_l_direction <= '1';
				motor_r_reset <= '0';
				motor_r_direction <= '0';
				if (count_int = 1000000) then
					new_state <= reset_state;
					count_reset <= '1';
				end if;

			when gentle_left =>
				count_reset <= '0';
				motor_l_reset <= '1';
				motor_l_direction <= '0';
				motor_r_reset <= '0';
				motor_r_direction <= '0';
				if (count_int = 1000000) then
					new_state <= reset_state;
					count_reset <= '1';
				end if;

			when sharp_left =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_l_direction <= '0';
				motor_r_reset <= '0';
				motor_r_direction <= '0';
				if (count_int = 1000000) then
					new_state <= reset_state;
					count_reset <= '1';
				end if;

			when gentle_right =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_l_direction <= '1';
				motor_r_reset <= '1';
				motor_r_direction <= '0';
				if (count_int = 1000000) then
					new_state <= reset_state;
					count_reset <= '1';
				end if;

			when sharp_right =>
				count_reset <= '0';
				motor_l_reset <= '0';
				motor_l_direction <= '1';
				motor_r_reset <= '0';
				motor_r_direction <= '1';
				if (count_int = 1000000) then
					new_state <= reset_state;
					count_reset <= '1';
				end if;
		end case;
	end process;

end architecture behaviour;
