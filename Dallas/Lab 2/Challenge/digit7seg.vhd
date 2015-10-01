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

ENTITY digit7seg IS
	PORT(
          digit : IN  UNSIGNED(5 DOWNTO 0);  -- number 0 to 32
          seg7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- one per segment
			 seg6 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
	);
END;


ARCHITECTURE impl OF digit7seg IS
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
    when "000000" =>
							seg7 <= zero;
							seg6 <= zero;
    when "000001" =>
							seg7 <= zero;
							seg6 <= one;
    when "000010" =>
							seg7 <= zero;
							seg6 <= two;
    when "000011" =>
							seg7 <= zero;
							seg6 <= three;
    when "000100" =>
							seg7 <= zero;
							seg6 <= four;
    when "000101" =>
							seg7 <= zero;
							seg6 <= five;
    when "000110" =>
							seg7 <= zero;
							seg6 <= six;
    when "000111" =>
							seg7 <= zero;
							seg6 <= seven;
    when "001000" =>
							seg7 <= zero;
							seg6 <= eight;
    when "001001" =>
							seg7 <= zero;
							seg6 <= nine;
    when "001010" =>
							seg7 <= one;
							seg6 <= zero;
    when "001011" =>
							seg7 <= one;
							seg6 <= one;
    when "001100" =>
							seg7 <= one;
							seg6 <= two;
    when "001101" =>
							seg7 <= one;
							seg6 <= three;
    when "001110" =>
							seg7 <= one;
							seg6 <= four;
    when "001111" =>
							seg7 <= one;
							seg6 <= five;
	 when "010000" =>
							seg7 <= one;
							seg6 <= six;
	 when "010001" =>
							seg7 <= one;
							seg6 <= seven;
	 when "010010" =>
							seg7 <= one;
							seg6 <= eight;
	 when "010011" =>
							seg7 <= one;
							seg6 <= nine;
	 when "010100" =>
							seg7 <= two;
							seg6 <= zero;
	 when "010101" =>
							seg7 <= two;
							seg6 <= one;
	 when "010110" =>
							seg7 <= two;
							seg6 <= two;
	 when "010111" =>
							seg7 <= two;
							seg6 <= three;
	 when "011000" =>
							seg7 <= two;
							seg6 <= four;
	 when "011001" =>
							seg7 <= two;
							seg6 <= five;
	 when "011010" =>
							seg7 <= two;
							seg6 <= six;
	 when "011011" =>
							seg7 <= two;
							seg6 <= seven;
	 when "011100" =>
							seg7 <= two;
							seg6 <= eight;
	 when "011101" =>
							seg7 <= two;
							seg6 <= nine;
	 when "011110" =>
							seg7 <= three;
							seg6 <= zero;
	 when "011111" =>
							seg7 <= three;
							seg6 <= one;
	 when "100000" =>
							seg7 <= three;
							seg6 <= two;
	 when "100001" =>
							seg7 <= three;
							seg6 <= three;
	 when "100010" =>
							seg7 <= three;
							seg6 <= four;
	 when "100011" =>
							seg7 <= three;
							seg6 <= five;
	 when "100100" =>
							seg7 <= three;
							seg6 <= six;
    when others =>
							seg7 <= "1111111"; -- null value
							seg6 <= "1111111";
    end case;
  end process;

END;
