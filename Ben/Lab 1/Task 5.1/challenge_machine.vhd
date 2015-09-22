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

   -- These two signals are used in the clock divider (see below).
   -- slow_clock is the output of the clock divider, and count50 is
   -- an internal signal used within the clock divider.
	
   signal clock_state, next_state, clock_1, count_reset: std_logic;
   signal count50 : unsigned(29 downto 0) := (others => '0');
	signal countTest, countTop : unsigned(8 downto 0);

   -- Note: the above syntax (others=>'0') is a short cut for initializing
   -- all bits in this 26 bit wide bus to 0. 

begin

    -- This is the clock divider process.  It converts a 50Mhz clock to a much
    -- slower clock (you can work out the period, but it is on the order of seconds).
    -- We haven't really talked about this in
    -- class yet, but you should be able to figure out how it works.  It counts 
    -- by 1, and uses the most significant bit of the count as the output (slow) clock.
    -- As a good exercise: what would you do if you wanted to slow down the speed of
    -- the output clock by half?  

    PROCESS (CLOCK_50)	
    BEGIN
		if rising_edge (CLOCK_50) THEN
			if (count_reset = '0') then
            count50 <= count50 + 1;
			else
				count50 <= to_unsigned(0, count50'length);
			end if;
			clock_state <= next_state;
      end if;
    END process;
	 
	 -- Generate a clock pulse by comparing the switch inputs with
	 -- the current count50 value. Every time the count50 exceeds
	 -- the input number, reset count50 and invert clock_1.
	 -- The input number is biased (one of the middle bits is set to 1)
	 -- to provide a minimum number (and thus minimum duration) for the
	 -- clock pulse. The user tunes the duration by pushing switches.
	 process(clock_state, next_state, count50, countTest, countTop)
	 begin
		case (clock_state) is
			when '0' =>
				if (countTop >= countTest) then
					next_state <= '1';
					count_reset <= '1';
				else
					next_state <= '0';
					count_reset <= '0';
				end if;
			when '1' =>
				if (countTop >= countTest) then
					next_state <= '0';
					count_reset <= '1';
				else
					next_state <= '1';
					count_reset <= '0';
				end if;
			when others =>
				next_state <= '0';
				count_reset <= '0';
			end case;
	 end process;
	 
	 -- A number to count to.
	 countTest <= unsigned(SW(17 downto 13) & '1' & SW(12 downto 10));
	 -- The high order bits of the counter.
	 countTop <= count50(27 downto 19);
	 
	 -- Communication.
	 LEDR(0) <= SW(0);
	 LEDR(9 downto 1) <= std_logic_vector(countTop);
	 LEDR(17 downto 10) <= "11111111" and not SW(17 downto 10);
	 LEDG(0) <= clock_1;
	 LEDG(2) <= count_reset;
	 
	 -- Generate next clock pulse.
	 process(clock_state)
	 begin
		case (clock_state) is
			when '0' => clock_1 <= '0';
			when '1' => clock_1 <= '1';
			when others => clock_1 <= '0';
		end case;
	 end process;

    -- instantiate the state machine component, which is defined in 
    -- state_machine.vhd (which you will write).    

    letter_machine_1: state_machine port map(clock_1, KEY(0), SW(0), HEX0);
end structural;
