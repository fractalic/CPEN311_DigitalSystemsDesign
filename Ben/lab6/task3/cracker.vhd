library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Entity part of the description.  Describes inputs and outputs

entity cracker is
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
end cracker;

-- Architecture part of the description

architecture rtl of cracker is
	
   COMPONENT s_memory IS
	   PORT (
		   address		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		   clock		: IN STD_LOGIC  := '1';
		   data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		   wren		: IN STD_LOGIC ;
		   q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
   END component;

component d_memory
  PORT
  (
    address   : IN STD_LOGIC_VECTOR (4 DOWNTO 0);
    clock   : IN STD_LOGIC  := '1';
    data    : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
    wren    : IN STD_LOGIC ;
    q   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
  );
end component;

component init_s is
  port(
    start : in std_logic;
    clock : in std_logic;
    done : out std_logic;
    wren : out std_logic;
    data : out std_logic_vector(7 downto 0);
    addr : out std_logic_vector(7 downto 0)
  );
end component;

component reorder_s is
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
end component;

	-- Enumerated type for the state variable.  You will likely be adding extra
	-- state names here as you complete your design
	
	type state_type is (
        state_reset, state_reg_new_key,

        state_init, state_fill, state_done,

        state_reg_new_char,

        state_reorder_begin, state_reorder_loop, state_reorder_done,
        state_decrypt_begin, state_decrypt_iterate, state_decrypt_iterate_delay,
        state_decrypt_regSi, state_decrypt_writeSj, state_decrypt_regSj,
        state_decrypt_loadE, state_decrypt_loadE_wait, state_decrypt_writeD,
        state_decrypt_done
    );

    constant MEM_SIZE : natural := 256;
    constant KEY_LENGTH : natural := 3;
    constant MESSAGE_LENGTH : natural := 32;
								
    signal secret_key : std_logic_vector(23 downto 0);

    -- These are signals that are used to connect to the memory													 
    signal address : STD_LOGIC_VECTOR (7 DOWNTO 0);	 
    signal data : STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal wren : STD_LOGIC;
    signal q : STD_LOGIC_VECTOR (7 DOWNTO 0);

    signal address_e : std_logic_vector(4 downto 0);
    signal q_e : std_logic_vector(7 downto 0);

    signal address_d : STD_LOGIC_VECTOR (4 DOWNTO 0);   
    signal data_d : STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal wren_d : STD_LOGIC;
    signal q_d : STD_LOGIC_VECTOR (7 DOWNTO 0);

    signal u_init_start : std_logic;
    signal u_init_done : std_logic;
    signal u_init_wren : std_logic;
    signal u_init_data : std_logic_vector(data'left downto data'right);
    signal u_init_addr : std_logic_vector(address'left downto address'right);
    signal u_init_active : std_logic;

    signal u_reorder_start : std_logic;
    signal u_reorder_done : std_logic;
    signal u_reorder_wren : std_logic;
    signal u_reorder_data : std_logic_vector(data'left downto data'right);
    signal u_reorder_addr : std_logic_vector(address'left downto address'right);
    signal u_reorder_active : std_logic;
    signal u_reorder_q : std_logic_vector(7 downto 0);

    signal u_address_s : std_logic_vector(7 downto 0);
    signal u_data_s : std_logic_vector(7 downto 0);
    signal u_wren_s : std_logic;

	begin
	
        u_s: s_memory
            port map (u_address_s, clock_50, u_data_s, u_wren_s, q);

        d_ram: d_memory
            port map(address => address_d, clock => clock_50, data => data_d, wren => wren_d, q => q_d);

        u_init: init_s
            port map(start => u_init_start, clock => clock_50, done => u_init_done,
            wren => u_init_wren, data => u_init_data, addr => u_init_addr);

        u_reorder: reorder_s
            port map(start => u_reorder_start, clock => clock_50, q => q, secret_key => secret_key,
            done => u_reorder_done, wren => u_reorder_wren, data => u_reorder_data, address => u_reorder_addr);

    -- Manage access to S.
    process(all)
    begin
        if (u_init_active = '1') then
            u_wren_s <= u_init_wren;
            u_data_s <= u_init_data;
            u_address_s <= u_init_addr;
        elsif (u_reorder_active = '1') then
            u_wren_s <= u_reorder_wren;
            u_data_s <= u_reorder_data;
            u_address_s <= u_reorder_addr;
        else
            u_wren_s <= wren;
            u_data_s <= data;
            u_address_s <= address;
        end if;
    end process;


    process(clock_50)
    -- State.
    variable currentState : state_type := state_init;

    -- Iteration.
    variable memI : integer := 0;
    variable memJ : integer := 0;
    variable memK : integer := 0;
    variable memImod : integer := 0;


    variable key : std_logic_vector(23 downto 0);
    variable key_sub : std_logic_vector(7 downto 0);

    variable char_e : std_logic_vector(7 downto 0);

    variable address_s_var : std_logic_vector(address'left downto address'right);
    variable data_s_var : std_logic_vector(data'left downto data'right);
    variable wren_s_var : std_logic;

    variable address_d_var : std_logic_vector(address_d'left downto address_d'right);
    variable data_d_var : std_logic_vector(data'left downto data'right);
    variable wren_d_var : std_logic;

    variable Si : std_logic_vector(data'left downto data'right);
    variable Sj : std_logic_vector(data'left downto data'right);
    variable Sf : std_logic_vector(data'left downto data'right);

    variable ready_var : std_logic;

    begin


    	if (rising_edge(clock_50)) then

    	case currentState is

            when state_reset =>
                if (go = '1') then
                    currentState := state_reg_new_key;
                    ready_var := '0';
                else
                    currentState := state_reset;
                end if;

                u_init_active <= '0';
                u_init_start <= '0';
                u_reorder_active <= '0';
                u_reorder_start <= '0';

                ready_var := '1';


            when state_reg_new_key =>
                currentState := state_init;

                key := key_in;

                ready_var := '0';



    		when state_init =>
    			currentState := state_fill;

                u_init_active <= '1';
                u_init_start <= '1';
                u_reorder_active <= '0';
                u_reorder_start <= '0';

                ready_var := '0';


    		when state_fill =>
                currentState := state_fill;
    			if (u_init_done = '1') then
    				currentState := state_done;
                end if;

                ready_var := '0';


    		when state_done =>
                --currentState := state_reorder_begin;
                currentState := state_decrypt_done;

                u_init_active <= '0';
                u_init_start <= '0';

                ready_var := '0';


            when state_reorder_begin =>
              currentState := state_reorder_loop;

              u_reorder_active <= '1';
              u_reorder_start <= '1';

              ready_var := '0';


            when state_reorder_loop =>
              if (u_reorder_done = '1') then
                currentState := state_reorder_done;
                ready_var := '1';
              else
                currentState := state_reorder_loop;
              end if;

              ready_var := '0';


            when state_reorder_done =>
                currentState := state_reorder_done;

                if (go = '1') then
                    currentState := state_reg_new_char;
                    ready_var := '0';
                end if;

                ready_var := '1';

                u_reorder_active <= '0';
                u_reorder_start <= '0';

                memI := 0;
                memJ := 0;
                memK := 0;

                wren_d_var := '0';



            when state_reg_new_char =>
                currentState := state_decrypt_iterate;

                ready_var := '0';
                char_e := char_in;



            when state_decrypt_iterate =>
              currentState := state_decrypt_iterate_delay;

              memI := (memI + 1) mod MEM_SIZE;

              wren_s_var := '0';
              address_s_var := std_logic_vector(to_unsigned(memI, address_s_var'length));

              ready_var := '0';


            when state_decrypt_iterate_delay =>
              currentState := state_decrypt_regSi;

              ready_var := '0';


            when state_decrypt_regSi =>
              currentState := state_decrypt_writeSj;

              Si := q;
              memJ := (memJ + to_integer(unsigned(Si)) ) mod MEM_SIZE;

              wren_s_var := '0';
              address_s_var := std_logic_vector(to_unsigned(memJ, address_s_var'length));

              ready_var := '0';


            when state_decrypt_writeSj =>
              currentState := state_decrypt_regSj;

              wren_s_var := '1';
              address_s_var := std_logic_vector(to_unsigned(memJ, address_s_var'length));
              data_s_var := Si;

              ready_var := '0';


            when state_decrypt_regSj =>
              currentState := state_decrypt_loadE;

              Sj := q;

              wren_s_var := '1';
              address_s_var := std_logic_vector(to_unsigned(memI, address_s_var'length));
              data_s_var := Sj;

              ready_var := '0';


            when state_decrypt_loadE =>
              currentState := state_decrypt_loadE_wait;

              wren_s_var := '0';
              address_s_var := std_logic_vector(to_unsigned( (to_integer(unsigned(Si)) + to_integer(unsigned(Sj)) ) mod MEM_SIZE, address_s_var'length ));

              ready_var := '0';


            when state_decrypt_loadE_wait =>
              currentState := state_decrypt_writeD;

              ready_var := '0';


            when state_decrypt_writeD =>
                currentState := state_decrypt_done;

                Sf := q;

                wren_d_var := '1';
                address_d_var := std_logic_vector(to_unsigned(memK, address_d_var'length));
                data_d_var := Sf xor char_e;

                memK := memK + 1;

                ready_var := '0';


            when state_decrypt_done =>
                currentState := state_decrypt_done;

                if (go = '1') then
                    if (new_key = '1') then
                        currentState := state_reg_new_key;
                        ready_var := '0';
                    else
                        currentState := state_reg_new_char;
                        ready_var := '0';
                    end if;
                end if;

                wren_d_var := '0';

                ready_var := '1';
                


        	when others =>
                currentState := state_init;
                ready_var := '0';


    		end case;
    	end if;


        address <= address_s_var;
        data <= data_s_var;
        wren <= wren_s_var;

        wren_d <= wren_d_var;
        address_d <= address_d_var;
        data_d <= data_d_var;

        ready <= ready_var;

    end process;

end rtl;


