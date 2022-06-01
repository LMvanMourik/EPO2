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
	type LocTrackState is (Data1,Data2,Data3, OrientCalc, TurnCalc, WaitState1,WaitState2,WaitState3);
	signal state, new_state: LocTrackState;
	signal new_loc, loc: std_logic_vector (15 downto 0);
	signal new_orient, orient, MazeHold: std_logic_vector (2 downto 0);

begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset='1') then
				state <= Data1;
				loc <= (others => '0');
				orient <= (others => '0');
			else	
				state <= new_state;
				--loc <= new_loc;
				--orient <= new_orient;
					
			end if;
		end if;
	end process;

	process(loc, data_ready, data_in)
	begin
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
					new_loc(15 downto 8) <= data_in;
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
					new_loc(7 downto 0) <= data_in;
					new_state <= OrientCalc;
				end if;

			when OrientCalc =>
				MazeTurn <= "000";
				if (unsigned(loc) = to_unsigned(0,24)) then
					if (new_loc(7 downto 0) = "00110000") then
						new_orient <= "001"; --east
					elsif (new_loc(7 downto 0) = "00110100") then
						new_orient <= "110"; --west
					elsif (new_loc(15 downto 8) = "00110000") then
						new_orient <= "010"; --south	
					else
						new_orient <= "101"; --north
					end if;
				else	
					if (new_loc(7 downto 0) > loc(7 downto 0)) then
						new_orient <= "001";
					elsif (new_loc(7 downto 0) < loc(7 downto 0)) then
						new_orient <= "110";
					elsif (new_loc(15 downto 8) > loc(15 downto 8)) then
						new_orient <= "010";
					else
						new_orient <= "101";	
					end if;
				end if;
				new_state <= TurnCalc;

			when TurnCalc =>
				MazeTurn <= "000";
				if (orient = "000") or (orient = new_orient) then
					MazeHold <= "010"; --staight
				else 
					if (orient = "001") then --east
						if (new_orient = "010") then --south
							MazeHold <= "001"; --right
						else --north
							MazeHold <= "100"; --left
						end if;
					elsif (orient = "110") then --west
						if (new_orient = "010") then --south
							MazeHold<= "100"; --left
						else --north
							MazeHold <= "001"; --right
						end if;
					elsif (orient = "010") then --south
						if (new_orient = "001") then --east
							MazeHold <= "100"; --left
						else --west
							MazeHold<= "001"; --right
						end if;
					else --north
						if (new_orient = "001") then --east
							MazeHold <= "001"; --right
						else --west
							MazeHold <= "100"; --left
						end if;
					end if;
				end if;
				if (MazePoint = '1') then
					new_state <= WaitState3;
				end if;

			when WaitState3 =>
				MazeTurn <= MazeHold;
				if (MazePoint = '0') then
					loc <= new_loc;
					orient <= new_orient;
					new_state <= Data1;
				end if;
		end case;
	end process;
end Architecture behavioural;