library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg is
  GENERIC (N: integer );
  Port (clk,rst,en: in std_logic; 
        A: in std_logic_vector(N-1 downto 0);
        Y: out std_logic_vector(N-1 downto 0));
end reg;

architecture beh of reg is
begin
  
--ck proces 
  process (clk,en,rst,A)
          begin 
            if clk'event and clk = '1' then
              if en = '1' then
		if rst = '1' then Y <= (others => '0');
                else Y <= A;
                end if;
              end if;
            end if;
          end process;  
end beh;
