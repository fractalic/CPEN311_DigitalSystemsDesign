LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
LIBRARY WORK;
USE WORK.ALL;


---
-- A Roulette game for the DE2 board. Three bets are allowed on each round
-- (one straight up, one colour, and one dozen). Money is paid out according
-- to the European odds.
-- requires: CLOCK_27 is wired to a fast clock running continuously.
-- effects: HEX6 and HEX7 are wired to a two digit hexadecimal number representing
--          the value of the last spin.
--          HEX0 through HEX2 are wired to a three digit hexadecimal number
--          representing the player's current total money.
--          LEDG(0) is high if player wins on bet1.
--          LEDG(1) is high if player wins on bet2.
--          LEDG(2) is high if player wins on bet3.
entity roulette is
	port(   CLOCK_27 : in STD_LOGIC; -- the fast clock for spinning wheel
		KEY : in STD_LOGIC_VECTOR(3 downto 0);  -- includes slow_clock and reset
		SW : in STD_LOGIC_VECTOR(17 downto 0);
		LEDG : out STD_LOGIC_VECTOR(3 DOWNTO 0);  -- ledg
        LEDR : out STD_LOGIC_VECTOR(17 downto 0); -- ledr
		HEX7 : out STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 7
		HEX6 : out STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 6
		HEX5 : out STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 5
		HEX4 : out STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 4
		HEX3 : out STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 3
		HEX2 : out STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 2
		HEX1 : out STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 1
		HEX0 : out STD_LOGIC_VECTOR(6 DOWNTO 0)   -- digit 0
	);
end roulette;


architecture structural of roulette is

signal resetb              : std_logic;
signal slow_clock          : std_logic;
signal spin_result,
       spin_result_latched : unsigned(5 downto 0);
signal bet1_value          : unsigned(5 downto 0);
signal bet2_colour         : std_logic;
signal bet3_dozen          : unsigned(1 downto 0);
signal bet1_wins,
       bet2_wins,
       bet3_wins           : std_logic;
signal bet1_amount,
       bet2_amount,
       bet3_amount         : unsigned(2 downto 0);
signal money,
       new_money           : unsigned(11 downto 0);
signal hex_array           : std_logic_vector(27 downto 0);

component new_balance is
    port(
        money     : in unsigned (11 downto 0);
        value1    : in unsigned (2 downto 0);
        value2    : in unsigned (2 downto 0);
        value3    : in unsigned (2 downto 0);
        bet1_wins : in std_logic;
        bet2_wins : in std_logic;
        bet3_wins : in std_logic;
        new_money : out unsigned (11 downto 0)
    );
end component;

component digit7seg is
    port(
          hex_digit     : in  unsigned(3 downto 0);
          seg7_pattern  : out std_logic_vector(6 downto 0)
    );
end component;

component win is
    port(
        spin_result_latched : in unsigned(5 downto 0);
        bet1_value          : in unsigned(5 downto 0);
        bet2_colour         : in std_logic;
        bet3_dozen          : in unsigned(1 downto 0);
        bet1_wins           : out std_logic;
        bet2_wins           : out std_logic;
        bet3_wins           : out std_logic
    );
end component;

component spinwheel is
    port(
        fast_clock   : in  std_logic;
        resetb       : in  std_logic; -- asynchronous
        spin_result  : out unsigned(5 downto 0)
    );
end component;

begin
    hex0 <= hex_array(6 downto 0);
    hex1 <= hex_array(13 downto 7);
    hex2 <= hex_array(20 downto 14);
    hex3 <= "1111111";
    hex4 <= "1111111";
    hex5 <= "1111111";
    hex6_converter : digit7seg port map (
                        hex_digit => spin_result_latched(3 downto 0),
                        seg7_pattern => hex6
                     );
    hex7_converter : digit7seg port map (
                        hex_digit => "00" & spin_result_latched(5 downto 4),
                        seg7_pattern => hex7
                     );

    ledg(0) <= bet1_wins;
    ledg(1) <= bet2_wins;
    ledg(2) <= bet3_wins;

    ledr <= sw;

    slow_clock <= not key(0);
    resetb <= key(1);

    gen_money_digits:
    for I in 1 to 3 generate
        money_digit : digit7seg port map (hex_digit => unsigned(new_money(4*I-1 downto 4*I-4)),
                                          seg7_pattern => hex_array(7*I-1 downto 7*I-7));
    end generate gen_money_digits;

    compute_balance : new_balance port map (money => money, value1 => bet1_amount,
                                            value2 => bet2_amount, value3 => bet3_amount,
                                            bet1_wins => bet1_wins, bet2_wins => bet2_wins,
                                            bet3_wins => bet3_wins, new_money => new_money);

    compute_win : win port map (spin_result_latched => spin_result_latched,
                                bet1_value => bet1_value, bet2_colour => bet2_colour,
                                bet3_dozen => bet3_dozen, bet1_wins => bet1_wins,
                                bet2_wins => bet2_wins, bet3_wins => bet3_wins);

    spin_the_wheel : spinwheel port map (fast_clock => clock_27, resetb => resetb,
                                         spin_result => spin_result);

    process(slow_clock)
    begin
        if (rising_edge(slow_clock))
        then
            if (resetb = '0')
            then
                bet1_value <= to_unsigned(0, bet1_value'length);
                bet2_colour <= '0';
                bet3_dozen <= to_unsigned(0, bet3_dozen'length);

                bet1_amount <= to_unsigned(0, bet1_amount'length);
                bet2_amount <= to_unsigned(0, bet2_amount'length);
                bet3_amount <= to_unsigned(0, bet3_amount'length);

                spin_result_latched <= to_unsigned(0, spin_result_latched'length);

                money <= to_unsigned(32, money'length);
            else
                bet1_value <= unsigned(sw(8 downto 3));
                bet2_colour <= sw(12);
                bet3_dozen <= unsigned(sw(17 downto 16));

                bet1_amount <= unsigned(sw(2 downto 0));
                bet2_amount <= unsigned(sw(11 downto 9));
                bet3_amount <= unsigned(sw(15 downto 13));

                spin_result_latched <= spin_result;

                money <= new_money;
            end if;
        end if;
    end process;

end;
