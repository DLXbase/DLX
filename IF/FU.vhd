library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FU is
	generic (N: integer := 32);
	Port(CLK : in std_logic;
		RST : in std_logic;
		CW : in std_logic_vector(2 downto 0);
		IN_ID : in std_logic_vector(N-1 downto 0);
		IREG_out : out std_logic_vector(N-1 downto 0);
		NPC_out : out std_logic_vector(N-1 downto 0);
		PC_4out : out std_logic_vector(N-1 downto 0) 
);
end FU;

architecture structural of FU is
	--signals
	signal pc_out_s, pc_4out_s, im_out_s : std_logic_vector(N-1 downto 0);

	--components
	component reg
		GENERIC (N: integer );
  		Port (clk,rst,en: in std_logic; 
        	A: in std_logic_vector(N-1 downto 0);
        	Y: out std_logic_vector(N-1 downto 0));
	end component;

	component IRAM
		generic (
    		RAM_DEPTH : integer := 48;
    		I_SIZE : integer := 32);
  		port (
    		Rst  : in  std_logic;
    		Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
    		Dout : out std_logic_vector(I_SIZE - 1 downto 0)
    		);
	end component;

	component add4
		generic ( NBIT: integer:= 32);           
		Port (A:	In	std_logic_vector(NBIT-1 downto 0);	
	      	res:	Out	std_logic_vector (NBIT-1 downto 0));
	end component;

	begin

	--port maps
	PC_REG : reg
		generic map(N => N)
		port map(clk => CLK,
				rst => RST,
				en => CW(2),
				A => IN_ID,
				Y => pc_out_s
		);

	ADD : add4
		generic map (NBIT => N)
		port map (
			A => pc_out_s,
			res => pc_4out_s
		);

	IRmem : IRAM
		port map (
			Rst => RST,
			Addr => pc_out_s,
			Dout => im_out_s					
		);

	NPC_REG : reg
		generic map(N => N)
		port map (
			clk => CLK,
			rst => RST,
			en => CW(1),
			A => pc_4out_s,
			Y => NPC_out
		);

	I_REG : reg
		generic map(N => N)
		port map (
			clk => CLK,
			rst => RST,
			en => CW(0),
			A => im_out_s,
			Y => IREG_out
		);

	PC_4OUT <= pc_4out_s;

end structural;
