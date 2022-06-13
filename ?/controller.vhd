library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controller is
	port (	clk				: in	std_logic;
			reset			: in	std_logic;
			sensor_l_in		: in	std_logic;
			sensor_m_in		: in	std_logic;
			sensor_r_in		: in	std_logic;
			count_in		: in	std_logic_vector (19 downto 0);
			reset_counter	: out	std_logic;
			reset_motor_l	: out	std_logic;
			reset_motor_r	: out	std_logic;
			direction_l		: out	std_logic;
			direction_r		: out	std_logic);
end entity controller;

architecture behavioural of controller is
			type controller_state is (	state_reset,
										state_sl,
										state_gl,
										state_fwd,
										state_gr,
										state_sr);
			signal	state, new_state: 	controller_state;
	begin
		process (clk)
			begin
				if (rising_edge (clk)) then
						if (reset = '1') then
							state <= state_reset;
						else
							state <= new_state;
						end if;
				end if;
		end process;
		
		process (state, count_in, sensor_l_in, sensor_m_in, sensor_r_in)
			begin
				case state is
					when state_reset =>
						reset_counter		<= '1';
						reset_motor_l		<= '1';
						reset_motor_r		<= '1';
						direction_l			<= '0';
						direction_r			<= '0';
						
						if (unsigned(count_in) >= to_unsigned(1000000, 20)) then
								new_state <= state_reset;
						else
							if (sensor_l_in = '0' and sensor_m_in = '1' and sensor_r_in = '1') then
								new_state <= state_sl;
							elsif (sensor_l_in = '0' and sensor_m_in = '0' and sensor_r_in = '1') then
								new_state <= state_gl;
							elsif (sensor_l_in = '1' and sensor_m_in = '0' and sensor_r_in = '0') then
								new_state <= state_gr;
							elsif (sensor_l_in = '1' and sensor_m_in = '1' and sensor_r_in = '0') then
								new_state <= state_sr;
							else
								new_state	<= state_fwd;
							end if;
						end if;
					
					when state_sl =>
						reset_counter		<= '0';
						reset_motor_l		<= '0';
						reset_motor_r		<= '0';
						direction_l			<= '0';
						direction_r			<= '0';
						
						if (unsigned(count_in) >= to_unsigned(1000000, 20)) then
							new_state <= state_reset;
						else
							new_state <= state_sl;
						end if;
						
					when state_gl =>
						reset_counter		<= '0';
						reset_motor_l		<= '1';
						reset_motor_r		<= '0';
						direction_l			<= '0';
						direction_r			<= '0';
						
						if (unsigned(count_in) >= to_unsigned(1000000, 20)) then
							new_state <= state_reset;
						else
							new_state <= state_gl;
						end if;
						
					when state_fwd =>
						reset_counter		<= '0';
						reset_motor_l		<= '0';
						reset_motor_r		<= '0';
						direction_l			<= '1';
						direction_r			<= '0';
						
						if (unsigned(count_in) >= to_unsigned(1000000, 20)) then
							new_state <= state_reset;
						else
							new_state <= state_fwd;
						end if;
						
					when state_gr =>
						reset_counter		<= '0';
						reset_motor_l		<= '0';
						reset_motor_r		<= '1';
						direction_l			<= '1';
						direction_r			<= '0';
						
						if (unsigned(count_in) >= to_unsigned(1000000, 20)) then
							new_state <= state_reset;
						else
							new_state <= state_gr;
						end if;
						
					when state_sr =>
						reset_counter		<= '0';
						reset_motor_l		<= '0';
						reset_motor_r		<= '0';
						direction_l			<= '1';
						direction_r			<= '1';
						
						if (unsigned(count_in) >= to_unsigned(1000000, 20)) then
							new_state <= state_reset;
						else
							new_state <= state_sr;
						end if;
				end case;
		end process;
end architecture behavioural;