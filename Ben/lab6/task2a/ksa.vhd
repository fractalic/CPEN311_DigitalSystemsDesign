library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description.  Describes inputs and outputs

entity ksa is
  port(CLOCK_50 : in  std_logic;  -- Clock pin
       KEY : in  std_logic_vector(3 downto 0);  -- push button switches
       SW : in  std_logic_vector(17 downto 0);  -- slider switches
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
   	 					  state_done,
                state_swap_begin, state_swap_readSi, state_swap_readSi_wait,
                state_swap_registerSi, state_swap_setj,
                state_swap_readSj, state_swap_readSj_wait,
                state_swap_writeSj, state_swap_writeSi, state_swap_done);

    constant MEM_SIZE : natural := 256;
    constant KEY_LENGTH : natural := 3;
								
    -- These are signals that are used to connect to the memory													 
	 signal address : STD_LOGIC_VECTOR (7 DOWNTO 0);	 
	 signal data : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 signal wren : STD_LOGIC;
	 signal q : STD_LOGIC_VECTOR (7 DOWNTO 0);
   signal secret_key : std_logic_vector(23 downto 0);

	 begin
	    -- Include the S memory structurally
	
       u0: s_memory port map (
	        address, clock_50, data, wren, q);


    secret_key <= "000000" & sw(17 downto 0);
    ledr <= sw;
			  
       -- for (i in 0..255)
       -- 	u0[i] = i

    process(clock_50)
    -- State.
    variable currentState : state_type := state_init;

    -- Iteration.
    variable memI : integer := 0;
    variable memJ : integer := 0;
    variable memImod : integer := 0;

    -- Communcation.
    variable address_var : std_logic_vector(address'left downto data'right);
    variable data_var : std_logic_vector(data'left downto data'right);
    variable wren_var : std_logic;
    variable Si : std_logic_vector(data'left downto data'right);
    variable Sj : std_logic_vector(data'left downto data'right);
    variable key_sub : std_logic_vector(7 downto 0);

    begin


    	if (rising_edge(clock_50)) then

    		case currentState is

    		when state_init =>
          -- State.
    			currentState := state_fill;

          -- Iteration.
          memI := 0;

          -- Communication.
          wren_var := '1';
          address_var := std_logic_vector(to_unsigned(memI, address_var'length));
          data_var := std_logic_vector(to_unsigned(memI, data_var'length));
          ledg(0) <= '0';

    		when state_fill =>
    			if (memI = MEM_SIZE - 1) then
    				currentState := state_done;
    			else
    				currentState := state_fill;

            memI := memI + 1;
          end if;

          address_var := std_logic_vector(to_unsigned(memI, address_var'length));
          data_var := std_logic_vector(to_unsigned(memI, data_var'length));

    		when state_done =>
          currentState := state_swap_begin;
          
          wren_var := '0';

        when state_swap_begin =>
          currentState := state_swap_readSi;

          memI := 0;
          memJ := 0;

        when state_swap_readSi =>
          currentState := state_swap_readSi_wait;

          wren_var := '0';
          address_var := std_logic_vector(to_unsigned(memI, address_var'length));

        when state_swap_readSi_wait =>
          currentState := state_swap_setj;

        when state_swap_registerSi =>
          currentState := state_swap_setj;

        when state_swap_setj =>
          currentState := state_swap_readSj;

          memImod := memI mod KEY_LENGTH;

          if (memIMod = 2) then
            key_sub := secret_key(7 downto 0);
          elsif (memImod = 1) then
            key_sub := secret_key(15 downto 8);
          elsif (memImod = 0) then
            key_sub := secret_key(23 downto 16);
          end if;

          Si := q;

          memJ := (memJ + to_integer(unsigned(q)) + to_integer(unsigned( key_sub ))) mod MEM_SIZE;

        when state_swap_readSj =>
          currentState := state_swap_readSj_wait;

          wren_var := '0';
          address_var := std_logic_vector(to_unsigned(memJ, address_var'length));

        when state_swap_readSj_wait =>
          currentState := state_swap_writeSj;

        when state_swap_writeSj =>
          currentState := state_swap_writeSi;

          Sj := q;
          wren_var := '1';
          address_var := std_logic_vector(to_unsigned(memJ, address_var'length));
          data_var := Si;

        when state_swap_writeSi =>
          if (memI = 255) then
            currentState := state_swap_done;
          else
            currentState := state_swap_readSi;
          end if;

          wren_var := '1';
          address_var := std_logic_vector(to_unsigned(memI, address_var'length));
          data_var := Sj;

          memI := memI + 1;

        when state_swap_done =>
          currentState := state_swap_done;
          ledg(0) <= '1';

          wren_var := '0';

    		when others =>
          currentState := state_init;

    		end case;
    	end if;


      address <= address_var;
      data <= data_var;
      wren <= wren_var;

      --j = 0
      --for i = 0 to 255 {
      --  j = (j + s[i] + secret_key[i mod keylength] ) mod 256 //keylength is 3 in our impl.
      --  swap values of s[i] and s[j]:
      --    { temp := s[i]; s[i] := s[j]; s}
      --}

    end process;


end rtl;


