library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- Compute PC+4
entity add4 is
  	generic ( NBIT: integer:= 32);           
	Port (A:	In	std_logic_vector(NBIT-1 downto 0);	
	      res:	Out	std_logic_vector (NBIT-1 downto 0));
end add4;


architecture beh of add4 is

begin
  --compute A+4; 
  res <= (std_logic_vector(unsigned(A)+4));
  
end beh; 


