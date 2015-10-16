library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3 is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
		 ledr						: out std_logic_vector(17 downto 0);
		 ledg 					: out std_logic_vector(7 downto 0);
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
  signal gray   : std_logic_vector(2 downto 0);
  signal i      : integer := 1;
  signal resetsw: std_logic;
  signal CS_DONE: std_logic;
  signal current_state, next_state : std_logic_vector(2 downto 0);

begin

  resetn <= not KEY(3);
  ledr <= sw;
  resetsw <= sw(0);
  
  process(clock_50)
	variable Yplace : unsigned(6 downto 0);
	variable Xplace : unsigned(7 downto 0);
	variable x0, x1, y0, y1 , dx, dy, sx, sy, error : signed(7 downto 0);
	variable error2 : signed(15 downto 0);
	begin
		x0 := "00000000"; -- 0 start
		x1 := "10011111"; -- 159 end

		if rising_edge(clock_50) then
		if CS_DONE = '0' then -- checks whether the clear-screen states are finished
			colour <= "001"; -- reset screen to black
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
			end if;
			x <= std_logic_vector(Xplace); -- update the place of X onscreen
			
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
		end if;
			
			-- drawing lines
		if CS_DONE = '1' then
			colour <= "100"; -- uses the i value in the loop to get the colour from the 'gray' process
			y0 := to_signed(i * 8, y0'length);
			y1 := to_signed(120 - (i * 8), y1'length);
			dx := abs(x1 - x0); -- this is always the same
			dy := abs(y1 - y0);
			if x0 < x1 then
				sx := "00000001"; -- forward in x
			else
				sx := -"00000001"; -- backward in x
			end if;
			if y0 < y1 then
				sy := "00000001"; -- forward in x
			else
				sy := -"00000001"; -- backward in x
			end if;
			error := dx - dy; -- finish initializing values according to algorithm
						
			error2 := error * 2;
			if error2 > -dy then	
				error := error - dy;
				x0 := x0 + sx; -- go forward / backward
			end if;
			if error2 < dx then
				error := error + dx;
				y0 := y0 + sy;
			end if;
				
			i <= i + 1; -- update i, the counter for drawing lines
			if i > 14 then -- reset y
				i <= 1;
			end if;
		end if; -- checks if screen has been cleared
		end if; -- this is the check for clock'event
  end process;
  
    process(all) begin
	case current_state is
		when "000" => -- reset state
			next_state <= "001";
			INITX <= '1';
			INITY <= '1';
			LOADY <= '1';
			PLOT <= '0';
			CS_DONE <= '0';
		when "001" => -- update x position / draw x line
			next_state <= "010";
			INITX <= '0';
			INITY <= '0';
			LOADY <= '0';
			PLOT <= '1';
			if YDONE = '1' and XDONE = '1' then
				next_state <= "011";
				CS_DONE <= '1'; -- finished clearing screen
			end if;
		when "010" => -- update y position
			next_state <= "001";
			INITX <= '1';
			INITY <= '0';
			LOADY <= '1';
			PLOT <= '0';
		when "011" => -- drawing is done!
			next_state <= "011";
			PLOT <= '0';
		when others => next_state <= "000"; -- catch-all
	end case;
	
	if resetn = '0' then
		next_state <= "000";
	end if;
  end process;
  
  process(clock_50) begin -- update states
	if rising_edge(clock_50) then
		next_state <= current_state;
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


