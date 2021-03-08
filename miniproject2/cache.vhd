library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache is
generic(
	ram_size : INTEGER := 32768;
);
port(
	clock : in std_logic;
	reset : in std_logic;
	
	-- Avalon interface --
	s_addr : in std_logic_vector (31 downto 0);
	s_read : in std_logic;
	s_readdata : out std_logic_vector (31 downto 0);
	s_write : in std_logic;
	s_writedata : in std_logic_vector (31 downto 0);
	s_waitrequest : out std_logic; 
    
	m_addr : out integer range 0 to ram_size-1;
	m_read : out std_logic;
	m_readdata : in std_logic_vector (7 downto 0);
	m_write : out std_logic;
	m_writedata : out std_logic_vector (7 downto 0);
	m_waitrequest : in std_logic
);
end cache;

architecture arch of cache is
type states is (start, r, w, mem_read, mem_write, mem_wait, wb);
signal state: states;
signal next_state: states


-- declare signals here

--Block Structure
--128 bits of data
--15 bit tag --> main mem only has 2^15 bytes
--1 bit valid
--1 bit dirty
--143 bits total
signal word: std_logic_vector(31 downto 0);
signal blk_tag: std_logic_vector (24 downto 0);
signal blk_flag: std_logic_vector (1 downto 0);
--bit 1 is the dirty flag, bit 0 is the valid flag


-- 32-block cache
type blk_data is array(3 downto 0) of word;
type data is array(31 downto 0) of blk_data;
type tags is array(31 downto 0) of blk_tag;
type  flags is array(31 downto 0) of blk_flag;

-- cache signal
signal cache_data: data;
signal cache_tags: tags;
signal cache_flags: flags;

begin

-- make circuits here
	cache_process: process(clock, reset)
	begin
		if reset = '1' then
			state <= start;
		elsif clock = '1' then
			state <= next_state;
		end if
	end process
	
	logic_process: process(s_read, s_write, m_waitrequest, state)
		variable address: std_logic_vector(14 downto 0);
		variable index: INTEGER := 0;
		variable offset: INTEGER;
	begin
		offset := to_integer(unsigned(s_addr(1 downto 0))); --why do we add one
		index := to_integer(unsigned(s_addr(6 downto 2)));
		
		case state is 
			when start =>
				--Set high by default
				s_waitrequest <= '1';
				
				--Check for write request
				if s_write = '1' then
					next_state <= w;
				
				--Check for read request
				elsif s_read = '1' then
					next_state <= r;
				
				--If no operation is given, stay in the original state
				else 
					next_state <= start;
				
				end if;
			
			--Read operation
			when r =>
				--Case 1: Matching tags and valid bit = 1, so we can read the data
				if cache_tags(index) = s_addr(31 downto 7) and cache_flags(index)(0) = '1' then
					--read data
					s_readdata <= cache_data(index)(offset)
					s_waitrequest <= '0';
					next_state <= start;
					
				--Case 2: Requested data dirty and not in cache
				elsif cache_flags(index)(1) = '1' then
					next_state <= mem_write;
					
				--Case 3: Requested data is NOT dirty and not in cache --> bring it from memory
				elsif cache_flags(index) = "00" or cache_flags(index) = "UU" then
					next_state <= mem_read;
					
				else
					next_state <= rd;
					
				end if;
				
			when w =>
				--Case 1: Check if tags match, valid = 1, and dirty is true then its a miss
				if cache_tags(index) = s_addr(31 downto 7) and cache_flags(index) = "11" then
					next_state <= wb;
					
				--Case 2: Normal write
				else 
					cache_flags(index) <= "11";
					cache_data(index)(offset) <= s_writedata;
					cache_tags(index) <= s_addr(31 downto 7);
					s_waitrequest <= '0';
					next_state <= start;
			when mem_read =>
			when mem_write =>
			when mem_wait =>
			when wb =>
		end case
	end process
		

end arch;