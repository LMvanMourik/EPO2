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
	type LocTrackState is (Data1,Data2,Data3, OrientCalc, TurnCalc, WaitState1,WaitState2,WaitState3, QuickBack);
	signal state, new_state: LocTrackState;
	signal loc1, loc2, new_loc1, new_loc2: std_logic_vector (15 downto 0);
	signal orient1, orient2, new_orient1, new_orient2, MazeHold: std_logic_vector (2 downto 0);

begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset='1') then
				loc1 <= (others => '0');
				loc2 <= (others => '0');
				orient1 <= (others => '0');
				orient2 <= (others => '0');
				state <= Data1;
			else	
				state <= new_state;
				loc1 <= new_loc1;
				loc2 <= new_loc2;
				orient1 <= new_orient1;
				orient2 <= new_orient2;
			end if;
		end if;
	end process;

	process(data_ready, data_in,state,loc1,loc2,orient1,orient2)
	begin
		new_loc1 <= loc1;
		new_loc2 <= loc2;
		new_orient1 <= orient1;
		new_orient2 <= orient2;
		case state is
			when Data1 =>
				MazeTurn <= "000";
				if (data_ready = '1') then
					if (data_in = "01100011") then
						new_state <= WaitState1;
					else
						new_state <= Data1;
					end if;
				end if;
			
			when WaitState1 =>
				MazeTurn <= "000";
				if (data_ready = '0') then
					new_state <= Data2;
				end if;
					
			when Data2 =>
				MazeTurn <= "000";
				if (data_ready = '1') then
					new_loc2(15 downto 8) <= data_in;
					new_state <= WaitState2;
				end if;

			when WaitState2 =>
				MazeTurn <= "000";
				if (data_ready = '0') then
					new_state <= Data3;
				end if;

			when Data3 =>
				MazeTurn <= "000";
				if (data_ready = '1') then
					new_loc2(7 downto 0) <= data_in;
					new_state <= OrientCalc;
				end if;

			when OrientCalc =>
				MazeTurn <= "000";
				if (unsigned(new_loc1) = to_unsigned(0,24)) then
					if (new_loc2(7 downto 0) = "00110000") then
						new_orient2 <= "001"; --east
					elsif (new_loc2(7 downto 0) = "00110100") then
						new_orient2 <= "110"; --west
					elsif (new_loc2(15 downto 8) = "00110000") then
						new_orient2 <= "010"; --south	
					else
						new_orient2 <= "101"; --north
					end if;
				else	
					if (new_loc2(7 downto 0) > new_loc1(7 downto 0)) then
						new_orient2 <= "001";
					elsif (new_loc2(7 downto 0) < new_loc1(7 downto 0)) then
						new_orient2 <= "110";
					elsif (new_loc2(15 downto 8) > new_loc1(15 downto 8)) then
						new_orient2 <= "010";
					else
						new_orient2 <= "101";	
					end if;
				end if;
				new_state <= TurnCalc;

			when TurnCalc =>
				MazeTurn <= "000";
				if (new_orient1 = "000") then
					MazeHold <= "000";
					new_state <= QuickBack;
				elsif (new_orient1 = new_orient2) then
					MazeHold <= "010"; --staight
				else 
					if (new_orient1 = "001") then --east
						if (new_orient2 = "010") then --south
							MazeHold <= "001"; --right
						else --north
							MazeHold <= "100"; --left
						end if;
					elsif (new_orient1 = "110") then --west
						if (new_orient2 = "010") then --south
							MazeHold<= "100"; --left
						else --north
							MazeHold <= "001"; --right
						end if;
					elsif (new_orient1 = "010") then --south
						if (new_orient2 = "001") then --east
							MazeHold <= "100"; --left
						else --west
							MazeHold<= "001"; --right
						end if;
					else --north
						if (new_orient2 = "001") then --east
							MazeHold <= "001"; --right
						else --west
							MazeHold <= "100"; --left
						end if;
					end if;
				end if;
				if (MazePoint = '1') then
					new_state <= WaitState3;
				end if;

			when QuickBack =>
				MazeTurn <= MazeHold;
				new_loc1 <= new_loc2;
				new_orient1 <= new_orient2;
				new_state <= Data1;

			when WaitState3 =>
				MazeTurn <= MazeHold;
				if (MazePoint = '0') then --or (new_orient1 = "000") then
					new_loc1 <= new_loc2;
					new_orient1 <= new_orient2;
					new_state <= Data1;
				end if;
		end case;
	end process;
end Architecture behavioural;