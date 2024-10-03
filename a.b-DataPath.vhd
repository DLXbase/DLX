library ieee;
use ieee.std_logic_1164.all;

entity DATAPATH is
	generic(N : integer := 32);
	port(
		CLK : in std_logic;
		RST : in std_logic;
		CW : in std_logic_vector(17 downto 0);
		IR: out std_logic_vector(N-1 downto 0);
	);
end DATAPATH;

architecture STRUCTURAL of DATAPATH is

--signals
signal pc_nxt_s, pc4_s, npc_reg1_s, ireg_s: std_logic_vector(N-1 downto 0); --fetch
signal b_en_s, b_addr_s, imm_reg_s, npc_reg2_s, a_reg_s, b_reg_s, rt_reg1_s : std_logic_vector(N-1 downto 0); --decode
signal alu_out1_s, rt_reg2_s : std_logic_vector(N-1 downto 0); --execute
signal lmd_out_s, alu_out2_s, rt_reg3_s : std_logic_vector(N-1 downto 0); --memory
signal wb_s : std_logic_vector(N-1 downto 0); --write back

--components
component FU
	generic (N: integer := 32);
	Port(CLK : in std_logic;
		RST : in std_logic;
		CW : in std_logic_vector(2 downto 0);
		IN_ID : in std_logic_vector(N-1 downto 0);
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
			A,B,IMM,RT_OUT,NPC_OUT,PC_NXT : OUT 	std_logic_vector(N-1 downto 0));      
	end DU;

end component;

component EXU
	generic (N: integer := 32);
	Port(CLK : in std_logic;
		RST : in std_logic;
		CW : in std_logic_vector(3 downto 0);
		ALU_FUNC : in TYPE_OP;
		NPC : in std_logic_vector(N-1 downto 0);
		A_REG : in std_logic_vector(N-1 downto 0);
		B_REG : in std_logic_vector(N-1 downto 0);
		RT_REG : in std_logic_vector(N-1 downto 0);
		IMM_REG : in std_logic_vector(N-1 downto 0);
		PC_4 :in std_logic_vector(N-1 downto 0);
		ZERO : out std_logic_vector(N-1 downto 0);
		BRANC_ADDR : out std_logic_vector(N-1 downto 0);
		ALU_OUT : out std_logic_vector(N-1 downto 0);
		RT_REG_OUT : out std_logic_vector(N-1 downto 0)
	);
end component;

component MU
  generic (N: integer := 32);
  port(
  		CLK: in std_logic;
		RST : in std_logic;
  		CW : in std_logic_vector(4 downto 0);
  		ALU_RESULT : in std_logic_vector(N-1 downto 0);
  		RT_REG_in : in std_logic_vector(N-1 downto 0);
  		LMD_LATCH_out : out std_logic_vector(N-1 downto 0);
  		ALU_REG_out : out std_logic_vector(N-1 downto 0);
  		RT_REG_out : out std_logic_vector(N-1 downto 0)
	);
end component;

component mux21 --write back
	generic ( NBIT: integer:= 32);           
	Port (A:	In	std_logic_vector(NBIT-1 downto 0);	
		  B:    in std_logic_vector (NBIT-1 downto 0); 
          sel:  in std_logic; 
	      muxout:	Out	std_logic_vector ((NBIT)-1 downto 0));
begin

--port map
	F_STAGE : FU
		generic map(N => N)
		port map(
			CLK => CLK,
			RST => RST,
			CW => '1' & CW(17) & CW(16),
			IN_ID => pc_nxt_s,
			IREG_out => ireg_s,
			NPC_out => npc_reg1_s,
			PC_4out => pc4_s
		);

	D_STAGE : DU
		generic map(N => N)
		port map(
			J_EN => CW(9)
			WR_EN => CW(0), --RF_EN
			A_EN => CW(14),
			B_EN => CW(13),
			IMM_EN => CW(12),
			RT_EN => CW(11),
			is_R_type => CW(10),
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
			CLK => ,
			RST => ,
			CW => ,
			ALU_FUNC => ,
			NPC => ,
			A_REG => ,
			B_REG => ,
			RT_REG => ,
			IMM_REG => ,
			PC_4 => ,
			ZERO => ,
			BRANCH_ADDR => ,
			ALU_OUT => ,
			RT_REG_OUT => 
		);

end STRUCTURAL;
