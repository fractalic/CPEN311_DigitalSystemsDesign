LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY sound IS
	PORT (CLOCK_50,AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK,AUD_ADCDAT			:IN STD_LOGIC;
			CLOCK_27															:IN STD_LOGIC;
			KEY																:IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			SW																	:IN STD_LOGIC_VECTOR(17 downto 0);
			I2C_SDAT															:INOUT STD_LOGIC;
			I2C_SCLK,AUD_DACDAT,AUD_XCK								:OUT STD_LOGIC;
			ledr : out std_logic_vector(17 downto 0));
END sound;

ARCHITECTURE Behavior OF sound IS

	   -- CODEC Cores
	
	COMPONENT clock_generator
		PORT(	CLOCK_27														:IN STD_LOGIC;
		    	reset															:IN STD_LOGIC;
				AUD_XCK														:OUT STD_LOGIC);
	END COMPONENT;

	COMPONENT audio_and_video_config
		PORT(	CLOCK_50,reset												:IN STD_LOGIC;
		    	I2C_SDAT														:INOUT STD_LOGIC;
				I2C_SCLK														:OUT STD_LOGIC);
	END COMPONENT;
	
	COMPONENT audio_codec
		PORT(	CLOCK_50,reset,read_s,write_s							:IN STD_LOGIC;
				writedata_left, writedata_right						:IN STD_LOGIC_VECTOR(23 DOWNTO 0);
				AUD_ADCDAT,AUD_BCLK,AUD_ADCLRCK,AUD_DACLRCK		:IN STD_LOGIC;
				read_ready, write_ready									:OUT STD_LOGIC;
				readdata_left, readdata_right							:OUT STD_LOGIC_VECTOR(23 DOWNTO 0);
				AUD_DACDAT													:OUT STD_LOGIC);
	END COMPONENT;
	
	component rom IS
	PORT
	(
		address		: IN STD_LOGIC_VECTOR (3 DOWNTO 0);
		clock		: IN STD_LOGIC  := '1';
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	end component;

	SIGNAL read_ready, write_ready, read_s, write_s		      :STD_LOGIC;
	SIGNAL writedata_left, writedata_right							:STD_LOGIC_VECTOR(23 DOWNTO 0);	
	SIGNAL readdata_left, readdata_right							:STD_LOGIC_VECTOR(23 DOWNTO 0);	
	SIGNAL reset															:STD_LOGIC;
	
	signal rom_address : std_logic_vector(3 downto 0);
	signal rom_clock : std_logic;
	signal rom_q : std_logic_vector(7 downto 0);
	signal note_counter : unsigned(3 downto 0);
	
	type state is (read_note_state, wait_note_state_1, wait_note_state_2, wait_state, drive_state, wait_state_2, note_timer_state, next_note_state);
	constant VOLUME : unsigned(23 downto 0) := "000000010000000000000000";
	constant NEG_VOLUME : unsigned(23 downto 0) := "111111110000000000000000";
	SIGNAL count_C : integer := 0;
	SIGNAL count_D : integer := 0;
	SIGNAL count_E : integer := 0;
	SIGNAL count_F : integer := 0;
	SIGNAL count_G : integer := 0;
	SIGNAL count_A : integer := 0;
	SIGNAL count_B : integer := 0;
	CONSTANT NUM_SAMPLES_C : integer := 184; -- 262 Hz
	CONSTANT NUM_SAMPLES_D : integer := 164; -- 294 Hz
	CONSTANT NUM_SAMPLES_E : integer := 146; -- 330 Hz
	CONSTANT NUM_SAMPLES_F : integer := 138; -- 349 Hz
	CONSTANT NUM_SAMPLES_G : integer := 122; -- 392 Hz
	CONSTANT NUM_SAMPLES_A : integer := 110; -- 440 Hz
 	CONSTANT NUM_SAMPLES_B : integer := 98; -- 494 Hz

BEGIN

	reset <= NOT(KEY(0));
	read_s <= '0';

	rom_clock <= clock_50;
	rom_address <= std_logic_vector(note_counter);
	
	ledr(7 downto 0) <= rom_q;
	
	song_storage : rom port map(address => rom_address, clock => rom_clock, q => rom_q);
	
	my_clock_gen: clock_generator PORT MAP (CLOCK_27, reset, AUD_XCK);
	cfg: audio_and_video_config PORT MAP (CLOCK_50, reset, I2C_SDAT, I2C_SCLK);
	codec: audio_codec PORT MAP(CLOCK_50,reset,read_s,write_s,writedata_left, writedata_right,AUD_ADCDAT,AUD_BCLK,AUD_ADCLRCK,AUD_DACLRCK,read_ready, write_ready,readdata_left, readdata_right,AUD_DACDAT);
	
   process (clock_50)
	variable current_state : state := read_note_state;
	variable temp_left_c, temp_left_d, temp_left_e, temp_left_f, temp_left_g, temp_left_a, temp_left_b : unsigned(23 downto 0);
	variable temp_right_c, temp_right_d, temp_right_e, temp_right_f, temp_right_g, temp_right_a, temp_right_b : unsigned(23 downto 0);
	variable note_timer : unsigned(28 downto 0);
	variable rom_q_var : unsigned(7 downto 0);
	begin
	if rising_edge(clock_50) then
	
	note_timer := note_timer + to_unsigned(1, note_timer'length);
	
	case current_state is
	
	when next_note_state =>
		current_state := read_note_state;
		
		if (note_counter = "1011") then
			note_counter <= "0000";
		else
			--note_counter <= "0001";
			note_counter <= note_counter + to_unsigned(1, note_counter'length);
		end if;
	
	when read_note_state =>
		current_state := wait_note_state_1;
		
	when wait_note_state_1 =>
		current_state := wait_note_state_2;
	
	when wait_note_state_2 =>
		current_state := wait_state;
		rom_q_var := unsigned(rom_q);
		
		
	when note_timer_state =>
		if (note_timer > to_unsigned(25000000, note_timer'length)) then
			note_timer := to_unsigned(0, note_timer'length);
			current_state := next_note_state;
		else
			current_state := wait_state;
		end if;
	
	when wait_state =>
		write_s <= '0';
		if write_ready = '1' then
			current_state := drive_state;
		end if;
		
	when drive_state =>
		if (rom_q_var = "00000001") then
			count_C <= count_C + 1;
			if count_C > NUM_SAMPLES_C then
				count_C <= 0;
			end if;
			if count_C > (NUM_SAMPLES_C / 2) then -- if count_A > wavelength_A /2 then
				temp_left_c := VOLUME;--temp_left + VOLUME; -- variable_left := volume + variable_left
				temp_right_c := VOLUME;--temp_right + VOLUME;
			else
				temp_left_c := NEG_VOLUME;--temp_left + NEG_VOLUME;
				temp_right_c := NEG_VOLUME;--temp_right + NEG_VOLUME;
			end if;
		end if;
		if rom_q_var = "00000010" then
			count_D <= count_D + 1;
			if count_D > NUM_SAMPLES_D then
				count_D <= 0;
			end if;
			if count_D > (NUM_SAMPLES_D / 2) then
				temp_left_d := VOLUME; 
				temp_right_d := VOLUME;
			else
				temp_left_d := NEG_VOLUME;
				temp_right_d := NEG_VOLUME;
			end if;
		end if;
		if rom_q_var = "00000011" then
			count_E <= count_E + 1;
			if count_E > NUM_SAMPLES_E then
				count_E <= 0;
			end if;
			if count_E > (NUM_SAMPLES_E / 2) then
				temp_left_e := VOLUME; 
				temp_right_e := VOLUME;
			else
				temp_left_e := NEG_VOLUME;
				temp_right_e := NEG_VOLUME;
			end if;
		end if;
		if rom_q_var = "00000100" then
			count_F <= count_F + 1;
			if count_F > NUM_SAMPLES_F then
				count_F <= 0;
			end if;
			if count_F > (NUM_SAMPLES_F / 2) then
				temp_left_f := VOLUME; 
				temp_right_f := VOLUME;
			else
				temp_left_f := NEG_VOLUME;
				temp_right_f := NEG_VOLUME;
			end if;
		end if;
		if rom_q_var = "00000101" then
			count_G <= count_G + 1;
			if count_G > NUM_SAMPLES_G then
				count_G <= 0;
			end if;
			if count_G > (NUM_SAMPLES_G / 2) then
				temp_left_g := VOLUME; 
				temp_right_g := VOLUME;
			else
				temp_left_g := NEG_VOLUME;
				temp_right_g := NEG_VOLUME;
			end if;
		end if;
		if (rom_q_var = "00000110") then
			count_A <= count_A + 1;
			if count_A > NUM_SAMPLES_A then
				count_A <= 0;
			end if;
			if count_A > (NUM_SAMPLES_A / 2) then
				temp_left_a := VOLUME; 
				temp_right_a := VOLUME;
			else
				temp_left_a := NEG_VOLUME;
				temp_right_a := NEG_VOLUME;
			end if;
		end if;
		if rom_q_var = "00000111" then
			count_B <= count_B + 1;
			if count_B > NUM_SAMPLES_B then
				count_B <= 0;
			end if;
			if count_B > (NUM_SAMPLES_B / 2) then
				temp_left_b := VOLUME; 
				temp_right_b := VOLUME;
			else
				temp_left_b := NEG_VOLUME;
				temp_right_b := NEG_VOLUME;
			end if;
		end if;
		
		write_s <= '1';
		writedata_left <= std_logic_vector(temp_left_c + temp_left_d + temp_left_e + temp_left_f + temp_left_g + temp_left_a + temp_left_b);
		writedata_right <= std_logic_vector(temp_right_c + temp_right_d + temp_right_e + temp_right_f + temp_right_g + temp_right_a + temp_right_b);
		current_state := wait_state_2;
		
		when wait_state_2 =>
		if write_ready = '0' then
			write_s <= '0';
			current_state := note_timer_state;
		end if;

	when others => current_state := wait_state;
	end case;
	end if;
	end process;
END Behavior;
