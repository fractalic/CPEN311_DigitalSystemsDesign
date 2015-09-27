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
signal seg7_sig : std_logic_vector(6 downto 0);
begin

    seg7 <= seg7_sig;

    process(digit)
    begin
        case digit is
            when to_unsigned(0, digit'length)  => seg7_sig <= "1000000";
            when to_unsigned(1, digit'length)  => seg7_sig <= "1111001";
            when to_unsigned(2, digit'length)  => seg7_sig <= "0100100";
            when to_unsigned(3, digit'length)  => seg7_sig <= "0110000";
            when to_unsigned(4, digit'length)  => seg7_sig <= "0011001";
            when to_unsigned(5, digit'length)  => seg7_sig <= "0010010";
            when to_unsigned(6, digit'length)  => seg7_sig <= "0000010";
            when to_unsigned(7, digit'length)  => seg7_sig <= "1111000";
            when to_unsigned(8, digit'length)  => seg7_sig <= "0000000";
            when to_unsigned(9, digit'length)  => seg7_sig <= "0010000";
            when to_unsigned(10, digit'length) => seg7_sig <= "0001000";
            when to_unsigned(11, digit'length) => seg7_sig <= "0000111";
            when to_unsigned(12, digit'length) => seg7_sig <= "1000110";
            when to_unsigned(13, digit'length) => seg7_sig <= "0100001";
            when to_unsigned(14, digit'length) => seg7_sig <= "0000110";
            when to_unsigned(15, digit'length) => seg7_sig <= "0001110";
            when others => seg7_sig <= "0000000";
        end case;
    end process;

end;
