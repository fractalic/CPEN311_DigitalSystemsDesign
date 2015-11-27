library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity init_s is
	port(
		start : in std_logic;
		clock : in std_logic;
		done : out std_logic;
		wren : out std_logic;
		data : out std_logic_vector(7 downto 0);
		addr : out std_logic_vector(7 downto 0)
	);
end init_s;

architecture behavioural of init_s is

constant MEM_SIZE : natural := 256;

type MemStateType is (state_reset, state_populate, state_done);

begin

	process(clock)

	variable state : MemStateType := state_reset;
	variable I : integer := 0;

	begin

	if (rising_edge(clock)) then

		case state is
			when state_reset =>
				if (start = '1') then
					state := state_populate;
				else
					state := state_reset;
				end if;

				I := 0;
				wren <= '0';
				done <= '0';

			when state_populate =>
				if (I = MEM_SIZE - 1) then
					state := state_done;
				else
					state := state_populate;
				end if;

				wren <= '1';
				data <= std_logic_vector(to_unsigned(I, data'length));
				addr <= std_logic_vector(to_unsigned(I, data'length));

				I := I + 1;
				done <= '0';

			when state_done =>
				if (start = '0') then
					state := state_reset;
				else
					state := state_done;
				end if;

				wren <= '0';
				done <= '1';
				
			when others =>
				state := state_reset;

		end case;
	end if;

	end process;

end behavioural;
