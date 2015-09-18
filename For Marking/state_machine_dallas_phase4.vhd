library ieee;
use ieee.std_logic_1164.all;

entity state_machine_slow is
   port (clk : in std_logic;  -- clock input to state machine
         resetb : in std_logic;  -- active-low reset input
         dir : in std_logic;     -- dir input
         hex1 : out std_logic_vector(6 downto 0);  -- output of state machine
			   LEDR : out std_logic_vector(7 downto 0)
   );
end state_machine_slow;

architecture behavioural of state_machine_slow is
  signal current_state, next_state : std_logic_vector(2 downto 0);
  begin
  process(all)
    begin
      hex1 <= "0000000";
      LEDR <= "00000000";
      case current_state is
        when "000" => -- D
          hex1 <= "1000000";
			    LEDR <= "00000000";
          if (dir = '1') then -- forward
            next_state <= "101";
			 else
				next_state <= "001"; -- reverse
          end if;
        when "001" => -- A
          hex1 <= "0001000";
			    LEDR <= "00000001";
          if (dir = '1') then
            next_state <= "000";
			 else
				next_state <= "010";
          end if;
        when "010" => -- L
          hex1 <= "1000111";
			    LEDR <= "00000010";
          if (dir = '1') then
            next_state <= "001";
			 else
				next_state <= "011";
          end if;
        when "011" => -- L
          hex1 <= "1000111";
			    LEDR <= "00000011";
          if (dir = '1') then
            next_state <= "010";
			 else
				next_state <= "100";
          end if;
        when "100" => -- A
          hex1 <= "0001000";
			    LEDR <= "00000100";
          if (dir = '1') then
            next_state <= "011";
			 else
				next_state <= "101";
          end if;
        when "101" => -- S
          hex1 <= "0010010";
			    LEDR <= "00000101";
          if (dir = '1') then
            next_state <= "100";
			 else
				next_state <= "000";
          end if;
        when others => next_state <= "000"; -- catch-all
      end case;
      
      if (resetb = '0') then  -- machine is reset when resetb = 0
          next_state <= "000";
      end if;      
      
  end process;
    
  process(clk)
      begin
        if rising_edge(clk) then
          current_state <= next_state;
        end if;
  end process;

end behavioural;
