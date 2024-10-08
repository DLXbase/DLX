library IEEE;
use IEEE.std_logic_1164.all;

-- check wether vector is zero 
entity is_zero is
  	generic ( NBIT: integer:= 32);           
	Port (A:	In	std_logic_vector(NBIT-1 downto 0);
            BEQZ_OR_BNEZ : in std_logic;
            res:  out std_logic);       
end is_zero;


architecture beh of is_zero is 
--A is the signal on top in block diagrams or schematics.
signal zeros : std_logic_vector(NBIT-1 downto 0) := (others => '0'); 
begin
      proc_zero : process(A, BEQZ_OR_BNEZ)
      begin
            if BEQZ_OR_BNEZ = '1' then
                  if A = zeros then
                        res <= '1';
                  else
                        res <= '0';
                  end if;
            else
                  if A = zeros then
                        res <= '0';
                  else
                        res <= '1';
                  end if;
            end if;
      end process proc_zero;
end beh; 
