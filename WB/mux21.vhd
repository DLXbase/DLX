library IEEE;
use IEEE.std_logic_1164.all;


-- mux 
entity mux21 is
  	generic ( NBIT: integer:= 32);           
	Port (A:	In	std_logic_vector(NBIT-1 downto 0);	
		  B:    in std_logic_vector (NBIT-1 downto 0); 
          sel:  in std_logic; 
	      muxout:	Out	std_logic_vector ((NBIT)-1 downto 0));
end mux21;


architecture beh of mux21 is 
--A is the signal on top in block diagrams or schematics. 
begin
 muxout <= A when (sel = '1') else
       B; 
end beh; 

