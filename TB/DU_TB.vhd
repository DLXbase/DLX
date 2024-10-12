library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all; 
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


--DECODE UNIT SIGNALS 
signal J_EN_s, WR_EN_s, A_EN_s, B_EN_s, IMM_EN_s, RT_EN_s, is_R_type_s: std_logic;
signal BR_EN_s: std_logic;
signal CLK_s, RST_s :	std_logic; 
signal NPC_IN_s, IR_s, DATAIN_s, ADDR_IN_s, BTA_OR_NPC_s: 	std_logic_vector(WORD_SIZE-1 downto 0);
signal A_s,B_s,IMM_s,RT_OUT_s,NPC_OUT_s,PC_NXT_s : std_logic_vector(WORD_SIZE-1 downto 0);


constant CLK_PERIOD: time := 2 ns;
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
				is_R_type => is_R_type_s,
				BR_EN => BR_EN_s,
				clk => CLK_s,
				rst => RST_s,
				NPC_IN => NPC_IN_s, --da controllare
				IR => IR_s, --da controllare
				DATAIN => DATAIN_s,
				ADDR_IN => ADDR_IN_s,
				BTA_OR_NPC => BTA_OR_NPC_s, --da controllare
				A => A_s,
				B => B_s,
				IMM => IMM_s,
				RT_OUT => RT_OUT_s,
				NPC_OUT => NPC_OUT_s,
				PC_NXT => PC_NXT_s
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

	--testbench will verify the generation of outputs is correct

	--Expect NPC to be changed synchronously. 
	NPC_IN_s <= std_logic_vector(to_unsigned(8, NPC_IN_s'length));

	-- process 
	-- begin 
	-- 	wait for 7 ns; 
	-- 	NPC_IN_s <= std_logic_vector(unsigned (NPC_IN_s) + 4);
	-- 	wait for 2 ns; 
	-- end process; 

	--PC_NEXT testing process
    PC_next_gen: process
	begin
		BTA_OR_NPC_s <= std_logic_vector(to_unsigned(8, BTA_OR_NPC_s'length));
        J_EN_s <= '0'; 
		BR_EN_s <= '0';
		wait;
		--no jumps or branches => I expect the PCout to be recomputed BTA_OR_NPC
    end process;

	REG_FILE: process 
	begin 
		WR_EN_s<='0';
		--R_type op 
		A_EN_s<='1'; B_EN_s<='1'; IMM_EN_s<='1'; RT_EN_s<='1'; is_R_type_s <= '1'; 
        
		IR_s (26 downto 21) <= "000000"; -- RS1
		IR_s (20 downto 16) <= "000001"; -- RS2
		IR_s (15 downto 11) <= "000010"; -- RT
		--writing on register 1
		WR_EN_s<='1'; 
		ADDR_IN_s <= "00001";
		DATAIN_s <= std_logic_vector(to_unsigned(8, DATAIN_s'length));
		--expect the registers A and B to be loaded with zero. 
		wait for 8 ns; 

		






	end process; 




end TEST;

