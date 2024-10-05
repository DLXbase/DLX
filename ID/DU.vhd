library IEEE;
use IEEE.std_logic_1164.all;

-- inputs and outputs are on N bits, defined through generic map
entity DU is
	generic (N: integer := 32); 
	Port (	--PC: in std_logic_vector(N-1 downto 0);
			J_EN, WR_EN, A_EN, B_EN, IMM_EN, RT_EN, is_R_type:	In	std_logic;    --control signals from CU
			BR_EN: in std_logic;  									--Signals wether there is a branch taken in EX stage
			clk, rst :	In	std_logic;     
			NPC_IN, IR, DATAIN, ADDR_IN, BTA_OR_NPC:	in 	std_logic_vector(N-1 downto 0);  --Incoming data from registers. RT_IN comes from the WB stage, BTA_OR_NPC comes from the EX stage. 
			A,B,IMM,RT_OUT,NPC_OUT,PC_NXT : OUT 	std_logic_vector(N-1 downto 0));     --output registers. 
	end DU;

architecture struct of DU is    
	
--instanciate components needed
	component reg 
  		GENERIC (N: integer);
  		Port (clk,rst,en: in std_logic; 
        	A: in std_logic_vector(N-1 downto 0);
       	    Y: out std_logic_vector(N-1 downto 0));
	end component;

	--reg_file read is not synchronous
  component reg_file is
  GENERIC (NBIT: integer:=32;
           NREG: integer:=32;
           NADDR: integer:= 5);
    Port (clk,rst,wr_en: in std_logic; 
        add_rd1: in std_logic_vector(NADDR-1 downto 0);
        add_rd2: in std_logic_vector(NADDR-1 downto 0);
        add_wr: in std_logic_vector(NADDR-1 downto 0);
        datain: in std_logic_vector(NBIT-1 downto 0);
        out2: out std_logic_vector(NBIT-1 downto 0);
        out1: out std_logic_vector(NBIT-1 downto 0));
	end component;

	--extend immediate from 16 to 32 bits
	component sign_extend is
	  	generic ( NBIT: integer:= 16);           
		Port (A:	In	std_logic_vector(NBIT-1 downto 0);	
			  res:	Out	std_logic_vector ((2*NBIT)-1 downto 0));
	end component;

	--to decide wether to jump or not
	component mux21 is
	  	generic ( NBIT: integer:= 32);           
		Port (A:	In	std_logic_vector(NBIT-1 downto 0);	
			  B:    in std_logic_vector (NBIT-1 downto 0); 
		      sel:  in std_logic; 
			  muxout:	Out	std_logic_vector ((NBIT)-1 downto 0));
	end component;
	
	--to invert the B_en signal
	component IV
	Port (	A:	In	std_logic;
		Y:	Out	std_logic);
	end component;

	component AND2 is
	Port (	a,b:	In	std_logic;
		    y:	Out	std_logic);
	end component;

--internal signals
	signal A_nxt, B_nxt, IMM_nxt, JTA: std_logic_vector (N-1 downto 0); 
	signal RT_nxt: std_logic_vector (4 downto 0); 
	signal BR_EN_NEG, J_SEL: std_logic; 

begin 

	RF_instance: reg_file
	generic map(NBIT => 32)
	port map(clk=> clk ,rst=>rst, wr_en=>wr_en,
			add_rd1 => IR(25 downto 21), add_rd2 =>IR (20 downto 16), add_wr => ADDR_IN, datain => DATAIN, 
			out1=>A_nxt, out2 => B_nxt);
	-- Rwad addresses come from IR, Write address is buffered from the WB stage. 
	
	A_reg: reg 
	generic map(N=>N) --32bits
	port map(clk => clk ,rst => rst, en => A_EN, 
			 A => A_nxt, -- A_nxt is the output read of the reg_file
			 Y => A);   
	
	B_reg: reg 
	generic map(N=>N) --32bits
	port map(clk => clk ,rst => rst, en => B_EN, 
			 A => B_nxt, -- B_nxt is the output read of the reg_file
			 Y => B);

	Sign_extend_block: sign_extend   
	generic map(NBIT=>N/2) --16 bits
	port map(A => IR(15 downto 0),
			 res => IMM_nxt);
	--extends the Immediate field to 32 bits, holding the sign. 

	IMM_reg: reg 
	generic map(N=>N) --32bits
	port map(clk => clk ,rst => rst, en => IMM_EN, 
			 A => IMM_nxt, -- A_nxt is the output read of the reg_file
			 Y => IMM);    

	RT_source_mux: mux21 --this mux decides which bits of IR determine the Target Register (for Rtype it's 15:11, for I type it's 20:16)
	generic map(NBIT=>5) --5 bits
	port map(A => IR(15 downto 11),    --R_type (sel = 1)
			 B => IR (20 downto 16),   --I_type (sel = 0)
			 sel => is_R_type, 
			 muxout => RT_nxt);

	RT_reg_inst: reg 
	generic map(N=>5) --5 bits
	port map(clk => clk ,rst => rst, en => RT_EN,
			 A => RT_nxt, 
			 Y => RT_out); 

	IV_instance:  IV 
	port map(A => BR_EN, 
			 Y => BR_EN_NEG);

	AND2_instance:  AND2 
	port map(a => BR_EN_NEG,
			 b => J_EN,  
			 Y => BR_EN_NEG);

	--compute JTA
	JTA <= NPC_IN(31 downto 28) & IR(25 downto 0) & "00"; 

	--if the jump is enabled AND there is no branch taken in ex stage, this mux selects the JTA as the new PC value, else if there is a branch it will choose the BTA, else PC+4.
	PC_source_MUX:  mux21 
	port map(A => JTA,  									   -- if J_sel is 1 set JTA
			 B => BTA_OR_NPC,                                  -- if J_SEL is 0 set BTA_OR_NPC
			 sel => J_SEL, 
			 muxout => PC_NXT);

	--create a buffer register for NPC
	NPC_reg_inst: reg 
	generic map(N=>32) --32 bits
	port map(clk => clk ,rst => rst, en => '1',  --always enabled
			 A => NPC_IN, 
			 Y => NPC_OUT);

end struct;

