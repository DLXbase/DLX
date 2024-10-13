library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all; 
--use ieee.std_logic_arith.all;
use work.alu_type.all;
--use ieee.numeric_std.all;
use work.all;
--constants
use work.constants.all; 
use work.myTypes.all;

entity dlx_cu is
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

end dlx_cu;

architecture dlx_cu_hw of dlx_cu is

                                                              
  signal IR_opcode : std_logic_vector(5 downto 0);  -- OpCode part of IR
  signal IR_func : std_logic_vector(10  downto 0);   -- Func part of IR when Rtype
  signal cw   : std_logic_vector(CW_SIZE -1 downto 0); -- full control word read from cw_mem


  -- control word is shifted to the correct stage
  signal cw_FU_DU : std_logic_vector(CW_SIZE - 1  downto 0); -- IF+ID
  signal cw_EXU : std_logic_vector(CW_SIZE -1- CW_FETCH_SIZE - CW_DU_SIZE  downto 0); -- EX
  signal cw_M : std_logic_vector(CW_SIZE - 1 - CW_FETCH_SIZE - CW_DU_SIZE - CW_EX_SIZE downto 0); -- MEM
  signal cw_WB : std_logic_vector(CW_SIZE - 1 - CW_FETCH_SIZE - CW_DU_SIZE - CW_EX_SIZE - CW_MEM_SIZE downto 0); -- WB

  signal aluOpcode_i: aluOp := aluNOP; -- ALUOP defined in package
  signal aluOpcode1: aluOp := aluNOP;
  signal aluOpcode2: aluOp := aluNOP;
  signal aluOpcode3: aluOp := aluNOP;

  --signal j_flush, beq_flush: std_logic; 
 
begin  -- dlx_cu_rtl
  --OPCODE AND FUNC FROM INCOMING IR
  IR_opcode <= IR_IN(31 downto 26);
  IR_func(FUNC_SIZE-1 downto 0)  <= IR_IN(FUNC_SIZE - 1 downto 0);

  -- stage one control signals
  IR_EN  <= cw_FU_DU(CW_SIZE - 1);
  NPC_EN <= cw_FU_DU(CW_SIZE - 2);
  
  -- stage two control signals
  RegA_EN   <= cw_FU_DU(CW_SIZE - CW_FETCH_SIZE - 1);
  RegB_EN   <= cw_FU_DU(CW_SIZE - CW_FETCH_SIZE - 2);
  RegIMM_EN <= cw_FU_DU(CW_SIZE - CW_FETCH_SIZE - 3);
  RT_REG_EN <= cw_FU_DU(CW_SIZE - CW_FETCH_SIZE - 4);
  IS_R_TYPE <= cw_FU_DU(CW_SIZE - CW_FETCH_SIZE - 5);
  J_EN      <= cw_FU_DU(CW_SIZE - CW_FETCH_SIZE - 6);
  
  -- stage three control signals
  MUXA_SEL      <= cw_EXU(CW_SIZE - CW_FETCH_SIZE - CW_DU_SIZE - 1);
  MUXB_SEL      <= cw_EXU(CW_SIZE - CW_FETCH_SIZE - CW_DU_SIZE - 2);
  ALU_OUTREG_EN <= cw_EXU(CW_SIZE - CW_FETCH_SIZE - CW_DU_SIZE - 3);
  BRANCH_EN     <= cw_EXU(CW_SIZE - CW_FETCH_SIZE - CW_DU_SIZE - 4);
  BEQZ_OR_BNEZ  <= cw_EXU(CW_SIZE - CW_FETCH_SIZE - CW_DU_SIZE - 5);
  SH2_EN        <= cw_EXU(CW_SIZE - CW_FETCH_SIZE - CW_DU_SIZE - 6);
  
  -- stage four control signals
  DRAM_WE      <= cw_M(CW_SIZE - CW_FETCH_SIZE - CW_DU_SIZE - CW_EX_SIZE - 1);
  LMD_EN       <= cw_M(CW_SIZE - CW_FETCH_SIZE - CW_DU_SIZE - CW_EX_SIZE - 2);

  
  -- stage five control signals
  WB_MUX_SEL <= cw_WB(CW_SIZE - CW_FETCH_SIZE - CW_DU_SIZE - CW_EX_SIZE - CW_MEM_SIZE - 1);
  RF_WE      <= cw_WB(CW_SIZE - CW_FETCH_SIZE - CW_DU_SIZE - CW_EX_SIZE - CW_MEM_SIZE - 2);
  JAL_EN     <= cw_WB(CW_SIZE - CW_FETCH_SIZE - CW_DU_SIZE - CW_EX_SIZE - CW_MEM_SIZE - 3); 
                    -- 19 - 2 - 6 - 6 - 2  = 19 - 16 = 3 


  --PC_enabling signal 
  PC_EN <= '1'; 


  -- purpose: pipeline control words
  CW_PIPE: process (Clk, Rst, branch_taken)
  begin  -- process Clk
    if Rst = '1' then                   -- asynchronous reset (active low)
      cw_FU_DU <= (others => '0');
      cw_EXU <= (others => '0');
      cw_M <= (others => '0');
      cw_WB <= (others => '0');
      aluOpcode1 <= aluNOP;
      aluOpcode2 <= aluNOP;
      aluOpcode3 <= aluNOP;
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      if (branch_taken = '1') then cw_FU_DU <= "11"&"000000"&"000000"&"00"&"000"; --  | NOP; 
      else   cw_FU_DU <= cw;
      end if; 
      cw_EXU <= cw_FU_DU(CW_SIZE - 1 - 2 - 6 downto 0);
      cw_M <= cw_EXU(CW_SIZE - 1 - 2 -6 - 6 downto 0);
      cw_WB <= cw_M(CW_SIZE - 1 - 2 -6 -6 -2 downto 0);  
      if (branch_taken = '1') then aluOpcode1 <= aluNOP; --  | NOP; 
      else   aluOpcode1 <= aluOpcode_i;
      end if; 
      aluOpcode2 <= aluOpcode1;
      aluOpcode3 <= aluOpcode2;
    end if;
  end process CW_PIPE;


  -- purpose: Generation of ALU OpCode
  -- type   : combinational
  -- inputs : IR_i
  -- outputs: aluOpcode
   ALU_OP_CODE_P : process (IR_opcode, IR_func, cw_FU_DU, branch_taken)
   begin  -- process ALU_OP_CODE_P
	case (IR_OPCODE) is
	        -- case of R type requires analysis of FUNC
		when RTYPE =>
			case (IR_func) is
				when RTYPE_ADD => aluOpcode_i <= ADD; 
				when RTYPE_SUB => aluOpcode_i <= SUB; 
				when RTYPE_AND => aluOpcode_i <= BITAND; 
				when RTYPE_OR => aluOpcode_i <= BITOR; 
				when RTYPE_SGE => aluOpcode_i <= SGE;  
				when RTYPE_SLE => aluOpcode_i <= SLE;  
				when RTYPE_SLL => aluOpcode_i <= FUNCLSL; 
				when RTYPE_SNE => aluOpcode_i <= SNE;
				when RTYPE_SRL => aluOpcode_i <= FUNCRSL;
				-- to be continued and filled with all the other instructions  
				when others => aluOpcode_i <= aluNOP;
			end case;
		when ITYPE_ADDI => aluOpcode_i <= ADD;  --ADDI
		when ITYPE_SUBI => aluOpcode_i <= SUB; --SUBI
		when ITYPE_ANDI => aluOpcode_i <= BITAND; --ANDI
		when ITYPE_ORI => aluOpcode_i <= BITOR; --ORI
		when ITYPE_SGEI => aluOpcode_i <= SGE; --SGEI
		when ITYPE_SLEI => aluOpcode_i <= SLE; --SLEI 
		when ITYPE_SLLI => aluOpcode_i <= FUNCLSL; --SLLI
		--when ITYPE_SNEI => aluOpcode_i <= SNE; --SNEI
		when ITYPE_SRLI => aluOpcode_i <= FUNCRSL; --SRLI
		when ITYPE_BEQZ => aluOpcode_i <= ADD; --BEQZ adds RS to NPC
		when ITYPE_BNEZ => aluOpcode_i <= ADD; --BNEZ adds RS to NPC
		when ITYPE_LW => aluOpcode_i <= ADD; --LW adds RS to NPC
		when ITYPE_SW => aluOpcode_i <= ADD; --SW adds RS to NPC
		when ITYPE_J => aluOpcode_i <= aluNOP; --J  alu does nothing 
		when ITYPE_JAL => aluOpcode_i <= aluNOP; --JAL   alu does nothing
	
		when others => aluOpcode_i <= aluNOP;
	 end case;

   if (cw_FU_DU(cw_size - CW_FETCH_SIZE - 6) = '1') or (branch_taken = '1') then aluOpcode_i <= aluNop; --NOP
   end if;
	end process ALU_OP_CODE_P;


--ASSIGN OPCODE AS RESULT OF PROCESS
ALU_OPCODE <= aluOpcode2;

--purpose: generation of cw
process (IR_OPCODE, IR_func, cw_FU_DU, branch_taken) 
begin 
  case (IR_OPCODE)  is 
    when RTYPE => case (IR_func) is          --IR,NPC | A,B,IMM,RT,R/I,J_EN | MUXA,MUXB,ALU_OUT,BR_EN,BEQZ/BNEZ,SH2EN| DRAM,LMD | WBMUX,RFWE,JAL_EN 
                    when RTYPE_ADD => cw    <= "11"   &        "110110"     &           "111000"                &   "00"   &     "110";    -- 0 | R type: ADD 
                    when RTYPE_SUB => cw    <= "11"   &        "110110"     &           "111000"                &   "00"   &     "110";    -- 1 | R type: SUB  
                    when RTYPE_AND => cw    <= "11"   &        "110110"     &           "111000"                &   "00"   &     "110";    -- 2 | R type: AND 
                    when RTYPE_OR  => cw    <= "11"   &        "110110"     &           "111000"                &   "00"   &     "110";    -- 3 | R type: OR
                    when RTYPE_XOR => cw    <= "11"   &        "110110"     &           "111000"                &   "00"   &     "110";    -- 4 | R type: XOR
                    when RTYPE_SLL => cw    <= "11"   &        "110110"     &           "111000"                &   "00"   &     "110";    -- 5 | R type: SLL
                    when RTYPE_SRL => cw    <= "11"   &        "110110"     &           "111000"                &   "00"   &     "110";    -- 6 | R type: SRL
                    when RTYPE_SNE => cw    <= "11"   &        "110110"     &           "111000"                &   "00"   &     "110";    -- 7 | R type: SNE
                    when RTYPE_SLE => cw    <= "11"   &        "110110"     &           "111000"                &   "00"   &     "110";    -- 8 | R type: SLE
                    when RTYPE_SGE => cw    <= "11"   &        "110110"     &           "111000"                &   "00"   &     "110";    -- 9 | R type: SGE
                    when others => cw       <= "11"   &        "000000"     &           "000000"                &   "00"   &     "000";  --  | NOP
                  end case; 

    when ITYPE_J    => cw                   <=  "11"   &        "101101"     &           "000000"                &   "00"   &     "000";  -- 21 |  I type: J
    when ITYPE_JAL  => cw                   <=  "11"   &        "101101"     &           "000000"                &   "00"   &     "011";  -- 22 |  I type: JAL
    when ITYPE_BEQZ => cw                   <=  "11"   &        "001000"     &           "001111"                &   "00"   &     "100";  -- 17 | I type: BEQZ
    when ITYPE_BNEZ => cw                   <=  "11"   &        "001000"     &           "001101"                &   "00"   &     "100";  -- 18 | I type: BNEZ
    when ITYPE_ADDI => cw                   <=  "11"   &        "101100"     &           "101000"                &   "00"   &     "110";     -- 9 | I type: ADDI
    when ITYPE_SUBI => cw                   <=  "11"   &        "101100"     &           "101000"                &   "00"   &     "110";    -- 10 | I type: SUBI
    when ITYPE_ANDI => cw                   <=  "11"   &        "101100"     &           "101000"                &   "00"   &     "110";    -- 11 | I type: ANDI 
    when ITYPE_ORI  => cw                   <=  "11"   &        "101100"     &           "101000"                &   "00"   &     "110";    -- 12 | I type: ORI
    when ITYPE_XORI => cw                   <=  "11"   &        "101100"     &           "101000"                &   "00"   &     "110";    -- 12 | I type: XORI
    when ITYPE_SLLI => cw                   <=  "11"   &        "101100"     &           "101000"                &   "00"   &     "110"; -- 13 | I type: 
    when ITYPE_NOP  => cw                   <=  "11"   &        "000000"     &           "000000"                &   "00"   &     "000";    --  | NOP
    when ITYPE_SRLI => cw                   <=  "11"   &        "101100"     &           "101000"                &   "00"   &     "110";    -- 16 | I type: SRLI
    when ITYPE_SLEI => cw                   <=  "11"   &        "101100"     &           "101000"                &   "00"   &     "110";    -- 14 | I type: SLEI
    when ITYPE_SGEI => cw                   <=  "11"   &        "101100"     &           "101000"                &   "00"   &     "110";    -- 13 | I type: SGEI
    when ITYPE_LW   => cw                   <=  "11"   &        "101100"     &           "101000"                &   "11"   &     "010";    -- 19 | I type: LW
    when ITYPE_SW   => cw                   <=  "11"   &        "101100"     &           "101000"                &   "11"   &     "000";    -- 20 | I type: SW
    when others     => cw                   <=  "11"   &        "000000"     &           "000000"                &   "00"   &     "000";    -- NOP
    end case;  
    
    -- pipeline flush
    if (cw_FU_DU(cw_size - CW_FETCH_SIZE - 6) = '1') or (branch_taken = '1') then cw <= "11" & "000000" & "000000" & "00" & "000"; --NOP
    end if; 

end process; 


-- --purpose: generation of FLUSH signals combinational
-- process (IR_OPCODE, branch_taken)
-- begin 
--   --if there is a jump, only 1 instruction needs to be flushed as JTA is computed at decode stage
--   if (IR_OPCODE = ITYPE_J) or (IR_OPCODE = ITYPE_JAL) then j_flush <= '1'; 
--   else j_flush <= '0'; 
--   end if;
--   --if a branch is taken (EX stage) I need to flush 2 instructions as 2 instructions are fetched before PC is correctly updated.
--   if (branch_taken = '1') then beq_flush <= '1'; 
--   else beq_flush <= '0'; 
--   end if; 
-- end process; 

end dlx_cu_hw;
