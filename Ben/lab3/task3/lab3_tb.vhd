LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY WORK;
USE WORK.ALL;

entity lab3_tb is
end entity lab3_tb;

architecture behavioural of lab3_tb is

component lab3 is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
       LEDG                : out std_logic_vector(8 downto 0);
       LEDR                : out std_logic_vector(17 downto 0);
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic);
end component;

signal CLOCK_50            : std_logic;
signal KEY                 : std_logic_vector(3 downto 0);
signal SW                  : std_logic_vector(17 downto 0);
signal LEDG                : std_logic_vector(8 downto 0);
signal LEDR                : std_logic_vector(17 downto 0);
signal VGA_R, VGA_G, VGA_B : std_logic_vector(9 downto 0);
signal VGA_HS              : std_logic;
signal VGA_VS              : std_logic;
signal VGA_BLANK           : std_logic;
signal VGA_SYNC            : std_logic;
signal VGA_CLK             : std_logic;

begin

	-- Inifinite loop.
	process
	begin

		clock_50 <= '0';
		wait for 1ns;
		clock_50 <= '1';
		wait for 1ns;
	end process;

	dut : lab3
	port map(CLOCK_50    => clock_50,        
       KEY           => key,     
       SW            => sw,     
       LEDG          => ledg,  
       LEDR          => ledr,    
       VGA_R => vga_r, VGA_G => vga_g, VGA_B => vga_b,
       VGA_HS        => vga_hs,      
       VGA_VS        => vga_vs,      
       VGA_BLANK     => vga_blank,      
       VGA_SYNC      => vga_sync,      
       VGA_CLK       => vga_clk);      

end behavioural;