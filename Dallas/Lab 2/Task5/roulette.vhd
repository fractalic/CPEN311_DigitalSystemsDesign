LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
 
LIBRARY WORK;
USE WORK.ALL;

----------------------------------------------------------------------
--
--  This is the top level template for Lab 2.  Use the schematic on Page 3
--  of the lab handout to guide you in creating this structural description.
--  The combinational blocks have already been designed in previous tasks,
--  and the spinwheel block is given to you.  Your task is to combine these
--  blocks, as well as add the various registers shown on the schemetic, and
--  wire them up properly.  The result will be a roulette game you can play
--  on your DE2.
--
-----------------------------------------------------------------------

ENTITY roulette IS
	PORT(   CLOCK_27 : IN STD_LOGIC; -- the fast clock for spinning wheel
		KEY : IN STD_LOGIC_VECTOR(3 downto 0);  -- includes slow_clock and reset
		SW : IN STD_LOGIC_VECTOR(17 downto 0);
		LEDG : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);  -- ledg
		LEDR : OUT STD_LOGIC_VECTOR(17 DOWNTO 0); -- ledr
		HEX7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 7
		HEX6 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 6
		HEX5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 5
		HEX4 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 4
		HEX3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 3
		HEX2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 2
		HEX1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);  -- digit 1
		HEX0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)   -- digit 0
	);
END roulette;

ARCHITECTURE structural OF roulette IS
  
  component win
    port (spin_result_latched : in unsigned(5 downto 0);  -- result of the spin (the winning number)
             bet1_value : in unsigned(5 downto 0); -- value for bet 1
             bet2_colour : in std_logic;  -- colour for bet 2
             bet3_dozen : in unsigned(1 downto 0);  -- dozen for bet 3
             bet1_wins : out std_logic;  -- whether bet 1 is a winner
             bet2_wins : out std_logic;  -- whether bet 2 is a winner
             bet3_wins : out std_logic); -- whether bet 3 is a winner
  end component;
  
  component digit7seg
    port (digit : IN  UNSIGNED(3 DOWNTO 0);  -- number 0 to 0xF
          seg7 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));  -- one per segment
  end component;
  
  component new_balance
    port (money : in unsigned(11 downto 0);  -- Current balance before this spin
             value1 : in unsigned(2 downto 0);  -- Value of bet 1
             value2 : in unsigned(2 downto 0);  -- Value of bet 2
             value3 : in unsigned(2 downto 0);  -- Value of bet 3
             bet1_wins : in std_logic;  -- True if bet 1 is a winner
             bet2_wins : in std_logic;  -- True if bet 2 is a winner
             bet3_wins : in std_logic;  -- True if bet 3 is a winner
             new_money : out unsigned(11 downto 0));  -- balance after adding winning bets and subtracting losing bets
  end component;
  
  component spinwheel
    port (fast_clock : IN  STD_LOGIC;  -- This will be a 27 Mhz Clock
		         resetb : IN  STD_LOGIC;      -- asynchronous reset
		         spin_result  : OUT UNSIGNED(5 downto 0));  -- current value of the wheel
  end component;
  
  signal bet1_value : unsigned(5 downto 0); -- number to bet on
  signal bet1_amount: unsigned(2 downto 0); -- amount of bet $$$
  signal bet1_wins : std_logic;
  
  signal bet2_colour : std_logic; -- red / black bet
  signal bet2_amount: unsigned(2 downto 0);
  signal bet2_wins : std_logic;
  
  signal bet3_dozen : unsigned(1 downto 0); -- dozen to bet on
  signal bet3_amount: unsigned(2 downto 0);
  signal bet3_wins : std_logic;
  
  signal resetb : std_logic;
  signal slow_clock : std_logic;
  
  signal money : unsigned(11 downto 0);
  signal new_money : unsigned(11 downto 0);
  
  signal spin_result : unsigned(5 downto 0);
  signal spin_result_latched : unsigned(5 downto 0);
  
 begin
 
	slow_clock <= not KEY(0);   
	resetb <= not KEY(1); 
	
   LEDG(0) <= bet1_wins;
	LEDG(1) <= bet2_wins;
	LEDG(2) <= bet3_wins;
	
	LEDR <= SW;
 
   process(slow_clock) begin
	if rising_edge(slow_clock) then
		bet1_value <= unsigned(SW(8 downto 3)); -- number to bet on
		bet1_amount <= unsigned(SW(2 downto 0)); -- amount of bet 35:1
     
		bet2_colour <= SW(12); -- red / black
		bet2_amount <= unsigned(SW(11 downto 9)); -- amount of bet 1:1
     
		bet3_dozen <= unsigned(SW(17 downto 16)); -- dozen to bet on
		bet3_amount <= unsigned(SW(15 downto 13)); -- amount of bet 2:1
			
		money <= new_money;
		
		spin_result_latched <= spin_result;
		
		if resetb = '1' then -- reset everything!
        money <= "000000100000"; -- $32 start wallet
        bet1_value <= "000000"; -- initialize number bet
        bet1_amount <= "000"; -- initialize bet1 amount
        bet2_colour <= '0'; -- initialize colour bet
        bet2_amount <= "000"; -- initialize bet2 amount
        bet3_dozen <= "00"; -- initialize dozen bet
        bet3_amount <= "000"; -- initialize bet3 amount
		  spin_result_latched <= spin_result;
		end if;
	end if;
   end process;
      
     WIN_BLOCK : win port map(spin_result_latched, bet1_value, bet2_colour, bet3_dozen, bet1_wins, bet2_wins, bet3_wins);
     BALANCE_BLOCK : new_balance port map(money, bet1_amount, bet2_amount, bet3_amount, bet1_wins, bet2_wins, bet3_wins, new_money);
     SPINWHEEL_BLOCK : spinwheel port map(CLOCK_27, resetb, spin_result);
       
     DIGIT_BLOCK0 : digit7seg port map(new_money(3 downto 0), HEX0);
     DIGIT_BLOCK1 : digit7seg port map(new_money(7 downto 4), HEX1);
     DIGIT_BLOCK2 : digit7seg port map(new_money(11 downto 8), HEX2);
     HEX3 <= "1111111";
     HEX4 <= "1111111";
     HEX5 <= "1111111";
     DIGIT_BLOCK6 : digit7seg port map(spin_result_latched(3 downto 0), HEX6);
     DIGIT_BLOCK7 : digit7seg port map(("00" & spin_result_latched(5 downto 4)), HEX7);
   
END;
