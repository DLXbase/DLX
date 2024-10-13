library ieee;
use ieee.std_logic_1164.all;

package myTypes is

-- Control unit input sizes
    constant OP_CODE_SIZE : integer :=  6;                                              -- OPCODE field size
    constant FUNC_SIZE    : integer :=  11;                                             -- FUNC field size

    -- R-Type instruction -> FUNC field
    constant RTYPE_SLL    : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000000100";  -- 0x04
    constant RTYPE_SRL    : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000000110";  -- 0x06
    --constant RTYPE_SRA    : std_logic_vector(FUNC_SIZE - 1 downto 0) := "000000000111";  -- 0x07
    constant RTYPE_ADD    : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000100000";  -- 0x20
    --constant RTYPE_ADDU   : std_logic_vector(FUNC_SIZE - 1 downto 0) := "000000100001";  -- 0x21
    constant RTYPE_SUB    : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000100010";  -- 0x22
    --constant RTYPE_SUBU   : std_logic_vector(FUNC_SIZE - 1 downto 0) := "000000100011";  -- 0x23
    constant RTYPE_AND    : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000100100";  -- 0x24
    constant RTYPE_OR     : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000100101";  -- 0x25
    constant RTYPE_XOR    : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000100110";  -- 0x26
    --constant RTYPE_SEQ    : std_logic_vector(FUNC_SIZE - 1 downto 0) := "000000101000";  -- 0x28
    constant RTYPE_SNE    : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000101001";  -- 0x29
    --constant RTYPE_SLT    : std_logic_vector(FUNC_SIZE - 1 downto 0) := "000000101010";  -- 0x2a
    --constant RTYPE_SGT    : std_logic_vector(FUNC_SIZE - 1 downto 0) := "000000101011";  -- 0x2b
    constant RTYPE_SLE    : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000101100";  -- 0x2c
    constant RTYPE_SGE    : std_logic_vector(FUNC_SIZE - 1 downto 0) := "00000101101";  -- 0x2d
    --constant RTYPE_MOVI2S : std_logic_vector(FUNC_SIZE - 1 downto 0) := "000000110000";  -- 0x30
    --constant RTYPE_MOVS2I : std_logic_vector(FUNC_SIZE - 1 downto 0) := "000000110001";  -- 0x31
    --constant RTYPE_MOVF   : std_logic_vector(FUNC_SIZE - 1 downto 0) := "000000110010";  -- 0x32
    --constant RTYPE_MOVD   : std_logic_vector(FUNC_SIZE - 1 downto 0) := "000000110011";  -- 0x33
    --constant RTYPE_MOVFP2I: std_logic_vector(FUNC_SIZE - 1 downto 0) := "000000110100";  -- 0x34
    --constant RTYPE_MOVI2FP: std_logic_vector(FUNC_SIZE - 1 downto 0) := "000000110101";  -- 0x35
    --constant RTYPE_MOVT2I : std_logic_vector(FUNC_SIZE - 1 downto 0) := "000000110111";  -- 0x37
    --constant RTYPE_MOVI2T : std_logic_vector(FUNC_SIZE - 1 downto 0) := "000000110110";  -- 0x36
    --constant RTYPE_SLTU   : std_logic_vector(FUNC_SIZE - 1 downto 0) := "000000111010";  -- 0x3a
    --constant RTYPE_SGTU   : std_logic_vector(FUNC_SIZE - 1 downto 0) := "000000111011";  -- 0x3b
    --constant RTYPE_SLEU   : std_logic_vector(FUNC_SIZE - 1 downto 0) := "000000111100";  -- 0x3c
    --constant RTYPE_SGEU   : std_logic_vector(FUNC_SIZE - 1 downto 0) := "000000111101";  -- 0x3d

-- R-Type instruction -> OPCODE field
    constant RTYPE : std_logic_vector(OP_CODE_SIZE - 1 downto 0) :=  "000000";          -- for ADD, SUB, AND, OR register-to-register operation

-- I-Type instruction -> OPCODE field
 -- General instructions OPCODE field constants
    constant ITYPE_J     : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "000010";  -- 0x02
    constant ITYPE_JAL   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "000011";  -- 0x03
    constant ITYPE_BEQZ  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "000100";  -- 0x04
    constant ITYPE_BNEZ  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "000101";  -- 0x05
    --constant ITYPE_BFPT  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "000110";  -- 0x06
    --constant ITYPE_BFPF  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "000111";  -- 0x07
    constant ITYPE_ADDI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "001000";  -- 0x08
    --constant ITYPE_ADDUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "001001";  -- 0x09
    constant ITYPE_SUBI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "001010";  -- 0x0a
    --constant ITYPE_SUBUI : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "001011";  -- 0x0b
    constant ITYPE_ANDI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "001100";  -- 0x0c
    constant ITYPE_ORI   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "001101";  -- 0x0d
    constant ITYPE_XORI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "001110";  -- 0x0e
    --constant ITYPE_LHI   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "001111";  -- 0x0f
    --constant ITYPE_RFE   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "010000";  -- 0x10
    --constant ITYPE_TRAP  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "010001";  -- 0x11
    --constant ITYPE_JR    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "010010";  -- 0x12
    --constant ITYPE_JALR  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "010011";  -- 0x13
    constant ITYPE_SLLI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "010100";  -- 0x14
    constant ITYPE_NOP   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "010101";  -- 0x15
    constant ITYPE_SRLI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "010110";  -- 0x16
    --constant ITYPE_SRAI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "010111";  -- 0x17
    --constant ITYPE_SEQI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "011000";  -- 0x18
    --constant ITYPE_SNEI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "011001";  -- 0x19
    --constant ITYPE_SLTI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "011010";  -- 0x1a
    --constant ITYPE_SGTI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "011011";  -- 0x1b
    constant ITYPE_SLEI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "011100";  -- 0x1c
    constant ITYPE_SGEI  : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "011101";  -- 0x1d
    --constant ITYPE_LB    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "100000";  -- 0x20
    --constant ITYPE_LH    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "100001";  -- 0x21
    constant ITYPE_LW    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "100011";  -- 0x23
    --constant ITYPE_LBU   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "100101";  -- 0x24
    --constant ITYPE_LHU   : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "100110";  -- 0x25
    --constant ITYPE_LF    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "100111";  -- 0x26
    --constant ITYPE_LD    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "101000";  -- 0x27
    --constant ITYPE_SB    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "101001";  -- 0x28
    --constant ITYPE_SH    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "101010";  -- 0x29
    constant ITYPE_SW    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "101011";  -- 0x2b
    --constant ITYPE_SF    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "101110";  -- 0x2e
    --constant ITYPE_SD    : std_logic_vector(OP_CODE_SIZE - 1 downto 0) := "101111";  -- 0x2f

end myTypes;



