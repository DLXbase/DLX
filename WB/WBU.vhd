library IEEE;
use IEEE.std_logic_1164.all;


-- mux 
entity WBU is
  	generic ( N: integer:= 32);           
	Port (ALU_OUT:	In	std_logic_vector(N-1 downto 0);	
		  LOAD:    in std_logic_vector (N-1 downto 0); 
          NPC_REG_in:  in std_logic_vector(N-1 downto 0);
          RT_REG_in: in std_logic_vector(N-1 downto 0);
          CW : in std_logic_vector(1 downto 0); --'JAL' & 'WB_mux'
          RF_ADDR : out std_logic_vector(N-1 downto 0);
          RF_DATA : out std_logic_vector(N-1 downto 0)
          );
end WBU;

architecture STRUCTURAL of WBU is
    --signals
    signal alu_lmd_s : std_logic_vector(N-1 downto 0);
    --components
    component mux21
        generic ( NBIT: integer:= 32);           
	    Port (A:	In	std_logic_vector(NBIT-1 downto 0);	
		      B:    in std_logic_vector (NBIT-1 downto 0); 
              sel:  in std_logic; 
	          muxout:	Out	std_logic_vector ((NBIT)-1 downto 0));
    end component;
begin
    --port map
    alu_lmd_mux : mux21
        generic map (NBIT => N)
        port map (
            A => ALU_OUT,
            B => LOAD,
            sel => CW(0),
            muxout => alu_lmd_s
        );

    addr_mux : mux21
        generic map (NBIT => N)
        port map (
            A => x"1F", --31 in hexadecimal
            B => RT_REG_in,
            sel => CW(1),
            muxout => RF_ADDR
        );

    data_mux : mux21
        generic map (NBIT => N)
        port map (
            A => NPC_REG_in, --31 in hexadecimal
            B => alu_lmd_s,
            sel => CW(1),
            muxout => RF_DATA
        );
end STRUCTURAL;