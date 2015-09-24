LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
LIBRARY WORK;
USE WORK.ALL;

--------------------------------------------------------------
--
--  This is a skeleton you can use for the win subblock.  This block determines
--  whether each of the 3 bets is a winner.  As described in the lab
--  handout, the first bet is a "straight-up" bet, the second bet is 
--  a colour bet, and the third bet is a "dozen" bet.
--
--  This should be a purely combinational block.  There is no clock.
--  Remember the rules associated with Pattern 1 in the lectures.
--
---------------------------------------------------------------

ENTITY win IS
	PORT(spin_result_latched : in unsigned(5 downto 0);  -- result of the spin (the winning number)
             bet1_value : in unsigned(5 downto 0); -- value for bet 1
             bet2_colour : in std_logic;  -- colour for bet 2
             bet3_dozen : in unsigned(1 downto 0);  -- dozen for bet 3
             bet1_wins : out std_logic;  -- whether bet 1 is a winner
             bet2_wins : out std_logic;  -- whether bet 2 is a winner
             bet3_wins : out std_logic); -- whether bet 3 is a winner
END win;

ARCHITECTURE behavioural OF win IS
  
BEGIN
  bet1 : process
  begin
    if (bet1_value = spin_result_latched) then
      bet1_wins <= '1';
    else bet1_wins <= '0';
    end if;
  end process;
  
  bet2 : process
  type colour_array is array (0 to 17) of std_logic_vector(5 downto 0); -- array describing the different sets of colours
  variable red : colour_array := ("000001", "000011", "000101", "000111", "001001", "001100", "001110", "010000", "010010", "010011", "010101", 
                                  "010111", "011001", "011011", "011110", "100000", "100010", "100100");
  variable black : colour_array := ("000010", "000100", "000110", "001000", "001010", "001011", "001101", "001111", "010001", "010100", "010110",
                                    "011000", "011010", "011100", "011101", "011111", "100001", "100011");
  begin
    case bet2_colour is
      when '1' => -- red
        for i in 0 to 17 loop
          if (spin_result_latched = red(i)) then -- runs through red variable, checks for a match
            bet2_wins <= '1';
          else bet2_wins <= '0';
          end if;
        end loop;
      when '0' => -- black
        for i in 0 to 17 loop
          if (spin_result_latched = black(i)) then -- runs through black variable, checks for a match
            bet2_wins <= '1';
          else bet2_wins <= '0';
          end if;
        end loop;
      when others => bet2_wins <= '0'; -- only a win is a win
    end case;
  end process;
  
  bet3 : process
  type dozen_array is array (0 to 11) of std_logic_vector(5 downto 0);
  variable first_dozen : dozen_array := ("000001", "000010", "000011", "000100", "000101", "000110", "000111", "001000", "001001", "001010", "001011", "001100");
  variable second_dozen : dozen_array := ("001101", "001110", "001111", "010000", "010001", "010010", "010011", "010100", "010101", "010110", "010111", "011000");
  variable third_dozen : dozen_array := ("011001", "011010", "011011", "011100", "011101", "011110", "011111", "100000", "100001", "100010", "100011", "100100");
  begin
    case bet3_dozen is
      when "00" => -- first dozen
        for i in 0 to 11 loop
          if (spin_result_latched = first_dozen(i)) then -- checks whether the winning number is in first_dozen
            bet3_wins <= '1';
          else bet3_wins <= '0';
          end if;
        end loop;
      when "01" => -- second dozen
        for i in 0 to 11 loop
          if (spin_result_latched = second_dozen(i)) then -- checks whether the winning number is in second_dozen
            bet3_wins <= '1';
          else bet3_wins <= '0';
          end if;
        end loop;
      when "10" => -- third dozen
        for i in 0 to 11 loop
          if (spin_result_latched = third_dozen(i)) then -- checks whether the winning number is in third_dozen
            bet3_wins <= '1';
          else bet3_wins <= '0';
          end if;
        end loop;
      when others => bet3_wins <= '0'; -- only a win is a win
    end case;
  end process;
  
END;
