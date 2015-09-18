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

entity phase4 is
   port (KEY: in std_logic_vector(3 downto 0);  -- push-button switches
         SW : in std_logic_vector(17 downto 0);  -- slider switches
         CLOCK_50: in std_logic;    -- 50MHz clock input
         CLOCK_27: in std_logic;    -- 27MHz clock input       
	 HEX0 : out std_logic_vector(6 downto 0); -- output to drive digit 0
	 HEX1 : out std_logic_vector(6 downto 0);
	 LEDG : out std_logic_vector(7 downto 0); -- output to know which state clock_50 is in
	 LEDR : out std_logic_vector(7 downto 0)  -- output to know which state clock_27 is in
   );     
end phase4;

------------------------------------------------------------
--
-- This is the architecture part of the top level file for Phase 3.
-- This file includes your lower level state machine, and wires up the
-- input and output pins to your state machine.
--
-------------------------------------------------------------

architecture structural of phase4 is

   -- declare the state machine component (think of this as a header
   -- specification in C).  This has to match the entity part of your
   -- state machine entity (from state_machine.vhd) exactly.  If you
   -- add pins to state_machine, they need to be reflected here

   component state_machine
      port (clk : in std_logic;   -- clock input
         resetb : in std_logic;   -- active-low reset input
         dir : in std_logic;      -- dir switch value
         hex0 : out std_logic_vector(6 downto 0);  -- drive digit 0
			ledg : out std_logic_vector(7 downto 0)
      );
   end component;
   
   component state_machine_slow
     port (clk : in std_logic;
       resetb : in std_logic;
       dir : in std_logic; -- use sw1
       hex1 : out std_logic_vector(6 downto 0); -- drive digit 1
       ledr : out std_logic_vector(7 downto 0)
     );
   end component;

   -- These two signals are used in the clock divider (see below).
   -- slow_clock is the output of the clock divider, and count50 is
   -- an internal signal used within the clock divider.
	
   signal slow_clock : std_logic; -- 50 MHz
   signal slower_clock : std_logic; -- 27 MHz
   
   signal count50 : unsigned(25 downto 0) := (others => '0');
   signal count502 : unsigned(25 downto 0) := (others => '0');

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
            count50 <= count50 + 1;
        end if;
    END process;
    
    PROCESS (CLOCK_27) -- counter for slower clk
      begin
        if rising_edge (CLOCK_27) then
          count502 <= count502 + 1;
        end if;
      END process;
      
    slower_clock <= count502(25); -- output for slower clock (27MHz)
    slow_clock <= count50(25);   -- the output is the MSB of the counter

    -- instantiate the state machine component, which is defined in 
    -- state_machine.vhd (which you will write).    

    u0: state_machine port map(slow_clock,  -- the clock input to the state machine
                                            -- is the slow clock
                               KEY(0),  -- the reset input to the state machine is
                                        -- pushbutton # 0
                               SW(0),   -- the dir input to the state machine is
                                        -- slider switch # 0,
                               HEX0,	-- the output of the state machine is connected
                                        -- to hex digit 0
										 LEDG); -- green leds used for finding current_state
										 
	  u1: state_machine_slow port map(slower_clock, KEY(1), SW(1), HEX1, LEDR);
	    
end structural;

