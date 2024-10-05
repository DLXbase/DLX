library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.alu_type.all;

entity EXU is
	generic (N: integer := 32);
	Port(CLK : in std_logic;
		RST : in std_logic;
		CW : in std_logic_vector(3 downto 0);
		ALU_FUNC : in alu_type;
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
end EXU;

architecture structural of EXU is
	--signals
	signal out_shift_s, op_1_s, op_2_s, out_cmp_s, alu_out_s : std_logic_vector(N-1 downto 0);
	--components
	component mux21 is
		generic ( NBIT: integer:= 32);           
	Port (A:	In	std_logic_vector(NBIT-1 downto 0);	
		  B:    in std_logic_vector (NBIT-1 downto 0); 
          sel:  in std_logic; 
	      muxout:	Out	std_logic_vector ((NBIT)-1 downto 0));
	end component;
	
	component alu is
		generic (N : integer := 32);
    port  ( FUNC: IN TYPE_OP;  -- function to execute
           DATA1, DATA2: IN std_logic_vector(N-1 downto 0);
           OUTALU: OUT std_logic_vector(N-1 downto 0));
	end component;

	component is_zero is
	  	generic ( NBIT: integer:= 32);           
	Port (A:	In	std_logic_vector(NBIT-1 downto 0);
          res:  out std_logic);    
	end component;

	component reg is
		 GENERIC (N: integer );
    Port (clk,rst,en: in std_logic; 
        A: in std_logic_vector(N-1 downto 0);
        Y: out std_logic_vector(N-1 downto 0));
	end component;

	component shift2 is
		generic(N: integer := 32);
	Port(en : in std_logic;
		A : in std_logic_vector(N-1 downto 0);
		Y : out std_logic_vector(N-1 downto 0));
	end component;

begin
	--portmaps

	EXU_SHIFT: shift2 
			   generic map(N=>N)
			   port map( A=>IMM_REG, Y=>out_shift_s, en=>CW(0));

	MUX1: mux21
			generic map(NBIT=>N)
			port map(A=>A_REG, B=>NPC_REG, sel=>CW(1), muxout=>op_1_s);


	MUX2: mux21
			generic map(NBIT=>N)
			port map(A=>B_REG, B=>IMM_REG, sel=>CW(2), muxout=>op_2_s);


	MUX3: mux21
			generic map(NBIT=>N)
			port map(A=>alu_out_s, B=>PC_4, sel=>out_cmp_s, muxout=>PC_4);

	EXU_ALU: alu
			generic map(N=>N)
			port map(FUNC=>ALU_FUNC,
           DATA1=>op_1_s, DATA2=>op_2_s,
           OUTALU=>ALU_OUT);

	EXU_CMPZ: iszero
			generic map(NBIT=>N)
			port map(A=>A_REG, res=>out_cmp_s);


end structural;
