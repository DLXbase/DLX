library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_unsigned.all;
--use IEEE.std_logic_arith.all;
use ieee.numeric_std.all; 
use WORK.alu_type.all;

entity ALU is
  generic (N : integer := 32);
  port 	 ( FUNC: IN AluOp;  -- function to execute
           DATA1, DATA2: IN std_logic_vector(N-1 downto 0);
           OUTALU: OUT std_logic_vector(N-1 downto 0));
end ALU;

architecture BEHAVIOR of ALU is

	--signal shift_vec:  std_logic_vector (5 downto 0);
	signal tmp_sub : signed (N-1 downto 0);
	signal  zero: std_logic;
	

begin

	tmp_sub <= signed(DATA1)-signed(DATA2);
	zero <= '1' when (signed (tmp_sub)  = 0) else '0';


P_ALU: process (FUNC, DATA1, DATA2, tmp_sub, zero)
  -- complete all the requested function
  --variable tmp_sub : signed (31 downto 0);
  --variable zero: std_logic;

  begin
    case FUNC is
	when ADD 	=> OUTALU <= std_logic_vector(signed(DATA1) + signed (DATA2)); 
	when SUB 	=> OUTALU <= std_logic_vector(signed(DATA1) - signed (DATA2));
	when MULT 	=> OUTALU <= std_logic_vector(signed(DATA1(N/2-1 DOWNTO 0)) * signed(DATA2(N/2-1 DOWNTO 0)));
	when BITAND 	=> OUTALU <= DATA1 AND DATA2 ; -- bitwise operations
	when BITOR 	=> OUTALU <= DATA1 OR DATA2;
	when BITXOR 	=> OUTALU <=  DATA1 XOR DATA2;
	when FUNCLSL 	=> OUTALU <= std_logic_vector(shift_left(signed(DATA1), to_integer(unsigned(DATA2(4 downto 0)))));
	when FUNCRSL 	=> OUTALU <= std_logic_vector(shift_right(signed(DATA1), to_integer(unsigned(DATA2(4 downto 0)))));

	
	when SGE 		=>  
						if (tmp_sub(N-1) = '0')  or (zero = '1') then
							OUTALU <= std_logic_vector(to_unsigned(1, N));
						else
							OUTALU <= (others => '0');
						end if;
	when SLE		=> 
						if (tmp_sub (N-1) = '1')  or (zero = '1') then
							OUTALU <= std_logic_vector(to_unsigned(1, N));
						else
							OUTALU <= (others => '0');
						end if;
	--when FUNCRL 	=> OUTALU <= (DATA1(N-2 DOWNTO 0)&DATA1(N-1)); -- rotate left
	--when FUNCRR 	=> OUTALU <= (DATA1(0)&DATA1(N-1 DOWNTO 1)); -- roate right
	--when others => null;
    when others => OUTALU <= (others=>'0'); 
    end case; 
  end process P_ALU;

end BEHAVIOR;

