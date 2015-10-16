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
  signal INITX2 : std_logic;
  signal INITY2 : std_logic;
  signal XDONE  : std_logic;
  signal YDONE  : std_logic;
  signal XDONE2  : std_logic;
  signal YDONE2  : std_logic;
  signal gray   : std_logic_vector(2 downto 0);
  signal current_state, next_state : std_logic_vector(2 downto 0);
  signal i      : unsigned(7 downto 0);
  signal CSDONE : std_logic;

begin

  resetn <= not KEY(3);
  
  process(all)
	variable Yplace : unsigned(6 downto 0);
	variable Xplace : unsigned(7 downto 0);
	variable error: signed(7 downto 0);
	variable x0, x1, dx : signed(7 downto 0);
	variable y0, y1, dy : signed(6 downto 0);
	variable error2 : signed(15 downto 0);
	variable sx, sy : std_logic; -- flags to check direction
	begin
		if rising_edge(clock_50) then
			colour <= "110"; -- reset screen to black
			if (INITY = '1') then
				Yplace := "0000000";
			elsif (LOADY = '1') then -- update y at the end of a line
				Yplace := Yplace + 1;
			end if;
			
			if (INITX = '1') then
				Xplace := "00000000";
			else
				Xplace := Xplace + 1;
			end if;
			
			if (Yplace = 119) then
				YDONE <= '1';
			else
				YDONE <= '0';
			end if;
			
			if (Xplace = 159) then -- start Xplace at 0 again
				XDONE <= '1';
			else
				XDONE <= '0';
			end if;
			
			if XDONE = '1' and YDONE = '1' then
				CSDONE <= '1';
			end if;
			
			if CSDONE = '0' then
			   x <= std_logic_vector(Xplace); -- update the place of X onscreen
				y <= std_logic_vector(Yplace);
			end if;
			
			-- *********************** END OF CLEARING SCREEN CODE

			if CSDONE = '1' then
			if INITY2 = '1' then
				y0 := "0001000";
			end if;
			if INITX2 = '1' then -- initialize origin of line
				x0 := "00000000";
			end if;
			
			x1 := "10011111"; -- 159 - always x endpoint
			y1 := "1110000"; -- 112
			
			dx := abs(x1 - x0);
			dy := abs(y1 - y0);
			
			if(x0 < x1) then -- find direction in x
				sx := '1';
			else
				sx := '0';
			end if;
			if(y0 < y1) then -- find direction in y
				sy := '1';
			else
				sy := '0';
			end if;
			
			error := dx - dy;
			
			if (x0 = x1) then -- check if we need to reset loop
				XDONE2 <= '1';
			else
				XDONE2 <= '0';
			end if;
			if (y0 = y1) then
				YDONE2 <= '1';
			else
				YDONE2 <= '0';
			end if;
			
			error2 := 2 * error;
			
			if(error2 > -dy) then
				error := error - dy;
				if sx = '1' then
					x0 := x0 + 1;
				else
					x0 := x0 - 1;
				end if;
			end if;
			
			if (error2 < dx) then
				error := error + dx;
				if sy = '1' then
					y0 := y0 + 1;
				else
					y0 := y0 - 1;
				end if;
			end if;
			
				colour <= "111";
				x <= std_logic_vector(x0); -- update pixel place
				y <= std_logic_vector(y0);
			
			end if; -- check for xdone, ydone
			
		end if; -- this is the check for rising_edge(clock_50)
  end process;
  
  process(all) begin
	case current_state is
		when "000" => -- reset state
			next_state <= "001";
			INITX <= '1';
			INITY <= '1';
			LOADY <= '1';
			PLOT <= '0';
		when "001" => -- update x position / draw x line
			next_state <= "001";
			INITX <= '0';
			INITY <= '0';
			LOADY <= '0';
			PLOT <= '1';
			--LEDR <= "111000111000111000";
			if CSDONE = '1' then
				next_state <= "011"; -- finished clearing screen
				--LEDG <= "11110000";
			elsif XDONE = '1' then
				next_state <= "010"; -- update y when x is done
			end if;
		when "010" => -- update y position
			next_state <= "001";
			INITX <= '1';
			INITY <= '0';
			LOADY <= '1';
			PLOT <= '0';
		when "011" => -- clearing screen is done!
			next_state <= "100"; -- ****************** WORKS UP TO HERE
			--ledr <= "101010101010101010";
			ledg <= "10101010";
			INITX2 <= '1'; -- used for x0
			INITY2 <= '1'; -- used for y0
			LOADY <= '0';
			PLOT <= '0';
			--i <= "00000001";
		when "100" => -- begin drawing the lines!
			next_state <= "100"; -- go to update state
			INITX2 <= '0';
			INITY2 <= '0';
			PLOT <= '1';
			--i <= i + 1;
			--LEDG <= "00001111";
			if XDONE2 = '1' and YDONE2 = '1' then
				next_state <= "101"; -- finished drawing all lines
			end if;
		when "101" => -- stop drawing
			next_state <= "101"; -- stay here foever
			plot <= '0';
			--ledr <= "111111111111111111";
			--ledg <= "11111111";
		when others => next_state <= "000"; -- catch-all
	end case;
	
	if resetn = '0' then
		next_state <= "000";
	end if;
  end process;
  
  process(clock_50) begin -- update states
	if rising_edge(clock_50) then
		current_state <= next_state;
	end if;
  end process;
  
	process(all) begin -- 'returns' a gray code with different values of i
		if i mod 8 = 0 then
			gray <= "000";
		elsif i mod 8 = 1 then
			gray <= "001";
		elsif i mod 8 = 2 then
			gray <= "011";
		elsif i mod 8 = 3 then
			gray <= "010";
		elsif i mod 8 = 4 then
			gray <= "110";
		elsif i mod 8 = 5 then
			gray <= "111";
		elsif i mod 8 = 6 then
			gray <= "101";
		elsif i mod 8 = 7 then
			gray <= "100";
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


