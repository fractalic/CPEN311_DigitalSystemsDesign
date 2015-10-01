LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ALL;

---
--  Determine the binary-coded decimal representation of a number.
--  effects: binary_coded_decimal provides the bcd representation
--           of number.
ENTITY bcd_converter IS
    PORT(
          number               : IN  UNSIGNED(11 DOWNTO 0);  -- number 0 to 0xFFF
          binary_coded_decimal : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END;


ARCHITECTURE behavioral OF bcd_converter IS
begin
    process(number)
        variable bcd_result : unsigned(16 downto 0) := "00000" &  number;
    begin
        for offset in 1 to 3 loop
            -- To the next five bits of bcd_result, add the bcd
            -- remainder of the previous four bits.
            bcd_result(4*(offset+1) downto 4*(offset+1)-4) :=
              ( bcd_result(4*offset downto 4*offset-4) mod 10 )
             +  bcd_result(4*(offset+1) downto 4*(offset+1)-4);

            -- To the previous four bits of bcd_result,
            -- subtract the bcd remainder.
            bcd_result(4*offset-1 downto 4*offset-4) :=
                number(4*offset-1 downto 4*offset-4)
              - number(4*offset-1 downto 4*offset-4) mod 10;
        end loop;

        binary_coded_decimal <= std_logic_vector(bcd_result(15 downto 0));
    end process;

end;
