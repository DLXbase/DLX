library IEEE;
use IEEE.std_logic_1164.all;
use work.constants.all; 

-- EXTEND 16 BIT VECTOR TO 32 BIT WHILE MAINTAINING THE SIGN
entity sign_extend is
  	generic ( NBIT: integer:= WORD_SIZE/2);           
	Port (A:	In	std_logic_vector(NBIT-1 downto 0);	
	      res:	Out	std_logic_vector ((2*NBIT)-1 downto 0));
end sign_extend;


architecture beh of sign_extend is

signal tmp_msb : std_logic_vector(NBIT-1 downto 0); 

begin
  tmp_msb <= (others => A(NBIT-1)); 
  res <= tmp_msb & A; 
end beh; 

