library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity motorcontrol is
	port (	clk		: in	std_logic;
		reset		: in	std_logic;
		direction	: in	std_logic;
		count_in	: in	std_logic_vector (19 downto 0);  -- Please enter upper bound

		pwm		: out	std_logic
	);
end entity motorcontrol;

architecture behavioural of motorcontrol is

	type pulse_state is (pulse_reset, pulse_high, pulse_low);
	signal state, new_state: pulse_state;
	signal count_int: unsigned(19 downto 0);

begin
	process (clk)
	begin
		if (rising_edge(clk)) then
			if (reset = '1') then
				state <= pulse_reset;
			else
				state <= new_state;
			end if;
		end if;
	end process;

	count_int <= unsigned(count_in);

	process (state, reset, count_in)
	begin
		case state is
			when pulse_reset =>
				pwm <= '0';
				if (reset = '0') then
					new_state <= pulse_high;
				else
					new_state <= pulse_reset;
				end if;

			when pulse_high =>
				pwm <= '1';
				if (direction = '0') then
					if ( count_int = 50000) then
						new_state <= pulse_low;
					end if;
				else 
					if ( count_int = 100000) then
						new_state <= pulse_low;
					end if;
				end if;

			when pulse_low =>
				pwm <= '0';
				if (direction = '0') then
					if ( count_int = 1000000) then
						new_state <= pulse_reset;
					end if;
				else 
					if ( count_int = 1000000) then
						new_state <= pulse_reset;
					end if;
				end if;

		end case;
	end process;
end architecture behavioural;