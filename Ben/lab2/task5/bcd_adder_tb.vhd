LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

LIBRARY WORK;
USE WORK.ALL;


---
--  Testbench for a binary coded decimal converter.
--  The converter is based on the form of an adder,
--  but with three carry bits.

ENTITY bcd_converter_tb IS
  -- no inputs or outputs
END bcd_converter_tb;

-- The architecture part decribes the behaviour of the test bench

ARCHITECTURE behavioural OF bcd_converter_tb IS

   -- We will use an array of records to hold a list of test vectors and expected outputs.
   -- This simplifies adding more tests; we just have to add another line in the array.
   -- Each element of the array is a record that corresponds to one test vector.
   
   -- Define the record that describes one test vector
   
   TYPE test_case_record IS RECORD
    number               : UNSIGNED(3 DOWNTO 0);
    carry_in             : std_logic;
    binary_coded_decimal : unsigned(3 DOWNTO 0);
    carry_out            : std_logic;
   END RECORD;

   -- Define a type that is an array of the record.

   TYPE test_case_array_type IS ARRAY (0 to 6) OF test_case_record;
     
   -- Define the array itself.  We will initialize it, one line per test vector.
   -- If we want to add more tests, or change the tests, we can do it here.
   -- Note that each line of the array is one record, and the 8 numbers in each
   -- line correspond to the 8 entries in the record.  Seven of these entries 
   -- represent inputs to apply, and one represents the expected output.
    
   signal test_case_array : test_case_array_type := (
        ("0000", '0', "0000", '0'),
        ("0001", '0', "0001", '0'),
        ("0101", '1', "0110", '0'),
        ("1010", '0', "0000", '1'),
        ("1001", '1', "0000", '1'),
        ("1010", '1', "0001", '1'),
        ("1111", '1', "0110", '1')
             );             

  -- Define the new_balance subblock, which is the component we are testing

  COMPONENT bcd_adder IS
      PORT(
          number               : IN  UNSIGNED(3 DOWNTO 0);
          carry_in             : in  std_logic;
          binary_coded_decimal : OUT unsigned(3 DOWNTO 0);
          carry_out            : out std_logic
    );
   END COMPONENT;

   -- local signals we will use in the testbench 

signal number               : UNSIGNED(3 DOWNTO 0);
signal carry_in             : std_logic;
signal binary_coded_decimal : unsigned(3 DOWNTO 0);
signal carry_out            : std_logic;

begin

   -- instantiate the design-under-test

   dut : bcd_adder PORT MAP(
          number => number,
          carry_in => carry_in,
          binary_coded_decimal => binary_coded_decimal,
          carry_out => carry_out);


   -- Code to drive inputs and check outputs.  This is written by one process.
   -- Note there is nothing in the sensitivity list here; this means the process is
   -- executed at time 0.  It would also be restarted immediately after the process
   -- finishes, however, in this case, the process will never finish (because there is
   -- a wait statement at the end of the process).

   process
   begin   
    
      -- Loop through each element in our test case array.  Each element represents
      -- one test case (along with expected outputs).
      
      for i in test_case_array'low to test_case_array'high loop
        

        number <= test_case_array(i).number; 
        carry_in <= test_case_array(i).carry_in;

        -- Print information about the testcase to the transcript window (make sure when
        -- you run this, your transcript window is large enough to see what is happening)
        
        report "-------------------------------------------";
        report "Test case " & integer'image(i) & ":" &
                 " number=" & integer'image(to_integer(test_case_array(i).number)) &
                 " carry_in=" & std_logic'image(test_case_array(i).carry_in);

        -- assign the values to the inputs of the DUT (design under test)          

        -- wait for some time, to give the DUT circuit time to respond (1ns is arbitrary)                

        wait for 1 ns;
        
        -- now print the results along with the expected results
        
        report  " Expect BCD=" & integer'image(to_integer(test_case_array(i).binary_coded_decimal)) & 
                " Actual BCD= " & integer'image(to_integer(binary_coded_decimal)) &
                 " Expect CO= " & std_logic'image(test_case_array(i).carry_out) &
                 " Actual CO= " & std_logic'image(carry_out);

        -- This assert statement causes a fatal error if there is a mismatch
                                                                    
        assert (test_case_array(i).binary_coded_decimal= binary_coded_decimal )
            report "MISMATCH.  THERE IS A PROBLEM IN YOUR DESIGN THAT YOU NEED TO FIX"
            severity failure;
        assert (test_case_array(i).carry_out= carry_out )
            report "MISMATCH.  THERE IS A PROBLEM IN YOUR DESIGN THAT YOU NEED TO FIX"
            severity failure;
      end loop;
                                           
      report "================== ALL TESTS PASSED =============================";
                                                                              
      wait; --- we are done.  Wait for ever
    end process;
end behavioural;