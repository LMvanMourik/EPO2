LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY reg IS
PORT
(
        reg_clk:        IN std_logic;                           -- clock
        reg_d:          IN std_logic_vector (7 DOWNTO 0);       -- data in
        reg_q:          OUT std_logic_vector (7 DOWNTO 0)       -- data out
);
END reg;

ARCHITECTURE reg_arch OF reg IS
BEGIN
        PROCESS (reg_clk)
        BEGIN
                IF (reg_clk'event AND reg_clk = '1') THEN
                        reg_q <= reg_d;
                END IF;
        END PROCESS;
END reg_arch;









COMPONENT reg
PORT
(
        reg_clk:        IN std_logic;                           -- clock
        reg_d:          IN std_logic_vector (7 DOWNTO 0);       -- data in
        reg_q:          OUT std_logic_vector (7 DOWNTO 0)       -- data out
);
END COMPONENT;



lbl_reg:     	reg     PORT MAP (
                                reg_clk => clk,
                                reg_d => reg_in,
                                reg_q => reg_out);

y <= reg_out;
