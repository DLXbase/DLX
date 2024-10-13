library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity RWMEM is
	generic(
			file_path: string;
			file_path_init: string ;
			Data_size : natural := 32;
			Instr_size: natural := 32;
			RAM_DEPTH: 	natural := 128;
			data_delay: natural := 0
		);
	port (
			CLK   				: in std_logic;
			RST					: in std_logic;
			ADDR				: in std_logic_vector(Instr_size - 1 downto 0);
			ENABLE				: in std_logic;
			WRITE_NOT_READ		: in std_logic;
			IN_DATA				: in std_logic_vector(Data_size-1 downto 0);
			DATA_READY			: out std_logic;
			OUT_DATA			: out std_logic_vector(Data_size-1 downto 0)
		);
end RWMEM;

architecture beh of RWMEM is
	type DRAMtype is array (0 to RAM_DEPTH - 1) of std_logic_vector(instr_size - 1 downto 0);
	signal DRAM_mem : DRAMtype;
	signal tmp_data: std_logic_vector(Data_size - 1 downto 0);
	signal int_data_ready,mem_ready: std_logic;
	signal counter: natural:=0;

	procedure rewrite_contenent(data: in DRAMtype; path_file: string) is
		variable index: natural range 0 to RAM_DEPTH;
		file wr_file: text;
		variable line_in: line;
	begin
		index:=0;
		file_open(wr_file,path_file,WRITE_MODE);
		while index < RAM_DEPTH loop
			hwrite(line_in,data(index));
			writeline(wr_file,line_in);
			index := index + 1;
		end loop;
	end rewrite_contenent;



begin  -- beh
	--write_process
	WR_PROCESS:
	process (CLK, RST,WRITE_NOT_READ)
		file mem_fp: text;
		variable index: integer range 0 to RAM_DEPTH;
		variable file_line : line;
		variable tmp_data_u : std_logic_vector(INSTR_SIZE-1 downto 0);
	begin  -- process
		if RST = '1' then  	 -- asynchronous reset (active low)
--			while index < RAM_DEPTH loop
--				DRAM_mem(index) <= std_logic_vector(to_unsigned(index,instr_size));
--				index := index + 1;
--			end loop;

			file_open(
				mem_fp,
				file_path_init,
				READ_MODE
			);

			while (not endfile(mem_fp)) loop
				readline(mem_fp,file_line);
				hread(file_line,tmp_data_u);
				DRAM_mem(index) <= tmp_data_u;
				index := index + 1;
			end loop;
			index := 0;
			file_close(mem_fp);

			int_data_ready <= '0';
			mem_ready <= '0';
		--elsif CLK'event and CLK = '1' then  -- rising clock edge
		elsif(ENABLE = '1') then
			counter <= counter + 1;
			int_data_ready <= '0';
			mem_ready <= '0';
			if (counter = data_delay) then
				counter <= 0;
				if (WRITE_NOT_READ = '0') then
					if to_integer(unsigned(ADDR)) > 0 then
						if to_integer(unsigned(ADDR)) < RAM_DEPTH then
							--DRAM_Mem(to_integer(unsigned(ADDR))+1) <= IN_DATA(Instr_size - 1 downto 0);
							DRAM_Mem(to_integer(unsigned(ADDR))) <= IN_DATA(Data_size - 1 downto 0); 
							mem_ready <= '1';
						end if;
					end if;
				else
					tmp_data <= DRAM_mem(to_integer(unsigned(ADDR)));
					int_data_ready <= '1';
				end if;
			else
				mem_ready <= '0';
				int_data_ready <= '0';
			end if;
		else
			counter <= 0;
		end if;
	end process;

	rewrite_contenent(DRAM_mem,file_path); -- refresh the file
	OUT_DATA <= tmp_data when int_data_ready='1' else (others=>'Z'); -- to cache
	data_ready <= int_data_ready or mem_ready;--delay add

end beh;
