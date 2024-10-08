library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic

entity AND2 is
	Port (	a,b:	In	std_logic;
		    y:	Out	std_logic);
end AND2;


architecture BEHAVIORAL of AND2 is

begin
	Y <= a and b;
end BEHAVIORAL;

