library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity reorder_s is
	port(
		start : in std_logic;
		clock : in std_logic;
		q : in std_logic_vector(7 downto 0);
		secret_key : in std_logic_vector(23 downto 0);
		done : out std_logic;
		wren : out std_logic;
		data : out std_logic_vector(7 downto 0);
		address : out std_logic_vector(7 downto 0)
	);
end reorder_s;

architecture behavioural of reorder_s is

constant MEM_SIZE : natural := 256;

type MemStateType is (state_reset, state_readSI, state_readSI_wait,
	state_computeJ, state_readSJ, state_writeSJ, state_writeSI, state_done);

begin

	process(clock)

	variable state : MemStateType := state_reset;
	variable I : integer := 0;
	variable J : integer := 0;

	variable Imod : integer := 0;

	variable key_sub : std_logic_vector(7 downto 0);

	variable Si : std_logic_vector(data'left downto data'right);
    variable Sj : std_logic_vector(data'left downto data'right);

	begin

	if (rising_edge(clock)) then

		case state is
			when state_reset =>
		        if (start = '1') then
					state := state_readSI;
				else
					state := state_reset;
				end if;

	          I := 0;
	          J := 0;

	          wren <= '0';
	          done <= '0';

	        when state_readSI =>
	          state := state_readSI_wait;

	          wren <= '0';
	          address <= std_logic_vector(to_unsigned(I, address'length));
	          done <= '0';

	        when state_readSI_wait =>
	          state := state_computeJ;

	        when state_computeJ =>
	          state := state_readSJ;

	          Imod := I mod 3;

	          if (IMod = 2) then
	            key_sub := secret_key(7 downto 0);
	          elsif (Imod = 1) then
	            key_sub := secret_key(15 downto 8);
	          elsif (Imod = 0) then
	            key_sub := secret_key(23 downto 16);
	          end if;

	          Si := q;

	          J := (J + to_integer(unsigned(Si)) + to_integer(unsigned( key_sub ))) mod MEM_SIZE;

	          wren <= '0';
	          done <= '0';

	        when state_readSJ =>
	          state := state_writeSJ;

	          wren <= '0';
	          address <= std_logic_vector(to_unsigned(J, address'length));
	          done <= '0';

	        when state_writeSj =>
	          state := state_writeSI;

	          wren <= '1';
	          address <= std_logic_vector(to_unsigned(J, address'length));
	          data <= Si;
	          done <= '0';

	        when state_writeSI =>
	          if (I = 255) then
	            state := state_done;
	          else
	            state := state_readSI;
	          end if;

	          Sj := q;
	          wren <= '1';
	          address <= std_logic_vector(to_unsigned(I, address'length));
	          data <= Sj;

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
