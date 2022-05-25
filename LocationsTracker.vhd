library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity LocationsTracker is
	port(	clk:	in std_logic;
		reset:	in std_logic;
		read:	out std_logic;
		data_in:	in std_logic_vector (7 downto 0); --out from uatr
		data_ready:	in std_logic;
		MazePoint:	in std_logic;
		MazeTurn:	out std_logic_vector (2 downto 0)
	);
end entity LocationsTracker;

Architecture behavioural of LocationsTracker is
	type LocTrackState is (DataCollect, TurnCalc);
	signal state, new_state: LocTrackState;
	signal loc, new_loc, old_loc: std_logic_vector (23 downto 0);
	signal data1, data2, data3: std_logic_vector (7 downto 0);
	signal orient, new_orient, old_orient, Diection: std_logic_vector (2 downto 0);

begin
	process(clk)
	begin
		if (rising_edge(clk)) then
			if (reset='1') then
				state <= DataCollect;
				loc <= (others => '0');
				orient <= (others => '0');
			else	
				state <= new_state;
				loc <= new_loc;
				orient <= new_orient;
					
			end if;
		end if;
	end process;

	process(loc, data_ready, data_in)
	begin
		case state is
			when DataCollect =>
				read <= '1' ;
				MazeTurn <= "000";
				if (data_ready = '1') then
					data1 <= data_in;
						if (data_ready = '0') then
							if(data_ready = '1') then
								data2 <= data_in;
									if (data_ready = '0') then
										if(data_ready = '1') then
											data3 <= data_in;
										end if;
									end if;
							end if;
						end if;
				end if;
				old_loc <= loc;
				new_loc <= data1 & data2 & data3;
				new_state <=  TurnCalc;
		
			when TurnCalc =>
				read <= '0';
				old_orient <= orient;
				if (MazePoint = '1') then
					if (unsigned(old_loc) = to_unsigned(0,24)) then
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
						if (new_loc(7 downto 0) > old_loc(7 downto 0)) then
							new_orient <= "001";
						elsif (new_loc(7 downto 0) < old_loc(7 downto 0)) then
							new_orient <= "110";
						elsif (new_loc(15 downto 8) > old_loc(15 downto 8)) then
							new_orient <= "010";
						else
							new_orient <= "101";	
						end if;
					end if;

					if (old_orient = "000") or (old_orient = new_orient) then
						MazeTurn <= "010"; --staight
					else 
						if (old_orient = "001") then --east
							if (new_orient = "010") then --south
								MazeTurn <= "001"; --right
							else --north
								MazeTurn <= "100"; --left
							end if;
						elsif (old_orient = "110") then --west
							if (new_orient = "010") then --south
								MazeTurn <= "100"; --left
							else --north
								MazeTurn <= "001"; --right
							end if;
						elsif (old_orient = "010") then --south
							if (new_orient = "001") then --east
								MazeTurn <= "100"; --left
							else --west
								MazeTurn <= "001"; --right
							end if;
						else --north
							if (new_orient = "001") then --east
								MazeTurn <= "001"; --right
							else --west
								MazeTurn <= "100"; --left
							end if;
						end if;
					end if;
				end if;
				if (MazePoint = '0') then
					new_state <= DataCollect;
				end if;
		end case;
	end process;
end Architecture behavioural;