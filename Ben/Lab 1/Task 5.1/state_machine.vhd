--------------------------------------------------------
--
--  This is the skeleton file for Lab 1 Phase 3.  You should
--  start with this file when you describe your state machine.  
--  
--------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

--------------------------------------------------------
--
--  This is the entity part of the top level file for Phase 3.
--  The entity part declares the inputs and outputs of the
--  module as well as their types.  For now, a signal of
--  “std_logic” type can take on the value ‘0’ or ‘1’ (it
--  can actually do more than this).  A signal of type
--  std_logic_vector can be thought of as an array of 
--  std_logic, and is used to describe a bus (a parallel 
--  collection of wires).
--
--  Note: you don't have to change the entity part.
--  
----------------------------------------------------------

entity state_machine is
   port (clk : in std_logic;  -- clock input to state machine
         resetb : in std_logic;  -- active-low reset input
         dir : in std_logic;     -- dir input
         hex_out : out std_logic_vector(6 downto 0)  -- output of state machine
            -- Note that in the above, hex0 is a 7-bit wide bus
            -- indexed using indices 6, 5, 4 ... down to 0.  The
            -- most-significant bit is hex(6) and the least significant
            -- bit is hex(0)
   );
end state_machine;

----------------------------------------------------------------
--
-- The following is the architecture part of the state machine.  It 
-- describes the behaviour of the state machine using synthesizable
-- VHDL.  
--
----------------------------------------------------------------- 

architecture behavioural of state_machine is

	-- State types
	type STATE is (state_B, state_E, state_N, state_J, state_A, state_M, state_I, state_N2);
	-- state management
	signal current_state, next_state : STATE;
	
	-- Direction type
	type DIRECTION is (dir_forward , dir_backward);
	-- direction management
	signal dir_sig : DIRECTION;
	

	begin
		process(dir)
		begin
			case dir is
				when '1' => dir_sig <= dir_forward;
				when '0' => dir_sig <= dir_backward;
				when others => dir_sig <= dir_forward;
			end case;
		end process;
		
		-- Next state logic
		process(next_state, current_state, resetb, dir_sig)
		begin
			case current_state is
				when state_B =>
					if (dir_sig = dir_forward) then
						next_state <= state_E;
					else
						next_state <= state_N2;
					end if;
				when state_E =>
					if (dir_sig = dir_forward) then
						next_state <= state_N;
					else
						next_state <= state_B;
					end if;
				when state_N =>
					if (dir_sig = dir_forward) then
						next_state <= state_J;
					else
						next_state <= state_E;
					end if;
				when state_J =>
					if (dir_sig = dir_forward) then
						next_state <= state_A;
					else
						next_state <= state_N;
					end if;
				when state_A =>
					if (dir_sig = dir_forward) then
						next_state <= state_M;
					else
						next_state <= state_J;
					end if;
				when state_M =>
					if (dir_sig = dir_forward) then
						next_state <= state_I;
					else
						next_state <= state_A;
					end if;
				when state_I =>
					if (dir_sig = dir_forward) then
						next_state <= state_N2;
					else
						next_state <= state_M;
					end if;
				when state_N2 =>
					if (dir_sig = dir_forward) then
						next_state <= state_B;
					else
						next_state <= state_I;
					end if;
				when others =>
					if (dir_sig = dir_forward) then
						next_state <= state_B;
					else
						next_state <= state_B;
					end if;
			end case;
			
			if (resetb = '0') then
				next_state <= state_B;
			end if;
		end process;

	-- Track state
	process (clk)
	begin
	   if (rising_edge(clk)) then
		   current_state <= next_state;
		end if;
	end process;

	-- Output logic
	process(current_state)
	begin
		case current_state is
			when state_B => hex_out <= "0000011";
			when state_E => hex_out <= "0000110";
			when state_N | state_N2 => hex_out <= "0101011";
			when state_J => hex_out <= "1100001";
			when state_A => hex_out <= "0001000";
			when state_M => hex_out <= "1001000";
			when state_I => hex_out <= "1111001";
			when others => hex_out <= "1111111";
		end case;
	end process;


end behavioural;
