library IEEE;
use IEEE.std_logic_1164.all;

-- check wether vector is zero 
entity is_zero is
  	generic ( NBIT: integer:= 32);           
	Port (A:	In	std_logic_vector(NBIT-1 downto 0);
          res:  out std_logic);       
end is_zero;


architecture beh of is_zero is 
--A is the signal on top in block diagrams or schematics. 
begin
 res <= '0' when (A = x"00000000") else
      '1'; 
end beh; 
