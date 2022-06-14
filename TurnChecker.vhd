library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity TurnChecker is
	port(	clk:	in std_logic;
		reset:	in std_logic;
		data_in:	in std_logic_vector (7 downto 0); --out from uatr
		data_ready:	in std_logic;
		MazePoint:	in std_logic;
		MazeTurn:	out std_logic_vector (2 downto 0)
	);
end entity TurnChecker;

Architecture behavioural of TurnChecker is
	type LocTrackState is (Data1, TurnCalc, WaitState, WaitForMazePoint);
	signal state, new_state: LocTrackState;
	signal Data, new_Data: std_logic_vector(7 downto 0);
	signal TurnHold: std_logic_vector (2 downto 0);

begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset='1') then
				state <= Data1;
				Data <= "00000000";
			else	
				state <= new_state;
				Data <= new_Data;
			end if;
		end if;
	end process;

	process(state, data_ready, data_in, Data, MazePoint,TurnHold)
	begin
		case state is
			when Data1 =>
				MazeTurn <= "000";
				TurnHold <= "000";
				if (data_ready = '1') and (data_in /= "00000000") then
					new_Data <= data_in;
					new_state <= TurnCalc;
				else
					new_state <= Data1;
					new_Data <= Data;
				end if;

			when TurnCalc =>
				MazeTurn <= "000";
				new_Data <= Data;
				if (Data = "01100110") then --forward
					TurnHold <= "010";
				elsif (Data= "01101100") then --left
					TurnHold <= "100"; 
				elsif (Data = "01110010") then --right
					TurnHold <= "001";
				elsif (Data = "01110101") then --u turn
					TurnHold<= "111";
				else ---n
					TurnHold <= "000";
				end if;
				if (MazePoint = '1') then
					new_state <= WaitState;
				else 
					new_state <= WaitForMazePoint;
				end if;

			when WaitForMazePoint =>
				MazeTurn <= "000";
				if (MazePoint = '1') then
					new_state <= WaitState;
				else 
					new_state <= WaitForMazePoint;
				end if;

			when WaitState =>
				MazeTurn <= TurnHold;
				if (MazePoint = '0') then
					new_state <= Data1;
				else
					new_state <= WaitState;
				end if;
		end case;
	end process;
end Architecture behavioural;