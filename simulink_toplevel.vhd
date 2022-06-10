-- *****************************************************************************
-- Name:     simulink_toplevel.vhd   
-- Project:  EE1L21 EPO-2 Smart Robot Challenge
-- Created:  04.10.20, 15.04.21
-- Author:   Bas Verdoes
-- Purpose:  SIMULINK_TOPLEVEL functions as an encapsulating entity that enables
--           feasible simulator integration with Simulink. It does this by
--           computing the robot's position/trajectory from the PWM-generator's
--           PWM signals.
-- *****************************************************************************

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity simulink_toplevel is
generic(
    CLK_SCALE : INTEGER := 5000 -- Lower clock frequency by scale factor
    );
port(
    -- Robot Interface
    CLK              : in  STD_LOGIC;
    NRST             : in  STD_LOGIC;
    SENSOR_IR_DATA   : in  STD_LOGIC_VECTOR(2 downto 0); -- ROS-sensor input (L - M - R)
    SENSOR_MINE_PROX : in  REAL;
    POS_X            : out REAL; -- Rover position (X-axis)
    POS_Y            : out REAL; -- Rover position (Y-axis)
    POS_PHI          : out REAL  -- Rover angle
    );
end simulink_toplevel;

architecture mixed of simulink_toplevel is

-- *****************************************************************************
-- SIGNAL DECLARATIONS
-- *****************************************************************************
-- GLOBAL
signal reset : STD_LOGIC; -- positive reset

-- ROBOT POSITION CALCULATION
signal pwm_r, pwm_l : STD_LOGIC;   -- servo pwm signals
signal v_r, v_l     : REAL := 0.0; -- velocity of right/left wheel
signal cycle_trigger_r, cycle_trigger_l : STD_LOGIC := '0';
signal cycle_ender_r  , cycle_ender_l   : STD_LOGIC := '0';

-- MINE SENSOR
signal mine_sensor_osc : STD_LOGIC := '0';
signal mine_sensor_tf  : STD_LOGIC := '0';

-- SIGNAL CONVERSION BETWEEN UART AND SIMULINK INTERFACE
signal uartif_tx_data      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal uartif_tx_serialin  : STD_LOGIC := '1';
signal uartif_tx_newdata   : STD_LOGIC := '0';
signal uartif_tx_received  : STD_LOGIC := '0';

signal uartif_rx_data      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
signal uartif_rx_serialout : STD_LOGIC := '1';
signal uartif_rx_newdata   : STD_LOGIC := '0';
signal uartif_rx_received  : STD_LOGIC := '0';

-- *****************************************************************************
-- SURROGATE FOR MATH_REAL LIBRARY
-- *****************************************************************************
constant CONST_PI : REAL := 3.14159_26535_89793_23846;
type REAL_VECTOR is array (NATURAL range <>) of REAL;

-- SINE FUNCTION
function sin (x : REAL) return REAL is
  constant SIN_TAYLOR_COEF : REAL_VECTOR(0 to 5) := (1.0,
  -0.16666_66666_66667, 0.00833_33333_33333, -0.00019_84126_98412_6984,
  0.00000_27557_31922_398589, -0.00000_00250_52108_385442);
  variable x_pow_i    : REAL;
  variable sin_taylor : REAL := 0.0;
begin
  -- x^i = x^1
  x_pow_i := x;
  -- Taylor series
  for i in 0 to 5 loop
    sin_taylor := sin_taylor + SIN_TAYLOR_COEF(i) * x_pow_i;
    x_pow_i := x_pow_i * x * x;
  end loop;
  return sin_taylor;
end sin;

-- COSINE FUNCTION
function cos (x : REAL) return REAL is
  constant COS_TAYLOR_COEF : REAL_VECTOR(0 to 5) := (1.0,
  -0.50000_00000_00000, 0.04166_666666_66667, -0.00138_88888_88889, 
  0.00002_48015_87301_58730, -0.00000_02755_73192_23986);
  variable x_pow_i    : REAL;
  variable cos_taylor : REAL := 0.0;
begin
  -- x^i = x^0
  x_pow_i := 1.0;
  -- Taylor series
  for i in 0 to 5 loop
    cos_taylor := cos_taylor + COS_TAYLOR_COEF(i) * x_pow_i;
    x_pow_i := x_pow_i * x * x;
  end loop;
  return cos_taylor;
end cos;

begin

reset <= not(NRST);

-- *****************************************************************************
-- DESIGN UNDER TEST
-- *****************************************************************************

-- Include your top-level here

DUT:
entity work.robot
    generic map(
        CLK_SCALE => CLK_SCALE
    )
	port map(
        clk			 => CLK,
		reset 	=> reset,
		sensor_l_in  => SENSOR_IR_DATA(2),
		sensor_m_in  => SENSOR_IR_DATA(1),
		sensor_r_in  => SENSOR_IR_DATA(0),
		motor_l_pwm  => pwm_l,
		motor_r_pwm  => pwm_r
	);

-- *****************************************************************************
-- COMPUTE ROVER POSITION (DO NOT ALTER!)
-- *****************************************************************************

-- Compute Rover velocity
VEL:  process(pwm_r, pwm_l, NRST, cycle_trigger_r, cycle_trigger_l, cycle_ender_r, cycle_ender_l)
        constant MAX_SPEED : REAL := 0.15; -- m/s
        
        variable tstamp_r, tstamp_l : REAL := 0.0;
        variable pwidth_r, pwidth_l : REAL := 0.0;
        variable veloci_r, veloci_l : REAL := 0.0;
      begin
      
      if(NRST = '1') then
        -- Compute pulse-width + Set timer to start 20ms cycle
        if(rising_edge(pwm_r)) then
          tstamp_r        := real(now/1 ns);
          cycle_trigger_r <= '1' after 20 ms - 10 ns;
        end if;
        -- Compute velocity information from last PWM pulse
        if(falling_edge(pwm_r)) then
          pwidth_r := ((real(now/1 ns) - tstamp_r) / 1.0e6);
          -- NOTE: The left and right wheel are driven by the same type of servo.
          -- Whereas 20% duty-cycle makes the left wheel turn forward, it makes the right wheel turn backward.
          -- Hence, there is a minus sign in the equation below.
          veloci_r := -1.0 * (pwidth_r - 1.5) * 2.0 * MAX_SPEED;
          if(veloci_r > MAX_SPEED) then
            veloci_r := MAX_SPEED;
          end if;
          if(veloci_r < -1.0 * MAX_SPEED) then
            veloci_r := -1.0 * MAX_SPEED;
          end if;
        end if;
        
        -- Apply PWM data for 20ms
        if(cycle_trigger_r = '1') then
          cycle_trigger_r <= '0';
          cycle_ender_r   <= '1' after 20 ms - 10 ns;
          v_r <= veloci_r;
        end if;
        if(cycle_ender_r = '1') then
          cycle_ender_r <= '0';
          v_r <= 0.0;
        end if;
        
        -- Compute pulse-width + Set timer to start 20ms cycle
        if(rising_edge(pwm_l)) then
          tstamp_l        := real(now/1 ns);
          cycle_trigger_l <= '1' after 20 ms - 10 ns;
        end if;
        -- Compute velocity information from last PWM pulse
        if(falling_edge(pwm_l)) then
          pwidth_l := ((real(now/1 ns) - tstamp_l) / 1.0e6);
          veloci_l := (pwidth_l - 1.5) * 2.0 * MAX_SPEED;
          if(veloci_l > MAX_SPEED) then
            veloci_l := MAX_SPEED;
          end if;
          if(veloci_l < -1.0 * MAX_SPEED) then
            veloci_l := -1.0 * MAX_SPEED;
          end if;
        end if;
        
        -- Apply PWM data for 20ms
        if(cycle_trigger_l = '1') then
          cycle_trigger_l <= '0';
          cycle_ender_l   <= '1' after 20 ms - 10 ns;
          v_l <= veloci_l;
        end if;
        if(cycle_ender_l = '1') then
          cycle_ender_l <= '0';
          v_l <= 0.0;
        end if;
        
      else
        -- Reset state
        veloci_r := 0.0;
        veloci_l := 0.0;
        v_r <= 0.0;
        v_l <= 0.0;
      end if;

      end process;

-- Compute Rover trajectory
DIV:  process(CLK, NRST)
        -- Sample Rover position every div_clk clock cycles
        constant div_clk : INTEGER := 10;
        variable div_cnt : INTEGER := 0;
        
        -- Rover positional data
        constant ROVER_WIDTH : REAL := 0.20; -- m
        variable rover_x : REAL := 0.0;
        variable rover_y : REAL := 0.0;
        variable dT : REAL := real(CLK_SCALE) * real(div_clk) / 100.0e6;
        variable phi: REAL := 0.0;
      begin
      
      -- Sample clock divider
      if(rising_edge(CLK)) then
        if(div_cnt > div_clk - 1) then
          div_cnt := 0;
        else
          div_cnt := div_cnt + 1;
        end if;
      end if;
      
      -- Update rover position
      if(NRST = '1') then
        if(rising_edge(CLK) and div_cnt = 0) then
          -- Ensure phi lies between -pi and pi
          if(phi > CONST_PI) then
            phi := phi - 2.0*CONST_PI;
          end if;
          if(phi < -1.0*CONST_PI) then
            phi := phi + 2.0*CONST_PI;
          end if;
          
          if(v_r = v_l) then
            -- Drive straight ahead
            rover_x := rover_x + v_r * cos(phi) * dT;
            rover_y := rover_y + v_r * sin(phi) * dT;
          else
            -- Drive in a turn
            rover_x := rover_x + ROVER_WIDTH/2.0 * (v_r+v_l)/(v_r-v_l) * (sin((v_r-v_l)*dT/ROVER_WIDTH + phi) - sin(phi));
            rover_y := rover_y - ROVER_WIDTH/2.0 * (v_r+v_l)/(v_r-v_l) * (cos((v_r-v_l)*dT/ROVER_WIDTH + phi) - cos(phi));
          end if;
          phi     := phi + (v_r-v_l)*dT/ROVER_WIDTH;
          POS_X   <= rover_x;
          POS_Y   <= rover_y;
          POS_PHI <= phi;
        end if;
      else
        -- Reset state
        rover_x := 0.0;
        rover_y := 0.0;
        phi     := 0.0;
        POS_X   <= 0.0;
        POS_Y   <= 0.0;
        POS_PHI <= 0.0;
      end if;
      
      end process;

-- *****************************************************************************
-- GENERATE MINESENSOR OSCILLATION INPUT SIGNAL (DO NOT ALTER!)
-- *****************************************************************************

MINE_TF_GEN:
process(SENSOR_MINE_PROX)
begin

if(SENSOR_MINE_PROX = 1.0) then
    mine_sensor_tf <= '1';
else
    mine_sensor_tf <= '0';
end if;

end process;

MINE_OSCILLATOR_GEN:
process
    variable osc_suppress_first_run : STD_LOGIC := '1';

    variable osc_freq_nomine : REAL := 100.0; -- Hz
    variable osc_freq_mine   : REAL :=  95.0;
    variable sensor_mine_prox_sample: REAL;
    variable mine_osc_period : TIME;
begin

-- Don't listen to garbage SENSOR_MINE_PROX data for the first 51ms
if(osc_suppress_first_run = '1') then
    osc_suppress_first_run := '0';
    wait for 51 ms;
-- Generate a frequency based on the proximity of the robot to a mine
else
    mine_sensor_osc <= not(mine_sensor_osc);
    if(SENSOR_MINE_PROX > 1.0 or SENSOR_MINE_PROX < 0.0) then
        sensor_mine_prox_sample := 0.0;
    else
        sensor_mine_prox_sample := SENSOR_MINE_PROX;
    end if;
    mine_osc_period := INTEGER(1.0e9/(osc_freq_mine + (1.0-sensor_mine_prox_sample)*(osc_freq_nomine-osc_freq_mine))) * 1 ns;
    wait for mine_osc_period/2;
end if;

end process;

end mixed;
