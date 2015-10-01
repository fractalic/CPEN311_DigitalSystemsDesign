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
  
  process (all)
  begin
    if spin_result_latched = bet1_value then
      bet1_wins <= '1';
    else bet1_wins <= '0';
    end if;
  end process;
    
  process(all)
  begin
	 if spin_result_latched > 0 then
    case bet2_colour is
    when '1' => -- red
      if (spin_result_latched < 11) or (spin_result_latched > 18 and spin_result_latched < 29) then -- half the set
        if spin_result_latched mod 2 = 0 then
          bet2_wins <= '0'; -- number is even / black
        else bet2_wins <= '1'; -- number is odd / red
        end if;
      else -- the other half of the set is obvious, doesn't need another if
        if spin_result_latched mod 2 = 0 then
          bet2_wins <= '1'; -- number is even / red
        else bet2_wins <= '0'; -- number is odd / black
        end if;
      end if;
    when '0' => -- black, opposite win logic to red
      if (spin_result_latched < 11) or (spin_result_latched > 18 and spin_result_latched < 29) then -- half the set
        if spin_result_latched mod 2 = 0 then
          bet2_wins <= '1'; -- number is even / black
        else bet2_wins <= '0'; -- number is odd / red
        end if;
      else -- the other half of the set is obvious, doesn't need another if
        if spin_result_latched mod 2 = 0 then
          bet2_wins <= '0'; -- number is even / red
        else bet2_wins <= '1'; -- number is odd / black
        end if;
      end if;
    when others => bet2_wins <= '0'; -- only a win is a win
    end case;
	 else bet2_wins <= '0';
	 end if;
   end process;
	
	process(all)
		begin
	 if spin_result_latched > 0 then
    case bet3_dozen is
    when "00" => -- first dozen
      if spin_result_latched < 13 then
        bet3_wins <= '1';
      else bet3_wins <= '0';
      end if;
    when "01" => -- second dozen
		if spin_result_latched > 12 then
			if spin_result_latched < 25 then
				bet3_wins <= '1';
         else bet3_wins <= '0';
         end if;
		else bet3_wins <= '0';
	   end if;
    when "10" => -- third dozen
		if spin_result_latched > 12 then
			if spin_result_latched > 24 then
				if spin_result_latched < 37 then
					bet3_wins <= '1';
				else bet3_wins <= '0';
				end if;
			else bet3_wins <= '0';
			end if;
		else bet3_wins <= '0';
		end if;
    when others => bet3_wins <= '0'; -- only a win is a win
    end case;
	 else bet3_wins <= '0';
	 end if;
  end process;
  
END;
