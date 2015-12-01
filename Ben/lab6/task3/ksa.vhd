library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description.  Describes inputs and outputs

entity ksa is
  port(CLOCK_50 : in  std_logic;  -- Clock pin
       KEY : in  std_logic_vector(3 downto 0);  -- push button switches
       SW : in  std_logic_vector(17 downto 0);  -- slider switches
		 LEDG : out std_logic_vector(7 downto 0);  -- green lights
		 LEDR : out std_logic_vector(17 downto 0));  -- red lights
end ksa;

-- Architecture part of the description

architecture rtl of ksa is

-- ROM for encrypted message.
component e_memory
  PORT
  (
    address   : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
    clock   : IN STD_LOGIC  := '1';
    q   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
  );
end component;

component cracker is
  port(
        clock_50 : in std_logic;
        key_in : in std_logic_vector(23 downto 0);
        char_in : in std_logic_vector(7 downto 0);
        go : in std_logic;
        new_key : in std_logic;

        -- '1' if internal machine has completed all processing
        -- stages and is now waiting for new data.
        ready : out std_logic;

        -- '1' as long as all decrypted chars since last
        -- key reset are lower-alpha.
        alpha_decryption : out std_logic

    );
end component;

    signal clock : std_logic;
    signal counter : std_logic_vector(27 downto 0);

	-- Enumerated type for the state variable.  You will likely be adding extra
	-- state names here as you complete your design
	
	type state_type is (
        state_reset, state_wait_for_key_ready, state_loadE, state_loadE_wait, state_regE,
        state_wait_for_char_ready, state_send_char, state_done,
        state_wait_rtz_1, state_wait_rtz_2
    );

    constant MEM_SIZE : natural := 256;
    constant KEY_LENGTH : natural := 3;
    constant MESSAGE_LENGTH : natural := 32;
								

    signal address_e : std_logic_vector(4 downto 0);
    signal q_e : std_logic_vector(7 downto 0);


    signal go : std_logic;
    signal send_new_key : std_logic;
    signal char_e : std_logic_vector(7 downto 0);


    signal key_1 : std_logic_vector(23 downto 0);
    signal ready_1 : std_logic;
    signal alpha_1 : std_logic;

	begin

    process(clock_50)
    variable counter : integer;
    variable counter_vector : std_logic_vector(27 downto 0);
    begin
        if (rising_edge(clock_50)) then
            counter := counter + 1;
            if (counter > 50000000) then
                counter := 0;
            end if;
            counter_vector := std_logic_vector(to_unsigned(counter, counter_vector'length));
            clock <= counter_vector(18);
        end if;
    end process;
	
    u_cracker: cracker port map(
        clock_50 => clock, key_in => key_1, char_in => char_e, go => go, new_key => send_new_key, ready => ready_1, alpha_decryption => alpha_1
    );

    e_rom: e_memory port map(address => address_e, clock => clock, q => q_e);

    ledr <= sw;
    send_new_key <= '0';

    process(clock)

    variable currentState : state_type := state_reset;

    variable memK : integer := 0;

    variable address_e_var : std_logic_vector(address_e'left downto address_e'right);

    variable Ek : std_logic_vector(7 downto 0);

    variable go_var : std_logic;
    begin


    	if (rising_edge(clock)) then
            case currentState is
                when state_reset =>
                    currentState := state_wait_for_key_ready;
                    key_1 <= "000000" & sw(17 downto 0);

                when state_wait_for_key_ready =>
                    currentState := state_wait_for_key_ready;

                    go_var := '0';

                    if (ready_1 = '1') then
                        go_var := '1';
                        currentState := state_wait_rtz_1;
                    end if;

                    memK := 0;
                    ledg(1 downto 0) <= "00";

                when state_wait_rtz_1 =>
                    currentState := state_wait_rtz_1;
                    go_var := '1';
                    if (ready_1 = '0') then
                        currentState := state_loadE;
                        go_var := '0';
                    end if;
                    ledg(1 downto 0) <= "01";


                when state_wait_for_char_ready =>
                    currentState := state_wait_for_char_ready;
                    go_var := '0';
                    ledg(2 downto 0) <= "011";

                    if (ready_1 = '1') then
                        currentState := state_wait_rtz_2;
                        go_var := '1';
                    end if;

                when state_wait_rtz_2 =>
                    currentState := state_wait_rtz_2;
                    go_var := '1';

                    if (ready_1 = '0') then
                        currentState := state_send_char;
                        go_var := '0';
                    end if;

                    ledg(2) <= '1';

                when state_loadE =>
                    currentState := state_loadE_wait;

                    address_e_var := std_logic_vector(to_unsigned(memK, address_e_var'length));

                    go_var := '0';

                when state_loadE_wait =>
                    currentState := state_regE;
                    go_var := '0';

                when state_regE =>
                    currentState := state_wait_for_char_ready;
                    Ek := q_e;
                    char_e <= Ek;

                when state_send_char =>
                    currentState := state_wait_rtz_1;

                    go_var := '0';

                    if (memK = MESSAGE_LENGTH - 1) then
                        currentState := state_done;
                    end if;

                    memK := memK + 1;
                    --ledg <= std_logic_vector(to_unsigned(memK, ledg'length));

                when state_done =>
                    currentState := state_done;
                    go_var := '0';

                when others =>
                    currentState := state_reset;
                    go_var := '0';

    		end case;
    	end if;

      address_e <= address_e_var;
      go <= go_var;

    end process;


end rtl;


