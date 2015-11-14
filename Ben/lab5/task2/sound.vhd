LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY sound IS
	PORT (CLOCK_50,AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK,AUD_ADCDAT			:IN STD_LOGIC;
			CLOCK_27															:IN STD_LOGIC;
			KEY																:IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			SW																	:IN STD_LOGIC_VECTOR(17 downto 0);
			LEDR															 	:OUT std_logic_vector(17 downto 0);
			I2C_SDAT															:INOUT STD_LOGIC;
			I2C_SCLK,AUD_DACDAT,AUD_XCK								:OUT STD_LOGIC);
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

	SIGNAL read_ready, write_ready, read_s, write_s		      :STD_LOGIC;
	SIGNAL writedata_left, writedata_right							:STD_LOGIC_VECTOR(23 DOWNTO 0);	
	SIGNAL readdata_left, readdata_right							:STD_LOGIC_VECTOR(23 DOWNTO 0);	
	SIGNAL reset															:STD_LOGIC;

	type sound_states is (init, wait_write, write_sample, wait_received, write_lower);
	--constant volume : std_logic_vector(23 downto 0) := std_logic_vector(to_unsigned(65536, 24));
	--constant neg_volume : std_logic_vector(23 downto 0) := std_logic_vector(to_signed(-65536, 24));
	constant volume : std_logic_vector(23 downto 0) := "000000001000000000000000";
	constant neg_volume : std_logic_vector(23 downto 0) := "111111111000000000000000";

	constant NOTE_PERIOD : unsigned(7 downto 0) := "00000000";
	type NotePeriod is record
		half : unsigned(NOTE_PERIOD'left downto NOTE_PERIOD'right);
		full : unsigned(NOTE_PERIOD'left downto NOTE_PERIOD'right);
	end record;

	type Piano is record
		C4 : NotePeriod;
		Cs4 : NotePeriod;
		D4 : NotePeriod;
		Ds4 : NotePeriod;
		E4 : NotePeriod;
		F4 : NotePeriod;
		G4 : NotePeriod;
		A4 : NotePeriod;
		B4 : NotePeriod;
		C5 : NotePeriod;
	end record;

	type PianoTimer is record
		C4 : unsigned(NOTE_PERIOD'left downto NOTE_PERIOD'right);
		Cs4 : unsigned(NOTE_PERIOD'left downto NOTE_PERIOD'right);
		D4 : unsigned(NOTE_PERIOD'left downto NOTE_PERIOD'right);
		Ds4 : unsigned(NOTE_PERIOD'left downto NOTE_PERIOD'right);
		E4 : unsigned(NOTE_PERIOD'left downto NOTE_PERIOD'right);
		F4 : unsigned(NOTE_PERIOD'left downto NOTE_PERIOD'right);
		G4 : unsigned(NOTE_PERIOD'left downto NOTE_PERIOD'right);
		A4 : unsigned(NOTE_PERIOD'left downto NOTE_PERIOD'right);
		B4 : unsigned(NOTE_PERIOD'left downto NOTE_PERIOD'right);
		C5 : unsigned(NOTE_PERIOD'left downto NOTE_PERIOD'right);
	end record;

	type NoteActive is record
		C4 : std_logic;
		Cs4 : std_logic;
		D4 : std_logic;
		Ds4 : std_logic;
		E4 : std_logic;
		F4 : std_logic;
		G4 : std_logic;
		A4 : std_logic;
		B4 : std_logic;
		C5 : std_logic;
	end record;

	constant notes : Piano := (
		(to_unsigned(91,NOTE_PERIOD'length), to_unsigned(183,NOTE_PERIOD'length)), -- C4
		(to_unsigned(86,NOTE_PERIOD'length), to_unsigned(173,NOTE_PERIOD'length)), -- C#4
		(to_unsigned(81,NOTE_PERIOD'length), to_unsigned(163,NOTE_PERIOD'length)), -- D4
		(to_unsigned(77,NOTE_PERIOD'length), to_unsigned(154,NOTE_PERIOD'length)), -- D#4
		(to_unsigned(68,NOTE_PERIOD'length), to_unsigned(145,NOTE_PERIOD'length)), -- E4
		(to_unsigned(68,NOTE_PERIOD'length), to_unsigned(137,NOTE_PERIOD'length)), -- F4
		(to_unsigned(61,NOTE_PERIOD'length), to_unsigned(122,NOTE_PERIOD'length)), -- G4
		(to_unsigned(54,NOTE_PERIOD'length), to_unsigned(109,NOTE_PERIOD'length)), -- A4
		(to_unsigned(48,NOTE_PERIOD'length), to_unsigned(97,NOTE_PERIOD'length)), -- B4
		(to_unsigned(45,NOTE_PERIOD'length), to_unsigned(91,NOTE_PERIOD'length))  -- C5
		);

	signal play : NoteActive;

BEGIN

	reset <= NOT(KEY(0));
	read_s <= '0';
	play.C4 <= SW(0);
	play.D4 <= SW(1);
	play.E4 <= SW(2);
	play.F4 <= SW(3);
	play.G4 <= SW(4);
	play.A4 <= SW(5);
	play.B4 <= SW(6);
	play.C5 <= SW(7);

	ledr <= sw;


	my_clock_gen: clock_generator PORT MAP (CLOCK_27, reset, AUD_XCK);
	cfg: audio_and_video_config PORT MAP (CLOCK_50, reset, I2C_SDAT, I2C_SCLK);
	codec: audio_codec PORT MAP(CLOCK_50,reset,read_s,write_s,writedata_left, writedata_right,AUD_ADCDAT,AUD_BCLK,AUD_ADCLRCK,AUD_DACLRCK,read_ready, write_ready,readdata_left, readdata_right,AUD_DACDAT);

	process(clock_50)
		variable sound_state : sound_states := init;
		variable sample_counter : PianoTimer;
		variable sample : std_logic_vector(23 downto 0);
	begin

		if (reset = '1') then
			sound_state := init;
		elsif (rising_edge(clock_50)) then

			writedata_right <= sample;
			writedata_left <= sample;

			case sound_state is
				when init =>
					sound_state := wait_write;
					sample_counter.C4 := "00000000";
					sample_counter.Cs4 := "00000000";
					sample_counter.D4 := "00000000";
					sample_counter.Ds4 := "00000000";
					sample_counter.E4 := "00000000";
					sample_counter.F4 := "00000000";
					sample_counter.G4 := "00000000";
					sample_counter.A4 := "00000000";
					sample_counter.B4 := "00000000";
					sample_counter.C5 := "00000000";

					sample := std_logic_vector(to_unsigned(0, sample'length));

				when wait_write =>
					write_s <= '0';

					if (write_ready = '1') then
						sound_state := write_sample;
					end if;

				when write_sample =>
					write_s <= '1';
					if (play.C4 = '1') then
						if (sample_counter.C4 > notes.C4.half) then
							sample := neg_volume;
						else
							sample := volume;
						end if;

						sample_counter.C4 := sample_counter.C4 + to_unsigned(1, sample_counter.C4'length);
						if (sample_counter.C4 > notes.C4.full) then
							sample_counter.C4 := to_unsigned(0, sample_counter.C4'length);
						end if;
					end if;

					sound_state := wait_received;

				when wait_received =>
					write_s <= '1';

					if (write_ready = '0') then
						sound_state := write_lower;
					end if;

				when write_lower =>
					write_s <= '0';
					sound_state := wait_write;

				when others => sound_state := init;
			end case;
		end if;
    end process;


END Behavior;
