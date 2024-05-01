//subroutine node_at_index.s - given an index, returns the node contents at that index
//x0 contains address of headPtr
//x1 contains requested index as an unsigned int

//returned contents:
//x0 contains the node at that index. if not found, returns -1

	.global node_at_index

	.text

node_at_index:

	str		x30, [sp, #-16]!		//push lr to stack
	stp		x19, x20, [sp, #-16]!//push x19 and x20 to stack
	mov		x19, x0					//keep headPtr in x19
	mov		x20, x1					//keep index in x20

	mov		x1, #-1					//x1 has index counter init to -1
	mov		x0, #-1					//x0 has return value init to -1

	//check if negative
	cmp		x20, #0					//compare index and 0
	blt		node_at_index_exit	//branch to exit

node_at_index_loop:

	add		x1, x1, #1				//increment index counter

	//get next node, break if null
	ldr		x19, [x19]				//load value of pointer into x0
	cmp		x19, #0					//check for empty list
	beq		node_at_index_exit	//if so, exit loop

	//check if we're at the right index
	cmp		x1, x20					//cmp index counter and given index
	beq		node_at_index_found	//branch to found label

	//jump to next field
	add		x19, x19, #8			//bitshift by 8
	b			node_at_index_loop	//loop again

node_at_index_found:

	ldr		x0, [x19]				//load pointer key into x0

node_at_index_exit:

	ldp		x19, x20, [sp], #16	//pop x19 and x20 from stack
	ldr		x30, [sp], #16			//pop lr from stack

	ret		lr

.end
