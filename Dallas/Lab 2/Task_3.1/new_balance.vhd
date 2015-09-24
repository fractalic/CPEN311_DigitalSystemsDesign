LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
LIBRARY WORK;
USE WORK.ALL;

--------------------------------------------------------------
--
-- Skeleton file for new_balance subblock.  This block is purely
-- combinational (think Pattern 1 in the slides) and calculates the
-- new balance after adding winning bets and subtracting losing bets.
--
---------------------------------------------------------------


ENTITY new_balance IS
  PORT(money : in unsigned(11 downto 0);  -- Current balance before this spin
       value1 : in unsigned(2 downto 0);  -- Value of bet 1
       value2 : in unsigned(2 downto 0);  -- Value of bet 2
       value3 : in unsigned(2 downto 0);  -- Value of bet 3
       bet1_wins : in std_logic;  -- True if bet 1 is a winner
       bet2_wins : in std_logic;  -- True if bet 2 is a winner
       bet3_wins : in std_logic;  -- True if bet 3 is a winner
       new_money : out unsigned(11 downto 0));  -- balance after adding winning
                                                -- bets and subtracting losing bets
END new_balance;


ARCHITECTURE behavioural OF new_balance IS
BEGIN
  
  process (all)
    variable bet1_outcome is unsigned := (7 downto 0); -- needs to hold up to 245
    variable bet2_outcome is unisgned := (2 downto 0); -- needs to hold up to 7
    variable bet3_outcome is unsigned := (4 downto 0); -- needs to hold up to 14
    begin
      case bet1_wins is
      when '1' => -- winner! 35:1
        bet1_outcome := 35 * value1;
      when others => bet1_outcome := not value1; -- loss of bet amount
      end case;
      
      case bet2_wins is
      when '1' => -- winner! 1:1
        bet2_outcome <= value2;
      when others => bet2_outcome := not value2; -- loss of bet amount
      end process;
        
      case bet3_wins is
      when '1' =>  -- winner! 2:1
        bet3_outcome <= 2 * value3;
      when others => bet3_outcome := not value3; -- loss of bet amount
      end case;
      
      new_money <= bet1_outcome + bet2_outcome + bet3_outcome;
        
  end process;
  
END;
