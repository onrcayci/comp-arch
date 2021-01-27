LIBRARY ieee;
USE ieee.STD_LOGIC_1164.all;

ENTITY fsm_tb IS
END fsm_tb;

ARCHITECTURE behaviour OF fsm_tb IS

COMPONENT comments_fsm IS
PORT (clk : in std_logic;
      reset : in std_logic;
      input : in std_logic_vector(7 downto 0);
      output : out std_logic
  );
END COMPONENT;

--The input signals with their initial values
SIGNAL clk, s_reset, s_output: STD_LOGIC := '0';
SIGNAL s_input: std_logic_vector(7 downto 0) := (others => '0');

CONSTANT clk_period : time := 1 ns;
CONSTANT SLASH_CHARACTER : std_logic_vector(7 downto 0) := "00101111";
CONSTANT STAR_CHARACTER : std_logic_vector(7 downto 0) := "00101010";
CONSTANT NEW_LINE_CHARACTER : std_logic_vector(7 downto 0) := "00001010";

BEGIN
dut: comments_fsm
PORT MAP(clk, s_reset, s_input, s_output);

 --clock process
clk_process : PROCESS
BEGIN
	clk <= '0';
	WAIT FOR clk_period/2;
	clk <= '1';
	WAIT FOR clk_period/2;
END PROCESS;
 
--TODO: Thoroughly test your FSM
stim_process: PROCESS
BEGIN
	
	REPORT "Test case 1, reading a multi-line of comment";
	s_input <= SLASH_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "When reading the start of a comment, the output should be '0'" SEVERITY ERROR;
	
	s_input <= STAR_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "When reading the second part of a comment, the output should be '0'" SEVERITY ERROR;
	
	s_input <= "01010100"; -- character t
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "When inside a comment, the output should be '1'" SEVERITY ERROR;
	
	s_input <= "01001000"; -- character h
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "When inside a comment, the output should be '1'" SEVERITY ERROR;
	
	s_input <= "01001001"; -- character i
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "When inside a comment, the output should be '1'" SEVERITY ERROR;
	
	s_input <= "01010011"; -- character s
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "When inside a comment, the output should be '1'" SEVERITY ERROR;
	
	s_input <= NEW_LINE_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "When inside a comment, the output should be '1'" SEVERITY ERROR;
	
	s_input <= "01010100"; -- character t
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "When inside a comment, the output should be '1'" SEVERITY ERROR;
	
	s_input <= "01001000"; -- character h
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "When inside a comment, the output should be '1'" SEVERITY ERROR;
	
	s_input <= "01001001"; -- character i
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "When inside a comment, the output should be '1'" SEVERITY ERROR;
	
	s_input <= "01010011"; -- character s
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "When inside a comment, the output should be '1'" SEVERITY ERROR;
	
	s_input <= STAR_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "When leaving a comment, the output should be '1'" SEVERITY ERROR;
	
	s_input <= SLASH_CHARACTER;
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '1') REPORT "When leaving a comment, the output should be '1'" SEVERITY ERROR;
	
	s_input <= "01010101"; -- character u
	WAIT FOR 1 * clk_period;
   ASSERT (s_output = '0') REPORT "When outside a comment, the output should be '0'" SEVERITY ERROR;

	REPORT "Test case 2, reading two slashes";
	s_input <= "00101111";
	WAIT FOR 1 * clk_period;
	ASSERT (s_output = '0') REPORT "After 1 slash output should be 0" SEVERITY ERROR;
	
	s_input <= "00101111";
	WAIT FOR 1*clk_period;
	ASSERT (s_output = '1') REPORT "After 2 slashes output should be 1" SEVERITY ERROR;
	
	--Q
	s_input <= "01010001";
	WAIT FOR 1*clk_period;
	ASSERT (s_output = '1') REPORT "During the comment the output should be 1" SEVERITY ERROR;
	
	--U
	s_input <= "01010101";
	WAIT FOR 1*clk_period;
	ASSERT (s_output = '1') REPORT "During the comment the output should be 1" SEVERITY ERROR;
	
	--A
	s_input <= "01000001";
	WAIT FOR 1*clk_period;
	ASSERT (s_output = '1') REPORT "During the comment the output should be 1" SEVERITY ERROR;
	
	--R
	s_input <= "01010010";
	WAIT FOR 1*clk_period;
	ASSERT (s_output = '1') REPORT "During the comment the output should be 1" SEVERITY ERROR;
	
	--T
	s_input <= "01010100";
	WAIT FOR 1*clk_period;
	ASSERT (s_output = '1') REPORT "During the comment the output should be 1" SEVERITY ERROR;
	
	--U
	s_input <= "01010101";
	WAIT FOR 1*clk_period;
	ASSERT (s_output = '1') REPORT "During the comment the output should be 1" SEVERITY ERROR;
	
	--S
	s_input <= "01010011";
	WAIT FOR 1*clk_period;
	ASSERT (s_output = '1') REPORT "During the comment the output should be 1" SEVERITY ERROR;
	
	s_input <= "00001010";
	WAIT FOR 1*clk_period;
	ASSERT (s_output = '1') REPORT "Output 1 during \n" SEVERITY ERROR;
	
	s_input <= "00000000";
	WAIT FOR 1*clk_period;
	ASSERT (s_output = '0') REPORT "Output 0 following \n" SEVERITY ERROR;
	
	WAIT;
END PROCESS stim_process;
END;
