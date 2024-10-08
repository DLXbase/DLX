library ieee;
use ieee.std_logic_1164.all;
use work.myTypes.all;

entity DLX is
  generic (
        IR_SIZE      : integer := 32;       -- Instruction Register Size
        PC_SIZE      : integer := 32       -- Program Counter Size
		N : integer := 32    
	);       -- ALU_OPC_SIZE if explicit ALU Op Code Word Size
  port (
    Clk : in std_logic;
    Rst : in std_logic);                -- Active Low
end DLX;


-- This architecture is currently not complete
-- it just includes:
-- instruction register (complete)
-- program counter (complete)
-- instruction ram memory (complete)
-- control unit (UNCOMPLETE)
--
architecture dlx_rtl of DLX is

 --------------------------------------------------------------------
 -- Components Declaration
 --------------------------------------------------------------------
  
  --Instruction Ram
  component IRAM
     generic (
       RAM_DEPTH : integer := 48;
       IR_SIZE    : integer := 32);
    port (
      Rst  : in  std_logic;
      Addr : in  std_logic_vector(PC_SIZE - 1 downto 0);
      Dout : out std_logic_vector(IR_SIZE - 1 downto 0));
  end component;

  -- Data Ram 
    component RWMEM 
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
      ENABLE          : in std_logic;
      READNOTWRITE    : in std_logic;
      --DATA_READY      : out std_logic;
      IN_DATA 		: in std_logic_vector((2*WORD_SIZE) - 1 downto 0);
      OUT_DATA 		: out std_logic_vector((2*WORD_SIZE) - 1 downto 0)
    );
  end entity RWMEM;

  -- Datapath (MISSING!You must include it in your final project!)
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
  
  -- Control Unit
  component dlx_cu
  generic (
    MICROCODE_MEM_SIZE :     integer := 33;  -- Microcode Memory Size (NUMBER OF INSTRUCTIONS)
    FUNC_SIZE          :     integer := 11;  -- Func Field Size for R-Type Ops
    OP_CODE_SIZE       :     integer := 6;  -- Op Code Size
    -- ALU_OPC_SIZE       :     integer := 6;  -- ALU Op Code Word Size
    IR_SIZE            :     integer := 32;  -- Instruction Register Size    
    CW_SIZE            :     integer := 20);  -- Control Word Size
  port (
    Clk                : in  std_logic;  -- Clock
    Rst                : in  std_logic;  -- Reset:Active-Low
    -- Instruction Register
    IR_IN              : in  std_logic_vector(IR_SIZE - 1 downto 0);   --IR must be taken from the IRAM and not the IR_REG for timing reasons. 
    -- IF Control Signal
    IR_EN        : out std_logic;  -- Instruction Register Enable
    NPC_EN       : out std_logic;                                       -- NextProgramCounter Register Latch Enable
    -- ID Control Signals
    RegA_EN      : out std_logic;  -- Register A Latch Enable
    RegB_EN      : out std_logic;  -- Register B Latch Enable
    RegIMM_EN    : out std_logic;  -- Immediate Register Latch Enable
	RT_REG_EN          : out std_logic;
	IS_R_TYPE          : out std_logic;  --To understand which bytes encode the Target Register
	J_EN               : out std_logic;
    -- EX Control Signals
    MUXA_SEL           : out std_logic;  -- A/NPC Sel
    MUXB_SEL           : out std_logic;  -- B/IMM Sel
    ALU_OUTREG_EN      : out std_logic;  -- ALU Output Register Enable
    BEQZ_OR_BNEZ       : out std_logic;  -- to configure the zero(?) block. Works different if it's a BEQZ or BNEZ. 
	SH2_EN             : out std_logic;  -- IMM is shifted by 2 if it's a branch to compute the BTA. 
    -- ALU Operation Code
    ALU_OPCODE         : out aluOp; -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);    
    -- MEM Control Signals
    DRAM_WE            : out std_logic;  -- Data RAM Write Enable
    LMD_EN       : out std_logic;  -- LMD Register Latch Enable
    -- WB Control signals
    WB_MUX_SEL         : out std_logic;  -- Write Back MUX Sel
    RF_WE              : out std_logic;  -- Register File Write Enable
    JAL_EN             : out std_logic; -- needed to write NPC on R31
	-- PC enable 
    PC_EN : out std_logic);

  end component;


  ----------------------------------------------------------------
  -- Signals Declaration
  ----------------------------------------------------------------
  
  -- Instruction Register (IR) and Program Counter (PC) declaration
  signal IR : std_logic_vector(IR_SIZE - 1 downto 0);
  signal PC : std_logic_vector(PC_SIZE - 1 downto 0);

  -- Instruction Ram Bus signals
  signal IRam_DOut : std_logic_vector(IR_SIZE - 1 downto 0);

  -- Datapath Bus signals
  signal PC_BUS : std_logic_vector(PC_SIZE -1 downto 0);

  -- Control Unit Bus signals
  signal IR_EN_i : std_logic;
  signal NPC_EN_i : std_logic;

  signal RegA_EN_i : std_logic;
  signal RegB_EN_i : std_logic;
  signal RegIMM_EN_i : std_logic;
  signal RT_REG_EN_i : std_logic;
  signal IS_R_TYPE_i : std_logic;
  signal J_EN_i : std_logic;

  signal ALU_OPCODE_i : aluOp;

  signal MUXA_SEL_i : std_logic;
  signal MUXB_SEL_i : std_logic;
  signal ALU_OUTREG_EN_i : std_logic;
  signal BEQZ_OR_BNEZ_i : std_logic;
  signal SH2_EN_i : std_logic;

  signal DRAM_WE_i : std_logic;
  signal LMD_EN_i : std_logic;

  signal WB_MUX_SEL_i : std_logic;
  signal RF_WE_i : std_logic;
  signal JAL_EN_i : std_logic;

  signal PC_EN_i : std_logic;


  -- Data Ram Bus signals
  signal DRAM_addr : std_logic_vector(N-1 downto 0);
  signal DRAM_data : std_logic_vector(N-1 downto 0);
  signal LMD_s : std_logic_vector(N-1 downto 0);


  begin  -- DLX

    -- This is the input to program counter: currently zero 
    -- so no uptade of PC happens
    -- TO BE REMOVED AS SOON AS THE DATAPATH IS INSERTED!!!!!
    -- a proper connection must be made here if more than one
    -- instruction must be executed
    --------PC_BUS <= (others => '0'); 

	DATAPATH_I : DATAPATH
		generic map (N => N)
		port map(
			CLK => CLK,
			RST => RST,
		
		);

    -- Control Unit Instantiation
    CU_I: dlx_cu
      port map (
          Clk             => Clk,
          Rst             => Rst,
          IR_IN           => IR,
          IR_LATCH_EN     => IR_LATCH_EN_i,
          NPC_LATCH_EN    => NPC_LATCH_EN_i,
          RegA_LATCH_EN   => RegA_LATCH_EN_i,
          RegB_LATCH_EN   => RegB_LATCH_EN_i,
          RegIMM_LATCH_EN => RegIMM_LATCH_EN_i,
          MUXA_SEL        => MUXA_SEL_i,
          MUXB_SEL        => MUXB_SEL_i,
          ALU_OUTREG_EN   => ALU_OUTREG_EN_i,
          EQ_COND         => EQ_COND_i,
          ALU_OPCODE      => ALU_OPCODE_i,
          DRAM_WE         => DRAM_WE_i,
          LMD_LATCH_EN    => LMD_LATCH_EN_i,
          JUMP_EN         => JUMP_EN_i,
          PC_LATCH_EN     => PC_LATCH_EN_i,
          WB_MUX_SEL      => WB_MUX_SEL_i,
          RF_WE           => RF_WE_i);

    -- Instruction Ram Instantiation
    IRAM_I: IRAM
      port map (
          Rst  => Rst,
          Addr => PC,
          Dout => IRam_DOut);

    
    
end dlx_rtl;
