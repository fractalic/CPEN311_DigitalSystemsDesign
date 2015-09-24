LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY WORK;
USE WORK.ALL;

ENTITY digit7seg_tb IS
END ENTITY;

ARCHITECTURE behavioural OF digit7seg_tb IS
  
  component digit7seg is
    port(
          digit : IN  UNSIGNED(3 DOWNTO 0);  -- number 0 to 0xF
          seg7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));  -- one per segment
	end component;
	
	signal digit : unsigned(3 downto 0) := "0000";
	signal seg7 : std_logic_vector(6 downto 0) := "0000000";
	
	begin
	  
	  dut : digit7seg port map(
	    digit => digit,
	    seg7 => seg7 );
	    
	 process
	 begin
	      
	      digit <= "0000";
	      wait for 2 ns;
	      
	      digit <= "0001";
	      wait for 2 ns;
	      
	      digit <= "0010";
	      wait for 2 ns;
	      
	      digit <= "0011";
	      wait for 2 ns;
	      
	      digit <= "0100";
	      wait for 2 ns;
	      
	      digit <= "0101";
	      wait for 2 ns;
	      
	      digit <= "0110";
	      wait for 2 ns;
	      
	      digit <= "0111";
	      wait for 2 ns;
	      
	      digit <= "1000";
	      wait for 2 ns;
	      
	      digit <= "1001";
	      wait for 2 ns;
	      
	      digit <= "1010";
	      wait for 2 ns;
	      
	      digit <= "1011";
	      wait for 2 ns;
	      
	      digit <= "1100";
	      wait for 2 ns;
	      
	      digit <= "1101";
	      wait for 2 ns;
	      
	      digit <= "1110";
	      wait for 2 ns;
	      
	      digit <= "1111";
	      wait for 2 ns;
	      
	 end process;
  
END behavioural;