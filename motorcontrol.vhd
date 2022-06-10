library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-- Please add necessary libraries:

entity motorcontrol is
	port (	clk		: in	std_logic;
		reset		: in	std_logic;
		direction	: in	std_logic;
		count_in	: in	std_logic_vector (19 downto 0);  -- Please enter upper bound

		pwm		: out	std_logic
	);
end entity motorcontrol;

Architecture behavioural of motorcontrol is
	type pwm_state is (reset_state, pwm_on, pwm_off);
	signal state, new_state: pwm_state;

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

	process(state,count_in,direction)
	begin
		case state is
			when reset_state => 
				pwm <= '0';
				new_state <= pwm_on;
			when pwm_on =>
				pwm <= '1';
				if (direction='0') and (unsigned(count_in) >= to_unsigned(50000,20)) then --50000 16 bit
					new_state <= pwm_off;
				elsif (direction='1') and (unsigned(count_in) >= to_unsigned(100000,20)) then----17 bits
					new_state <= pwm_off;
				else new_state <= pwm_on;
				end if;
			when pwm_off =>
				pwm <='0';
				new_state <= pwm_off;
		end case;
	end process;
end Architecture behavioural;