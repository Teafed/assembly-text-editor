//subroutine node_search - prints all strings in linked list that contain a string
//x0 contains headPtr
//x1 contains string address of what's being searched for

	.global node_search

	.data
szOut1:		.asciz "    Line "
szOut2:		.asciz ": "
szIndex:		.skip 21

	.text

node_search:

	//push registers
	str		x30, [sp, #-16]!		//push lr
	stp		x19, x20, [sp, #-16]!//push x19, x20

	mov		x19, x0					//keep headPtr into x19
	mov		x20, x1					//keep search string in x20
	stp		x0, x1, [sp, #-16]!	//push x0, x1

	mov		x21, #-1					//index counter in x21 initialized to 0

node_search_loop:

	add		x21, x21, #1				//increment index

	//check and get next node
	ldr		x19, [x19]				//load value of pointer into x19
	cmp		x19, #0					//check for empty list
	beq		node_search_exit		//if so, exit loop

	ldr		x0, [x19]				//double-dereference
	mov		x1, x20					//bring back search string
	stp		x0, x1, [sp, #-16]!	//push x0, x1

	//get copies of the strings
	str		x1, [sp, #-16]!		//push s2
	bl			String_copy				//get copy of s1
	mov		x1, x0					//put s1 copy into x1
	ldr		x0, [sp], #16			//bring back s2 into x0
	str		x1, [sp, #-16]!		//push s1 copy
	bl			String_copy				//get copy of s2
	mov		x1, x0					//put s2 copy back into x1
	ldr		x0, [sp], #16			//pop back s1 copy to x0

	//convert copies to lowercase
	str		x1, [sp, #-16]!		//push s2 copy
	bl			String_toLowerCase		//s1 to lower
	mov		x1, x0					//put lc s1 into x1
	ldr		x0, [sp], #16			//bring back s2 copy into x0
	str		x1, [sp, #-16]!		//push lc s1
	bl			String_toLowerCase	//s2 to lower
	mov		x1, x0					//put lc s2 back into x1
	ldr		x0, [sp], #16			//pop back lc s1 to x0

	stp		x0, x1, [sp, #-16]!	//push both lc strings to stack
	bl			String_contains		//branch to String_contains
	ldp		x1, x2, [sp], #16		//pop strings into x1 and x2
	str		x0, [sp, #-16]!		//push answer to stack

	//free memory of lc strings
	str		x2, [sp, #-16]!		//push s2
	mov		x0, x1					//put s1 in x0
	bl			free						//free the memory!
	ldr		x0, [sp], #16			//pop back s2 to x0
	bl			free						//free the memory

	ldr		x0, [sp], #16			//pop answer from stack

	cmp		x0, #1					//must return true to print line
	beq		node_search_print		//print full string if match

	ldp		x1, x2, [sp], #16		//pop original strings
	add		x19, x19, #8			//jump x1 -> next field
	mov		x0, x1					//put s1 back into x0
	mov		x1, x2					//put s2 back into x1
	b			node_search_loop		//loop again

node_search_print:

	//print index
	ldr		x0, =szOut1				//load address of szOut1 into x0
	bl			putstring				//print

	mov		x0, x21					//put index into x0
	ldr		x1, =szIndex			//load address of szIndex into x0
	bl			int64asc					//convert index into string
	ldr		x0, =szIndex			//load address of szIndex into x0
	bl			putstring				//print index

	ldr		x0, =szOut2				//load address of szOut2 into x0
	bl			putstring				//print

	//print found string
	ldr		x0, [x19]				//double-dereference
	bl			putstring				//print matched line
	ldp		x1, x2, [sp], #16		//pop original strings

	add		x19, x19, #8			//jump x1 -> next field
	mov		x0, x1					//put s1 back into x0
	mov		x1, x2					//put s2 back into x1
	b			node_search_loop		//loop again

node_search_exit:

	//pop registers
	ldp		x0, x1, [sp], #16		//pop original strings
	ldp		x19, x20, [sp], #16	//pop x19, x20
	ldr		x30, [sp], #16			//pop lr

	ret		lr							//return to sender

.end


/*	wait i have a better idea. better just put this code right here and never use it again!
	//call String_toLowerCase for both strings, and make sure they're not modifying the originals
	str		x1, [sp, #-16]!			//push s2 to save
	bl		String_toLowerCase		//s1 to lower
	mov		x2, x0					//put into x2 for a moment
	ldr		x0, [sp], #16			//pop s2 int x0
	str		x2, [sp, #-16]!			//push lc s1
	bl		String_toLowerCase		//s2 to lower
	mov		x1, x0					//put lc s2 into x1
	ldr		x2, [sp], #16			//pop lc s1 into x0

	stp		x0, x1, [sp, #-16]!		//push x0, x1
	bl		String_contains			//branch and link to String_contains
	mov		x21, x0					//save answer in x21

	//free memory
	ldp		x0, x1, [sp], #16		//pop int x1, x2
	str		x1, [sp, #-16]!			//push x1
	bl		free					//free memory
	ldr		x0, [sp], #16			//pop into x0
	bl		free					//free memory
	mov		x0, x21					//move answer back to x0
*/
