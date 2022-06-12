library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity LocationsTracker is
	port(	clk:	in std_logic;
		reset:	in std_logic;
		data_in:	in std_logic_vector (7 downto 0); --out from uatr
		data_ready:	in std_logic;
		MazePoint:	in std_logic;
		MazeTurn:	out std_logic_vector (2 downto 0)
	);
end entity LocationsTracker;

Architecture behavioural of LocationsTracker is
	type LocTrackState is (Data1, TurnCalc, WaitState, WaitForMazePoint);
	signal state, new_state: LocTrackState;
	signal Turn, new_Turn: std_logic_vector(7 downto 0);
	--signal loc1, loc2, new_loc1, new_loc2: std_logic_vector (15 downto 0);
	signal MazeHold: std_logic_vector (2 downto 0); --orient1, orient2, new_orient1, new_orient2, 

begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset='1') then
				state <= Data1;
				Turn <= "00000000";
			else	
				state <= new_state;
				Turn <= new_Turn;
			end if;
		end if;
	end process;

	process(state, data_ready, data_in, Turn, MazePoint)
	begin
		case state is
			when Data1 =>
				MazeTurn <= "000";
				MazeHold <= "000";
				if (data_ready = '1') and (data_in /= "00000000") then
					new_Turn <= data_in;
					new_state <= TurnCalc;
				else
					new_state <= Data1;
					new_Turn <= Turn;
				end if;

			when TurnCalc =>
				MazeTurn <= "000";
				new_Turn <= Turn;
				if (Turn = "01100110") then --forward
					MazeHold <= "010";
				elsif (Turn= "01101100") then --left
					MazeHold <= "100"; 
				elsif (Turn = "01110010") then --right
					MazeHold <= "001";
				elsif (Turn = "01110101") then --u turn
					MazeHold<= "111";
				else ---n
					MazeHold <= "000";
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
				MazeTurn <= MazeHold;
				if (MazePoint = '0') then
					new_state <= Data1;
				else
					new_state <= WaitState;
				end if;
		end case;
	end process;
end Architecture behavioural;