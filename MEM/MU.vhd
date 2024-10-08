library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.constants.all; 


entity MU is
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
  
end MU;

architecture structural of MU is
  --signals
  --signal DRAM_out: std_logic_vector(N-1 downto 0);
  --component
  component reg
    generic(N : integer);
    port(
      clk, rst, en : in std_logic;
      A : in std_logic_vector(N-1 downto 0);
      Y : out std_logic_vector(N-1 downto 0)
    );
  end component;

--  component DRAM
--    generic(
--	--FILE_PATH: string;
--	FILE_PATH_INIT: string;
--	WORD_SIZE : natural := 32;
--	ENTRIES : natural := 128
--	--DATA_DELAY : natural := 2
--    );
--    port(
--	CLK : in std_logic;
--	RST : in std_logic;
--	ADDRESS : in std_logic_vector(WORD_SIZE-1 downto 0);
--	ENABLE : in std_logic;
--	READNOTWRITE : in std_logic;
--	--DATA_READY : out std_logic;
--	IN_DATA : in std_logic_vector(2*WORD_SIZE-1 downto 0);
--	OUT_DATA : out std_logic_vector(2*WORD_SIZE-1 downto 0)
--    );
--  end component;

begin
  --port map
--  DRAM_u : DRAM
--	generic map(FILE_PATH_INIT => "test_mem.asm.mem")
--	port map(
--		CLK => CLK,
--		RST => RST,
--		ADDRESS => ALU_RESULT,
--		ENABLE => CW(4),
--		READNOTWRITE => CW(3),
--		IN_DATA => RT_REG_in,
--		OUT_DATA => DRAM_out
--	);

  LMD_REG : reg
	generic map (N => N)
	port map (
		clk => CLK,
		rst => RST,
		en => LMD_EN,
		A => LMD_LATCH_in,
		Y => LMD_LATCH_out
	);

  ALU_OUT_REG_1 : reg
	generic map (N => N)
	port map (
		clk => CLK,
		rst => RST,
		en => '1',
		A => ALU_RESULT,
		Y => ALU_REG_out
	);

  RT_REG_3 : reg
	generic map (N => N)
	port map (
		clk => CLK,
		rst => RST,
		en => '1',
		A => RT_REG_in,
		Y => RT_REG_out
	);

	--JAL npc reg
	JAL_NPC_m : reg
		generic map (N => N)
		port map (
			clk => CLK,
			rst => RST ,
			en => '1',
			A => NPC_REG_in,
			Y => NPC_REG_out
		);
  
end structural;
