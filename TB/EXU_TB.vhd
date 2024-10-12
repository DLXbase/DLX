library IEEE;
use IEEE.std_logic_1164.all;
use work.alu_type.all;
use work.myTypes.all;
use ieee.numeric_std.all;
use work.constants.all; 

entity TBEXU is
end TBEXU;

architecture TEST of TBEXU is
 
    constant N: integer := 32; 
    
    component EXU
        generic (N: integer := WORD_SIZE);
        Port(CLK : in std_logic;
            RST : in std_logic;
            MUXA_SEL,MUXB_SEL,ZERO_SEL,ALUOUT_EN,SHIFT2_EN: in std_logic; 
            --CW : in std_logic_vector(6 downto 0);
            ALU_FUNC : in work.alu_type.aluOp;
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

        -- Declare internal signals for all inputs to the DUT
        signal CLK_S        : std_logic;
        signal RST_S        : std_logic;
        signal MUXA_SEL_S,MUXB_SEL_S,ZERO_SEL_S,ALUOUT_EN_S,SHIFT2_EN_S: std_logic; 
        signal ALU_FUNC_S   : work.alu_type.aluOp;
        signal NPC_REG_S    : std_logic_vector(N-1 downto 0);
        signal A_REG_S      : std_logic_vector(N-1 downto 0);
        signal B_REG_S      : std_logic_vector(N-1 downto 0);
        signal RT_REG_S     : std_logic_vector(N-1 downto 0);
        signal IMM_REG_S    : std_logic_vector(N-1 downto 0);
        signal PC_4_S       : std_logic_vector(N-1 downto 0);
    
        -- Declare internal signals for all outputs from the DUT
        signal ZERO_S       : std_logic;
        signal BRANC_ADDR_S : std_logic_vector(N-1 downto 0);
        signal ALU_OUT_S    : std_logic_vector(N-1 downto 0);
        signal RT_REG_OUT_S : std_logic_vector(N-1 downto 0);
        signal NPC_OUT_S    : std_logic_vector(N-1 downto 0);
begin 


     -- DUT instance
     UUT: entity work.EXU
     generic map (N => N) -- Assuming 32-bit configuration
     port map (
         -- Inputs
         CLK         => CLK_S,
         RST         => RST_S,
         MUXA_SEL => MUXA_SEL_S,
         MUXB_SEL=> MUXB_SEL_S,
         ZERO_SEL=> ZERO_SEL_S,
         ALUOUT_EN=> ALUOUT_EN_S,
         SHIFT2_EN => SHIFT2_EN_S,
         ALU_FUNC    => ALU_FUNC_S,
         NPC_REG     => NPC_REG_S,
         A_REG       => A_REG_S,
         B_REG       => B_REG_S,
         RT_REG      => RT_REG_S,
         IMM_REG     => IMM_REG_S,
         PC_4        => PC_4_S,

         -- Outputs
         ZERO        => ZERO_S,
         BRANC_ADDR  => BRANC_ADDR_S,
         ALU_OUT     => ALU_OUT_S,
         RT_REG_OUT  => RT_REG_OUT_S,
         NPC_OUT     => NPC_OUT_S
     );


	--clk process
	process
	begin
		CLK_S <= '1';			
		wait for 1 ns;
		CLK_S <= '0';
		wait for 1 ns;
	end process;

    --reset 
	RST_S <= '1' after 2 ns, '0' after 5 ns;

    --operands value
    A_REG_S <= std_logic_vector(to_unsigned(3, 32));
    B_REG_S <= std_logic_vector(to_unsigned(1, 32));
    IMM_REG_S <= std_logic_vector(to_unsigned(5, 32));

    --NPC value (must check it is simply transfered to output with 1 cc delay)
    NPC_REG_S <= std_logic_vector(to_unsigned(8, 32));

    PC_4_S <= std_logic_vector(unsigned(NPC_REG_S) - 4);

    --RT REG (must check it is simply transfered to output with 1 cc delay)
    RT_REG_S <= std_logic_vector(to_unsigned(2, 32));
		
    --instruction
	process
	begin
	    --Control word for RTYPE => "11100"
        MUXA_SEL_S <= '1'; MUXB_SEL_S <= '1'; ALUOUT_EN_S <= '1'; ZERO_SEL_S <= '0';  SHIFT2_EN_S <= '0'; 	
        ALU_FUNC_S <= ADD; 		
        wait for 13 ns;   --expected: ALUOUT = A+B=4;

        MUXA_SEL_S <= '1'; MUXB_SEL_S <= '1'; ALUOUT_EN_S <= '1'; ZERO_SEL_S <= '0';  SHIFT2_EN_S <= '0'; 	
        ALU_FUNC_S <= SUB; 		
        wait for 2 ns;   --expected: ALUOUT = A-B=2; 

        MUXA_SEL_S <= '1'; MUXB_SEL_S <= '1'; ALUOUT_EN_S <= '1'; ZERO_SEL_S <= '0';  SHIFT2_EN_S <= '0'; 	
        ALU_FUNC_S <= MULT; 		
        wait for 2 ns;   --expected: ALUOUT = A*B=3;

        MUXA_SEL_S <= '1'; MUXB_SEL_S <= '1'; ALUOUT_EN_S <= '1'; ZERO_SEL_S <= '0';  SHIFT2_EN_S <= '0'; 	
        ALU_FUNC_S <= SGE; 		
        wait for 2 ns;   --expected: ALUOUT = 1;

        MUXA_SEL_S <= '1'; MUXB_SEL_S <= '1'; ALUOUT_EN_S <= '1'; ZERO_SEL_S <= '0';  SHIFT2_EN_S <= '0'; 	
        ALU_FUNC_S <= SLE; 		
        wait for 2 ns;   --expected: ALUOUT = 0;
        
        --Control word for LW => "10100"
        MUXA_SEL_S <= '1'; MUXB_SEL_S <= '0'; ALUOUT_EN_S <= '1'; ZERO_SEL_S <= '0';  SHIFT2_EN_S <= '0'; 	
        ALU_FUNC_S <= ADD; 		
        wait for 2 ns;   --expected: ALUOUT = A+IMM=8;

        --Control word for BNEZ => "00101"
        MUXA_SEL_S <= '0'; MUXB_SEL_S <= '0'; ALUOUT_EN_S <= '1'; ZERO_SEL_S <= '0';  SHIFT2_EN_S <= '1'; 	
        ALU_FUNC_S <= ADD; 		
        wait for 2 ns;   --expected: ALUOUT = NPC + IMM *4 = 8 + 20 = 28
                         --expected: ZERO_S = 1; 
        
		wait; 
	end process;
end TEST;