library IEEE;
use IEEE.std_logic_1164.all;
use work.alu_type.all;
use work.myTypes.all;
use work.constants.all; 


entity TBDUWB is
end TBDUWB;

architecture TEST of TBDUWB is

component DU is
	generic (N: integer := WORD_SIZE); 
	Port (	--PC: in std_logic_vector(N-1 downto 0);
			J_EN, WR_EN, A_EN, B_EN, IMM_EN, RT_EN, is_R_type:	In	std_logic;    --control signals from CU
			BR_EN: in std_logic;  				--Signals wether there is a branch taken in EX stage
			clk, rst :	In	std_logic;     
			NPC_IN, IR, DATAIN, ADDR_IN, BTA_OR_NPC:	in 	std_logic_vector(N-1 downto 0);  --Incoming data from registers. RT_IN comes from the WB stage, BTA_OR_NPC comes from the EX stage. 
			A,B,IMM,RT_OUT,NPC_OUT,PC_NXT : OUT 	std_logic_vector(N-1 downto 0));     --output registers. 
end component;

component WBU is
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

--DECODE UNIT SIGNALS 
signal J_EN_s, WR_EN_s, A_EN_s, B_EN_s, IMM_EN_s, RT_EN_s, is_R_type_s: std_logic;
signal BR_EN_s: std_logic;
signal CLK_s, RST_s :	std_logic; 
signal NPC_IN_s, IR_s, DATAIN_s, ADDR_IN_s, BTA_OR_NPC_s: 	std_logic_vector(WORD_SIZE-1 downto 0);
signal A_s,B_s,IMM_s,RT_OUT_s,NPC_OUT_s,PC_NXT_s : std_logic_vector(WORD_SIZE-1 downto 0);

signal ALU_OUT_s, LOAD_s, NPC_REG_in_s, RT_REG_in_s, RF_ADDR_s, RF_DATA_s: std_logic_vector(WORD_SIZE-1 downto 0);
signal IS_JAL_s, ALUOUT_OR_LOAD_s: std_logic;

constant CLK_PERIOD: time := 10 ns;
begin

--port maps
    DUT_D : DU
        generic map (N => WORD_SIZE)
		port map(J_EN => J_EN_s,
				WR_EN => WR_EN_s,
				A_EN => A_EN_s,
				B_EN => B_EN_s,
				IMM_EN => IMM_EN_s,
				RT_EN => RT_EN_s,
				is_R_typ => is_R_type_s,
				BR_EN => BR_EN_s,
				clk => CLK,
				rst => RST,
				NPC_IN => NPC_IN_s, --da controllare
				IR => IR_s, --da controllare
				DATAIN => RF_DATA_s,
				ADDR_IN => RF_ADDR_s,
				BTA_OR_NPC => BTA_OR_NPC_s, --da controllare
				A => A_s,
				B => B_s,
				IMM => IMM_s,
				RT_OUT => RT_OUT_s,
				NPC_OUT => NPC_OUT_s,
				PC_NXT => PC_NEXT_s
);

    DUT_WB : WBU
        generic map (N => WORD_SIZE)
		port map(ALU_OUT => ALU_OUT_s, --da controllare
  				 LOAD => LOAD_s,    --da controllare                 
  				 NPC_REG_in => NPC_REG_in_s, --da controllare         
  				 RT_REG_in => RT_REG_in_s,   --da controllare         
  				 IS_JAL => IS_JAL_s,                  
  				 ALUOUT_OR_LOAD => ALUOUT_OR_LOAD_s,  
  				 RF_ADDR => RF_ADDR_s,                
  				 RF_DATA => RF_DATA_s                 
);


    -- Clock generation process
    CLK_GEN: process
    begin
        while true loop
            CLK_s <= '0';
            wait for CLK_PERIOD / 2;
            CLK_s <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;


--reset 
	RST_s <= '1' after 2 ns, '0' after 5 ns;

    SIMULATION: process
	begin



    end process;




end TEST;

