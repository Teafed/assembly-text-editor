//String_copy mallocs enough bytes and copies the source string
//	into the newly allocated memory. Returns the address of the
//	newly allocated string in x0.
//x0: holds the address to the first byte of a valid c-string
//lr: contains the return address

//returned register contents: Address of the first byte of
//	newly copied string
//all aapcs registers are preserved
//x1, x2, x3, and w4 are utilized and not preserved

	.data

	.global String_copy

	.text

String_copy:

	//AAPCS registers are preserved due to not being used

	stp		x19, x20, [sp, #-16]!		//push
	stp		x21, x22, [sp, #-16]!		//push
	stp		x23, x24, [sp, #-16]!		//push
	stp		x25, x26, [sp, #-16]!		//push
	stp		x27, x28, [sp, #-16]!		//push
	stp		x29, x30, [sp, #-16]!		//push
	str		x0, [sp, #-16]!				//push source address onto stack

	bl			String_length					//get amount of bytes needed
	add		x0, x0, #1						//add space for null
	str		x0, [sp, #-16]!				//push length onto stack

	bl			malloc							//allocate the memory
	mov		x1, #0
	strb		w1, [x0]
	ldr		x1, [sp], #16					//pop length into x1
	ldr		x2, [sp], #16					//pop source address into x2
	mov		x3, x0							//copy destination string address

	//x1 points to first digit of source string
	//x2 has the number of iterations
	//x3 points to the first digit of destination string

top_loop:

	cmp		x1, #0						// while (count != 0)
	beq		exit_loop					// {
	ldrb	w4, [x2], #1				//		w4 = srcStr[count]
	strb	w4, [x3], #1				//		dstStr[count] = w4
	sub		x1, x1, #1					//		x1--
	b		top_loop					// }

exit_loop:

	ldp		x29, x30, [sp], #16			//pop
	ldp		x27, x28, [sp], #16			//pop
	ldp		x25, x26, [sp], #16			//pop
	ldp		x23, x24, [sp], #16			//pop
	ldp		x21, x22, [sp], #16			//pop
	ldp		x19, x20, [sp], #16			//pop

	ret		lr

.end
