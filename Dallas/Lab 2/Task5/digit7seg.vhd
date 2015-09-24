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
          digit : IN  UNSIGNED(3 DOWNTO 0);  -- number 0 to 0xF
          seg7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)  -- one per segment
	);
END;


ARCHITECTURE behavioral OF digit7seg IS
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
  variable A     : std_logic_vector(6 downto 0) := "0001000";
  variable B     : std_logic_vector(6 downto 0) := "0000011";
  variable C     : std_logic_vector(6 downto 0) := "1000110";
  variable D     : std_logic_vector(6 downto 0) := "0100001";
  variable E     : std_logic_vector(6 downto 0) := "0000110";
  variable F     : std_logic_vector(6 downto 0) := "0001110";
  
  begin
    case digit is
    when "0000" => seg7 <= zero;
    when "0001" => seg7 <= one;
    when "0010" => seg7 <= two;
    when "0011" => seg7 <= three;
    when "0100" => seg7 <= four;
    when "0101" => seg7 <= five;
    when "0110" => seg7 <= six;
    when "0111" => seg7 <= seven;
    when "1000" => seg7 <= eight;
    when "1001" => seg7 <= nine;
    when "1010" => seg7 <= A;
    when "1011" => seg7 <= B;
    when "1100" => seg7 <= C;
    when "1101" => seg7 <= D;
    when "1110" => seg7 <= E;
    when "1111" => seg7 <= F;
    when others => seg7 <= "0000000"; -- null value
    end case;
  end process;

END;
