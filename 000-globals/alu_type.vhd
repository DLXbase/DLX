--alu operations
package alu_type is
	type aluOp is (ADD, SUB, MULT, BITAND, BITOR, BITXOR, FUNCLSL, FUNCRSL, SGE, SLE, SNE, aluNOP);
end alu_type;