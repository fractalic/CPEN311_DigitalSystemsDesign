LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ALL;

---
-- Convert a number to a human-readable pattern for a 7-segment display.
-- effects: seg7_pattern is wired to a bit pattern representing the number.
--
ENTITY digit7seg IS
    PORT(
          hex_digit    : IN  UNSIGNED(3 DOWNTO 0);  -- number 0 to 0xF
          seg7_pattern : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)  -- one per segment
    );
END;


ARCHITECTURE behavioral OF digit7seg IS
signal seg7_sig : std_logic_vector(6 downto 0);
begin

    seg7_pattern <= seg7_sig;

    process(hex_digit)
    begin
        case hex_digit is
            when to_unsigned(0, hex_digit'length)  => seg7_sig <= "1000000";
            when to_unsigned(1, hex_digit'length)  => seg7_sig <= "1111001";
            when to_unsigned(2, hex_digit'length)  => seg7_sig <= "0100100";
            when to_unsigned(3, hex_digit'length)  => seg7_sig <= "0110000";
            when to_unsigned(4, hex_digit'length)  => seg7_sig <= "0011001";
            when to_unsigned(5, hex_digit'length)  => seg7_sig <= "0010010";
            when to_unsigned(6, hex_digit'length)  => seg7_sig <= "0000010";
            when to_unsigned(7, hex_digit'length)  => seg7_sig <= "1111000";
            when to_unsigned(8, hex_digit'length)  => seg7_sig <= "0000000";
            when to_unsigned(9, hex_digit'length)  => seg7_sig <= "0010000";
            when to_unsigned(10, hex_digit'length) => seg7_sig <= "0001000";
            when to_unsigned(11, hex_digit'length) => seg7_sig <= "0000011";
            when to_unsigned(12, hex_digit'length) => seg7_sig <= "1000110";
            when to_unsigned(13, hex_digit'length) => seg7_sig <= "0100001";
            when to_unsigned(14, hex_digit'length) => seg7_sig <= "0000110";
            when to_unsigned(15, hex_digit'length) => seg7_sig <= "0001110";
            when others => seg7_sig <= "0000000";
        end case;
    end process;

end;
