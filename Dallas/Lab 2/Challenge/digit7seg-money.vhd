LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ALL;

-----------------------------------------------------
--
--  This block will contain a decoder to decode a 4-bit number
--  to a 7-bit vector suitable to drive a HEX dispaly
--
--  It is a purely combinational block (think Pattern 1) and
--  is similar to a block you designed in Lab 1.
--
--------------------------------------------------------

ENTITY digit7segmoney IS
	PORT(
          digit : IN  UNSIGNED(3 DOWNTO 0);  -- number 0 to 0xF
          seg2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- one per segment
			 seg1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			 seg0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END;


ARCHITECTURE behavioral OF digit7segmoney IS
BEGIN
  process(all)
  variable zero  : std_logic_vector(6 downto 0) := "1000000";
  variable one   : std_logic_vector(6 downto 0) := "1111001";
  variable two   : std_logic_vector(6 downto 0) := "0100100";
  variable three : std_logic_vector(6 downto 0) := "0110000";
  variable four  : std_logic_vector(6 downto 0) := "0011001";
  variable five  : std_logic_vector(6 downto 0) := "0010010";
  variable six   : std_logic_vector(6 downto 0) := "0000010";
  variable seven : std_logic_vector(6 downto 0) := "1111000";
  variable eight : std_logic_vector(6 downto 0) := "0000000";
  variable nine  : std_logic_vector(6 downto 0) := "0011000";
  
  begin
    case digit is
    when unsigned(0, digit'length) =>
												  seg2 <= zero;
												  seg1 <= zero;
												  seg0 <= zero;
    when others =>
						 seg2 <= "1111111"; -- null value
						 seg1 <= "1111111";
						 seg0 <= "1111111";
    end case;
  end process;
  
  gen_wallet_display:
  for I in 0 to (digit'length - 1)

END;
