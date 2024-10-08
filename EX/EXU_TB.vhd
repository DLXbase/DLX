library IEEE;
use IEEE.std_logic_1164.all;
use work.alu_type.all;
use work.myTypes.all;

entity TBEXU is
end TBEXU;

architecture TEST of TBEXU is

    component EXU
        generic (N: integer := 32);
        Port(CLK : in std_logic;
            RST : in std_logic;
            CW : in std_logic_vector(6 downto 0);
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

        -- Declare internal signals for all inputs to the DUT
        signal CLK_S        : std_logic;
        signal RST_S        : std_logic;
        signal CW_S         : std_logic_vector(6 downto 0);
        signal ALU_FUNC_S   : aluOp;
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
     generic map (N => 32) -- Assuming 32-bit configuration
     port map (
         -- Inputs
         CLK         => CLK_S,
         RST         => RST_S,
         CW          => CW_S,
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
		CLK <= '1';			
		wait for 1 ns;
		CLK <= '0';
		wait for 1 ns;
	end process;

    --reset 
	rst <= '1' after 2 ns, '0' after 10 ns;

    --operands value
    A_REG_S <= std_logic_vector(to_unsigned(10, 32));
    B_REG_S <= std_logic_vector(to_unsigned(20, 32));
    IMM_REG <= std_logic_vector(to_unsigned(50, 32));

    --NPC value (must check it is simply transfered to output with 1 cc delay)
    NPC_REG <= std_logic_vector(to_unsigned(8, 32));

    PC_4 <= NPC_REG - 4; 

    --RT REG (must check it is simply transfered to output with 1 cc delay)
    RT_REG <= <= std_logic_vector(to_unsigned(2, 5));
		
    --instruction
	process
	begin
	    --Control word for RTYPE. 
		CW_S <= "11100";	
        ALU_FUNC <= ADD; 		
        wait for 2 ns; 
		wait; 
	end process;
end TEST;