library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder is
  	generic ( NBIT: integer:= 32);           
	Port (A:	In	std_logic_vector(NBIT-1 downto 0);
		  B:	in std_logic_vector(NBIT-1 downto 0);	
	      res:	Out	std_logic_vector (NBIT-1 downto 0));
end adder;


architecture beh of adder is

begin
  --compute A+4; 
  res <= std_logic_vector(signed(A)+signed(B));
  
end beh; 


