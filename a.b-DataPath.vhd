library ieee;
use ieee.std_logic_1164.all;

entity DATAPATH is
	generic(N : integer := 32);
	port(
		CLK : in std_logic;
		RST : in std_logic;
		CW : in std_logic_vector(17 downto 0);
		ALU_FUNC : in TYPE_OP;
		from_IRAM : in std_logic_vector(N-1 downto 0); --output of iram
		to_IRAM : out std_logic_vector(N-1 downto 0); --input for iram 
		IR: out std_logic_vector(N-1 downto 0);
		PC_to_IRAM : out std_logic_vector(N-1 downto 0)
	);
end DATAPATH;

architecture STRUCTURAL of DATAPATH is

--signals
signal pc_nxt_s, pc4_s, npc_reg1_s, ireg_s: std_logic_vector(N-1 downto 0); --fetch
signal b_en_s, b_addr_s, imm_reg_s, npc_reg2_s, a_reg_s, b_reg_s, rt_reg1_s : std_logic_vector(N-1 downto 0); --decode
signal alu_out_s, rt_reg2_s, npc_reg3_s : std_logic_vector(N-1 downto 0); --execute
signal lmd_out_s, alu_out2_s, rt_reg3_s, npc_reg4_s : std_logic_vector(N-1 downto 0); --memory
signal wb_s : std_logic_vector(N-1 downto 0); --write back

--components
component FU
	generic (N: integer := 32);
	Port(CLK : in std_logic;
		RST : in std_logic;
		CW : in std_logic_vector(2 downto 0);
		IN_ID : in std_logic_vector(N-1 downto 0);
		from_IRAM : in std_logic_vector(N-1 downto 0); --output of iram
		to_IRAM : out std_logic_vector(N-1 downto 0); --input for iram 
		IREG_out : out std_logic_vector(N-1 downto 0);
		NPC_out : out std_logic_vector(N-1 downto 0);
		PC_4out : out std_logic_vector(N-1 downto 0) 
);
end component;

component DU
	generic (N: integer := 32); 
	Port (	--PC: in std_logic_vector(N-1 downto 0);
			J_EN, WR_EN, A_EN, B_EN, IMM_EN, RT_EN, is_R_type:	In	std_logic;
			BR_EN: in std_logic;  									
			clk, rst :	In	std_logic;     
			NPC_IN, IR, DATAIN, RT_IN, BTA_OR_NPC:	in 	std_logic_vector(N-1 downto 0);   
			A,B,IMM,RT_OUT,NPC_OUT,PC_NXT : OUT 	std_logic_vector(N-1 downto 0)
			);

end component;

component EXU
	generic (N: integer := 32);
	Port(CLK : in std_logic;
		RST : in std_logic;
		CW : in std_logic_vector(3 downto 0);
		ALU_FUNC : in TYPE_OP;
		NPC_REG : in std_logic_vector(N-1 downto 0);
		A_REG : in std_logic_vector(N-1 downto 0);
		B_REG : in std_logic_vector(N-1 downto 0);
		RT_REG : in std_logic_vector(N-1 downto 0);
		IMM_REG : in std_logic_vector(N-1 downto 0);
		PC_4 :in std_logic_vector(N-1 downto 0);
		ZERO : out std_logic_vector(N-1 downto 0);
		BRANC_ADDR : out std_logic_vector(N-1 downto 0);
		ALU_OUT : out std_logic_vector(N-1 downto 0);
		RT_REG_OUT : out std_logic_vector(N-1 downto 0);
		NPC_OUT : out std_logic_vector(N-1 downto 0)
);
end component;

component MU
	generic (N: integer := 32);
	port(
		CLK: in std_logic;
		RST : in std_logic;
		CW : in std_logic_vector(2 downto 0);
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
generic ( N: integer:= 32);           
Port (ALU_OUT:	In	std_logic_vector(N-1 downto 0);	
	  LOAD:    in std_logic_vector (N-1 downto 0); 
	  NPC_REG_in:  in std_logic_vector(N-1 downto 0);
	  RT_REG_in: in std_logic_vector(N-1 downto 0);
	  CW : in std_logic_vector(1 downto 0); --'JAL' & 'WB_mux'
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
			CW => '1' & CW(17) & CW(16), --PC & IR & NPC
			IN_ID => pc_nxt_s,
			from_IRAM => from_IRAM,
			to_IRAM => to_IRAM,
			IREG_out => ireg_s,
			NPC_out => npc_reg1_s,
			PC_4out => pc4_s
		);

	D_STAGE : DU
		generic map(N => N)
		port map(
			J_EN => CW(10),
			WR_EN => CW(1), --RF_EN
			A_EN => CW(15),
			B_EN => CW(14),
			IMM_EN => CW(13),
			RT_EN => CW(12),
			is_R_type => CW(11),
			BR_EN => b_en_s, --from exectute to decode
			clk => CLK,
			rst => RST,
			NPC_IN => npc_reg1_s,
			IR => ireg_s,
			DATAIN => wb_s,
			RT_IN => rt_reg3_s,
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
			CW => CW(12) & CW(7) & CW(16) & CW(6) & CW(8) & CW(9) & CW(5), --RT & ALU_OUT & NPC & BEQZ/BENZ & B & A & SH2EN
			ALU_FUNC => ALU_FUNC,
			NPC_REG => npc_reg2_s,
			A_REG => a_reg_s,
			B_REG => b_reg_s,
			RT_REG => rt_reg1_s,
			IMM_REG => imm_reg_s,
			PC_4 => pc4_s,
			ZERO => b_es_s,
			BRANCH_ADDR => b_addr_s,
			ALU_OUT => alu_out_s,
			RT_REG_OUT => rt_reg2_s,
			NPC_OUT => npc_reg3_s
		);

	MEM_STAGE : MU
		generic map (N => N)
		port map (
			CLK => CLK,
			RST => RST,
			CW => CW(3) & CW(7) & CW(12), --LMD & ALU_OUT & RT
			
		);

end STRUCTURAL;
