library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.lab4_pkg.all; -- types and constants that we will use
                       -- look in lab4_pkg.vhd to see these defns

----------------------------------------------------------------
--
--  This file is the starting point for Lab 4.  This design implements
--  a simple pong game, with a paddle at the bottom and one ball that 
--  bounces around the screen.  When downloaded to an FPGA board, 
--  KEY(0) will move the paddle to right, and KEY(1) will move the 
--  paddle to the left.  KEY(3) will reset the game.  If the ball drops
--  below the bottom of the screen without hitting the paddle, the game
--  will reset.
--
--  This is written in a combined datapath/state machine style as
--  discussed in the second half of Slide Set 8.  It looks like a 
--  state machine, but the datapath operations that will be performed
--  in each state are described within the corresponding WHEN clause
--  of the state machine.  From this style, Quartus II will be able to
--  extract the state machine from the design.
--
--  In Lab 4, you will modify this file as described in the handout.
--
--  This file makes extensive use of types and constants described in
--  lab4_pkg.vhd    Be sure to read and understand that file before
--  trying to understand this one.
-- 
------------------------------------------------------------------------

-- Entity part of the description.  Describes inputs and outputs

entity lab4 is
    port(CLOCK_50            : in  std_logic;  -- Clock pin
    KEY                 : in  std_logic_vector(3 downto 0);  -- push button switches
     SW                     : in  std_logic_vector(17 downto 0); -- switches for cheat codes!
    VGA_R, VGA_G, VGA_B : out std_logic_vector(9 downto 0);  -- The outs go to VGA controller
    VGA_HS              : out std_logic;
    VGA_VS              : out std_logic;
    VGA_BLANK           : out std_logic;
    VGA_SYNC            : out std_logic;
    VGA_CLK             : out std_logic);
end lab4;

-- Architecture part of the description

architecture rtl of lab4 is

-- These are signals that will be connected to the VGA adapater.
-- The VGA adapater was described in the Lab 3 handout.

signal resetn : std_logic;
signal x      : std_logic_vector(7 downto 0);
signal y      : std_logic_vector(6 downto 0);
signal colour : std_logic_vector(5 downto 0);
signal plot   : std_logic;
signal draw  : point;

-- Be sure to see all the constants, types, etc. defined in lab4_pkg.vhd

begin

    -- include the VGA controller structurally.  The VGA controller 
    -- was decribed in Lab 3.  You probably know it in great detail now, but 
    -- if you have forgotten, please go back and review the description of the 
    -- VGA controller in Lab 3 before trying to do this lab.

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

    -- the x and y lines of the VGA controller will be always
    -- driven by draw.x and draw.y.   The process below will update
    -- signals draw.x and draw.y.

    x <= std_logic_vector(draw.x(x'range));
    y <= std_logic_vector(draw.y(y'range));


    -- =============================================================================

    -- This is the main process.  As described above, it is written in a combined
    -- state machine / datapath style.  It looks like a state machine, but rather
    -- than simply driving control signals in each state, the description describes 
    -- the datapath operations that happen in each state.  From this Quartus II
    -- will figure out a suitable datapath for you.

    -- Notice that this is written as a pattern-3 process (sequential with an
    -- asynchronous reset)

    controller_state : process(CLOCK_50, KEY)  

    -- This variable will contain the state of our state machine.  The 
    -- draw_state_type was defined above as an enumerated type  
    variable state : draw_state_type := START; 

    -- This variable will store the x position of the paddle (left-most pixel of the paddle)
    variable paddle_x : unsigned(draw.x'range);

    -- These variables will store the puck and the puck velocity.
    -- In this implementation, the puck velocity has two components: an x component
    -- and a y component.  Each component is always +1 or -1.
    variable puck : point;
    variable puck_velocity : velocity;
    variable puck2 : point;
    variable puck2_velocity : velocity;

    -- This will be used as a counter variable in the IDLE state
    variable clock_counter : natural := 0;

    variable PADDLE_SHRINK_COUNT : natural := 0;
    variable PADDLE_SHRINK_NUMBER : natural := 0;
    variable PADDLE_SPEED : natural := 2;
    variable PADDLE_WIDTH : natural := 10;

    variable BRICK_COLOUR_VAR : std_logic_vector(5 downto 0) := BRICK_COLOUR;

begin

    if KEY(3) = '0' then
        state := INIT;
    elsif rising_edge(CLOCK_50) then

    case state is

    when INIT =>

        draw <= (x => to_unsigned(0, draw.x'length),
        y => to_unsigned(0, draw.y'length));             
        paddle_x := to_unsigned(PADDLE_X_START, paddle_x'length);

        puck.x := to_unsigned(FACEOFF_X, 8) & "00000000";
        puck.y := to_unsigned(FACEOFF_Y, 8) & "00000000";
        puck2.x := to_unsigned(FACEOFF_X_2, 8) & "00000000";
        puck2.y := to_unsigned(FACEOFF_Y_2, 8) & "00000000";
        puck_velocity.x := "0000000011110000";--to_signed(1, puck_velocity.x'length);
        puck_velocity.y := -"0000000001000000";--to_signed(-1, puck_velocity.y'length); -- up to right at 45 degrees
        puck2_velocity.x := "0000000011100000";--to_signed(1, puck2_velocity.x'length);
        puck2_velocity.y := -"0000000010000000";--to_signed(-1, puck2_velocity.y'length); -- down to right at 45 degrees
        colour <= BG_COLOUR;
        plot <= '1';
        PADDLE_SHRINK_COUNT := 0;
        PADDLE_SHRINK_NUMBER := 0;
        state := START;

    when START =>   
          
        if (draw.x = SCREEN_WIDTH-1) then
            if (draw.y = SCREEN_HEIGHT-1) then
                state := DRAW_TOP_ENTER;
            else
                draw.y <= draw.y + to_unsigned(1, draw.y'length);
                draw.x <= to_unsigned(0, draw.x'length);                
            end if;
        else
            draw.x <= draw.x + to_unsigned(1, draw.x'length);
        end if;

    when DRAW_TOP_ENTER =>                
        draw.x <= to_unsigned(LEFT_LINE, draw.x'length);
        draw.y <= to_unsigned(TOP_LINE, draw.y'length);
        colour <= BORDER_COLOUR;
        state := DRAW_TOP_LOOP;

    when DRAW_TOP_LOOP =>
        if draw.x = RIGHT_LINE then            
            state := DRAW_RIGHT_ENTER;
        else
            draw.y <= to_unsigned(TOP_LINE, draw.y'length);
            draw.x <= draw.x + to_unsigned(1, draw.x'length);
        end if;

    when DRAW_RIGHT_ENTER =>              
        draw.y <= to_unsigned(TOP_LINE, draw.y'length);
        draw.x <= to_unsigned(RIGHT_LINE, draw.x'length); 
        state := DRAW_RIGHT_LOOP;

    when DRAW_RIGHT_LOOP => 
        if draw.y = SCREEN_HEIGHT-1 then
            state := DRAW_LEFT_ENTER;
        else               
            draw.x <= to_unsigned(RIGHT_LINE,draw.x'length);
            draw.y <= draw.y + to_unsigned(1, draw.y'length);
        end if;

    when DRAW_LEFT_ENTER =>               
        draw.y <= to_unsigned(TOP_LINE, draw.y'length);
        draw.x <= to_unsigned(LEFT_LINE, draw.x'length);  
        state := DRAW_LEFT_LOOP;

    when DRAW_LEFT_LOOP =>       
        if (draw.y = SCREEN_HEIGHT-1) then
            state := DRAW_BRICK_ENTER;
            clock_counter := 0;
        else                   
            draw.x <= to_unsigned(LEFT_LINE, draw.x'length);
            draw.y <= draw.y + to_unsigned(1, draw.y'length);
        end if;

    when DRAW_BRICK_ENTER =>
        colour <= BRICK_COLOUR_VAR;
        draw.x <= to_unsigned(BRICK_LEFT, draw.x'length);
        draw.y <= to_unsigned(BRICK_TOP, draw.y'length);
        state := DRAW_BRICK_LOOP;

    when DRAW_BRICK_LOOP =>
        if (draw.y = BRICK_TOP) then
            if (draw.x = BRICK_RIGHT) then
                draw.y <= draw.y + to_unsigned(1, draw.y'length);
            else
                draw.x <= draw.x + to_unsigned(1, draw.x'length);
            end if;
        elsif (draw.x = BRICK_RIGHT) then
            if (draw.y = BRICK_BOTTOM) then
                draw.x <= draw.x - to_unsigned(1, draw.x'length);
            else
                draw.y <= draw.y + to_unsigned(1, draw.y'length);
            end if;
        elsif (draw.y = BRICK_BOTTOM) then
            if (draw.x = BRICK_LEFT) then
                draw.y <= draw.y - to_unsigned(1, draw.y'length);
            else
                draw.x <= draw.x - to_unsigned(1, draw.x'length);
            end if;
        elsif (draw.x = BRICK_LEFT) then
            if (draw.y = BRICK_TOP + to_unsigned(1, draw.y'length)) then
                state := IDLE;
            else
                draw.y <= draw.y - to_unsigned(1, draw.y'length);
            end if;
        else
            state := IDLE;
        end if;

    when IDLE => 
        plot <= '0';

        if (clock_counter < LOOP_SPEED) then
            clock_counter := clock_counter + 1;
        else
            state := ERASE_PADDLE_ENTER;

            clock_counter := 0;
            PADDLE_SHRINK_COUNT := PADDLE_SHRINK_COUNT + 1;

            if SW(0) = '0' then
                puck_velocity.y := puck_velocity.y + GRAVITY; -- green
            end if;
            if SW(1) = '0' then
                puck2_velocity.y := puck2_velocity.y + GRAVITY; -- blue
            end if;

            if SW(2) = '1' then
                PADDLE_SPEED := PADDLE_SPEED_1;
            elsif SW(3) = '1' then
                PADDLE_SPEED := PADDLE_SPEED_2;
            else
                PADDLE_SPEED := PADDLE_SPEED_0;
            end if;

        end if;

    when ERASE_PADDLE_ENTER =>
        draw.y <= to_unsigned(PADDLE_ROW, draw.y'length);
        draw.x <= paddle_x;
        colour <= BG_COLOUR;
        plot <= '1';
        state := ERASE_PADDLE_LOOP;

    when ERASE_PADDLE_LOOP =>
        if draw.x = paddle_x + PADDLE_WIDTH - 1 - PADDLE_SHRINK_NUMBER then
            state := DRAW_PADDLE_ENTER;
        else
            draw.y <= to_unsigned(PADDLE_ROW, draw.y'length);
            draw.x <= draw.x + to_unsigned(1, draw.x'length);
        end if;

    when DRAW_PADDLE_ENTER =>

        if (PADDLE_SHRINK_COUNT >= 160) then -- every 20s (20 * 8/s)
            PADDLE_SHRINK_COUNT := 0;
            PADDLE_SHRINK_NUMBER := PADDLE_SHRINK_NUMBER + 1;

            if (PADDLE_SHRINK_NUMBER >= 6) then
                PADDLE_SHRINK_NUMBER := 6;
            end if;
            
        end if;    

        if (SW(4) = '1') then
            PADDLE_WIDTH := PADDLE_WIDTH_1;
        elsif (SW(5) = '1') then
            PADDLE_WIDTH := PADDLE_WIDTH_2;
        else
            PADDLE_WIDTH := PADDLE_WIDTH_0;
        end if;

        if (KEY(0) = '0') then
            
            if paddle_x < to_unsigned(RIGHT_LINE - PADDLE_WIDTH - PADDLE_SPEED + PADDLE_SHRINK_NUMBER, paddle_x'length) then 
                paddle_x := paddle_x + to_unsigned(PADDLE_SPEED, paddle_x'length);
            else
                paddle_x := to_unsigned(RIGHT_LINE - PADDLE_WIDTH + PADDLE_SHRINK_NUMBER, paddle_x'length);
            end if;
        elsif (KEY(1) = '0') then
            if paddle_x > to_unsigned(LEFT_LINE + PADDLE_SPEED, paddle_x'length) then
                paddle_x := paddle_x - to_unsigned(PADDLE_SPEED, paddle_x'length);
            else
                paddle_x := to_unsigned(LEFT_LINE + 1, paddle_x'length);                
            end if;
        end if;
        draw.y <= to_unsigned(PADDLE_ROW, draw.y'length);                
        draw.x <= paddle_x;           
        colour <= PADDLE1_COLOUR;       
        state := DRAW_PADDLE_LOOP;

    when DRAW_PADDLE_LOOP =>

        if draw.x = paddle_x + PADDLE_WIDTH - PADDLE_SHRINK_NUMBER - 1 then
            plot  <= '0';  
            state := ERASE_PUCK;
        else
            draw.y <= to_unsigned(PADDLE_ROW, draw.y'length);
            draw.x <= draw.x + to_unsigned(1, draw.x'length);
        end if;

    when ERASE_PUCK =>
        colour <= BG_COLOUR;
        plot <= '1';
        draw.x <= "00000000" & puck.x(15 downto 8);  
        draw.y <= "00000000" & puck.y(15 downto 8);

        state := DRAW_PUCK;
        puck.x := unsigned(signed(puck.x) + puck_velocity.x);
        puck.y := unsigned(signed(puck.y) + puck_velocity.y);               

        -- Check for collision with bounds.
        if puck.y <= (TOP_LINE + to_unsigned(1, INT_BITS)) & to_unsigned(0, FRAC_BITS) then
            puck.y := (TOP_LINE + to_unsigned(1, INT_BITS)) & to_unsigned(0, FRAC_BITS);
            puck_velocity.y := 0-puck_velocity.y;
        end if;

        if (puck.x <= (LEFT_LINE + to_unsigned(1, INT_BITS)) & to_unsigned(0, FRAC_BITS) ) then
            puck.x := (LEFT_LINE + to_unsigned(1, INT_BITS)) & to_unsigned(0, FRAC_BITS);
            puck_velocity.x := 0-puck_velocity.x;
        end if;

        if (puck.x >= (RIGHT_LINE - to_unsigned(1, INT_BITS)) & to_unsigned(0, FRAC_BITS)) then
            puck.x := (RIGHT_LINE - to_unsigned(1, INT_BITS)) & to_unsigned(0, FRAC_BITS);
            puck_velocity.x := 0-puck_velocity.x;
        end if;

        -- Check for collision with paddle.
        if puck.y >= PADDLE_ROW - "00000001" & "00000000" then--PADDLE_ROW - 1 then
            if puck.x >= paddle_x & "00000000" and puck.x <= paddle_x + PADDLE_WIDTH - PADDLE_SHRINK_NUMBER & "00000000" then
                puck.y := (PADDLE_ROW - to_unsigned(1, INT_BITS)) & to_unsigned(0, FRAC_BITS);
                puck_velocity.y := 0-puck_velocity.y;
            else
                state := INIT;
            end if;     
        end if;

        -- Check for collision with brick
        if ( ( (puck.x >= to_unsigned(BRICK_LEFT, INT_BITS) & FRAC_ZERO) and
               (puck.x <= to_unsigned(BRICK_RIGHT, INT_BITS) & FRAC_ZERO)    ) and
             ( (puck.y >= to_unsigned(BRICK_TOP, INT_BITS) & FRAC_ZERO) and
               (puck.y <= to_unsigned(BRICK_BOTTOM, INT_BITS) & FRAC_ZERO)   ) ) then
            if ( (unsigned(signed(puck.x) - puck_velocity.x) < to_unsigned(BRICK_LEFT, INT_BITS) & FRAC_ZERO) or
                 (unsigned(signed(puck.x) - puck_velocity.x) > to_unsigned(BRICK_RIGHT, INT_BITS) & FRAC_ZERO) ) then
                if (puck_velocity.x > "00000000") then
                    puck.x := (to_unsigned(BRICK_LEFT, INT_BITS) - INT_ONE) & FRAC_ZERO;
                else
                    puck.x := (to_unsigned(BRICK_RIGHT, INT_BITS) + INT_ONE) & FRAC_ZERO;
                end if;

                puck_velocity.x := 0-puck_velocity.x;
            else
                if (puck_velocity.y > "00000000") then
                    puck.y := (to_unsigned(BRICK_TOP, INT_BITS) - INT_ONE) & FRAC_ZERO;
                else
                    puck.y := (to_unsigned(BRICK_BOTTOM, INT_BITS) + INT_ONE) & FRAC_ZERO;
                end if;
                puck_velocity.y := 0-puck_velocity.y;
            end if;
            BRICK_COLOUR_VAR := PUCK1_COLOUR;
        end if;

    when DRAW_PUCK =>
        colour <= PUCK1_COLOUR;
        plot <= '1';
        draw.x <= "00000000" & puck.x(15 downto 8);  
        draw.y <= "00000000" & puck.y(15 downto 8);
        state := ERASE_PUCK_2;

    when ERASE_PUCK_2 =>
        colour <= BG_COLOUR;
        plot <= '1';
        draw.x <= "00000000" & puck2.x(15 downto 8);  
        draw.y <= "00000000" & puck2.y(15 downto 8);

        state := DRAW_PUCK_2;

        puck2.x := unsigned(signed(puck2.x) + puck2_velocity.x);
        puck2.y := unsigned(signed(puck2.y) + puck2_velocity.y);                

        if puck2.y <= (TOP_LINE + to_unsigned(1, INT_BITS)) & to_unsigned(0, FRAC_BITS) then
            puck2.y := (TOP_LINE + to_unsigned(1, INT_BITS)) & to_unsigned(0, FRAC_BITS);
            puck2_velocity.y := 0-puck2_velocity.y;
        end if;

        if (puck2.x <= (LEFT_LINE + to_unsigned(1, INT_BITS)) & to_unsigned(0, FRAC_BITS) ) then
            puck2.x := (LEFT_LINE + to_unsigned(1, INT_BITS)) & to_unsigned(0, FRAC_BITS);
            puck2_velocity.x := 0-puck2_velocity.x;
        end if;

        if (puck2.x >= (RIGHT_LINE - to_unsigned(1, INT_BITS)) & to_unsigned(0, FRAC_BITS)) then
            puck2.x := (RIGHT_LINE - to_unsigned(1, INT_BITS)) & to_unsigned(0, FRAC_BITS);
            puck2_velocity.x := 0-puck2_velocity.x;
        end if;

        if puck2.y >= PADDLE_ROW - "00000001" & "00000000" then
            if ( (puck2.x >= paddle_x & "00000000") and
                 (puck2.x <= (paddle_x + PADDLE_WIDTH - PADDLE_SHRINK_NUMBER) & "00000000") ) then
                puck2.y := (PADDLE_ROW - to_unsigned(1, INT_BITS)) & to_unsigned(0, FRAC_BITS);
                puck2_velocity.y := 0-puck2_velocity.y;
            else
                state := INIT;
            end if;     
        end if;

        -- Check for collision with brick
        if ( ( (puck2.x >= to_unsigned(BRICK_LEFT, INT_BITS) & FRAC_ZERO) and
               (puck2.x <= to_unsigned(BRICK_RIGHT, INT_BITS) & FRAC_ZERO)    ) and
             ( (puck2.y >= to_unsigned(BRICK_TOP, INT_BITS) & FRAC_ZERO) and
               (puck2.y <= to_unsigned(BRICK_BOTTOM, INT_BITS) & FRAC_ZERO)   ) ) then
            if ( (unsigned(signed(puck2.x) - puck2_velocity.x) < to_unsigned(BRICK_LEFT, INT_BITS) & FRAC_ZERO) or
                 (unsigned(signed(puck2.x) - puck2_velocity.x) > to_unsigned(BRICK_RIGHT, INT_BITS) & FRAC_ZERO) ) then
                if (puck2_velocity.x > "00000000") then
                    puck2.x := (to_unsigned(BRICK_LEFT, INT_BITS) - INT_ONE) & FRAC_ZERO;
                else
                    puck2.x := (to_unsigned(BRICK_RIGHT, INT_BITS) + INT_ONE) & FRAC_ZERO;
                end if;

                puck2_velocity.x := 0-puck2_velocity.x;
            else
                if (puck2_velocity.y > "00000000") then
                    puck2.y := (to_unsigned(BRICK_TOP, INT_BITS) - INT_ONE) & FRAC_ZERO;
                else
                    puck2.y := (to_unsigned(BRICK_BOTTOM, INT_BITS) + INT_ONE) & FRAC_ZERO;
                end if;
                puck2_velocity.y := 0-puck2_velocity.y;
            end if;
            BRICK_COLOUR_VAR := PUCK2_COLOUR;
        end if;

    when DRAW_PUCK_2 =>
        colour <= PUCK2_COLOUR;
        plot <= '1';
        draw.x <= "00000000" & puck2.x(15 downto 8);  
        draw.y <= "00000000" & puck2.y(15 downto 8);
        state := DRAW_BRICK_ENTER;

    when others =>
        state := START;

    end case;
    end if;
    end process;
end rtl;


