library ieee;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- Do not modify the port map of this structure
entity comments_fsm is
port (clk : in std_logic;
      reset : in std_logic;
      input : in std_logic_vector(7 downto 0);
      output : out std_logic
  );
end comments_fsm;

architecture behavioral of comments_fsm is

-- The ASCII value for the '/', '*' and end-of-line characters
constant SLASH_CHARACTER : std_logic_vector(7 downto 0) := "00101111";
constant STAR_CHARACTER : std_logic_vector(7 downto 0) := "00101010";
constant NEW_LINE_CHARACTER : std_logic_vector(7 downto 0) := "00001010";

-- Define the states
TYPE State_type is (S0, S1, S2, S3, S4);

-- Create a signal that uses the different states
signal state : State_type;

begin

-- Insert your processes here
process (clk, reset)
begin

   -- upon reset, set the state to S0
   if (reset = '1') then
      state <= S0;
    
   -- if there is a rising edge of the clock
   elsif rising_edge(clk) then

      -- check the value of the state variable and change the state
      -- based on the value
      case state is

         -- if the current state is S0 and input is '/', then the next state is S1
         when S0 =>
            if input = SLASH_CHARACTER then
               state <= S1;
            end if;
            
         -- if the current state is S1
         when S1 =>

            -- if input is '/', then the next state is S2
            if input = SLASH_CHARACTER then
               state <= S2;
                
            -- else if input is '*', then the next state is S3
            elsif input = STAR_CHARACTER then
               state <= S3;
            end if;
            
         -- if the current state is S2 and input is '\n', then the next state is S0
         when S2 =>
            if input = NEW_LINE_CHARACTER then
               state <= S0;
            end if;
            
         -- if the current state is S3 and input is '*', then the next state is S4
         when S3 =>
            if input = STAR_CHARACTER then
               state <= S4;
            end if;
            
         -- if the current state is S4
         when S4 =>

            -- if input is '/', then the next state is S0
            if input = SLASH_CHARACTER then
               state <= S0;

            -- else, the next state is S3
            else
               state <= S3;
            end if;
      end case;
   end if;
end process;

-- decode the current state to create the output
-- if the current state is S0 or S1, output is 0 otherwise output is 1
output <= '0' when (state = S0 or state = S1) else '1';

end behavioral;