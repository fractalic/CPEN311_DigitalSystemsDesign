LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ALL;

---
--  Determine the binary-coded decimal representation of a number.
--  effects: binary_coded_decimal provides the bcd representation
--           of number.
ENTITY bcd_adder IS
    PORT(
          number               : IN  UNSIGNED(3 DOWNTO 0);
          carry_in             : in  std_logic;
          binary_coded_decimal : OUT unsigned(3 DOWNTO 0);
          carry_out            : out std_logic
    );
END;


ARCHITECTURE behavioral OF bcd_adder IS
begin
    process(number, carry_in)
    variable add_number_carry : unsigned(4 downto 0):= "00000";
    variable bcd : unsigned(4 downto 0) := "00000";
    begin
      if(carry_in = '1') then
        add_number_carry := ('0' & number) + to_unsigned(1, 1);
      else
        add_number_carry := ('0' & number);
      end if;
    
      bcd := add_number_carry mod 10;
      binary_coded_decimal <= bcd(3 downto 0);
      if (add_number_carry > 9) then
        carry_out <= '1';
      else
        carry_out <= '0';
      end if;
    end process;

end;
