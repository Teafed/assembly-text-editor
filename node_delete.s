//subroutine node_delete - this removes a node from the linked list
//x0 contains headPtr
//x1 contains index to delete as unsigned int

//returned contents:
//x0 contains the total number of bytes deallocated

	.global node_delete

	.text

node_delete:

	stp		x29, x30, [sp, #-16]!//push x23, lr
	stp		x27, x28, [sp, #-16]!//push x21, x22
	stp		x21, x22, [sp, #-16]!//push x21, x22
	stp		x19, x20, [sp, #-16]!//push s19, x20
	mov		x29, x0					//keep original headPtr in x10

	mov		x18, x0					//put headPtr in x18
	mov		x19, x0					//put headPtr in x19
	mov		x20, x1					//put index in x20
	mov		x21, #0					//start counter at 0
	mov		x27, #0					//x27 is number of bytes deallocated

	//if head is null
	ldr		x19, [x19]				//load value of pointer into x19
	cbz		x19, node_delete_exit//if null, exit

	//if index < 0
	cmp		x20, #0					//compare index with 0
	blt		node_delete_exit		//branch to exit

	//if index == head
	cmp		x21, x20					//if index == 0
	beq		node_delete_0			//branch to null case handler

	//if index > 0
	b			node_delete_loop		//branch to loop


node_delete_0:

	//delete string
	ldr		x0, [x19]				//load that which holds the string
	mov		x28, x0
	bl			node_delete_string	//branch to delete malloc'd string

	//if head->next doesn't exist
	add		x0, x19, #8				//check next field
	ldr		x0, [x0]					//load address of head->next
	cbz		x0, node_delete_head	//branch if next doesn't exist

	//if head->next exists
	mov		x1, x29					//move headPtr into x1
	ldr		x2, [x1]					//load head->key address into x2

	str		x2, [sp, #-16]!		//push x2
	stp		x0, x1, [sp, #-16]!	//push x0, x1
	mov		x0, x2					//head->key address is in x0
	bl			free						//free that memory
	ldp		x0, x1, [sp], #16		//pop x0, x1
	ldr		x2, [sp], #16			//pop x2

	add		x27, x27, #16			//16 for node size


	//x0 contains head->next
	//x1 contains headPtr
	//x2 contains head->key

	str		x0, [x1]					//headPtr now holds head->next. good job!

	b			node_delete_exit		//branch to exit

	//delete head node
	//make headPtr point to saved register value

node_delete_loop:

	//x19 = current node
	//x20 = index
	//x21 = counter
	//x28 = prev node
	//x29 = next node

	cmp		x20, x21
	beq		node_found

	mov		x28, x19					//current node to prev node
	ldr		x29, [x19, #8]			//x29 is next node (to set to current)
	mov		x19, x29					//set to current node
	ldr		x29, [x19, #8]			//x29 is next node

	add		x21, x21, #1			//increment
	b			node_delete_loop		//loop again

node_found:

	str		x29, [x28, #8]			//store next in prev
	ldr		x0, [x19]				//load current node str address
	str		x0, [sp, #-16]!		//push
	bl			String_length			//get string length
	add		x27, x0, #1				//add 1 to length
	ldr		x0, [sp], #16			//pop

	bl			free						//freeeeee

	mov		x0, x19					//and also get node address in x0
	bl			free						//freeeeeee

	add		x27, x27, #16			//add node size as well

	b			node_delete_exit		//get outta here

node_delete_head:

	//me when there's only a head
//	bl			node_delete_string 	//branch to node_delete_string
	bl			node_delete_node		//branch to node_delete_node

	//clear headPtr
	mov		x0, #0					//put 0 in x0
	str		x0, [x29]				//put in headPtr

//	ldr		x0, [sp], #16			//string power!!!


node_delete_exit:

	mov		x0, x27					//bytes deallocated to x0

	ldp		x19, x20, [sp], #16	//pop x19, x20
	ldp		x21, x22, [sp], #16	//pop x21, x22
	ldp		x27, x28, [sp], #16	//pop x21, x22
	ldp		x29, x30, [sp], #16	//pop x23, lr

	ret		lr							//return to sender

node_delete_string:

	//free the malloc'd string
	stp		x0, x30, [sp, #-16]!	//push x0, lr
	ldr		x0, [x19]				//load value of pointer into x0

	//get length first
	str		x0, [sp, #-16]!		//malloc power!!!
	bl			String_length			//get length
	add		x0, x0, #1				//add 1 for null terminator
	mov		x22, x0					//move to x22
	ldr		x0, [sp], #16			//free power!!! me when i get two political sayings mixed up

	bl			free						//free the memory!
	ldp		x0, x30, [sp], #16	//pop x0, lr
	add		x27, x27, x22			//add that to x27

	ret		lr							//return

node_delete_node:

	//free node
	stp		x0, x30, [sp, #-16]!	//push x0, lr
	mov		x0, x19					//load value of pointer into x0
	bl			free						//free the memory!
	ldp		x0, x30, [sp], #16	//pop x0, lr

	add		x27, x27, #16			//16 for node size

	ret		lr							//return

.end


/*
node_delete_loop:


	cmp		x21, x20
	beq		node_found
	ldr		x18, [x18]
	add		x18, x18, #8
	add		x21, x21, #1

	b			node_delete_loop

node_found:

	ldr		x1, [x18]
	add		x1, x1, #8
	ldr		x2, [x1]
	str		x2, [x18]
	sub		x1, x1, #8

	mov		x17, x1
	ldr		x18, [x1]
	bl			free

	mov		x18, x17
	bl			free

	b			node_delete_exit		//branch to exit
*/
