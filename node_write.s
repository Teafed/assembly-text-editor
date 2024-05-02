//subroutine node_write = writes all linked list contents to
//	a file.
//x0 contains address of headPtr
//x1 contains address of a filename string

	.global node_write

				.equ DFD, -100
				.equ FLAGS, 0101
				.equ MODE, 0660

	.data

chLF:			.byte 0xa

	.text

node_write:

	stp		x21, x30, [sp, #-16]!//push x21, lr
	stp		x19, x20, [sp, #-16]!//push x19, x20
	mov		x19, x0					//keep head in x19
	mov		x20, x1					//keep filename in x20

	//set up registers and call openat (nr 56)
	mov		x0, #DFD					//put dfd into x0
	mov		x1, x20					//put filename into x1
	mov		x2, #FLAGS				//put flags into x2
	mov		x3, #MODE				//put file perms into x3
	mov		x8, #56					//service code 56 calls openat
	svc		#0							//call system

	mov		x21, x0					//move file descriptor to x21

node_write_loop:

	//get next node, break if null
	ldr		x19, [x19]				//load value of pointer into x19
	cbz		x19, node_write_exit	//if null, exit loop
	ldr		x0, [x19]				//double-dereference key into x0

	//set up registers and call write (nr 64)
	mov		x1, x0					//put string address in x1
	bl			String_length			//get string length
	mov		x2, x0					//put string length into x2
	mov		x0, x21					//put dfd into x0
	mov		x8, #64					//service code 64 calls write
	svc		#0							//call system

	//write new line to file as well
	mov		x0, x21					//put dfd into x0
	ldr		x1, =chLF				//load new line to x1
	mov		x2, #1					//make space for 1 character
	svc		#0							//call system

//temp branch to see if just first string writes
//	b			node_write_exit

	//jump to next field
	add		x19, x19, #8			//bitshift by 8
	b			node_write_loop		//loop again

node_write_exit:

	//set up registers and call close (nr 57)
	mov		x0, x21					//bring file descriptor back to x0
	mov		x8, #57					//service code 57 calls close
	svc		#0							//call system

	ldp		x19, x20, [sp], #16	//pop x19, x20
	ldp		x21, x30, [sp], #16	//pop x21, lr

	ret		lr

.end
