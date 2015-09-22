library ieee;
use ieee.std_logic_1164.all;

---------------------------------------------------------------------
--
-- This is a test bench used to test your state machine in Modelsim.
-- This is not part of the state machine design, it is only used to
-- drive inputs and outputs during testing in Modelsim.  You would 
-- not try to compile this using Quartus II.
--
-- This is the most bare-bones testbench I could think of.  You can
-- enhance this significantly to increase the quality of your tests.
--
---------------------------------------------------------------------


-- A test bench has no inputs or outputs 

entity state_machine_tb is
  -- no inputs or outputs
end entity;


-- The architecture part decribes the behaviour of the test bench

architecture rtl of state_machine_tb is

   -- declare the state machine component (think of this as a header
   -- specification in C).  This has to match the entity part of your
   -- state machine entity (from state_machine.vhd) exactly.  If you
   -- add pins to state_machine, they need to be reflected here

   component state_machine
      port (clk : in std_logic;
            resetb : in std_logic;
            dir : in std_logic;
            hex_out : out std_logic_vector(6 downto 0)
      );
   end component;

   -- local signals for your testbench 

   signal dir_local : std_logic := '0';
   signal resetb_local : std_logic := '0';	
   signal clk_local : std_logic := '1';		
   signal hex0_local : std_logic_vector(6 downto 0);
	
begin

	-- instantiate the design-under-test

        dut : state_machine port map(clk_local, resetb_local, dir_local, hex0_local);

        -- Drive the clock pin.  This creates a square waveform with 
        -- period 2 ns.  Note that this is *not* synthesizable; it doesn't
        -- describe real hardware.  It only describes a pattern to apply to 
        -- the clock input during simulation in Modelsim

        clk_local <= not clk_local after 1 ns;

        -- Resetb starts out at 0 (to reset the state machine), and then goes to 1 at 1ns

        resetb_local <= '0', '1' after 1 ns;

        -- Create a pattern for the dir input. You can play with this if you want
        -- to better test your design
  
        dir_local <= '1', '0' after 15 ns, '1' after 21 ns;

        -- Note that it is also possible for your testbench to monitor the output of
        -- your state machine and detect any errors.  We don't do that here.  In this
        -- lab, you will just look at the waveform in Modelsim to make sure it 
        -- looks correct.  We'll talk more about testbenches later in the course.

end rtl;
