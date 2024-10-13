library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.math_real.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;
use work.constants.all; 

entity reg_file is
  GENERIC (NBIT: integer:=WORD_SIZE;
           NREG: integer:= RF_SIZE;
           NADDR: integer:= RF_ADDR_SIZE);
  Port (clk,rst,wr_en: in std_logic; 
        add_rd1: in std_logic_vector(NADDR-1 downto 0);
        add_rd2: in std_logic_vector(NADDR-1 downto 0);
        add_wr: in std_logic_vector(NBIT-1 downto 0);
        datain: in std_logic_vector(NBIT-1 downto 0);
        out2: out std_logic_vector(NBIT-1 downto 0);
        out1: out std_logic_vector(NBIT-1 downto 0));
end reg_file;

architecture beh of reg_file is
  
  subtype REG_ADDR is natural range 0 to NREG-1; -- using natural type
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(NBIT-1 downto 0); 
	signal regs,regs_nxt : REG_ARRAY; 
begin


--clk proces 
  process (clk,rst)
          begin 
            if clk'event and clk = '1' then
		        if rst = '1' then 
					regs <= (others => (others =>'0'));
                else 
					regs <= regs_nxt;
                end if;
            end if; 
          end process;
          
-- comb process;
   process(wr_en,add_wr,datain,rst)
     begin
		   --regs_nxt <= regs;
       if rst = '1' then regs_nxt <= (others => (others =>'0'));
       else
        if wr_en = '1' then regs_nxt(to_integer(unsigned(add_wr))) <= datain;
        end if; 
      end if;
    end process; 

out1 <= regs(to_integer(unsigned(add_rd1)));
out2 <= regs(to_integer(unsigned(add_rd2))); 


end beh; 

