library IEEE;
use IEEE.std_logic_1164.all;
use work.alu_type.all;
use work.myTypes.all;
use work.constants.all; 


entity TBIF is
end TBIF;

architecture TEST of TBIF is

component FU is
	generic (N: integer := WORD_SIZE);
	Port(CLK : in std_logic;
		RST : in std_logic;
		PC_EN, NPC_EN, IR_EN : in std_logic;    --control word signals
		IN_ID : in std_logic_vector(N-1 downto 0);
		from_IRAM : in std_logic_vector(N-1 downto 0); --output of iram
		to_IRAM : out std_logic_vector(N-1 downto 0); --input for iram 
		IREG_out : out std_logic_vector(N-1 downto 0);
		NPC_out : out std_logic_vector(N-1 downto 0);
		PC_4out : out std_logic_vector(N-1 downto 0) );
end component;

  component IRAM
    generic (
      RAM_DEPTH : integer := 48;
      I_SIZE : integer := 32
    );
    port (
      Rst  : in  std_logic;
      Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
      Dout : out std_logic_vector(I_SIZE - 1 downto 0)
    );
  end component;


signal CLK_s,RST_s, PC_EN_s, NPC_EN_s, IR_EN_s: std_logic;
signal from_IRAM_s, to_IRAM_s, IREG_out_s, NPC_out_s, PC_4out_s: std_logic_vector(WORD_SIZE-1 downto 0);
--signal pc_s, IRAM_DOut_s : std_logic_vector(WORD_SIZE-1 downto 0);
signal IN_ID_s : std_logic_vector(WORD_SIZE-1 downto 0) := (others => '0');

constant CLK_PERIOD: time := 10 ns;


begin
    --port maps
    DUT_F : FU
			generic map(N => WORD_SIZE)
			port map (
            CLK => CLK_s,
            RST => RST_s,
			PC_EN => PC_EN_s,
			NPC_EN => NPC_EN_s,
			IR_EN => IR_EN_s,
			IN_ID => IN_ID_s,
			from_IRAM => from_IRAM_s, 
			To_IRAM => To_IRAM_s,
			IREG_out => IREG_out_s,
			NPC_out => NPC_out_s,
			PC_4out => PC_4out_s
);


    DUT_M : IRAM
			generic map(RAM_DEPTH => 48,
						I_SIZE => 32)
			port map( rst => RST_s,
					  Addr => To_IRAM_s,
					  Dout => from_IRAM_s
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
	RST_S <= '1' after 2 ns, '0' after 5 ns;

    SIMULATION: process
	begin
		wait for 10 ns;
		PC_EN_s <= '1';
		NPC_EN_s <= '1';
		IR_EN_s <= '1';
		
		for n in 0 to 10 loop --normal execution
			--IN_ID_s <= std_logic_vector(to_unsigned(n, IN_ID_s'length));
			wait for 10 ns;
			IN_ID_s <= PC_4out_s;
		end loop;

		wait for 20 ns;

		IN_ID_s <= x"0000000C";  --jump case

		wait for 10 ns;

		IN_ID_s <= x"00000008";

		wait for 20 ns;

		wait;

	end process;



end TEST;

