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

component init_s is
  port(
    start : in std_logic;
    clock : in std_logic;
    done : out std_logic;
    wren : out std_logic;
    data : out std_logic_vector(7 downto 0);
    addr : out std_logic_vector(7 downto 0)
  );
end component;

component reorder_s is
  port(
    start : in std_logic;
    clock : in std_logic;
    q : in std_logic_vector(7 downto 0);
    secret_key : in std_logic_vector(23 downto 0);
    done : out std_logic;
    wren : out std_logic;
    data : out std_logic_vector(7 downto 0);
    address : out std_logic_vector(7 downto 0)
  );
end component;

	-- Enumerated type for the state variable.  You will likely be adding extra
	-- state names here as you complete your design
	
	type state_type is (state_init, state_fill, state_done,
                state_reorder_begin, state_reorder_loop, state_reorder_done,
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

   signal u_init_start : std_logic;
   signal u_init_done : std_logic;
   signal u_init_wren : std_logic;
   signal u_init_data : std_logic_vector(data'left downto data'right);
   signal u_init_addr : std_logic_vector(address'left downto address'right);
   signal u_init_active : std_logic;

   signal u_reorder_start : std_logic;
   signal u_reorder_done : std_logic;
   signal u_reorder_wren : std_logic;
   signal u_reorder_data : std_logic_vector(data'left downto data'right);
   signal u_reorder_addr : std_logic_vector(address'left downto address'right);
   signal u_reorder_active : std_logic;
   signal u_reorder_q : std_logic_vector(7 downto 0);

   signal u_address_s : std_logic_vector(7 downto 0);
   signal u_data_s : std_logic_vector(7 downto 0);
   signal u_wren_s : std_logic;

	 begin
	    -- Include the S memory structurally
	
       u_s: s_memory port map (
	        u_address_s, clock_50, u_data_s, u_wren_s, q);

       e_rom: e_memory port map(address => address_e, clock => clock_50, q => q_e);

       d_ram: d_memory port map(address => address_d, clock => clock_50, data => data_d, wren => wren_d, q => q_d);

      u_init: init_s port map(start => u_init_start, clock => clock_50, done => u_init_done,
        wren => u_init_wren, data => u_init_data, addr => u_init_addr);

      u_reorder: reorder_s port map(start => u_reorder_start, clock => clock_50, q => q, secret_key => secret_key,
        done => u_reorder_done, wren => u_reorder_wren, data => u_reorder_data, address => u_reorder_addr);

    secret_key <= "000000" & sw(17 downto 0);
    ledr <= sw;

    process(all)
    begin
      if (u_init_active = '1') then
        u_wren_s <= u_init_wren;
        u_data_s <= u_init_data;
        u_address_s <= u_init_addr;
      elsif (u_reorder_active = '1') then
        u_wren_s <= u_reorder_wren;
        u_data_s <= u_reorder_data;
        u_address_s <= u_reorder_addr;
      else
        u_wren_s <= wren;
        u_data_s <= data;
        u_address_s <= address;
      end if;
    end process;
			  
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
    			currentState := state_fill;

          ledg(2 downto 0) <= "000";

          u_init_active <= '1';
          u_init_start <= '1';
          u_reorder_active <= '0';
          u_reorder_start <= '0';

    		when state_fill =>
    			if (u_init_done = '1') then
    				currentState := state_done;
    			else
    				currentState := state_fill;
          end if;

    		when state_done =>
          currentState := state_reorder_begin;
          
          ledg(1 downto 0) <= "01";

          u_init_active <= '0';
          u_init_start <= '0';

        when state_reorder_begin =>
          currentState := state_reorder_loop;

          u_reorder_active <= '1';
          u_reorder_start <= '1';


        when state_reorder_loop =>
          if (u_reorder_done = '1') then
            currentState := state_reorder_done;
          else
            currentState := state_reorder_loop;
          end if;

        when state_reorder_done =>
          currentState := state_decrypt_begin;
          
          ledg(1 downto 0) <= "11";
          ledg(2) <= '0';

          u_reorder_active <= '0';
          u_reorder_start <= '0';


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

          ledg(2) <= '1';

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


