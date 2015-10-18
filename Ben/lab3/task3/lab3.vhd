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

begin

  -- Datapath registers.
  process(stateClock)
  begin
    if (rising_edge(stateClock)) then
      if (load_colour = '1') then
        if (colour_graycode) then
          colour <= graycode;
        else
          colour <= COLOUR_BLACK;
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
            x <= x + sx;
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
            y <= y + sy;
          end if;
        end if;
      end if;

      if (load_x0 = '1') then
        x0 <= to_unsigned(0, x0'length);
      end if;

      if load_x1 = '1') then
        x1 <= to_unsigned(159, x0'length);
      end if;

      if (load_y0 = '1') then
        y0 <= to_unsigned(k,y0'length - 4)*to_unsigned(8, 4);
      end if;

      if (load_y1 = '1') then
        y1 <= to_unsigned(120,y1'length)
              - to_unsigned(k,y1'length - 4)*to_unsigned(8, 4)


    end if;
  end process;


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


