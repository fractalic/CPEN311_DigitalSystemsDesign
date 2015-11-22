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
   	 					  state_done);

    constant MEM_SIZE : natural := 256;
								
    -- These are signals that are used to connect to the memory													 
	 signal address : STD_LOGIC_VECTOR (7 DOWNTO 0);	 
	 signal data : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 signal wren : STD_LOGIC;
	 signal q : STD_LOGIC_VECTOR (7 DOWNTO 0);	

	 begin
	    -- Include the S memory structurally
	
       u0: s_memory port map (
	        address, clock_50, data, wren, q);
			  
       -- for (i in 0..255)
       -- 	u0[i] = i

    process(clock_50)
    variable currentState : state_type := state_init;
    variable memIndex : integer := 0;

    begin

    	if (rising_edge(clock_50)) then
            address <= std_logic_vector(to_unsigned(memIndex, address'length));
            data <= std_logic_vector(to_unsigned(memIndex, data'length));

    		case currentState is

    		when state_init =>
    			currentState := state_fill;

                memIndex := 0;
                wren <= '1';

    		when state_fill =>
    			if (memIndex = MEM_SIZE - 1) then
    				currentState := state_done;
    			else
    				currentState := state_fill;

                    memIndex := memIndex + 1;
                end if;

    		when state_done =>
                currentState := state_done;
                
                wren <= '0';

    		when others =>
                currentState := state_init;
    		end case;
    	end if;

    end process;


end rtl;


