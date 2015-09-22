--------------------------------------------------------
--
--  This is the top-level file for Lab 1 Phase 3.  This
--  file provides a connection between the switch and light
--  pins and the pins of the lower-level module.  This file
--  also contains a clock divider that steps down a 50Mhz
--  clock.
--  
--  You can use this file directly.  There is nothing you have
--  to add to this file for Phase 3.
--
--------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------
--
--  This is the entity part of the top level file for Phase 3.
--  The inputs are named to match the names of specific I/O
--  pins as described in the pin assignments file. 
--  
----------------------------------------------------------

entity challenge_machine is
   port (KEY: in std_logic_vector(3 downto 0);  -- push-button switches
         SW : in std_logic_vector(17 downto 0);  -- slider switches
         CLOCK_50: in std_logic;                 -- 50MHz clock input
			CLOCK_27: in std_logic;                 -- 27MHz clock input
			LEDR : out std_logic_vector(17 downto 0); -- red leds
			LEDG : out std_logic_vector(8 downto 0); -- green leds
			HEX0 : out std_logic_vector(6 downto 0); -- output to drive digit 0
			HEX1 : out std_logic_vector(6 downto 0) -- output to drive digit 1
   );     
end challenge_machine;

------------------------------------------------------------
--
-- This is the architecture part of the top level file for Phase 3.
-- This file includes your lower level state machine, and wires up the
-- input and output pins to your state machine.
--
-------------------------------------------------------------

architecture structural of challenge_machine is

   -- declare the state machine component (think of this as a header
   -- specification in C).  This has to match the entity part of your
   -- state machine entity (from state_machine.vhd) exactly.  If you
   -- add pins to state_machine, they need to be reflected here

   component state_machine
      port (clk : in std_logic;   -- clock input
         resetb : in std_logic;   -- active-low reset input
         dir : in std_logic;      -- dir switch value
         hex_out : out std_logic_vector(6 downto 0)  -- drive digit 0
      );
   end component;
	
	-- The divided clock for the state machine.
   signal clock_1, clock_2 : std_logic;
	-- Count the number of clock pulses since last reset.
   signal count50, count50_2 : unsigned(29 downto 0) := (others => '0');
	-- countTest: a number to count to
	-- countTop: high order bits of count50
	signal countTest, countTest_2, countTop, countTop_2 : unsigned(8 downto 0);

begin

	-- Generate a clock pulse by comparing the switch inputs with
	 -- the current count50 value. Every time the count50 exceeds
	 -- the input number, reset count50 and invert clock_1.
	 -- The input number is biased (one of the middle bits is set to 1)
	 -- to provide a minimum number (and thus minimum duration) for the
	 -- clock pulse. The user tunes the duration by pushing switches.
	 -- The same logic is applied to generate the second clock, clock_2.
    PROCESS (CLOCK_50)	
    BEGIN
		if rising_edge (CLOCK_50) then
			if (countTop >= countTest) then
				clock_1 <= not clock_1;
				count50 <= to_unsigned(0, count50'length);
			else
				count50 <= count50 + 1;
			end if;
			
			if (countTop_2 >= countTest_2) then
				clock_2 <= not clock_2;
				count50_2 <= to_unsigned(0, count50_2'length);
			else
				count50_2 <= count50_2 + 1;
			end if;
      end if;
    END process;
	 
	 -- A number to count to.
	 countTest <= unsigned(SW(17 downto 13) & '1' & SW(12 downto 10));
	 -- The high order bits of the counter.
	 countTop <= count50(27 downto 19);
	 
	 -- A number to count to.
	 countTest_2 <= unsigned(SW(9 downto 5) & '1' & SW(4 downto 2));
	 -- The high order bits of the counter.
	 countTop_2 <= count50_2(27 downto 19);
	 
	 -- Communication.
	 LEDR(1 downto 0) <= SW(1 downto 0);
	 LEDR(9 downto 2) <= "11111111" and not SW(9 downto 2);
	 LEDR(17 downto 10) <= "11111111" and not SW(17 downto 10);
	 LEDG(0) <= clock_1;
	 LEDG(1) <= clock_2;

    -- instantiate the state machine component   
    letter_machine_1: state_machine port map(clock_1, KEY(0), SW(0), HEX0);
	 letter_machine_2: state_machine port map(clock_2, KEY(1), SW(1), HEX1);
end structural;
