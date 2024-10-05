library ieee;
use ieee.std_logic_1164.all;

package myTypes is

-- Control unit input sizes
    constant OP_CODE_SIZE : integer :=  6;                                              -- OPCODE field size
    constant FUNC_SIZE    : integer :=  11;                                             -- FUNC field size

-- R-Type instruction -> FUNC field
    constant RTYPE_ADD : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000000";    -- ADD RS1,RS2,RD
    constant RTYPE_SUB : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000001";    -- SUB RS1,RS2,RD
    constant RTYPE_AND : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000010";    -- AND RS1,RS2,RD
    constant RTYPE_OR : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000011";    -- OR RS1,RS2,RD

    constant RTYPE_SGE : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000100";    -- RD = 1 IF RS1>=RS2 subtract and check Cout
    constant RTYPE_SLE : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000101";    -- RD = 1 IF RS1<=RS2 subtract and check cout
    constant RTYPE_SLL : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000110";    -- RD= RS1<<RS2(5 SOWNTO 0) shifter
    constant RTYPE_SNE : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000000111";    -- OR RS1,RS2,RD check 2 inputs are equal
    constant RTYPE_SRL : std_logic_vector(FUNC_SIZE - 1 downto 0) :=  "00000001000";    -- ADD RS1,RS2,RD  

    -- ...................
    -- to be completed with the others 2 alu operation
    -- ...................


-- R-Type instruction -> OPCODE field
    constant RTYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000000";          -- for ADD, SUB, AND, OR register-to-register operation

-- I-Type instruction -> OPCODE field
    constant ITYPE_ADDI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000001";    -- ADDI1 RS1,RD,INP1
    constant ITYPE_SUBI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000010";
    constant ITYPE_ANDI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000011";
    constant ITYPE_ORI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000100";

    constant ITYPE_SGEI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000101";
    constant ITYPE_SLEI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000110";
    constant ITYPE_SLLI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000111";
    constant ITYPE_SNEI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001000";
    constant ITYPE_SRLI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001001";

    constant ITYPE_BEQZ : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001010";
    constant ITYPE_BNEZ : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001011";

    constant ITYPE_LW : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001100";
    constant ITYPE_SW : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "001101";

--J type instruction -> OPCODE field
    constant JTYPE_J : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010000"; 
    constant JTYPE_JAL : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "010001";

    constant NOP : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "100000";  
end myTypes;


