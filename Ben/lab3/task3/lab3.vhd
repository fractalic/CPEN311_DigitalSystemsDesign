library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lab3 is
  port(CLOCK_50            : in  std_logic;
       KEY                 : in  std_logic_vector(3 downto 0);
       SW                  : in  std_logic_vector(17 downto 0);
       LEDG                : out  std_logic_vector(8 downto 0);
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

  signal x0,x1      : unsigned(7 downto 0);
  signal dx     : signed(x0'left downto x0'right);
  signal sx     : signed(1 downto 0);
  signal xpos     : signed(x0'left downto x0'right);
  signal initxpos : std_logic;
  signal loadxpos : std_logic;

  signal y0,y1      : unsigned(6 downto 0);
  signal dy     : signed(y0'left downto y0'right);
  signal sy     : signed(1 downto 0);
  signal ypos     : signed(y0'left downto y0'right);
  signal initypos : std_logic;
  signal loadypos : std_logic;

  signal colour : std_logic_vector(2 downto 0);
  signal plot   : std_logic;

  signal E2GreaterThanMinusDY : std_logic;
  signal E2LessThanDX         : std_logic;

  signal err     : signed(7 downto 0);
  signal loaderr : std_logic;
  signal initerr : std_logic;
  signal e2      : signed(8 downto 0);
  signal loade2  : std_logic;

  signal lineDone : std_logic;

  signal clock, reset_async : std_logic;

  type vga_state is (line_init, line_analyse, line_step, line_plot, done);

  signal drawState : vga_state;

  signal stateClock : std_logic;

begin

  -- includes the vga adapter, which should be in your project 

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
  
  stateClock <= key(1);

  -- next state logic
  process(stateClock)
  begin
    if (rising_edge(stateClock)) then
      case drawState is
        when line_init => drawState <= line_plot;
        when line_plot =>
          if (lineDone = '1') then
            drawState <= done;
          else
            drawState <= line_analyse;
          end if;
        when line_analyse => drawState <= line_step;
        when line_step    => drawState <= line_plot;
        when others       => drawState <= line_init;
      end case;
    end if;
  end process;

  -- signaling logic
  dx <= abs(signed(x1)-signed(x0));
  dy <= abs(signed(y1)-signed(y0));
  process(x0,y0,x1,y1,e2,dx,dy,xpos,ypos)
  begin
    if (x0 < x1) then
      sx <= to_signed(1,sx'length);
    else
      sx <= to_signed(-1,sx'length);
    end if;

    if (y0 < y1) then
      sy <= to_signed(1,sy'length);
    else
      sy <= to_signed(-1,sy'length);
    end if;

    if (e2 < dx) then
      E2LessThanDX <= '1';
    else 
      E2LessThanDX <= '0';
    end if;

    if (e2 > -1*dy) then
      E2GreaterThanMinusDY <= '1';
    else
      E2GreaterThanMinusDY <= '0';
    end if;

    if ((x1 = unsigned(xpos)) and (y1 = unsigned(ypos))) then
      lineDone <= '1';
    else
      lineDone <= '0';
    end if;
  end process;

  -- output logic
  process(drawState)
  begin
    case drawState is
      when line_init =>
        initerr <= '1';
        loaderr <= '1';
        initxpos <= '1';
        loadxpos <= '1';
        initypos <= '1';
        loadypos <= '1';

        loade2 <= '0';
        plot <= '0';
      when done =>
        initerr <= '0';
        loaderr <= '0';
        initxpos <= '0';
        loadxpos <= '0';
        initypos <= '0';
        loadypos <= '0';
        loade2 <= '0';
        plot <= '0';
      when line_plot =>
        plot <= '1';

        initerr <= '0';
        loaderr <= '0';
        initxpos <= '0';
        loadxpos <= '0';
        initypos <= '0';
        loadypos <= '0';
        loade2 <= '0';
      when line_analyse =>
        loade2 <= '1';

        initerr <= '0';
        loaderr <= '0';
        initxpos <= '0';
        loadxpos <= '0';
        initypos <= '0';
        loadypos <= '0';
        plot <= '0';
      when line_step =>
        loadxpos <= '1';
        loadypos <= '1';
        loaderr  <= '1';

        initerr <= '0';
        initxpos <= '0';
        initypos <= '0';
        plot <= '0';
        loade2 <= '1';
    end case;
  end process;

  clock  <= stateClock;
  colour <= std_logic_vector(ypos(2 downto 0));

  x0 <= to_unsigned(10,x0'length);
  x1 <= to_unsigned(20,x1'length);
  y0 <= to_unsigned(10,y0'length);
  y1 <= to_unsigned(10,y1'length);

  process(stateClock)
  variable newErr : signed(err'left downto err'right);
  variable newXpos : signed(xpos'left downto xpos'right);
  variable newYpos : signed(ypos'left downto ypos'right);
  begin
    if (rising_edge(stateClock)) then
      if (loaderr = '1') then
        newErr := err;
        if (E2GreaterThanMinusDY = '1') then
          newErr := newErr - dy;
        end if;
        if (E2LessThanDX = '1') then
          newErr := newErr + dx;
        end if;
        err <= newErr;
      end if;

      if (loadxpos = '1') then
        if (initxpos = '1') then
          newXpos := signed(x0);
        else
          newXpos := xpos + sx;
        end if;
        xpos <= newXpos;
      end if;

      if (loadypos = '1') then
        if (initypos = '1') then
          ypos <= signed(y0);
        else
          ypos <= ypos + sy;
        end if;
      end if;

      if (loade2 = '1') then
        e2 <= signed(std_logic_vector(err)&'0');
      end if;
    end if;
  end process;

  ledg(7 downto 0) <= std_logic_vector(xpos);

end rtl;


