library ieee;
use ieee.std_logic_1164.all;

--constants
package constants is 
	constant WORD_SIZE: integer := 32; 
	constant RF_SIZE: integer := 32; 
	constant RF_ADDR_SIZE: integer := 5; 
	 
	constant OPCODE_SIZE: integer := 6; 
	constant FUNC_FIELD_SIZE: integer := 11; 
	
	constant CONTROL_WORD_SIZE: integer := 19;
	constant CW_FETCH_SIZE : integer := 2; 
	constant CW_DU_SIZE : integer := 6;
	constant CW_EX_SIZE : integer := 6;
	constant CW_MEM_SIZE : integer := 2;
	constant CW_WB_SIZE : integer := 3;
	--19 = 2 + 6 + 6 + 2 + 3

end constants; 


