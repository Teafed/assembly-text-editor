/*
 * Subroutine String_contains: Provided two pointers to null-terminated
 *	strings, String_contains will return 1 (true) to x0 if any part of
 *	string 1 contains string 2 (ignoring case), or 0 (false) if not
 * x0: Must point to the full null-terminated string
 * x1: Must point to a null-terminated string to match with the start of string 1
 * LR: Must contain the return address
 *
 * Returned register contents:
 *	x0: int byte result
 *	x1: full string (originally in x0)
 *	x2: string to search (originally in x1)
 * All registers are preserved except x0
 */
	.global String_contains

	.text

String_contains:

	str		x30, [sp, #-16]!		//push x30 onto stack
	stp		x19, x20, [sp, #-16]!//push s1 and s2 onto stack
	mov		x19, x0					//s1 goes in x19
	mov		x20, x1					//s2 goes in x20

//check if s2.length > s1.length
	stp		x0, x1, [sp, #-16]!	//push s1 and s2 onto stack
	bl			String_length			//get s1.length

	ldp		x1, x2, [sp], #16		//pop s1 and s2 from stack
	mov		x3, x0					//move s1.length to x3
	str		x2, [sp, #-16]!		//push s2 to stack
	mov		x0, x2					//move s2 to x0
	stp		x1, x3, [sp, #-16]!	//push s1 and s1.length onto stack
	bl			String_length			//get s2.length

	ldp		x1, x3, [sp], #16		//pop s1 and s1.length from stack
	ldr		x4, [sp], #16			//pop s2 from stack
	sub		x3, x3, x0				//x3 contains s1.length - s2.length
	cmp		x3, #0					//compare search size to 0
	blt		no_match					//if s2.length > s1.length, exit

	mov		x0, x1					//s1 goes into x0
	mov		x1, x2					//move s2 to x1
	mov		x4, #0					//x4 = 0

	//x0 = s1
	//x1 = s2
	//x3 = size
	//x4 = index

contains_loop:

	//for each call, the start index of s1 gets incremented by 1
	stp		x0, x1, [sp, #-16]!	//push s1 and s2 onto stack
	bl			String_startsWith_2	//check if strings start the same
	mov		x2, x0					//put answer in x2
	ldp		x0, x1, [sp], #16		//pop x0 and x1 from stack
	cmp		x2, #1					//compare substrings
	beq		exit_loop				//if return true, go to match_found

	cmp		x4, x3					//compare index and size
	bge		no_match					//end of string, can't search any more

	add		x0, x0, #1				//if not add 1 to the full string address

	add		x4, x4, #1				//increment index
	b			contains_loop			//loop again

no_match:

	mov		x2, #0					//return false to x0

exit_loop:

	mov		x0, x2					//put answer into x0
	mov		x1, x19					//put s1 into x1
	mov		x2, x20					//put s2 into x2
	ldp		x19, x20, [sp], #16	//pop x0 and x1 from stack
	ldr		x30, [sp], #16			//pop x30 from stack

	ret		lr							//return to sender

.end
