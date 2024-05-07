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

	//get original length
	str		x0, [sp, #-16]!		//push x0
	bl			String_length			//get string length
	mov		x1, x0					//put length in x1
	str		x0, [sp, #-16]!		//push original length as well

	//get new length
	mov		x0, x29					//put szBuffer into x0
	bl			String_length			//get string length
	add		x0, x0, #1				//add 1 for null terminator
	mov		x2, x0					//move into x2
	ldr		x1, [sp], #16			//pop original length into x1
	ldr		x0, [sp], #16			//pop malloc'd string address into x0

	sub		x1, x2, x1				//get difference of string length

	stp		x0, x1, [sp, #-16]!	//push x0, x1
	mov		x0, x29
	bl			String_copy
	ldp		x1, x2, [sp], #16		//pop malloc'd string and return length

	str		x2, [sp, #-16]!		//push return legnth

	ldr		x3, [x27]				//old string in x3
	str		x0, [x27]				//store new string

	mov		x0, x3					//old string to x0
	bl			free						//freeeeeeeeeeeeeeeeeeeeeeeeeee

	ldr		x2, [sp], #16			//pop return length

node_edit_exit:

	mov		x0, x2					//length difference from x0

	ldp		x27, x28, [sp], #16	//pop x27 and x28 from stack
	ldp		x29, x30, [sp], #16	//pop x29, lr from stack

	ret		lr

node_edit_last:

	b			node_edit_exit


.end
