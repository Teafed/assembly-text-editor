//FREE NODES - this frees the memory for strings and nodes; make sure headPtr address is in x0
//subroutine node_free
//x0 contains address of headPtr

	.global node_free

	.text

node_free:

	str		x30, [sp, #-16]!		//push lr
	ldr		x0, [x0]				//load value of headPtr into x0

node_free_loop:

	cmp		x0, #0					//compare pointer value to null
	beq		node_free_exit			//if no more nodes exist, exit loop

	//free the malloc'd string
	str		x0, [sp, #-16]!			//push x0 momentarily
	ldr		x0, [x0]				//load value of pointer into x0
	bl		free					//free the memory!
	ldr		x0, [sp], #16			//pop x0 back into existence

	ldr		x19, [x0, #8]			//load x0 into x19 and move 8 bytes
	str		x19, [sp, #-16]!		//push x19 momentarily as well
	bl		free					//free the memory!
	ldr		x0, [sp], #16			//pop x19 into x0

	b		node_free_loop			//loop once again

node_free_exit:

	ldr		x30, [sp], #16			//pop lr
	ret		lr						//return. finally

.end
