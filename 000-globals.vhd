library ieee;
use ieee.std_logic_1164.all;

--alu operations
package alu_type is
	type aluOp is (ADD, SUB, MULT, BITAND, BITOR, BITXOR, FUNCLSL, FUNCLSR, FUNCRSL, FUNCRR, SGE, SLE, SNE, aluNOP);
end alu_type;

--constants
package constants is 
	constant WORD_SIZE: integer := 32; 
	constant RF_SIZE: integer := 32; 
	constant RF_ADDR_SIZE: integer := 5; 
	constant CONTROL_WORD_SIZE: integer := 17; 
	constant OPCODE_SIZE: integer := 6; 
	constant FUNC_FIELD_SIZE: integer := 11; 
end constants; 


