library IEEE;
use IEEE.std_logic_1164.all;
use work.alu_type.all;
use work.myTypes.all;

entity TBCU is
end TBCU;

architecture TEST of TBDP is

	component DATAPATH 
		generic(N : integer := 32);
		port(
			CLK : in std_logic;
			RST : in std_logic;
			CW : in std_logic_vector(17 downto 0);
			ALU_FUNC : in aluOP;
			from_IRAM : in std_logic_vector(N-1 downto 0); --output of iram
			from_DRAM : in std_logic_vector(N-1 downto 0); --output of dram
			addr_to_DRAM : out std_logic_vector(N-1 downto 0); --input address for dram
			data_to_DRAM : out std_logic_vector(N-1 downto 0); --input data for dram
			to_IRAM : out std_logic_vector(N-1 downto 0); --input for iram 
			IR: out std_logic_vector(N-1 downto 0);
			PC_to_IRAM : out std_logic_vector(N-1 downto 0)
		);
	end component;

    constant IR_SIZE : integer := 32; 

	signal CLK_S       : std_logic;
	signal RST_S       : std_logic;
	signal CW_S        : std_logic_vector(17 downto 0);
	signal ALU_FUNC_S  : aluOP;
	signal from_IRAM_S : std_logic_vector(N-1 downto 0);  
	signal from_DRAM_S : std_logic_vector(N-1 downto 0);  
		
	signal addr_to_DRAM_S   : std_logic_vector(N-1 downto 0);
	signal data_to_DRAM_S   : std_logic_vector(N-1 downto 0);
	signal to_IRAM_S        : std_logic_vector(N-1 downto 0);
	signal IR_S             : std_logic_vector(N-1 downto 0);
	signal PC_to_IRAM_S     : std_logic_vector(N-1 downto 0);
begin

	--clk process
	process
	begin
		CLK <= '1';			-- clock cycle 2 ns
		wait for 1 ns;
		CLK <= '0';
		wait for 1 ns;
	end process;
	
		rst <= '1' after 2 ns, '0' after 10 ns;
		
    --instruction
	process
	begin
	    --opcode: "1000 00(00)" NOP
		IR_IN <= NOP&"00000"&"00000"&"0000000000000000";			
		wait for 15 ns;
		--ADD
		IR_IN <= RTYPE & "00000"&"00000"&"00000"&RTYPE_ADD;			
		wait for 2 ns;
		--SUB
		IR_IN <= ITYPE_BEQZ & "00000"&"00000"&"00000"&RTYPE_SUB;			
		wait for 2 ns; 
		--AND
		IR_IN <= ITYPE_ADDI & "00000"&"00000"&"00000"&RTYPE_AND;			
		wait for 2 ns; 	
		wait; 
	end process;
end TEST;