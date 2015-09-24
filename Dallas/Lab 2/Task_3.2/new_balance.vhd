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
    variable balance : unsigned(11 downto 0); -- outcome of bet
    variable unsigned_value1: unsigned(11 downto 0);
    variable unsigned_value2: unsigned(11 downto 0);
    variable unsigned_value3: unsigned(11 downto 0);
    begin
      balance := money; -- holds the value of money temporarily
      unsigned_value1 := to_unsigned(1, 9) * value1; -- converts values to appropriate length (12)
      unsigned_value2 := to_unsigned(1, 9) * value2;
      unsigned_value3 := to_unsigned(1, 9) * value3;
      case bet1_wins is
      when '1' => -- winner! 35:1
        balance := balance + (to_unsigned(35, 9) * value1);
      when others => balance := balance - unsigned_value1; -- loss of bet amount
      end case;
      
      case bet2_wins is
      when '1' => -- winner! 1:1
        balance := balance + unsigned_value2;
      when others => balance := balance - unsigned_value2; -- loss of bet amount
      end case;
        
      case bet3_wins is
      when '1' =>  -- winner! 2:1
        balance := balance + (to_unsigned(2, 9) * value3);
      when others => balance := balance - unsigned_value3; -- loss of bet amount
      end case;
      
      new_money <= balance;
        
  end process;
  
END;
