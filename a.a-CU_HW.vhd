library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all; 
--use ieee.std_logic_arith.all;
use work.alu_type.all;
--use ieee.numeric_std.all;
use work.all;

entity dlx_cu is
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

end dlx_cu;

architecture dlx_cu_hw of dlx_cu is
  type mem_array is array (integer range 0 to MICROCODE_MEM_SIZE - 1) of std_logic_vector(CW_SIZE - 1 downto 0);
  signal cw_mem : mem_array := (--IR,NPC | A,B,IMM,RT,R/I,J_EN | MUXA,MUXB,ALU_OUT,BEQZ/BNEZ,SH2EN| DRAM,LMD | WBMUX,RFWE,JAL_EN 
                                  "11"   &        "110110"     &           "11100"                &   "00"   &     "110",    -- 0 | R type: ADD  
                                  "11"   &        "110110"     &           "11100"                &   "00"   &     "110",    -- 1 | R type: SUB  
                                  "11"   &        "110110"     &           "11100"                &   "00"   &     "110",    -- 2 | 2R type: AND 
                                  "11"   &        "110110"     &           "11100"                &   "00"   &     "110",    -- 3 | R type: OR
                                  "11"   &        "110110"     &           "11100"                &   "00"   &     "110",    -- 4 | R type: SGE 
                                  "11"   &        "110110"     &           "11100"                &   "00"   &     "110",    -- 5 | R type: SLE 
                                  "11"   &        "110110"     &           "11100"                &   "00"   &     "110",    -- 6 | R type: SLL 
                                  "11"   &        "110110"     &           "11100"                &   "00"   &     "110",    -- 7 | R type: SNE 
                                  "11"   &        "110110"     &           "11100"                &   "00"   &     "110",    -- 8 | R type: SRL
                                  
                                  "11"   &        "101100"     &           "10100"                &   "00"   &     "110",    -- 9 | I type: ADDI 
                                  "11"   &        "101100"     &           "10100"                &   "00"   &     "110",    -- 10 | I type: SUBI 
                                  "11"   &        "101100"     &           "10100"                &   "00"   &     "110",    -- 11 | I type: ANDI 
                                  "11"   &        "101100"     &           "10100"                &   "00"   &     "110",    -- 12 | I type: ORI 
                                  "11"   &        "101100"     &           "10100"                &   "00"   &     "110",    -- 13 | I type: SGEI 
                                  "11"   &        "101100"     &           "10100"                &   "00"   &     "110",    -- 14 | I type: SLEI 
                                  "11"   &        "101100"     &           "10100"                &   "00"   &     "110",    -- 15 | I type: SNEI 
                                  "11"   &        "101100"     &           "10100"                &   "00"   &     "110",    -- 16 | I type: SRLI 
                                                                      
                                  "11"   &        "001000"     &           "00111"                &   "00"   &     "100",    -- 17 | I type: BEQZ 
                                  "11"   &        "001000"     &           "00101"                &   "00"   &     "100",    -- 18 | I type: BNEZ 
                                                         
                                  "11"   &        "101100"     &           "10100"                &   "11"   &     "010",    -- 19 | I type: LW              
                                  "11"   &        "101100"     &           "10100"                &   "11"   &     "000",    -- 20 | I type: SW 

                                  "11"   &        "101101"     &           "00000"                &   "00"   &     "000", -- 21 |  I type: J
                                  --add extra mux to write on R31
                                  "11"   &        "101101"     &           "00000"                &   "00"   &     "001", -- 22 |  I type: JAKL
								  
								  "11"   &        "000000"     &           "00000"                &   "00"   &     "000", -- 23 | NOP
								  "11"   &        "000000"     &           "00000"                &   "00"   &     "000", -- 24 | NOP
								  "11"   &        "000000"     &           "00000"                &   "00"   &     "000", -- 25 | NOP
								  "11"   &        "000000"     &           "00000"                &   "00"   &     "000", -- 26 | NOP
								  "11"   &        "000000"     &           "00000"                &   "00"   &     "000", -- 27 | NOP
								  "11"   &        "000000"     &           "00000"                &   "00"   &     "000", -- 28 | NOP
								  "11"   &        "000000"     &           "00000"                &   "00"   &     "000", -- 29 | NOP
								  "11"   &        "000000"     &           "00000"                &   "00"   &     "000", -- 30 | NOP
								  "11"   &        "000000"     &           "00000"                &   "00"   &     "000", -- 31 | NOP
                                  "11"   &        "000000"     &           "00000"                &   "00"   &     "000" -- 32 | NOP
								  
									              );
                                
                                
  signal IR_opcode : std_logic_vector(OP_CODE_SIZE -1 downto 0);  -- OpCode part of IR
  signal IR_func : std_logic_vector(FUNC_SIZE downto 0);   -- Func part of IR when Rtype
  signal cw   : std_logic_vector(CW_SIZE - 1 downto 0); -- full control word read from cw_mem


  -- control word is shifted to the correct stage
  signal cw1 : std_logic_vector(CW_SIZE -1  downto 0); -- IF+ID
  signal cw2 : std_logic_vector(CW_SIZE - 1 - 2 - 6  downto 0); -- EX
  signal cw3 : std_logic_vector(CW_SIZE - 1 - 2 - 6 -5 downto 0); -- MEM
  signal cw4 : std_logic_vector(CW_SIZE - 1 - 2 - 6 - 5 -2 downto 0); -- WB

  signal aluOpcode_i: aluOp := aluNOP; -- ALUOP defined in package
  signal aluOpcode1: aluOp := aluNOP;
  signal aluOpcode2: aluOp := aluNOP;
  signal aluOpcode3: aluOp := aluNOP;

 
begin  -- dlx_cu_rtl

  IR_opcode(5 downto 0) <= IR_IN(31 downto 26);
  IR_func(10 downto 0)  <= IR_IN(FUNC_SIZE - 1 downto 0);

  cw <= cw_mem(to_integer(unsigned(IR_opcode)));


  -- stage one control signals
  IR_EN  <= cw1(CW_SIZE - 1);
  NPC_EN <= cw1(CW_SIZE - 2);
  
  -- stage two control signals
  RegA_EN   <= cw1(CW_SIZE - 3);
  RegB_EN   <= cw1(CW_SIZE - 4);
  RegIMM_EN <= cw1(CW_SIZE - 5);
  RT_REG_EN <= cw1(CW_SIZE - 6);
  IS_R_TYPE <= cw1(CW_SIZE - 7);
  J_EN      <= cw1(CW_SIZE - 8);
  
  -- stage three control signals
  MUXA_SEL      <= cw2(CW_SIZE - 9);
  MUXB_SEL      <= cw2(CW_SIZE - 10);
  ALU_OUTREG_EN <= cw2(CW_SIZE - 11);
  BEQZ_OR_BNEZ  <= cw2(CW_SIZE - 12);
  SH2_EN        <= cw2(CW_SIZE - 13);
  
  -- stage four control signals
  DRAM_WE      <= cw3(CW_SIZE - 14);
  LMD_EN       <= cw3(CW_SIZE - 15);

  
  -- stage five control signals
  WB_MUX_SEL <= cw4(CW_SIZE - 16);
  RF_WE      <= cw4(CW_SIZE - 17);
  JAL_EN     <= cw4(CW_SIZE -18); 


  --PC_enabling signal 
  PC_EN<='1'; 


  -- process to pipeline control words
  CW_PIPE: process (Clk, Rst)
  begin  -- process Clk
    if Rst = '1' then                   -- asynchronous reset (active low)
      cw1 <= (others => '0');
      cw2 <= (others => '0');
      cw3 <= (others => '0');
      cw4 <= (others => '0');
      aluOpcode1 <= aluNOP;
      aluOpcode2 <= aluNOP;
      aluOpcode3 <= aluNOP;
    elsif Clk'event and Clk = '1' then  -- rising clock edge
      cw1 <= cw;
      cw2 <= cw1(CW_SIZE - 1 - 2 -6 downto 0);
      cw3 <= cw2(CW_SIZE - 1 - 2 -6 -5 downto 0);
      cw4 <= cw3(CW_SIZE - 1 - 2 -6 -5 -2 downto 0);
      
      aluOpcode1 <= aluOpcode_i;
      aluOpcode2 <= aluOpcode1;
      aluOpcode3 <= aluOpcode2;
    end if;
  end process CW_PIPE;

  ALU_OPCODE <= aluOpcode3;

  -- purpose: Generation of ALU OpCode
  -- type   : combinational
  -- inputs : IR_i
  -- outputs: aluOpcode
   ALU_OP_CODE_P : process (IR_opcode, IR_func)
   begin  -- process ALU_OP_CODE_P
	case to_integer(unsigned(IR_opcode)) is
	        -- case of R type requires analysis of FUNC
		when 0 =>
			case to_integer(unsigned(IR_func)) is
				when 0 => aluOpcode_i <= ADD; 
				when 1 => aluOpcode_i <= SUB; 
				when 2 => aluOpcode_i <= BITAND; 
				when 3 => aluOpcode_i <= BITOR; 
				when 4 => aluOpcode_i <= SGE;  
				when 6 => aluOpcode_i <= SLE;  
				when 7 => aluOpcode_i <= FUNCLSL; 
				when 8 => aluOpcode_i <= SNE;
				when 9 => aluOpcode_i <= FUNCRSL;
				-- to be continued and filled with all the other instructions  
				when others => aluOpcode_i <= aluNOP;
			end case;
		when 1 => aluOpcode_i <= ADD;  --ADDI
		when 2 => aluOpcode_i <= SUB; --SUBI
		when 3 => aluOpcode_i <= BITAND; --ANDI
		when 4 => aluOpcode_i <= BITOR; --ORI
		when 5 => aluOpcode_i <= SGE; --SGEI
		when 6 => aluOpcode_i <= SLE; --SLEI 
		when 7 => aluOpcode_i <= FUNCLSL; --SLLI
		when 8 => aluOpcode_i <= SNE; --SNEI
		when 9 => aluOpcode_i <= FUNCRSL; --SRLI
		when 10 => aluOpcode_i <= ADD; --BEQZ adds RS to NPC
		when 11 => aluOpcode_i <= ADD; --BNEZ adds RS to NPC
		when 12 => aluOpcode_i <= ADD; --LW adds RS to NPC
		when 13 => aluOpcode_i <= ADD; --SW adds RS to NPC

		when 16 => aluOpcode_i <= aluNOP; --J  alu does nothing 
		when 17 => aluOpcode_i <= aluNOP; --JAL   alu does nothing
	
		when others => aluOpcode_i <= aluNOP;
	 end case;
	end process ALU_OP_CODE_P;
end dlx_cu_hw;

