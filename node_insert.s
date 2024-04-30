//subroutine node_insert
//x0 must contain malloc'd heap address
//x1 contains address of tailPtr
//x2 contains address of headPtr

	.global node_insert

	.text

node_insert:

	//save registers to stack
	stp		x19, x30, [sp, #-16]!//push x19, lr
	stp		x21, x22, [sp, #-16]!//push x21, x22

	mov		x19, x0					//keep heap address in x19
	mov		x21, x1					//keep tailPtr in x21
	mov		x22, x2					//keep headPtr in x22

	//get new node address
	str		x19, [sp, #-16]!		//push this x19 as well
	stp		x21, x22, [sp, #-16]!//and x21 and x22. just for a bit

	mov		x0, #16					//assign 16 bytes to be allocated
	bl			malloc					//allocate memory

	ldp		x21, x22, [sp], #16	//and x21 and x22. just for a bit
	ldr		x19, [sp], #16			//pop x19 - it now has the string address

	str		x19, [x0]				//x19 gets stored into the allocated memory

	mov		x1, x22					//move headPtr address into x1
	ldr		x1, [x1]					//load value of headPtr into x1

	//check if linked list is empty
	cmp		x1, #0					//compare x1 to null
	beq		insert_empty			//if so, branch to insert_empty

	//insert into list at the tail
	mov		x1, x21					//load tailPtr address into x1
	ldr		x1, [x1]					//load value of tailPtr into x1
	str		x0, [x1, #8]			//store the new node address at the tail 8 bytes forward

	mov		x1, x21					//load tailPtr address into x1
	str		x0, [x1]					//store x0 into tailPtr

	b			insert_exit				//branch to exit

insert_empty: //this is for if the list is empty

	mov		x1, x22					//put headPtr address into x1
	str		x0, [x1]					//store allocated memory address into x0

	mov		x1, x21					//put tailPtr address into x1
	str		x0, [x1]					//store allocated memory address into x0


insert_exit:

	ldp		x21, x22, [sp], #16	//push x21, x22
	ldp		x19, x30, [sp], #16	//push x19, lr

	ret		lr

.end
