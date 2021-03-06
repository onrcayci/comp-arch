library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cache is
	generic(
		ram_size : INTEGER := 32768
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
signal next_state: states;


-- declare signals here

--Block Structure
--128 bits of data
--8 bit tag --> main mem only has 2^15 bytes; 2^5 blocks and each block has 2^2 words; therefore 15 - (5 + 2) = 8 bits for tag
--1 bit valid
--1 bit dirty
--138 bits total


-- 32-block cache
type blk_data is array(3 downto 0) of std_logic_vector(31 downto 0);
type data is array(31 downto 0) of blk_data;
type tags is array(31 downto 0) of std_logic_vector (7 downto 0);
type  flags is array(31 downto 0) of std_logic_vector (1 downto 0);
--bit 1 is the dirty flag, bit 0 is the valid flag

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
		end if;
	end process;
	
	logic_process: process(s_read, s_write, m_waitrequest, state)
		-- byte count for main memory, in order to support word aligned
		variable byte_count: INTEGER := 0;
		-- word offset count in order to load or write a whole cache block
		variable offset_count: INTEGER := 0;
		variable address: std_logic_vector(14 downto 0);
		-- block index
		variable index: INTEGER := 0;
		-- block offset, which corresponds to the word in a block
		variable offset: INTEGER;
	begin
		offset := to_integer(unsigned(s_addr(1 downto 0)));
		index := to_integer(unsigned(s_addr(6 downto 2)));
		
		case state is
		
			-- Initial state
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
				if cache_tags(index) = s_addr(14 downto 7) and cache_flags(index)(0) = '1' then
					--read data
					s_readdata <= cache_data(index)(offset);
					s_waitrequest <= '0';
					next_state <= start;
					
				--Case 2: Requested data dirty and not in cache
				elsif cache_flags(index)(1) = '1' then
					next_state <= mem_write;
					
				--Case 3: Requested data is NOT dirty and not in cache --> bring it from memory
				elsif cache_flags(index) = "00" or cache_flags(index) = "UU" then
					next_state <= mem_read;
					
				end if;
			
			-- Write operation
			when w =>
				--Case 1: Check if tags don't match, valid = 1, and dirty is true then its a miss
				if cache_tags(index) /= s_addr(14 downto 7) and cache_flags(index) = "11" then
					next_state <= wb;
					
				--Case 2: Normal write
				else 
					cache_flags(index) <= "11";
					cache_data(index)(offset) <= s_writedata;
					cache_tags(index) <= s_addr(14 downto 7);
					s_waitrequest <= '0';
					next_state <= start;
				end if;
			
			-- Memory Read operation
			when mem_read =>
				
				-- Check for memory wait request to read
				if m_waitrequest = '1' then
					
					-- We are using only the lower 15 bits for the address space
					m_addr <= to_integer(unsigned(s_addr(14 downto 0))) + byte_count + (4 * offset_count);
					m_read <= '1';
					m_write <= '0';
					
					-- Since main memory is slower than cache, wait for the read to be processed
					next_state <= mem_wait;
				else
					next_state <= mem_read;
				end if;
				
			-- Write to the main memory
			when mem_write =>
				
				-- Remove the old data from the main memory
				if byte_count < 3 and offset_count < 4 and m_waitrequest = '1' then
					address := cache_tags(index) & s_addr(6 downto 0);
					m_addr <= to_integer(unsigned(address)) + byte_count + (4 * offset_count);
					m_write <= '1';
					m_read <= '0';
					
					-- Write operation
					m_writedata <= cache_data(index)(offset + offset_count)((byte_count * 8) + 7 downto (byte_count * 8));
					byte_count := byte_count + 1;
					next_state <= mem_write;
				elsif byte_count = 3 and m_waitrequest = '1' then
					address := cache_tags(index) & s_addr(6 downto 0);
					m_addr <= to_integer(unsigned(address)) + byte_count + (4 * offset_count);
					m_write <= '1';
					m_read <= '0';
					
					-- Write operation
					m_writedata <= cache_data(index)(offset + offset_count)((byte_count * 8) + 7 downto (byte_count * 8));
					byte_count := 0;
					offset_count := offset_count + 1;
					if offset_count < 4 then
						next_state <= mem_write;
					else
						byte_count := 0;
						offset_count := 0;
						next_state <= mem_read;
					end if;
				else
					m_write <= '0';
					next_state <= mem_write;
				end if;
			
			-- Waiting to access the main memory
			when mem_wait =>
				if byte_count < 3 and offset_count < 4 and m_waitrequest = '0' then
					cache_data(index)(offset + offset_count)((byte_count * 8) + 7 downto (byte_count * 8)) <= m_readdata;
					byte_count := byte_count + 1;
					m_read <= '0';
					next_state <= mem_read;
				elsif byte_count = 3 and m_waitrequest = '0' then
					cache_data(index)(offset + offset_count)((byte_count * 8) + 7 downto (byte_count * 8)) <= m_readdata;
					byte_count := 0;
					offset_count := offset_count + 1;
					m_read <= '0';
					if offset_count < 4 then
						next_state <= mem_read;
					else
						s_readdata <= cache_data(index)(offset);
						cache_tags(index) <= s_addr(14 downto 7);
						cache_flags(index) <= "01";
						m_read <= '0';
						m_write <= '0';
						s_waitrequest <= '0';
						byte_count := 0;
						offset_count := 0;
						next_state <= start;
					end if;
				else
					next_state <= mem_wait;
				end if;
				
			--writeback from cache to mem
			when wb =>
				--First write the contents of cache to mem
				if byte_count < 3 and offset_count < 4 and m_waitrequest = '1' then
					address := cache_tags(index) & s_addr(6 downto 0);
					m_addr <= to_integer(unsigned(address)) + byte_count + (4 * offset_count);
					m_write <= '1';
					m_read <= '0';
					m_writedata <= cache_data(index)(offset + offset_count)((byte_count * 8) + 7 downto (byte_count * 8));
					byte_count := byte_count + 1;
					next_state <= wb;
					
				elsif byte_count = 3 and m_waitrequest = '1' then
					address := cache_tags(index) & s_addr(6 downto 0);
					m_addr <= to_integer(unsigned(address)) + byte_count + (4 * offset_count);
					m_write <= '1';
					m_read <= '0';
					m_writedata <= cache_data(index)(offset + offset_count)((byte_count * 8) + 7 downto (byte_count * 8));
					byte_count := 0;
					offset_count := offset_count + 1;
					if offset_count < 4 then
						next_state <= wb;
					else
					cache_data(index)(offset) <= s_writedata;
					cache_tags(index) <= s_addr(14 downto 7);
					cache_flags(index) <= "11";
					byte_count := 0;
					offset_count := 0;
					s_waitrequest <= '0';
					next_state <= start;
					end if;
				else
					m_write <= '0';
					next_state <= wb;
				end if;
		end case;
	end process;
		

end arch;