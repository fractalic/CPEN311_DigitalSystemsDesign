library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--
-- This is a package that provides useful constants and types for Lab 4.
-- 

package lab4_pkg is
  constant SCREEN_WIDTH  : positive := 160;
  constant SCREEN_HEIGHT : positive := 120;
  
  constant FRAC_BITS : natural := 8;
  constant INT_BITS : natural := 8;
  constant INT_ONE  : unsigned(INT_BITS - 1 downto 0) := to_unsigned(1, INT_BITS);
  constant INT_ZERO  : unsigned(INT_BITS - 1 downto 0) := to_unsigned(0, INT_BITS);
  constant FRAC_ZERO : unsigned(FRAC_BITS - 1 downto 0) := to_unsigned(0, FRAC_BITS);

  -- Use the same precision for x and y as it simplifies life
  -- A new type that describes a pixel location on the screen
  type point is record
    x : unsigned(FRAC_BITS + INT_BITS - 1 downto 0);
    y : unsigned(FRAC_BITS + INT_BITS - 1 downto 0);
  end record;

  -- A new type that describes a velocity.  Each component of the
  -- velocity can be either + or -, so use signed type
  type velocity is record
    x : signed(FRAC_BITS + INT_BITS - 1 downto 0);
    y : signed(FRAC_BITS + INT_BITS - 1 downto 0);
  end record;
  
  constant GRAVITY : signed(FRAC_BITS + INT_BITS - 1 downto 0) := "0000000000001000";
  constant PADDLE_SPEED_0 : natural := 2;
  constant PADDLE_SPEED_1 : natural := 5;
  constant PADDLE_SPEED_2 : natural := 10;
  
  --Colours.  
  constant BLACK : std_logic_vector(5 downto 0) := "000000";
  constant BLUE  : std_logic_vector(5 downto 0) := "000011";
  constant GREEN : std_logic_vector(5 downto 0) := "001100";
  constant CYAN : std_logic_vector(5 downto 0) := "001111";
  constant RED   : std_logic_vector(5 downto 0) := "110000";
  constant PURPLE : std_logic_vector(5 downto 0) := "110011";
  constant YELLOW   : std_logic_vector(5 downto 0) := "111100";
  constant WHITE : std_logic_vector(5 downto 0) := "111111";

  constant BG_COLOUR      : std_logic_vector(5 downto 0) := BLACK;
  constant PUCK1_COLOUR   : std_logic_vector(5 downto 0) := "011001";
  constant PUCK2_COLOUR   : std_logic_vector(5 downto 0) := "011011";
  constant PADDLE1_COLOUR : std_logic_vector(5 downto 0) := "110101";
  constant BORDER_COLOUR  : std_logic_vector(5 downto 0) := "101010";
  constant BRICK_COLOUR   : std_logic_vector(5 downto 0) := "111001";

  -- We are going to write this as a state machine.  The following
  -- is a list of states that the state machine can be in.
  
  type draw_state_type is (INIT, START, 
                           DRAW_TOP_ENTER, DRAW_TOP_LOOP, 
									DRAW_RIGHT_ENTER, DRAW_RIGHT_LOOP,
									DRAW_LEFT_ENTER, DRAW_LEFT_LOOP,
                  DRAW_BRICK_ENTER, DRAW_BRICK_LOOP,
                  IDLE, 
									ERASE_PADDLE_ENTER, ERASE_PADDLE_LOOP, 
									DRAW_PADDLE_ENTER, DRAW_PADDLE_LOOP, 
									ERASE_PUCK, DRAW_PUCK, ERASE_PUCK_2,
									DRAW_PUCK_2);

  -- Here are some constants that we will use in the code. 
 
  -- These constants contain information about the paddle 
  constant PADDLE_WIDTH_0 : natural := 10;  -- width, in pixels, of the paddle
  constant PADDLE_WIDTH_1 : natural := 15;
  constant PADDLE_WIDTH_2 : natural := 20;
  constant PADDLE_ROW : natural := SCREEN_HEIGHT - 2;  -- row to draw the paddle 
  constant PADDLE_X_START : natural := SCREEN_WIDTH / 2;  -- starting x position of the paddle

  -- These constants describe the lines that are drawn around the  
  -- border of the screen  
  constant TOP_LINE : natural := 4;
  constant RIGHT_LINE : natural := SCREEN_WIDTH - 5;
  constant LEFT_LINE : natural := 5;

  -- These constants describe the starting location for the puck 
  constant FACEOFF_X : natural := SCREEN_WIDTH/2;
  constant FACEOFF_Y : natural := SCREEN_HEIGHT/2;
  
  constant FACEOFF_X_2 : natural := SCREEN_WIDTH/2 - 20;
  constant FACEOFF_Y_2 : natural := SCREEN_HEIGHT/2;

  constant BRICK_LEFT   : natural := SCREEN_WIDTH/2-5;
  constant BRICK_RIGHT  : natural := SCREEN_WIDTH/2+5;
  constant BRICK_TOP    : natural := SCREEN_HEIGHT/2-34;
  constant BRICK_BOTTOM : natural := SCREEN_HEIGHT/2-24;
  
  -- This constant indicates how many times the counter should count in the
  -- START state between each invocation of the main loop of the program.
  -- A larger value will result in a slower game.  The current setting will    
  -- cause the machine to wait in the start state for 1/8 of a second between 
  -- each invocation of the main loop.  The 50000000 is because we are
  -- clocking our circuit with  a 50Mhz clock. 
  constant LOOP_SPEED : natural := 50000000/16;
  constant PADDLE_SHRINK_SPEED : natural := 50000000*20; -- 20s?
  
  --Component from the Verilog file: vga_adapter.v
  component vga_adapter
    generic(RESOLUTION : string);
    port (resetn                                       : in  std_logic;
          clock                                        : in  std_logic;
          colour                                       : in  std_logic_vector(5 downto 0);
          x                                            : in  std_logic_vector(7 downto 0);
          y                                            : in  std_logic_vector(6 downto 0);
          plot                                         : in  std_logic;
          VGA_R, VGA_G, VGA_B                          : out std_logic_vector(9 downto 0);
          VGA_HS, VGA_VS, VGA_BLANK, VGA_SYNC, VGA_CLK : out std_logic);
  end component;
end;

package body lab4_pkg is
end package body;
