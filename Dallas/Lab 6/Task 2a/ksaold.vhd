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
							  read_b,
							  wait_b_read,
							  fill_b_i,
							  wait_b_fill,
							  fill_b_j,
							  done_b);
								
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
		 variable j : integer := 0;
		 variable temp : std_logic_vector(7 downto 0) := "00000000";
		 variable secret_key : unsigned(7 downto 0) := "00000000";
		 variable current_state : state_type;
		 begin
		 if rising_edge(clock_50) then
			case current_state is
				when init =>
					wren <= '0';
					i := 0;
					j := 0;
					data <= "00000000";
					address <= "00000000";
					current_state := fill_a;
				when fill_a =>
					if i = 255 then
						current_state := done_a;
					end if;
					data <= std_logic_vector(to_unsigned(i, data'length));
					address <= std_logic_vector(to_unsigned(i, data'length));
					wren <= '1';
					current_state := wait_a;
				when wait_a =>
					wren <= '0';
					i := i + 1;
					current_state := fill_a;
				when done_a => -- done first loop
					i := 0;
					wren <= '0';
					current_state := read_b;
					
				when read_b =>
					if i = 255 then
						current_state := done_b;
					end if;
					wren <= '0';
					address <= std_logic_vector(to_unsigned(i, address'length));
					current_state := wait_b_read;
					if i mod 3 = 0 then
						secret_key := unsigned(SW(7 downto 0));
					elsif i mod 3 = 1 then
						secret_key := unsigned(SW(15 downto 8));
					else
						secret_key := "000000"&unsigned(SW(17 downto 16));
					end if;
				when wait_b_read =>
					wren <= '0';
					temp := data;
					j := (j + to_integer(unsigned(data)) + to_integer(secret_key)) mod 256;
					current_state := fill_b_i;
				when fill_b_i =>
					address <= std_logic_vector(to_unsigned(i, address'length));
					data <= std_logic_vector(to_unsigned(j, data'length));
					wren <= '1';
					current_state := wait_b_fill;
				when wait_b_fill =>
					wren <= '0';
					current_state := fill_b_j;
				when fill_b_j =>
					address <= std_logic_vector(to_unsigned(j, address'length));
					data <= temp;
					wren <= '1';
					i := i + 1;
					current_state := read_b;
				when done_b => -- done second loop
					current_state := done_b;
				when others => current_state := init;
			end case;
		 end if;
		 end process; 
end RTL;


