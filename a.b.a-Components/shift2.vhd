library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;

entity SHIFT2 is
	generic(N: integer := 32);
	Port(en : in std_logic;
		A : in std_logic_vector(N-1 downto 0);
		Y : out std_logic_vector(N-1 downto 0)
		);
end SHIFT2;

architecture behavioral of SHIFT2 is
begin
	sh2: process (en, A)
		begin
			if en = '1' then
				Y <= std_logic_vector(shift_left(signed(A),2));
			else 
				Y <= A;
			end if;
	end process sh2;

end behavioral;
