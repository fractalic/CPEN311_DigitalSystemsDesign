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
	
type state_type is (init, 
                       fill_a,
							  wait_a,
   	 					  done_a,
							  init_b,
							  goto_b_i,
							  wait_b_i,
							  read_b_i,
							  goto_b_j,
							  wait_b_j,
							  write_b_j,
							  write_b_i,
							  done_b);
								
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
		
	    process (clock_50)
		 variable i : integer := 0;
		 variable j : integer := 0;
		 variable imod : integer := 0;
		 variable temp_address : std_logic_vector(7 downto 0);
		 variable temp_data : std_logic_vector(7 downto 0);
		 variable temp_wren : std_logic;
		 variable temp_i, temp_j : std_logic_vector(7 downto 0) := "00000000";
		 variable temp_secret_key : std_logic_vector(7 downto 0) := "00000000";
		 variable current_state : state_type;
		 begin
		 if rising_edge(clock_50) then
			case current_state is
			when init =>
    		 current_state := fill_a;
			 i := 0;
          temp_wren := '1';
          temp_address := std_logic_vector(to_unsigned(i, temp_address'length));
          temp_data := std_logic_vector(to_unsigned(i, temp_data'length));
          ledg(0) <= '0';

    		when fill_a =>
    			if i = 255 then
    				current_state := done_a;
    			else
    				current_state := fill_a;
					i := i + 1;
          end if;
          temp_address := std_logic_vector(to_unsigned(i, temp_address'length));
          temp_data := std_logic_vector(to_unsigned(i, temp_data'length));

    		when done_a =>
          current_state := init_b;
          temp_wren := '0';

        when init_b =>
          current_state := goto_b_i;
          i := 0;
          j := 0;

        when goto_b_i =>
          current_state := wait_b_i;

          temp_wren := '0';
          temp_address := std_logic_vector(to_unsigned(i, temp_address'length));

        when wait_b_i =>
          current_state := read_b_i;

        when read_b_i =>
          current_state := goto_b_j;
          imod := i mod 3;
          if (imod = 0) then
            temp_secret_key := secret_key(7 downto 0);
          elsif (imod = 1) then
            temp_secret_key := secret_key(15 downto 8);
          elsif (imod = 2) then
            temp_secret_key := secret_key(23 downto 16);
          end if;
          temp_i := q;
          j := (j + to_integer(unsigned(q)) + to_integer(unsigned( temp_secret_key ))) mod 256;

        when goto_b_j =>
          current_state := wait_b_j;
          temp_wren := '0';
          temp_address := std_logic_vector(to_unsigned(j, temp_address'length));

        when wait_b_j =>
          current_state := write_b_j;

        when write_b_j =>
          current_state := write_b_i;
          temp_j := q;
          temp_wren := '1';
          temp_address := std_logic_vector(to_unsigned(j, temp_address'length));
          temp_data := temp_i;

        when write_b_i =>
          if (i = 255) then
            current_state := done_b;
          else
            current_state := goto_b_i;
          end if;
          temp_wren := '1';
          temp_address := std_logic_vector(to_unsigned(i, temp_address'length));
          temp_data := temp_j;
          i := i + 1;

        when done_b =>
          current_state := done_b;
          ledg(0) <= '1';
          temp_wren := '0';

    		when others =>
          current_state := init;
    		end case;
    	end if;
      address <= temp_address;
      data <= temp_data;
      wren <= temp_wren;
		 end process; 
end RTL;


