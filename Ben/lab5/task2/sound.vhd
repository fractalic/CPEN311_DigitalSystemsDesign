LIBRARY ieee;
USE ieee.std_logic_1164.all;
use ieee.numeric_std.all;

ENTITY sound IS
	PORT (CLOCK_50,AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK,AUD_ADCDAT			:IN STD_LOGIC;
			CLOCK_27															:IN STD_LOGIC;
			KEY																:IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			SW																	:IN STD_LOGIC_VECTOR(17 downto 0);
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

	type sound_states is (init_state, wait_state, write_sample_state);
	--constant volume : std_logic_vector(23 downto 0) := std_logic_vector(to_unsigned(65536, 24));
	--constant neg_volume : std_logic_vector(23 downto 0) := std_logic_vector(to_signed(-65536, 24));
	constant volume : std_logic_vector(23 downto 0) := "000000001000000000000000";
	constant neg_volume : std_logic_vector(23 downto 0) := "111111111000000000000000";

BEGIN

	reset <= NOT(KEY(0));
	read_s <= '0';

	my_clock_gen: clock_generator PORT MAP (CLOCK_27, reset, AUD_XCK);
	cfg: audio_and_video_config PORT MAP (CLOCK_50, reset, I2C_SDAT, I2C_SCLK);
	codec: audio_codec PORT MAP(CLOCK_50,reset,read_s,write_s,writedata_left, writedata_right,AUD_ADCDAT,AUD_BCLK,AUD_ADCLRCK,AUD_DACLRCK,read_ready, write_ready,readdata_left, readdata_right,AUD_DACDAT);

	process(clock_50)
		variable sound_state : sound_states := init_state;
		variable sample_counter : unsigned(7 downto 0);
	begin
		if (rising_edge(clock_50)) then
			case sound_state is
				when init_state =>
					sound_state := wait_state;
					sample_counter := to_unsigned(0, sample_counter'length);

				when wait_state =>
					write_s <= '0';

					if (write_ready = '1') then
						sound_state := write_sample_state;
					end if;

				when write_sample_state =>
					write_s <= '1';

					if (sample_counter > to_unsigned(91, sample_counter'length)) then
						writedata_left <= neg_volume;
						writedata_right <= neg_volume;
					else
						writedata_left <= volume;
						writedata_right <= volume;
					end if;

					if (write_ready = '0') then
						sound_state := wait_state;
					end if;

					sample_counter := sample_counter + to_unsigned(1, sample_counter'length);
					if (sample_counter > to_unsigned(183, sample_counter'length)) then
						sample_counter := to_unsigned(0, sample_counter'length);
					end if;

				when others => sound_state := init_state;
			end case;
		end if;
    end process;


END Behavior;
