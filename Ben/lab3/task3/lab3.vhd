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

  signal load_colour,
         load_sx,
         load_dx,
         load_x,
         load_x0,
         load_x1,
         load_sy,
         load_dy,
         load_y,
         load_y0,
         load_y1       : std_logic;

  signal ctrl_colour_graycode,
         ctrl_err_dy,
         ctrl_err_dx
                       : std_logic;

  signal clear_screen,
         init_x,
         init_y        : std_logic;

  signal load_i,
         load_j,
         load_k        : std_logic;

  signal init_i,
         init_j,
         init_k        : std_logic;

  signal load_err,
         load_err2     : std_logic;

  signal init_err      : std_logic;

  signal x,x0,x1       : unsigned(7 downto 0);
  signal dx            : signed(x'left downto x'right);
  signal sx            : signed(1 downto 0);
  signal y,y0,y1       : unsigned(6 downto 0);
  signal dy            : signed(y'left downto y'right);
  signal sy            : signed(1 downto 0);
  signal colour        : std_logic_vector(2 downto 0);

  signal i             : unsigned(x'left downto x'right);
  signal j             : unsigned(y'left downto y'right);
  signal k             : unsigned(3 downto 0);

  signal err           : signed(7 downto 0);
  signal err2          : signed(err'left+1 downto err'right);

  signal plot          : std_logic;

  signal stateClock    : std_logic;

  signal COLOUR_RESET  : std_logic_vector(2 downto 0);

begin

  COLOUR_RESET <= "001";

  stateClock <= key(0);

  -- Datapath registers.
  process(stateClock)
  variable err_interim : signed(err'left downto err'right);
  begin
    if (rising_edge(stateClock)) then
      if (load_colour = '1') then
        if (ctrl_colour_graycode = '1') then
          colour <= std_logic_vector(k(2 downto 0));
        else
          colour <= COLOUR_RESET;
        end if;
      end if;

      if (load_sx = '1') then
        if (x0 < x1) then
          sx <= to_signed(1,  sx'length);
        else
          sx <= to_signed(-1, sx'length);
        end if;
      end if;

      if (load_sy = '1') then
        if (y0 < y1) then
          sy <= to_signed(1,  sy'length);
        else
          sy <= to_signed(-1, sy'length);
        end if;
      end if;

      if (load_dx = '1') then
        dx <= abs(signed(x1)-signed(x0));
      end if;

      if (load_dy = '1') then
        dy <= abs(signed(y1)-signed(y0));
      end if;

      if (load_x = '1') then
        if (clear_screen = '1') then
          x <= i;
        else
          if (init_x = '1') then
            x <= x0;
          else
            x <= unsigned(signed(x) + sx);
          end if;
        end if;
      end if;

      if (load_y = '1') then
        if (clear_screen = '1') then
          y <= j;
        else
          if (init_y = '1') then
            y <= y0;
          else
            y <= unsigned(signed(y) + sy);
          end if;
        end if;
      end if;

      if (load_x0 = '1') then
        x0 <= to_unsigned(0, x0'length);
      end if;

      if (load_x1 = '1') then
        x1 <= to_unsigned(159, x0'length);
      end if;

      if (load_y0 = '1') then
        -- multiply k by 8
        y0 <= k&"000";
      end if;

      if (load_y1 = '1') then
        y1 <= to_unsigned(120,y1'length)
              - k&"000";
      end if;

      if (load_i = '1') then
        if (init_i = '1') then
          i <= to_unsigned(0, i'length);
        else
          i <= i + 1;
        end if;
      end if;

      if (load_j = '1') then
        if (init_j = '1') then
          j <= to_unsigned(0, j'length);
        else
          j <= j + 1;
        end if;
      end if;

      if (load_k = '1') then
        if (init_k = '1') then
          k <= to_unsigned(0, k'length);
        else
          k <= k + 1;
        end if;
      end if;

      if (load_err2 = '1') then
        -- multiply err by 2
        err2 <= err & '0';
      end if;

      if (load_err = '1') then
        if (init_err = '1') then
          err <= dx - dy;
        else
          err_interim := err;
          if (ctrl_err_dy = '1') then
            err_interim := err_interim - dy;
          end if;
          if (ctrl_err_dx = '1') then
            err_interim := err_interim + dx;
          end if ;
          err <= err_interim;
        end if;
      end if;

    end if;
  end process;


  -- VGA Driver
  vga_u0 : vga_adapter
    generic map(RESOLUTION => "160x120") 
    port map(resetn    => KEY(3),
             clock     => clock_50,
             colour    => colour,
             x         => std_logic_vector(x),
             y         => std_logic_vector(y),
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


