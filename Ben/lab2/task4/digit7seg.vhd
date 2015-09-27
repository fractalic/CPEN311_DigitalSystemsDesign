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

    process(digit)
    begin
        case digit is
            when to_unsigned(0, digit'length) => seg7_sig <= "1000000";
            when others => seg7_sig <= "0000000";
        end case;
    end process;

end;
