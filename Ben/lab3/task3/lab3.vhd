library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3 is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
       LEDG                : out  std_logic_vector(8 downto 0);
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);
       VGA_HS              : out std_logic;
       VGA_VS              : out std_logic;
       VGA_BLANK           : out std_logic;
       VGA_SYNC            : out std_logic;
       VGA_CLK             : out std_logic);
end lab3;

architecture rtl of lab3 is

 --Component from the Verilog file: vga_adapter.v

  component vga_adapter
    generic(RESOLUTION : string);
    port (resetn : in  std_logic;
          clock  : in  std_logic;
          colour : in  std_logic_vector(2 downto 0);
          x      : in  std_logic_vector(7 downto 0);
          y      : in  std_logic_vector(6 downto 0);
          plot   : in  std_logic;
          VGA_R, VGA_G, VGA_B
                 : out std_logic_vector(9 downto 0);
          VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK
                : out std_logic);
  end component;

  

begin


  -- VGA Driver
  vga_u0 : vga_adapter
    generic map(RESOLUTION => "160x120") 
    port map(resetn    => KEY(3),
             clock     => clock_50,
             colour    => colour,
             x         => std_logic_vector(xpos),
             y         => std_logic_vector(ypos),
             plot      => plot,
             VGA_R     => VGA_R,
             VGA_G     => VGA_G,
             VGA_B     => VGA_B,
             VGA_HS    => VGA_HS,
             VGA_VS    => VGA_VS,
             VGA_BLANK => VGA_BLANK,
             VGA_SYNC  => VGA_SYNC,
             VGA_CLK   => VGA_CLK);
end rtl;


