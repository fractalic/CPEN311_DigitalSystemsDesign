library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3 is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
       LEDG                : out std_logic_vector(7 downto 0);
       LEDR                : out std_logic_vector(17 downto 0);
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
         ctrl_err_dx,
         ctrl_col_done,
         ctrl_row_done,
         ctrl_line_done
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

  type vga_state is (vga_init, vga_plot, vga_nextRow, vga_nextCol,
                     vga_mapLine, vga_initLine, vga_errLine, vga_plotLine,
                     vga_computeLine, vga_stepLine, vga_nextLine, vga_freeze);

  signal drawState : vga_state;

  signal clock_counter : unsigned(27 downto 0);

  signal COLOUR_RESET  : std_logic_vector(2 downto 0);

begin

  COLOUR_RESET <= "001";

  process(clock_50)
  begin
    if (rising_edge(clock_50)) then
      clock_counter <= clock_counter + 1;
    end if;
  end process;

  stateClock <= clock_counter(14);
  --ledg(x'left downto x'right) <= std_logic_vector(x);
  --ledr(y'left downto y'right) <= std_logic_vector(y);

  -- incorrect output
  ledg(dx'left downto dx'right) <= std_logic_vector(dx);
  ledr(dy'left downto dy'right) <= std_logic_vector(dy);

  --ledg(x0'left downto x0'right) <= std_logic_vector(x0);
  --ledr(y0'left downto y0'right) <= std_logic_vector(y0);
  --ledr(17 downto 17-y1'length+1) <= std_logic_vector(y1);

  -- Datapath combinational logic.
  process(x,y,x1,y1)
  begin
    if ((x = x1) and (y = y1)) then
      ctrl_line_done <= '1';
    else
      ctrl_line_done <= '0';
    end if;

    if (x = to_unsigned(159,x'length)) then
      ctrl_row_done <= '1';
    else
      ctrl_row_done <= '0';
    end if;

    if (y = to_unsigned(119,y'length)) then
      ctrl_col_done <= '1';
    else
      ctrl_col_done <= '0';
    end if;

    if (err2 > -1*dy) then
      ctrl_err_dy <= '1';
    else
      ctrl_err_dy <= '0';
    end if;

    if (err2 < dx) then
      ctrl_err_dx <= '1';
    else
      ctrl_err_dx <= '0';
    end if;
  end process;

  -- Datapath registers.
  process(stateClock)
  variable err_interim : signed(err'left downto err'right);
  begin
    if (rising_edge(stateClock)) then
      if (load_colour = '1') then
        if (ctrl_colour_graycode = '1') then
          --colour <= std_logic_vector(k(2 downto 0));
          colour <= "101";
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
        --x0 <= to_unsigned(0, x0'length);
        x0 <= to_unsigned(10, x0'length);
      end if;

      if (load_x1 = '1') then
        --x1 <= to_unsigned(159, x1'length);
        x1 <= to_unsigned(20, x0'length);
      end if;

      if (load_y0 = '1') then
        -- multiply k by 8
        --y0 <= k&"000";
        y0 <= to_unsigned(50, y0'length);
      end if;

      if (load_y1 = '1') then
        --y1 <= to_unsigned(120,y1'length)
        --      - (k&"000");
        y1 <= to_unsigned(60, y0'length);
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

  -- Controller.
  process(stateClock, key(3))
  variable
         load_colour_var,
         load_sx_var,
         load_dx_var,
         load_x_var,
         load_x0_var,
         load_x1_var,
         load_sy_var,
         load_dy_var,
         load_y_var,
         load_y0_var,
         load_y1_var,
         ctrl_colour_graycode_var,
         ctrl_err_dy_var,
         ctrl_err_dx_var,
         ctrl_col_done_var,
         ctrl_row_done_var,
         ctrl_line_done_var,
         clear_screen_var,
         init_x_var,
         init_y_var,
         load_i_var,
         load_j_var,
         load_k_var,
         init_i_var,
         init_j_var,
         init_k_var,
         load_err_var,
         load_err2_var,
         init_err_var,
         plot_var
                : std_logic := '0';
  begin
    if (key(3) = '0') then
      drawState <= vga_init;
    elsif(rising_edge(stateClock)) then
      load_colour_var := '0';
      load_sx_var := '0';
      load_dx_var := '0';
      load_x_var := '0';
      load_x0_var := '0';
      load_x1_var := '0';
      load_sy_var := '0';
      load_dy_var := '0';
      load_y_var := '0';
      load_y0_var := '0';
      load_y1_var := '0';
      ctrl_colour_graycode_var := '0';
      clear_screen_var := '0';
      init_x_var := '0';
      init_y_var := '0';
      load_i_var := '0';
      load_j_var := '0';
      load_k_var := '0';
      init_i_var := '0';
      init_j_var := '0';
      init_k_var := '0';
      load_err_var := '0';
      load_err2_var := '0';
      init_err_var := '0';
      plot_var := '0';

      case drawState is
        when vga_init =>
          --drawState <= vga_plot;
          drawState <= vga_mapLine;

          load_colour_var := '1';
          load_i_var := '1';
          init_i_var := '1';
          load_j_var := '1';
          init_j_var := '1';

          --ledg <= "00000001";

        when vga_plot =>
          if (ctrl_col_done = '1') then
            if (ctrl_row_done = '1') then
              drawState <= vga_mapLine;
            else
              drawState <= vga_nextCol;
            end if;
          else
            drawState <= vga_nextRow;
          end if;

          plot_var := '1';
          clear_screen_var := '1';
          load_x_var   := '1';
          load_y_var   := '1';

          --ledg <= "00000010";

        when vga_nextRow =>
          drawState <= vga_plot;

          load_j_var := '1';
          --ledg <= "10000011";

        when vga_nextCol =>
          drawState <= vga_plot;

          load_i_var := '1';
          load_j_var := '1';
          init_j_var := '1';

          --ledg <= "00000011";

        when vga_mapLine =>
          drawState <= vga_initLine;

          load_x0_var := '1';
          load_x1_var := '1';
          load_y0_var := '1';
          load_y1_var := '1';
          load_k_var  := '1';
          init_k_var  := '1';

          --ledg <= "00000100";

        when vga_initLine =>
          drawState <= vga_errLine;

          load_dx_var := '1';
          load_sx_var := '1';
          load_x_var  := '1';
          init_x_var  := '1';
          load_dy_var := '1';
          load_sy_var := '1';
          load_y_var  := '1';
          init_y_var  := '1';

          --ledg <= "00000101";

        when vga_errLine =>
          drawState <= vga_plotLine;

          load_err_var := '1';
          init_err_var := '1';

          --ledg <= "00000110";

        when vga_plotLine =>
          if (ctrl_line_done = '1') then
            drawState <= vga_nextLine;
          else
            drawState <= vga_computeLine;
          end if;

          ctrl_colour_graycode_var := '1';
          load_colour_var := '1';
          plot_var := '1';

          --ledg <= "00000111";

        when vga_computeLine =>
          drawState <= vga_stepLine;

          load_err2_var := '1';

          --ledg <= "00001000";

        when  vga_stepLine =>
          drawState <= vga_plotLine;

          if (ctrl_err_dy = '1') then
            load_err_var := '1';
            load_x_var  := '1';
          end if;

          if (ctrl_err_dx = '1') then
            load_err_var := '1';
            load_y_var  := '1';
          end if;

          --ledg <= "00001001";

        when vga_nextLine =>
          if (k = to_unsigned(13,k'length)) then
            drawState <= vga_freeze;
          else
            drawState <= vga_mapLine;
          end if;

          load_k_var := '1';

          --ledg <= "00001010";

        when vga_freeze =>
          drawState <= vga_freeze;

          --ledg <= "00001011";

        when others => drawState <= vga_init;
      end case;

        load_colour <= load_colour_var;
        load_sx <= load_sx_var;
        load_dx <= load_dx_var;
        load_x <= load_x_var;
        load_x0 <= load_x0_var;
        load_x1 <= load_x1_var;
        load_sy <= load_sy_var;
        load_dy <= load_dy_var;
        load_y <= load_y_var;
        load_y0 <= load_y0_var;
        load_y1 <= load_y1_var;
        ctrl_colour_graycode <= ctrl_colour_graycode_var;
        clear_screen <= clear_screen_var;
        init_x <= init_x_var;
        init_y <= init_y_var;
        load_i <= load_i_var;
        load_j <= load_j_var;
        load_k <= load_k_var;
        init_i <= init_i_var;
        init_j <= init_j_var;
        init_k <= init_k_var;
        load_err <= load_err_var;
        load_err2 <= load_err2_var;
        init_err <= init_err_var;
        plot <= plot_var;
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


