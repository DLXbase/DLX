library ieee;
use ieee.std_logic_1164.all;

--constants
package constants is 
	constant WORD_SIZE: integer := 32; 
	constant RF_SIZE: integer := 32; 
	constant RF_ADDR_SIZE: integer := 5; 
	constant CONTROL_WORD_SIZE: integer := 17; 
	constant OPCODE_SIZE: integer := 6; 
	constant FUNC_FIELD_SIZE: integer := 11; 
end constants; 


