//subroutine node_edit.s - given an index, the node contents get edited
//x0 contains address of headPtr
//x1 contains requested index as an unsigned int
//x2 contains szBuffer to be allocated

//returned contents:
//x0 contains number of bytes added or deleted

	.global node_edit

	.text

node_edit:

	stp		x29, x30, [sp, #-16]!//push x29, lr to stack
	stp		x27, x28, [sp, #-16]!//push x27 and x28 to stack
	mov		x27, x0					//keep headPtr in x27
	mov		x28, x1					//keep index in x28
	mov		x29, x2					//x29 has new string

	//check if negative
	cmp		x28, #0					//compare index and 0
	blt		node_edit_exit			//branch to exit

	mov		x1, #-1					//x1 has index counter init to -1
	mov		x2, #0					//x0 has return value init to 0

	//x1 = counter
	//x2 = memory change
	//x27 = headPtr
	//x28 = index
	//x29 = szBuffer

node_edit_lookup:

	//find node at index

	add		x1, x1, #1				//increment index counter

	//get next node, break if null
	ldr		x27, [x27]				//load value of pointer into x0
	cmp		x27, #0					//check for empty list
	beq		node_edit_exit			//if so, exit loop

	//check if we're at the right index
	cmp		x1, x28					//cmp index counter and given index
	beq		node_edit_found		//branch to found label

	//jump to next field
	add		x27, x27, #8			//bitshift by 8
	b			node_edit_lookup		//loop again

node_edit_found:

	//get address to change
	str		x0, [sp, #-16]!		//push current node

	//get original length
	str		x0, [sp, #-16]!		//push x0
	bl			String_length			//get string length
	mov		x1, x0					//put length in x1
	str		x0, [sp, #-16]!		//push original length as well

	//get new length
	mov		x0, x29					//put szBuffer into x0
	bl			String_length			//get string length
	mov		x2, x0					//move into x2
	ldr		x1, [sp], #16			//pop original length into x1
	ldr		x0, [sp], #16			//pop malloc'd string address into x0

	sub		x1, x2, x1				//get difference of string length

	//get new malloc'd address

	//x0 has address to free
	//x1 has length difference
	//x2 has new string length
	add		x2, x2, #1				//add 1 to new length for null terminator
	stp		x0, x1, [sp, #-16]!	//push address to free, difference
	mov		x0, x2					//move length to x0
	bl			malloc					//allocate memory
	ldp		x1, x2, [sp], #16		//bring back

	//x0 has new address
	//x1 has address to free
	//x2 has length difference

	//make a copy and put into new address
	stp		x0, x1, [sp, #-16]!	//push new address, address to free
	str		x2, [sp, #-16]!		//push length difference as well
	mov		x0, x29					//put szBuffer in x0
	bl			String_copy				//copy szBuffer
	ldr		x3, [sp], #16			//pop length difference
	ldp		x1, x2, [sp], #16		//bring back

	//x0 has new copy address
	//x1 has new key address
	//x2 has address to free
	//x3 has length difference

	//push address to free
	ldr		x4, [x27]				//get old address from x27
	stp		x4, x3, [sp, #-16]!	//push address to free and diff

	str		x0, [x27]				//store copy address into key address
//	str		x1, [x27]

	ldp		x1, x2, [sp], #16		//pop address to free, diff

	ldr		x5, [sp], #16			//pop head
//?str		x27, [x5]


	str		x2, [sp, #-16]!		//push length difference
	mov		x0, x1					//move dead address to x0 to free it
	bl			free						//hooray
	ldr		x2, [sp], #16			//pop length difference

node_edit_exit:

	mov		x0, x2					//length difference from x0

	ldp		x27, x28, [sp], #16	//pop x27 and x28 from stack
	ldp		x29, x30, [sp], #16	//pop x29, lr from stack

	ret		lr

node_edit_last:

	b			node_edit_exit


.end
