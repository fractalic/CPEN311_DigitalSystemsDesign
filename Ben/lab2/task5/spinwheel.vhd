LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY WORK;
USE WORK.ALL;

--------------------------------------------------------------
---
--	A simulated European roulette wheel.
--	requires: fast_clock is a square wave with a period small enough
--			  as to be untimable by humans.
--			  resetb is an active low signal.
--	effects: Sets spin_result to a number from 0 to 35.
---------------------------------------------------------------

ENTITY spinwheel IS
	PORT(
		fast_clock   : IN  STD_LOGIC;  -- This will be a 27 Mhz Clock
		resetb       : IN  STD_LOGIC;      -- asynchronous reset
		spin_result  : OUT UNSIGNED(5 downto 0));  -- current value of the wheel
END;

ARCHITECTURE behavioral OF spinwheel IS

    --  We will use an integer to represent the count internally.  Of course we will
    --  need to cast it to an unsigned value before sending it outside the block.

	SIGNAL	wheel_internal : INTEGER;
	
BEGIN
	-- The wheel is always spinning
	PROCESS( fast_clock, resetb )
	BEGIN

                -- Asynchronous reset, follows pattern 3 in Slide Set 3

		IF (resetb ='0') THEN
			wheel_internal <= 0;

                -- If not reset, check for a rising clock edge

		ELSIF RISING_EDGE(fast_clock) THEN
			IF (wheel_internal = 36) THEN
				wheel_internal <= 0;
			ELSE
				wheel_internal <= wheel_internal + 1;
			END IF;
		END IF;
	END PROCESS;

	spin_result <= to_unsigned(wheel_internal, spin_result'length);
END;