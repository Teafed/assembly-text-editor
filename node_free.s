//subroutine node_free - this frees the memory for strings and
// nodes; make sure headPtr address is in x0
//x0 contains address of headPtr
//returns nothing

	.global node_free

	.text

node_free:

	stp		x19, x30, [sp, #-16]!//push x19, lr
	str		x0, [sp, #-16]!		//push x0
	ldr		x0, [x0]					//load value of headPtr into x0

node_free_loop:

	cmp		x0, #0					//compare pointer value to null
	beq		node_free_exit			//if no more nodes exist, exit loop

	//free the malloc'd string
	str		x0, [sp, #-16]!		//push x0 momentarily
	ldr		x0, [x0]					//load value of pointer into x0
	bl			free						//free the memory!
	ldr		x0, [sp], #16			//pop x0 back into existence

	//go to next string
	ldr		x19, [x0, #8]			//load x0 into x19 and move 8 bytes
	str		x19, [sp, #-16]!		//push x19 momentarily as well
	bl			free						//free the memory!
	ldr		x0, [sp], #16			//pop x19 into x0

	b			node_free_loop			//loop once again

node_free_exit:

	//clear anything left in headPtr
	ldr		x0, [sp], #16			//pop headPtr
	str		x1, [sp, #-16]!		//push x1
	mov		x1, #0					//move 0 to x1
	str		x1, [x0]					//headPtr now doesn't point anywhere
	ldr		x1, [sp], #16			//pop headPtr
	ldp		x19, x30, [sp], #16	//pop x0, lr


	ret		lr							//return. finally

.end
