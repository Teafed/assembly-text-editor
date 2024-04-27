//subroutine node_print - prints all linked list contents to console
//x0 contains address of headPtr

	.global node_print

	.text

node_print:

	str		x19, [sp, #-16]!		//push x19
	str		x30, [sp, #-16]!		//push lr
	mov		x19, x0					//keep headPtr into x19

node_print_top:

	ldr		x19, [x19]				//load value of pointer into x19
	cmp		x19, #0					//check for empty list
	beq		node_print_exit			//if so, exit loop

	ldr		x0, [x19]				//double-dereference
	bl		putstring				//print string

	add		x19, x19, #8			//jump x1 -> next field
	b		node_print_top			//loop again

node_print_exit:

	ldr		x30, [sp], #16			//pop lr
	ldr		x19, [sp], #16			//pop x19
	ret		lr						//return to sender

.end
