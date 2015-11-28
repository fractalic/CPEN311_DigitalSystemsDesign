library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description.  Describes inputs and outputs

entity ksa is
  port(CLOCK_50 : in  std_logic;  -- Clock pin
       KEY : in  std_logic_vector(3 downto 0);  -- push button switches
       SW : in  std_logic_vector(15 downto 0);  -- slider switches
		 LEDG : out std_logic_vector(7 downto 0);  -- green lights
		 LEDR : out std_logic_vector(17 downto 0));  -- red lights
end ksa;

-- Architecture part of the description

architecture rtl of ksa is

   -- Declare the component for the ram.  This should match the entity description 
	-- in the entity created by the megawizard. If you followed the instructions in the 
	-- handout exactly, it should match.  If not, look at s_memory.vhd and make the
	-- changes to the component below
	
   COMPONENT s_memory IS
	   PORT (
		   address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		   clock		: IN STD_LOGIC  := '1';
		   data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		   wren		: IN STD_LOGIC ;
		   q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
   END component;

	-- Enumerated type for the state variable.  You will likely be adding extra
	-- state names here as you complete your design
	
	type state_type is (state_init, 
                       state_fill,
							  state_fill_wait,
   	 					  state_done);
								
    -- These are signals that are used to connect to the memory													 
	 signal address : STD_LOGIC_VECTOR (7 DOWNTO 0);	 
	 signal data : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 signal wren : STD_LOGIC;
	 signal q : STD_LOGIC_VECTOR (7 DOWNTO 0);	

	 begin
	    -- Include the S memory structurally
	
       u0: s_memory port map (
	        address, clock_50, data, wren, q);
		
	    process (clock_50)
		 variable i : integer := 0;
		 variable current_state : state_type;
		 begin
		 if rising_edge(clock_50) then
			case current_state is
				when state_init =>
					wren <= '0';
					i := 0;
					data <= "00000000";
					address <= "00000000";
					current_state := state_fill;
				when state_fill =>
					if i = 255 then
						current_state := state_done;
					end if;
					data <= std_logic_vector(to_unsigned(i, data'length));
					address <= std_logic_vector(to_unsigned(i, data'length));
					wren <= '1';
					current_state := state_fill_wait;
				when state_fill_wait =>
					wren <= '0';
					i := i + 1;
					current_state := state_fill;
				when state_done =>
					current_state := state_done;
				when others => current_state := state_init;
			end case;
		 end if;
		 end process;
			  
       -- write your code here.  As described in Slide Set 14, this 
       -- code will drive the address, data, and wren signals to
       -- fill the memory with the values 0...255
         
       -- You will be likely writing this is a state machine. Ensure
       -- that after the memory is filled, you enter a DONE state which
       -- does nothing but loop back to itself.  
end RTL;


