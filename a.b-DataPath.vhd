library ieee;
use ieee.std_logic_1164.all;
use work.alu_type.all;
use work.constants.all; 

entity DATAPATH is
	generic(N : integer := WORD_SIZE);
	port(
		CLK : in std_logic;
		RST : in std_logic;
		--CW : in std_logic_vector(17 downto 0);
		ALU_FUNC : in aluOP;
		from_IRAM : in std_logic_vector(N-1 downto 0); --output of iram (IRAM_DOut)
		from_DRAM : in std_logic_vector(N-1 downto 0); --output of dram

		--CONTROL SIGNALS
        -- FETCH STAGE (useless)
		IR_EN        : in std_logic;  -- Instruction Register Enable
		NPC_EN       : in std_logic;  -- NextProgramCounter Register Latch Enable
		-- ID Control Signals
		RegA_EN      : in std_logic;  -- Register A Latch Enable
		RegB_EN      : in std_logic;  -- Register B Latch Enable
		RegIMM_EN    : in std_logic;  -- Immediate Register Latch Enable
		RT_REG_EN    : in std_logic;
		IS_R_TYPE    : in std_logic;  -- To understand which bytes encode the Target Register
		J_EN         : in std_logic;
		-- EX Control Signals
		MUXA_SEL     : in std_logic;  -- A/NPC Sel
		MUXB_SEL     : in std_logic;  -- B/IMM Sel
		ALU_OUTREG_EN: in std_logic;  -- ALU Output Register Enable
		BRANCH_EN    : in std_logic;  -- Branch Enable
		--ZERO_EN		 : in std_logic;
		BEQZ_OR_BNEZ : in std_logic;  -- to configure the zero(?) block. Works different if it's a BEQZ or BNEZ.
		SH2_EN       : in std_logic;  -- IMM is shifted by 2 if it's a branch to compute the BTA.
		-- ALU Operation Code
		--ALU_OPCODE   : in aluOp;      -- ALU Operation Code????? C'è già
		-- MEM Control Signals
		--DRAM_WE      : in std_logic;  -- Data RAM Write Enable --NON SERVE QUA
		LMD_EN       : in std_logic;  -- LMD Register Latch Enable
		-- WB Control Signals
		WB_MUX_SEL   : in std_logic;  -- Write Back MUX Sel
		RF_WE        : in std_logic;  -- Register File Write Enable
		JAL_EN       : in std_logic;  -- needed to write NPC on R31
		-- PC enable 
		PC_EN        : in std_logic;

		branch_taken : out  std_logic;
		addr_to_DRAM : out std_logic_vector(N-1 downto 0); --input address for dram
		data_to_DRAM : out std_logic_vector(N-1 downto 0); --input data for dram
		to_IRAM : out std_logic_vector(N-1 downto 0); --input for iram (PC)
		IR: out std_logic_vector(N-1 downto 0)
		--PC_to_IRAM : out std_logic_vector(N-1 downto 0)
	);
end DATAPATH;

architecture STRUCTURAL of DATAPATH is

--signals
signal pc_nxt_s, pc4_s, npc_reg1_s, ireg_s: std_logic_vector(N-1 downto 0); --fetch
signal b_addr_s, imm_reg_s, npc_reg2_s, a_reg_s, b_reg_s, rt_reg1_s : std_logic_vector(N-1 downto 0); --decode
signal b_en_s : std_logic;
signal alu_out_s, rt_reg2_s, npc_reg3_s : std_logic_vector(N-1 downto 0); --execute
signal lmd_out_s, alu_out2_s, rt_reg3_s, npc_reg4_s : std_logic_vector(N-1 downto 0); --memory
signal wb_data_s, wb_addr_s : std_logic_vector(N-1 downto 0); --write back


--components
component FU
	generic (N: integer := WORD_SIZE);
	Port(CLK : in std_logic;
		RST : in std_logic;
		PC_EN, NPC_EN, IR_EN : in std_logic;    --control word signals
		IN_ID : in std_logic_vector(N-1 downto 0);
		from_IRAM : in std_logic_vector(N-1 downto 0); --output of iram
		to_IRAM : out std_logic_vector(N-1 downto 0); --input for iram 
		IREG_out : out std_logic_vector(N-1 downto 0);
		NPC_out : out std_logic_vector(N-1 downto 0);
		PC_4out : out std_logic_vector(N-1 downto 0) );
end component;

component DU
	generic (N: integer := WORD_SIZE); 
	Port (	--PC: in std_logic_vector(N-1 downto 0);
			J_EN, WR_EN, A_EN, B_EN, IMM_EN, RT_EN, is_R_type:	In	std_logic;    --control signals from CU
			BR_EN: in std_logic;  									--Signals wether there is a branch taken in EX stage
			clk, rst :	In	std_logic;     
			NPC_IN, IR, DATAIN, ADDR_IN, BTA_OR_NPC:	in 	std_logic_vector(N-1 downto 0);  --Incoming data from registers. RT_IN comes from the WB stage, BTA_OR_NPC comes from the EX stage. 
			A,B,IMM,RT_OUT,NPC_OUT,PC_NXT : OUT 	std_logic_vector(N-1 downto 0)); 

end component;

component EXU
	generic (N: integer := WORD_SIZE);
	Port(CLK : in std_logic;
		RST : in std_logic;
		MUXA_SEL,MUXB_SEL,ZERO_EN,ZERO_SEL,ALUOUT_EN,SHIFT2_EN: in std_logic; 
		ALU_FUNC : in aluOp;
		NPC_REG : in std_logic_vector(N-1 downto 0);
		A_REG : in std_logic_vector(N-1 downto 0);
		B_REG : in std_logic_vector(N-1 downto 0);
		RT_REG : in std_logic_vector(N-1 downto 0);
		IMM_REG : in std_logic_vector(N-1 downto 0);
		PC_4 :in std_logic_vector(N-1 downto 0);
		ZERO : out std_logic;
		BRANC_ADDR : out std_logic_vector(N-1 downto 0);
		ALU_OUT : out std_logic_vector(N-1 downto 0);
		RT_REG_OUT : out std_logic_vector(N-1 downto 0);
		NPC_OUT : out std_logic_vector(N-1 downto 0)
);
end component;

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

component WBU
	generic ( N: integer:= WORD_SIZE);           
	Port (ALU_OUT:	In	std_logic_vector(N-1 downto 0);	
		  LOAD:    in std_logic_vector (N-1 downto 0); 
          NPC_REG_in:  in std_logic_vector(N-1 downto 0);
          RT_REG_in: in std_logic_vector(N-1 downto 0);
          IS_JAL, ALUOUT_OR_LOAD: in std_logic; 
          RF_ADDR : out std_logic_vector(N-1 downto 0);
          RF_DATA : out std_logic_vector(N-1 downto 0)
          );
end component;


begin	
--port map
	F_STAGE : FU
		generic map(N => N)
		port map(
			CLK => CLK,
			RST => RST,
			IR_EN => IR_EN,
			PC_EN => PC_EN,
			NPC_EN => NPC_EN,
			IN_ID => pc_nxt_s,
			from_IRAM => from_IRAM,
			to_IRAM => to_IRAM,
			IREG_out => ireg_s,
			NPC_out => npc_reg1_s,
			PC_4out => pc4_s
		);

	IR <= ireg_s;
	

	D_STAGE : DU
		generic map(N => N)
		port map(
			J_EN => J_EN,
			WR_EN => RF_WE, --RF_EN
			A_EN => RegA_EN,
			B_EN => RegB_EN,
			IMM_EN => RegIMM_EN,
			RT_EN => RT_REG_EN,
			is_R_type => IS_R_TYPE,
			BR_EN => b_en_s, --from exectute to decode
			clk => CLK,
			rst => RST,
			NPC_IN => npc_reg1_s,
			IR => ireg_s,
			DATAIN => wb_data_s,
			ADDR_IN => wb_addr_s,
			BTA_OR_NPC => b_addr_s,
			A => a_reg_s,
			B => b_reg_s,
			IMM => imm_reg_s,
			RT_OUT => rt_reg1_s,
			NPC_OUT => npc_reg2_s,
			PC_NXT => pc_nxt_s
		);

	EX_STAGE : EXU
		generic map(N => N)
		port map(
			CLK => CLK,
			RST => RST,
			MUXA_SEL => MUXA_SEL,
			MUXB_SEL => MUXB_SEL,
			ZERO_EN => BRANCH_EN,
			ZERO_SEL => BEQZ_OR_BNEZ,
			ALUOUT_EN => ALU_OUTREG_EN,
			SHIFT2_EN => SH2_EN,
			ALU_FUNC => ALU_FUNC,
			NPC_REG => npc_reg2_s,
			A_REG => a_reg_s,
			B_REG => b_reg_s,
			RT_REG => rt_reg1_s,
			IMM_REG => imm_reg_s,
			PC_4 => pc4_s,
			ZERO => b_en_s,
			BRANC_ADDR => b_addr_s,
			ALU_OUT => alu_out_s,
			RT_REG_OUT => rt_reg2_s,
			NPC_OUT => npc_reg3_s
		);
        --this signal goes to output to the CU
		branch_taken <= b_en_s; 

	MEM_STAGE : MU
		generic map (N => N)
		port map (
			CLK => CLK,
			RST => RST,
			LMD_EN => LMD_EN, 
			ALU_RESULT => alu_out_s,
			RT_REG_in => rt_reg2_s,
			NPC_REG_in => npc_reg3_s,
			LMD_LATCH_in => from_DRAM,
			LMD_LATCH_out => lmd_out_s,
			ALU_REG_out => alu_out2_s,
			RT_REG_out => rt_reg3_s,
			NPC_REG_out => npc_reg4_s
		);
		
		addr_to_DRAM <= alu_out_s;
		data_to_DRAM <= rt_reg2_s;

	WB_STAGE : WBU
		generic map (N => N)
		port map (
			ALU_OUT => alu_out2_s,
			LOAD => lmd_out_s,
			NPC_REG_in => npc_reg4_s,
			RT_REG_in => rt_reg3_s,
			IS_JAL => JAL_EN, 
			ALUOUT_OR_LOAD => WB_MUX_SEL, 
			RF_ADDR => wb_addr_s,
			RF_DATA => wb_data_s
		);

end STRUCTURAL;
