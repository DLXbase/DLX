library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;
use work.alu_type.all;
use work.myTypes.all;
use work.constants.all;

entity TBMEM is
end TBMEM;

architecture TEST of TBMEM is

    --components
    component MU
        generic (N: integer := WORD_SIZE);
        port(
            CLK: in std_logic;
            RST : in std_logic;
            LMD_EN: in std_logic; 
            ALU_RESULT : in std_logic_vector(N-1 downto 0);
            RT_REG_in : in std_logic_vector(N-1 downto 0);
            NPC_REG_in : in std_logic_vector(N-1 downto 0);
            LMD_LATCH_in : in std_logic_vector(N-1 downto 0);
        
            LMD_LATCH_out : out std_logic_vector(N-1 downto 0);
            ALU_REG_out : out std_logic_vector(N-1 downto 0);
            RT_REG_out : out std_logic_vector(N-1 downto 0);
            NPC_REG_out : out std_logic_vector(N-1 downto 0)
        );
    end component;

    component RWMEM
        generic(
			file_path: string;
			file_path_init: string;
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
			READNOTWRITE		: in std_logic;
			IN_DATA				: in std_logic_vector(Data_size-1 downto 0);
			DATA_READY			: out std_logic;
			OUT_DATA			: out std_logic_vector(Data_size-1 downto 0)
		);
    end component;

    --signals

    signal DRAM_OUT_s  : std_logic_vector(WORD_SIZE-1 downto 0);
    signal NPC_OUT_s, LMD_OUT_s, ALU_OUT_s, RT_OUT_s : std_logic_vector(WORD_SIZE-1 downto 0);
    signal RT_IN_s : std_logic_vector(WORD_SIZE-1 downto 0) := x"FFFFFFFF";
    signal NPC_IN_s : std_logic_vector(WORD_SIZE-1 downto 0) := x"00000000";
	signal ALU_IN_s : std_logic_vector(WORD_SIZE-1 downto 0) := x"00000000";


    signal CLK         : std_logic := '0';
    signal RST         : std_logic := '0';
    signal ENABLE      : std_logic := '0';
    signal READNOTWRITE: std_logic := '0';
    signal DATA_READY  : std_logic;

    signal LMD_EN : std_logic := '0';

    constant CLK_PERIOD: time := 10 ns;

begin

    --port maps
    DUT_D : RWMEM
        generic map (
            file_path => "/home/ms24.11/Desktop/DLX/DLX(HW_CU)/output_file.mem",
            file_path_init => "/home/ms24.11/Desktop/DLX/DLX(HW_CU)/test.asm.mem",
            Data_size => 32,
            Instr_size => 32,
            RAM_DEPTH => 128,
            data_delay => 0    
        )
        port map (
            CLK => CLK,
            RST => RST,
            ADDR => ALU_IN_s, --questo
            ENABLE => ENABLE,
            READNOTWRITE => READNOTWRITE,
            IN_DATA => RT_IN_s, --questo
            DATA_READY => DATA_READY,
            OUT_DATA => DRAM_OUT_s
        );

    DUT_M : MU
        generic map (N => WORD_SIZE)
        port map (
            CLK => CLK,
            RST => RST,
            LMD_EN => LMD_EN,
            ALU_RESULT => ALU_IN_s, --questo
            RT_REG_in => RT_IN_s, --questo
            NPC_REG_in => NPC_IN_s, --indip
            LMD_LATCH_in => DRAM_OUT_s,
            LMD_LATCH_out => LMD_OUT_s,
            ALU_REG_out => ALU_OUT_s,
            RT_REG_out => RT_OUT_s,
            NPC_REG_out => NPC_OUT_s
        );

        -- Clock generation process
    CLK_GEN: process
    begin
        while true loop
            CLK <= '0';
            wait for CLK_PERIOD / 2;
            CLK <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    STIMULUS_INDIP: process
		variable tmp_npc : signed(NPC_IN_s'range);
        variable tmp_rt : signed(RT_IN_s'range);
    begin
        
        while true loop
--            if NPC_IN_s = x"0" then
--                NPC_IN_s <= x"FFFFFFFF";
--            end if;
--            if RT_IN_s = x"FFFFFFFF" then
--                RT_IN_s <= x"0";
--            end if;
            tmp_npc := signed(NPC_IN_s);
            tmp_rt := signed(RT_IN_s);
            tmp_npc := tmp_npc + 1;
            tmp_rt := tmp_npc - 1;
            NPC_IN_s <= std_logic_vector(tmp_npc);
            RT_IN_s <= std_logic_vector(tmp_rt);
            wait for 20 ns;
        end loop;
        wait;
    end process;

    STIMULUS: process
    variable tmp_addr : signed(ALU_IN_s'range);
	variable exit_flag : std_logic := '0';
    begin
        -- Reset the system
        RST <= '1';
        wait for 20 ns;
        RST <= '0';
        wait for 20 ns;

        -- Write data to the DRAM
        ENABLE <= '1';
        LMD_EN <= '1';
        READNOTWRITE <= '0';  -- Write operation
        while exit_flag = '0' loop
			if ALU_IN_s = x"0000007E" then --MEMORY IS 128 in depth
				exit_flag := '1';
			end if;
            tmp_addr := signed(ALU_IN_s);
            tmp_addr := tmp_addr + 1;
            ALU_IN_s <= std_logic_vector(tmp_addr);
            wait for 10 ns;
        end loop;
		exit_flag := '0';

        READNOTWRITE <= '1';  -- Read operation
        ALU_IN_s <= x"00000000";  -- Address 0
        wait for 40 ns;

        while exit_flag = '0' loop
			if ALU_IN_s = x"0000007E" then
				exit_flag := '1';
			end if;
            tmp_addr := signed(ALU_IN_s);
            tmp_addr := tmp_addr + 1;
            ALU_IN_s <= std_logic_vector(tmp_addr);
            wait for 10 ns;
        end loop;

        wait;
    end process;

--run around 2700ns

end TEST;
