library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_arith.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity RWMEMv1 is
  generic(
    --FILE_PATH: string;           -- RAM output data file
    FILE_PATH_INIT: string;      -- RAM initialization data file
    WORD_SIZE: natural := 32;    -- Number of bits per word
    ENTRIES: natural := 128     -- Number of lines in the ROM
    --DATA_DELAY: natural := 2     -- Delay (in # of clock cycles)
  );
  
  port (
    CLK             : in std_logic;
    RST             : in std_logic;
    ADDRESS         : in std_logic_vector(WORD_SIZE - 1 downto 0);
    --ENABLE          : in std_logic;
    READNOTWRITE    : in std_logic;
    --DATA_READY      : out std_logic;
	IN_DATA 		: in std_logic_vector((2*WORD_SIZE) - 1 downto 0);
    OUT_DATA 		: out std_logic_vector((2*WORD_SIZE) - 1 downto 0)
  );
end entity RWMEMv1;

architecture beh of RWMEMv1 is 
  type DRAMtype is array (0 to ENTRIES - 1) of integer; --SIZE(INTEGER) < 2*WORDSIZE-1 check
  signal DRAM_mem : DRAMtype;   

  begin
	
	MEM_PROC: process(CLK, RST)
		file mem_fp: text;
    	variable file_line : line;
    	variable index : integer := 0;
    	variable tmp_data_u : std_logic_vector(2*WORD_SIZE-1 downto 0);
	begin
		if RST = '0' then --active low
			file_open(mem_fp,FILE_PATH_INIT,READ_MODE);
			index := 0;
			while ((not endfile(mem_fp)) and (index < ENTRIES)) loop
        		readline(mem_fp,file_line);
        		hread(file_line,tmp_data_u);
        		DRAM_mem(index) <= to_integer(unsigned(tmp_data_u));       
        		index := index + 4;
      		end loop;
			file_close(mem_fp);
		elsif CLK = '1' and CLK'event then
			--if ENABLE = '1' then
				if READNOTWRITE = '1'then
					OUT_DATA <= std_logic_vector(to_unsigned(DRAM_mem(to_integer(unsigned(ADDRESS))), OUT_DATA'length));
				else
					DRAM_mem(to_integer(unsigned(ADDRESS))) <= to_integer(signed(IN_DATA));
				end if;
			--end if;
		end if; 
	end process MEM_PROC;

end beh;
