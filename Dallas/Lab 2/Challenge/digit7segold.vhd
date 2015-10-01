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

ENTITY digit7segold IS
	PORT(
          digit : IN  UNSIGNED(3 DOWNTO 0);  -- number 0 to 0xF
          seg2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
			 seg1 : OUT STD_LOGIC_VECTOR(6 downto 0);
			 seg0 : OUT STD_LOGIC_VECTOR(6 downto 0)-- one per segment
	);
END;


ARCHITECTURE behavioral OF digit7segold IS
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
    if digit < unsigned(0, digit'length) then
		seg2 <= zero;
		seg1 <= zero;
		seg0 <= zero;
		
	 if digit < unsigned(100, digit'length) then
		seg2 <= zero;
		if digit < unsigned(10, digit'length) then seg1 <= zero;
			elsif digit < unsigned(20, digit'length) then seg1 <= one;
			elsif digit < unsigned(30, digit'length) then seg1 <= two;
			elsif digit < unsigned(40, digit'length) then seg1 <= three;
			elsif digit < unsigned(50, digit'length) then seg1 <= four;
			elsif digit < unsigned(60, digit'length) then seg1 <= five;
			elsif digit < unsigned(70, digit'length) then seg1 <= six;
			elsif digit < unsigned(80, digit'length) then seg1 <= seven;
			elsif digit < unsigned(90, digit'length) then seg1 <= eight;
			elsif digit < unsigned(100, digit'length) then seg1 <= nine;
			else seg1 <= "1111111";
		end if;
		case digit(2 downto 0) is
			when unsigned(0, digit'length) => seg0 <= zero;
			when unsigned(1, digit'length) => seg0 <= one;
			when unsigned(2, digit'length) => seg0 <= two;
			when unsigned(3, digit'length) => seg0 <= three;
			when unsigned(4, digit'length) => seg0 <= four;
			when unsigned(5, digit'length) => seg0 <= five;
			when unsigned(6, digit'length) => seg0 <= six;
			when unsigned(7, digit'length) => seg0 <= seven;
			when unsigned(8, digit'length) => seg0 <= eight;
			when unsigned(9, digit'length) => seg0 <= nine;
			when others => seg0 <= "1111111";
		 end case;
		 
	 elsif digit < unsigned(200, digit'length) then
		seg2 <= one;
		if digit < unsigned(110, digit'length) then seg1 <= zero;
			elsif digit < unsigned(120, digit'length) then seg1 <= one;
			elsif digit < unsigned(130, digit'length) then seg1 <= two;
			elsif digit < unsigned(140, digit'length) then seg1 <= three;
			elsif digit < unsigned(150, digit'length) then seg1 <= four;
			elsif digit < unsigned(160, digit'length) then seg1 <= five;
			elsif digit < unsigned(170, digit'length) then seg1 <= six;
			elsif digit < unsigned(180, digit'length) then seg1 <= seven;
			elsif digit < unsigned(190, digit'length) then seg1 <= eight;
			elsif digit < unsigned(200, digit'length) then seg1 <= nine;
			else seg1 <= "1111111";
		end if;
		case digit(2 downto 0) is
			when unsigned(0, digit'length) => seg0 <= zero;
			when unsigned(1, digit'length) => seg0 <= one;
			when unsigned(2, digit'length) => seg0 <= two;
			when unsigned(3, digit'length) => seg0 <= three;
			when unsigned(4, digit'length) => seg0 <= four;
			when unsigned(5, digit'length) => seg0 <= five;
			when unsigned(6, digit'length) => seg0 <= six;
			when unsigned(7, digit'length) => seg0 <= seven;
			when unsigned(8, digit'length) => seg0 <= eight;
			when unsigned(9, digit'length) => seg0 <= nine;
			when others => seg0 <= "1111111";
		 end case;
		 
	 elsif digit < unsigned(300, digit'length) then
		seg2 <= one;
		if digit < unsigned(210, digit'length) then seg1 <= zero;
			elsif digit < unsigned(220, digit'length) then seg1 <= one;
			elsif digit < unsigned(230, digit'length) then seg1 <= two;
			elsif digit < unsigned(240, digit'length) then seg1 <= three;
			elsif digit < unsigned(250, digit'length) then seg1 <= four;
			elsif digit < unsigned(260, digit'length) then seg1 <= five;
			elsif digit < unsigned(270, digit'length) then seg1 <= six;
			elsif digit < unsigned(280, digit'length) then seg1 <= seven;
			elsif digit < unsigned(290, digit'length) then seg1 <= eight;
			elsif digit < unsigned(300, digit'length) then seg1 <= nine;
			else seg1 <= "1111111";
		end if;
		case digit(2 downto 0) is
			when unsigned(0, digit(2 downto 0)'length) => seg0 <= zero;
			when unsigned(1, digit'length) => seg0 <= one;
			when unsigned(2, digit'length) => seg0 <= two;
			when unsigned(3, digit'length) => seg0 <= three;
			when unsigned(4, digit'length) => seg0 <= four;
			when unsigned(5, digit'length) => seg0 <= five;
			when unsigned(6, digit'length) => seg0 <= six;
			when unsigned(7, digit'length) => seg0 <= seven;
			when unsigned(8, digit'length) => seg0 <= eight;
			when unsigned(9, digit'length) => seg0 <= nine;
			when others => seg0 <= "1111111";
		 end case;
	 else seg2 <= zero;
	 end if;
  end process;

END;
