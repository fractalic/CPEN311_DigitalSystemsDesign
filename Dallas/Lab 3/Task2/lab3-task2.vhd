library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3 is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
		 ledr						: out std_logic_vector(17 downto 0);
		 ledg						: out std_logic_vector(7 downto 0);
       VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
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
    port (resetn                                       : in  std_logic;
          clock                                        : in  std_logic;
          colour                                       : in  std_logic_vector(2 downto 0);
          x                                            : in  std_logic_vector(7 downto 0);
          y                                            : in  std_logic_vector(6 downto 0);
          plot                                         : in  std_logic;
          VGA_R, VGA_G, VGA_B                          : out std_logic_vector(9 downto 0);
          VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : out std_logic);
  end component;

  signal resetn : std_logic;
  signal x      : std_logic_vector(7 downto 0);
  signal y      : std_logic_vector(6 downto 0);
  signal colour : std_logic_vector(2 downto 0);
  signal plot   : std_logic;
  signal loady  : std_logic;
  signal loadx  : std_logic;
  signal inity  : std_logic;
  signal initx  : std_logic;
  signal XDONE  : std_logic;
  signal YDONE  : std_logic;

begin

  resetn <= not KEY(3);
  ledr <= sw;
  -- x      <= SW(7 downto 0);
  -- y      <= SW(14 downto 8);
  -- colour <= SW(17 downto 15);
  plot <= not KEY(0);
  
  process(clock_50)
	variable Yplace : unsigned(6 downto 0);
	variable Xplace : unsigned(7 downto 0);
	variable colourtype : unsigned(2 downto 0);
	begin
		if rising_edge(clock_50) then
			if (INITY = '1') then
				Yplace := "0000000";
			elsif (LOADY = '1') then -- update y at the end of a line
				Yplace := Yplace + 1;
			end if;
			y <= std_logic_vector(Yplace); -- update the place of Y onscreen
			
			if (INITX = '1') then
				Xplace := "00000000";
			else
				Xplace := Xplace + 1;
				colourtype := colourtype + 1;
			end if;
			x <= std_logic_vector(Xplace); -- update the place of X onscreen
			
			if (resetn = '1' or colourtype > "111") then -- changes colour every line
				colourtype := "000";
				colour <= "000";
			else
				colour <= std_logic_vector(colourtype mod 8);
			end if;
			
			if (Yplace = 119) then
				YDONE <= '1';
				LOADY <= '0';
			else
				YDONE <= '0';
			end if;
			
			if (Xplace = 159) then -- start Xplace at 0 again
				LOADY <= '1'; -- only update Y at the end of a line
				INITX <= '1';
				XDONE <= '1';
			else
				XDONE <= '0';
				LOADY <= '0';
			end if;
			
			if (resetn = '1') then
				INITX <= '1';
				INITY <= '1';
			else
				INITX <= '0';
				INITY <= '0';
			end if;
			
			--if(YDONE = '1' and XDONE = '1') then
				--PLOT <= '0';
			--else
				--PLOT <= '1';
			--end if;
		
		end if;
  end process;

  vga_u0 : vga_adapter
    generic map(RESOLUTION => "160x120") 
    port map(resetn    => KEY(3),
             clock     => CLOCK_50,
             colour    => colour,
             x         => x,
             y         => y,
             plot      => plot,
             VGA_R     => VGA_R,
             VGA_G     => VGA_G,
             VGA_B     => VGA_B,
             VGA_HS    => VGA_HS,
             VGA_VS    => VGA_VS,
             VGA_BLANK => VGA_BLANK,
             VGA_SYNC  => VGA_SYNC,
             VGA_CLK   => VGA_CLK);


end RTL;


