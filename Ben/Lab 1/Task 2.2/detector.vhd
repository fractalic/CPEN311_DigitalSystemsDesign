---------------------------------------------------------
--
--  This is a sample bare-bones state machine.  It should
--  be read in conjunction with the Lab 1 handout.  
--
---------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

------------------------------------------------------------
-- Entity part of the declaration.  Declare the input/output
-- signals of the entity
------------------------------------------------------------

entity detector is
   port (insig,           -- input data bit     
         reset,           -- an active high reset signal
         clk : std_logic; -- clock signal
         alert : out std_logic -- indicates when pattern has been detected
         );  
end detector;

------------------------------------------------------------
-- Architecture part.  Describe behaviour of state machine.
------------------------------------------------------------

architecture behavioural of detector is

-- Declare two internal signals. The first one represents the
-- next_state (the output of the Next State Logic block, and the
-- second represents the current_state (the output of the flip-flops
-- that hold the state

signal next_state, current_state : std_logic_vector(1 downto 0);	
begin

   -- The following describes the behaviour of the next state logic block.
   -- This is a combinational block with inputs current_state and insig,
   -- and output next_state.  Given the current state and the input bit
   -- this block computes the next state of the state machine.

   -- Note that this block is using VHDL 2008 (the “all” statement is part
   -- of VHDL 2008).  If you are using a VHDL compiler that is older, you
   -- will need to replace “all” with a list of signals that are inputs
   -- to the block.  In Quartus II and Modelsim, there are options to turn on
   -- parsing of VHDL 2008.

   process (all)
   begin

      -- Depending on the current state and the insig, compute the next state
      -- Read this code in conjunction with the state diagram in the lab 1 handout.
      -- Note that we are doing a bad thing here.  In EECE 259, you talked about how
      -- to define constants to represent state encoding.  This would have been
      -- better programming practice.  I’ve only done it this way here to help
      -- more clearly demonstate the physical meaning of these signals.

      case current_state is
         when "00" =>
            if (insig = '0') then
               next_state <= "00";
            else 
               next_state <= "01";
            end if;
         when "01" =>
            if (insig = '0') then
               next_state <= "00";
            else 
               next_state <= "10";
            end if;			
         when "10" =>
            if (insig = '0') then
               next_state <= "11";
            else 
               next_state <= "10";
            end if;
         when "11" => next_state <= "11";		 
         when others => next_state <= "00";
      end case;

      -- if the reset signal is high, then the next state is 00 regardless
      -- of the other inputs.

      if (reset = '1') then  
          next_state <= "00";
      end if;
   end process;

   -- This process is another combinational block.  It computes the value of
   -- the alert output based on the current state.  It is written using an “if”
   -- construct; a more complex block might be written using a case statement as in
   -- the previous process.  Note again this is written using VHDL 2008 features.
	
   process(all) 
   begin
         if (current_state = "11") then
            alert <= '1';
         else 
            alert <= '0';
         end if;
   end process;
	
   -- The following process describes the behaviour of the two bit state machine.
   -- This is a sequential process; the current state is updated only on the rising 
   -- edge of the clock.  Note that clk is in the sensitivity list (this is different
   -- than the combinational blocks described above).  

   process(clk)
   begin 
      if rising_edge(clk) then 
         current_state <= next_state;
      end if;
   end process;
	
end behavioural;
