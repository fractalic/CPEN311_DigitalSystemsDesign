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

-- ROM for encrypted message.
component e_memory
  PORT
  (
    address   : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
    clock   : IN STD_LOGIC  := '1';
    q   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
  );
end component;

component d_memory
  PORT
  (
    address   : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
    clock   : IN STD_LOGIC  := '1';
    data    : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    wren    : IN STD_LOGIC ;
    q   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
  );
end component;

	-- Enumerated type for the state variable.  You will likely be adding extra
	-- state names here as you complete your design
	
	type state_type is (state_init, 
                       state_fill,						
   	 					  state_done,
                state_swap_begin, state_swap_readSi, state_swap_readSi_wait,
                state_swap_registerSi, state_swap_setj,
                state_swap_readSj, state_swap_readSj_wait,
                state_swap_writeSj, state_swap_writeSi, state_swap_done,
                state_decrypt_begin, state_decrypt_iterate, state_decrypt_iterate_delay,
                state_decrypt_regSi, state_decrypt_writeSj, state_decrypt_regSj,
                state_decrypt_loadE, state_decrypt_loadE_wait, state_decrypt_writeD,
                state_decrypt_done
                );

    constant MEM_SIZE : natural := 256;
    constant KEY_LENGTH : natural := 3;
    constant MESSAGE_LENGTH : natural := 32;
								
   signal secret_key : std_logic_vector(23 downto 0);

    -- These are signals that are used to connect to the memory													 
	 signal address : STD_LOGIC_VECTOR (7 DOWNTO 0);	 
	 signal data : STD_LOGIC_VECTOR (7 DOWNTO 0);
	 signal wren : STD_LOGIC;
	 signal q : STD_LOGIC_VECTOR (7 DOWNTO 0);

   signal address_e : std_logic_vector(4 downto 0);
   signal q_e : std_logic_vector(7 downto 0);

   signal address_d : STD_LOGIC_VECTOR (4 DOWNTO 0);   
   signal data_d : STD_LOGIC_VECTOR (7 DOWNTO 0);
   signal wren_d : STD_LOGIC;
   signal q_d : STD_LOGIC_VECTOR (7 DOWNTO 0);

	 begin
	    -- Include the S memory structurally
	
       u0: s_memory port map (
	        address, clock_50, data, wren, q);

       e_rom: e_memory port map(address => address_e, clock => clock_50, q => q_e);

       d_ram: d_memory port map(address => address_d, clock => clock_50, data => data_d, wren => wren_d, q => q_d);


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
    variable memK : integer := 0;
    variable memImod : integer := 0;

    -- Communcation.
    variable address_s_var : std_logic_vector(address'left downto address'right);
    variable data_s_var : std_logic_vector(data'left downto data'right);
    variable wren_s_var : std_logic;

    variable address_e_var : std_logic_vector(address_e'left downto address_e'right);

    variable address_d_var : std_logic_vector(address_d'left downto address_d'right);
    variable data_d_var : std_logic_vector(data'left downto data'right);
    variable wren_d_var : std_logic;

    variable Si : std_logic_vector(data'left downto data'right);
    variable Sj : std_logic_vector(data'left downto data'right);
    variable Sf : std_logic_vector(data'left downto data'right);
    variable Ek : std_logic_vector(data'left downto data'right);
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
          wren_s_var := '1';
          address_s_var := std_logic_vector(to_unsigned(memI, address_s_var'length));
          data_s_var := std_logic_vector(to_unsigned(memI, data_s_var'length));
          ledg(1 downto 0) <= "00";

    		when state_fill =>
    			if (memI = MEM_SIZE - 1) then
    				currentState := state_done;
    			else
    				currentState := state_fill;

            memI := memI + 1;
          end if;

          address_s_var := std_logic_vector(to_unsigned(memI, address_s_var'length));
          data_s_var := std_logic_vector(to_unsigned(memI, data_s_var'length));

    		when state_done =>
          currentState := state_swap_begin;
          
          wren_s_var := '0';


        when state_swap_begin =>
          currentState := state_swap_readSi;

          memI := 0;
          memJ := 0;

        when state_swap_readSi =>
          currentState := state_swap_readSi_wait;

          wren_s_var := '0';
          address_s_var := std_logic_vector(to_unsigned(memI, address_s_var'length));

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

          memJ := (memJ + to_integer(unsigned(Si)) + to_integer(unsigned( key_sub ))) mod MEM_SIZE;

        when state_swap_readSj =>
          currentState := state_swap_writeSj;

          wren_s_var := '0';
          address_s_var := std_logic_vector(to_unsigned(memJ, address_s_var'length));

        when state_swap_readSj_wait =>
          currentState := state_swap_writeSj;

        when state_swap_writeSj =>
          currentState := state_swap_writeSi;

          wren_s_var := '1';
          address_s_var := std_logic_vector(to_unsigned(memJ, address_s_var'length));
          data_s_var := Si;

        when state_swap_writeSi =>
          if (memI = 255) then
            currentState := state_swap_done;
          else
            currentState := state_swap_readSi;
          end if;

          Sj := q;
          wren_s_var := '1';
          address_s_var := std_logic_vector(to_unsigned(memI, address_s_var'length));
          data_s_var := Sj;

          memI := memI + 1;

        when state_swap_done =>
          currentState := state_decrypt_begin;
          ledg(0) <= '1';

          wren_s_var := '0';


        when state_decrypt_begin =>
          currentState := state_decrypt_iterate;

          memI := 0;
          memJ := 0;
          memK := 0;

          wren_d_var := '0';

        when state_decrypt_iterate =>
          currentState := state_decrypt_iterate_delay;

          memI := (memI + 1) mod MEM_SIZE;

          wren_s_var := '0';
          address_s_var := std_logic_vector(to_unsigned(memI, address_s_var'length));

        when state_decrypt_iterate_delay =>
          currentState := state_decrypt_regSi;

        when state_decrypt_regSi =>
          currentState := state_decrypt_writeSj;

          Si := q;
          memJ := (memJ + to_integer(unsigned(Si)) ) mod MEM_SIZE;

          wren_s_var := '0';
          address_s_var := std_logic_vector(to_unsigned(memJ, address_s_var'length));

        when state_decrypt_writeSj =>
          currentState := state_decrypt_regSj;

          wren_s_var := '1';
          address_s_var := std_logic_vector(to_unsigned(memJ, address_s_var'length));
          data_s_var := Si;

        when state_decrypt_regSj =>
          currentState := state_decrypt_loadE;

          Sj := q;

          wren_s_var := '1';
          address_s_var := std_logic_vector(to_unsigned(memI, address_s_var'length));
          data_s_var := Sj;

        when state_decrypt_loadE =>
          currentState := state_decrypt_loadE_wait;

          wren_s_var := '0';
          address_s_var := std_logic_vector(to_unsigned( (to_integer(unsigned(Si)) + to_integer(unsigned(Sj)) ) mod MEM_SIZE, address_s_var'length ));

          address_e_var := std_logic_vector(to_unsigned(memK, address_e_var'length));

        when state_decrypt_loadE_wait =>
          currentState := state_decrypt_writeD;

        when state_decrypt_writeD =>
          currentState := state_decrypt_iterate;

          Sf := q;
          Ek := q_e;

          wren_d_var := '1';
          address_d_var := std_logic_vector(to_unsigned(memK, address_d_var'length));
          data_d_var := Sf xor Ek;

          if (memK = MESSAGE_LENGTH - 1) then
            currentState := state_decrypt_done;
          end if;

          memK := memK + 1;

        when state_decrypt_done =>
          wren_d_var := '0';

          ledg(1) <= '1';

          currentState := state_decrypt_done;

    		when others =>
          currentState := state_init;

    		end case;
    	end if;


      address <= address_s_var;
      data <= data_s_var;
      wren <= wren_s_var;

      wren_d <= wren_d_var;
      address_d <= address_d_var;
      data_d <= data_d_var;

      address_e <= address_e_var;

      --j = 0
      --for i = 0 to 255 {
      --  j = (j + s[i] + secret_key[i mod keylength] ) mod 256 //keylength is 3 in our impl.
      --  swap values of s[i] and s[j]:
      --    { temp := s[i]; s[i] := s[j]; s}
      --}

    end process;


end rtl;


