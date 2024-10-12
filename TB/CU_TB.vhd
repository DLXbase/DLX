library IEEE;
use IEEE.std_logic_1164.all;
use work.alu_type.all;
use work.constants.all; 
use work.myTypes.all;

entity TBCU is
end TBCU;

architecture TEST of TBCU is

    constant IR_SIZE : integer := 32; 
    
	signal clk,rst: std_logic;
	signal IR_IN  : std_logic_vector(IR_SIZE - 1 downto 0);
	signal branch_taken       :   std_logic; 
	--IF
	signal IR_EN        : std_logic;  -- Instruction Register Enable
	signal NPC_EN       : std_logic; 
	--ID
	signal RegA_EN      :  std_logic;  -- Register A Latch Enable
	signal RegB_EN      :  std_logic;  -- Register B Latch Enable
	signal RegIMM_EN    :  std_logic;  -- Immediate Register Latch Enable
	signal RT_REG_EN    :  std_logic;
	signal IS_R_TYPE     :  std_logic;  --To understand which bytes encode the Target Register
	signal J_EN         :  std_logic;
	--EX
	signal MUXA_SEL           : std_logic;  
	signal MUXB_SEL           :  std_logic;  
	signal ALU_OUTREG_EN      : std_logic;  
	signal BRANCH_EN          :  std_logic;
	signal BEQZ_OR_BNEZ       :  std_logic;  
	signal SH2_EN             : std_logic; 

	signal ALU_OPCODE         :  aluOp; -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);    
    -- MEM 
	signal DRAM_WE            :  std_logic;  -- Data RAM Write Enable
	signal LMD_EN       :  std_logic;  -- LMD Register Latch Enable
	-- WB
	signal WB_MUX_SEL         :  std_logic;  -- Write Back MUX Sel
	signal RF_WE              :  std_logic;  -- Register File Write Enable
	signal JAL_EN             :  std_logic; -- needed to write NPC on R31
	-- PC enable 
	signal PC_EN :  std_logic; 


	component dlx_cu 
		generic (
			MICROCODE_MEM_SIZE :     integer := 33;  -- Microcode Memory Size (NUMBER OF INSTRUCTIONS)
			FUNC_SIZE          :     integer := FUNC_FIELD_SIZE;  -- Func Field Size for R-Type Ops
			OP_CODE_SIZE       :     integer := OPCODE_SIZE;  -- Op Code Size
			-- ALU_OPC_SIZE       :     integer := 6;  -- ALU Op Code Word Size
			IR_SIZE            :     integer := WORD_SIZE;  -- Instruction Register Size    
			CW_SIZE            :     integer := CONTROL_WORD_SIZE);  -- Control Word Size
		  port (
			Clk                : in  std_logic;  -- Clock
			Rst                : in  std_logic;  -- Reset:Active-Low
			-- Instruction Register
			IR_IN              : in  std_logic_vector(IR_SIZE - 1 downto 0);   --IR must be taken from the IRAM and not the IR_REG for timing reasons. 
			branch_taken       : in  std_logic; 
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
			BRANCH_EN          : out std_logic;  -- Branch Enable
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

begin

	cu: dlx_cu
	generic map (
		MICROCODE_MEM_SIZE => 33,  -- Microcode Memory Size (NUMBER OF INSTRUCTIONS)
		FUNC_SIZE => 11,  -- Func Field Size for R-Type Ops
		OP_CODE_SIZE => 6,  -- Op Code Size
		IR_SIZE => 32,  -- Instruction Register Size    
		CW_SIZE => CONTROL_WORD_SIZE)
	port map (
    clk            => CLK,
    rst            => RST,
    IR_IN          => IR_IN,
	branch_taken   => branch_taken,
    IR_EN          => IR_EN,
    NPC_EN         => NPC_EN,
    RegA_EN        => RegA_EN,
    RegB_EN        => RegB_EN,
    RegIMM_EN      => RegIMM_EN,
    RT_REG_EN      => RT_REG_EN,
    IS_R_TYPE      => IS_R_TYPE,
    J_EN           => J_EN,
    MUXA_SEL       => MUXA_SEL,
    MUXB_SEL       => MUXB_SEL,
    ALU_OUTREG_EN  => ALU_OUTREG_EN,
	BRANCH_EN	  => BRANCH_EN,
    BEQZ_OR_BNEZ   => BEQZ_OR_BNEZ,
    SH2_EN         => SH2_EN,
    ALU_OPCODE     => ALU_OPCODE,
    DRAM_WE        => DRAM_WE,
    LMD_EN         => LMD_EN,
    WB_MUX_SEL     => WB_MUX_SEL,
    RF_WE          => RF_WE,
    JAL_EN         => JAL_EN,
    PC_EN          => PC_EN
);
	--clk process
	process
	begin
		CLK <= '1';			-- clock cycle 2 ns
		wait for 1 ns;
		CLK <= '0';
		wait for 1 ns;
	end process;
	
		rst <= '1' after 2 ns, '0' after 10 ns;
		branch_taken <= '0'; 
		
    --instruction
	process
	begin
	    --opcode: "1000 00(00)" NOP
		IR_IN <= ITYPE_NOP&"00000"&"00000"&"0000000000000000";			
		wait for 15 ns;
		--ADD
		IR_IN <= RTYPE & "00000"&"00000"&"00000"&RTYPE_ADD;			
		wait for 2 ns;
		--SUB
		IR_IN <= RTYPE&"00000"&"00000"&"00000"&RTYPE_SUB;			
		wait for 2 ns; 
		--AND
		IR_IN <= RTYPE & "00000"&"00000"&"00000"&RTYPE_AND;			
		wait for 2 ns; 	
		--JUMP
		IR_IN <= ITYPE_J & "00000"&"00000"&"00000"&"00000000000";			
		wait for 2 ns; 
		--AND
		IR_IN <= RTYPE & "00000"&"00000"&"00000"&RTYPE_AND;			
		wait for 2 ns; 
		--SUB
		IR_IN <= RTYPE & "00000"&"00000"&"00000"&RTYPE_SUB;			
		wait for 2 ns; 
		--BRANCH
		IR_IN <= ITYPE_BEQZ & "00000"&"00000"&"00000"&RTYPE_ADD;			
		wait for 2 ns; 
		--SUB
		IR_IN <= RTYPE & "00000"&"00000"&"00000"&RTYPE_SUB;			
		wait for 2 ns;
		--AND
		IR_IN <= RTYPE & "00000"&"00000"&"00000"&RTYPE_AND;	
		--(simulate branch taken)
		branch_taken <= '1';		
		wait for 2 ns;
		--SUB
		IR_IN <= RTYPE & "00000"&"00000"&"00000"&RTYPE_SUB;		
		branch_taken <= '1';	
		wait for 2 ns;
		wait; 
	end process;
end TEST;