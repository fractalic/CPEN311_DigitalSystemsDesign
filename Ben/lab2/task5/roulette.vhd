LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
LIBRARY WORK;
USE WORK.ALL;


---
-- A Roulette game for the DE2 board. Three bets are allowed on each round
-- (one straight up, one colour, and one dozen). Money is paid out according
-- to the European odds.
-- requires: CLOCK_27 is wired to a fast clock running continuously.
-- effects: HEX6 and HEX7 are wired to a two digit hexadecimal number representing
--          the value of the last spin.
--          HEX0 through HEX2 are wired to a three digit hexadecimal number
--          representing the player's current total money.
--          LEDG(0) is high if player wins on bet1.
--          LEDG(1) is high if player wins on bet2.
--          LEDG(2) is high if player wins on bet3.
--          
entity roulette is
	port(   CLOCK_27 : in STD_LOGIC; -- the fast clock for spinning wheel
		KEY : in STD_LOGIC_VECTOR(3 downto 0);  -- includes slow_clock and reset
		SW : in STD_LOGIC_VECTOR(17 downto 0);
		LEDG : out STD_LOGIC_VECTOR(3 DOWNTO 0);  -- ledg
		HEX7 : out STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 7
		HEX6 : out STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 6
		HEX5 : out STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 5
		HEX4 : out STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 4
		HEX3 : out STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 3
		HEX2 : out STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 2
		HEX1 : out STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 1
		HEX0 : out STD_LOGIC_VECTOR(6 DOWNTO 0)   -- digit 0
	);
end roulette;


architecture structural of roulette is

component new_balance is
    port(
        money     : in unsigned (11 downto 0);
        value1    : in unsigned (2 downto 0);
        value2    : in unsigned (2 downto 0);
        value3    : in unsigned (2 downto 0);
        bet1_wins : in std_logic;
        bet2_wins : in std_logic;
        bet3_wins : in std_logic;
        new_money : out unsigned (11 downto 0)
    );
end component;

component digit7seg is
    port(
          hex_digit     : in  unsigned(3 downto 0);
          seg7_pattern  : out std_logic_vector(6 downto 0)
    );
end component;

component win is
    port(
        spin_result_latched : in unsigned(5 downto 0);
        bet1_value          : in unsigned(5 downto 0);
        bet2_colour         : in std_logic;
        bet3_dozen          : in unsigned(1 downto 0);
        bet1_wins           : out std_logic;
        bet2_wins           : out std_logic;
        bet3_wins           : out std_logic
    );
end component;

component spinwheel is
    port(
        fast_clock   : in  std_logic;
        resetb       : in  std_logic; -- asynchronous
        spin_result  : out unsigned(5 downto 0)
    );
end component;

begin

-- TODO: connect everything together

end;
