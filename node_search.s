//subroutine node_search - prints all strings in linked list that contain a string
//x0 contains headPtr
//x1 contains string address of what's being searched for

	.global node_search

	.data

//node data
iheadPtr:	.quad 0
itailPtr:	.quad 0
szIdx:		.skip 21					//buffer for printing index
dbHit:		.quad 0

//output strings
szOut1:		.asciz "Search \""
szOut2:		.asciz "\" ("
szOut3:		.asciz " hits in 1 file of 1 searched)\n"
szOut4:		.asciz "    Line "
szOut5:		.asciz ": "
chLF:			.byte 0xa

	.text

node_search:

	//push registers
	stp		x21, x30, [sp, #-16]!//push x21, lr
	stp		x19, x20, [sp, #-16]!//push x19, x20

	mov		x19, x0					//keep headPtr in x19
	mov		x20, x1					//keep search string in x20
	str		x0, [sp, #-16]!		//push headPtr for printing later

	mov		x21, #-1					//index counter in x21 initialized to -1

node_search_loop:

	add		x21, x21, #1			//increment index

	//check if next node exists and get node
	ldr		x0, [x19]				//load value of pointer into x19
	cmp		x0, #0					//check for empty list
	beq		search_loop_exit		//if so, exit loop

	ldr		x0, [x19]				//load value of pointer into x19
	ldr		x0, [x0]					//double-dereference
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
	bl			String_toLowerCase	//s1 to lower
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
	beq		node_search_add_index//print full string if match

	ldp		x1, x2, [sp], #16		//pop original strings
	ldr		x19, [x19]				//double-dereference
	add		x19, x19, #8			//jump x1 -> next field

	mov		x0, x1					//put s1 back into x0
	mov		x1, x2					//put s2 back into x1
	b			node_search_loop		//loop again

//add indexes of found values into a linked list
node_search_add_index:

	mov		x0, #21					//put 21 bytes to malloc into x0
	bl			malloc					//malloc 21 bytes
	str		x21, [x0]				//put index into new address
	ldr		x1, =itailPtr			//put tail ptr in x1
	ldr		x2, =iheadPtr			//put head ptr in x2
	bl			node_insert				//insert index into linked list

	//increment hit count
	ldr		x1, =dbHit				//load address of dbHit into x0
	ldr		x0, [x1]					//load value of dbHit
	add		x0, x0, #1				//increment
	str		x0, [x1]					//store into dbHit

	ldp		x1, x2, [sp], #16		//pop original strings

	ldr		x19, [x19]				//double-dereference
	add		x19, x19, #8			//jump x1 -> next field
	mov		x0, x1					//put s1 back into x0
	mov		x1, x2					//put s2 back into x1
	b			node_search_loop		//loop again

search_loop_exit:

	str		x1, [sp, #-16]!		//push s2

	//print smth like Search "toMorrow" (3 hits in 1 file of 1 searched)
	ldr		x0, =szOut1				//load address of szOut1 into x0
	bl			putstring				//print

	ldr		x0, [sp], #16			//pop back s2 to x0
	bl			putstring				//print search term

	ldr		x0, =szOut2				//load address of szOut2 into x0
	bl			putstring				//print

	ldr		x0, =dbHit				//load address of dbHit into x0
	ldr		x0, [x0]					//load value of dbHit into x0
	ldr		x1, =szIdx				//load address of szIdx into x1
	bl			int64asc					//convert address of szIdx into x0
	ldr		x0, =szIdx				//load address of szIdx into x0
	bl			putstring				//print index

	ldr		x0, =szOut3				//load address of szOut3 into x0
	bl			putstring				//print

	ldr		x1, [sp], #16 			//bring string headPtr into x0

	//only print if there were any hits
	ldr		x0, =dbHit				//load address of dbHit into x0
	ldr		x0, [x0]					//load value into x0
	cmp		x0, #0					//compare hits with 0
	beq		node_search_exit		//ignore printing if no hits

	mov		x0, x1					//move string headPtr into x0
	mov		x1, #2					//put 2 into x1 (line mode)
	ldr		x2, =iheadPtr			//load headPtr into x2

	bl			node_print				//branch to node_print

node_search_exit:

	//free memory for index linked list
	str		x0, [sp, #-16]!		//push x0 for a bit
	ldr		x0, =iheadPtr			//load address of headPtr into x0
	bl			node_free				//free memory

	//reset dbHit count
	ldr		x1, =dbHit				//load address of dbHit into x1
	mov		x0, #0					//put 0 in x0
	str		x0, [x1]					//store 0 into dbHit

	ldr		x0, [sp], #16			//pop back x0

	//pop registers
	ldp		x19, x20, [sp], #16	//pop x19, x20
	ldp		x21, x30, [sp], #16	//pop x21, lr

	ret		lr							//return to sender

/*
//reminder: in this section we're not operating on the main linked list,
// we're searching through the linked list of found indexes. the memory
// allocated to the found indexes gets freed once node_search concludes
//
node_search_print:
//
	ldr		x20, [sp], #16			//pop main headPtr into x20
	stp		x19, x30, [sp, #-16]!//push x19, lr
	mov		x19, x0					//keep headPtr in x19
//
node_search_print_loop:
//
	//get next node, break if null
	ldr		x19, [x19]				//load value of pointer into x19
	cmp		x19, #0					//check for empty list
	beq		node_search_print_loop_exit //lol
//
	//print index
	ldr		x0, =szOut4				//load address of szOut4 into x0
	bl			putstring				//print szOut4
	ldr		x0, [x19]				//double-dereference
	ldr		x1, =szIndex			//load address of szIndex into x0
	bl			int64asc					//convert address of szIndex into x0
	ldr		x0, =szIndex			//load address of szIndex into x0
	bl			putstring				//print index
	ldr		x0, =szOut5				//load address of szOut5 into x0
	bl			putstring				//print szOut5
//
	//call node_at_index
	mov		x0, x20					//move address of main headPtr into x0
	ldr		x1, [x19]				//move value of pointer into x1
	bl			node_at_index			//return contents of node at index
	cmp		x0, #-1					//make sure it exists
	beq		node_search_print_loop //
	bl			putstring				//print that string
//
	//new line and jump to next field
	ldr		x0, =chLF				//load chLF address into x0
	bl			putch						//print new line
	add		x19, x19, #8			//bitshift by 8
	b			node_search_print_loop //loop again
//
node_search_print_loop_exit:
//
	ldp		x19, x30, [sp], #16	//pop x19, lr
	b			node_search_exit
//
.end
*/
/* [2024-04-29 21:45:31] boring print option
	//print index
	ldr		x0, =szOut1				//load address of szOut1 into x0
	bl			putstring				//print
//
	mov		x0, x21					//put index into x0
	ldr		x1, =szIndex			//load address of szIndex into x0
	bl			int64asc					//convert index into string
	ldr		x0, =szIndex			//load address of szIndex into x0
	bl			putstring				//print index
//
	ldr		x0, =szOut2				//load address of szOut2 into x0
	bl			putstring				//print
//
	//print found string
	ldr		x0, [x19]				//double-dereference
	bl			putstring				//print matched line
*/
//
//
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
//
	stp		x0, x1, [sp, #-16]!		//push x0, x1
	bl		String_contains			//branch and link to String_contains
	mov		x21, x0					//save answer in x21
//
	//free memory
	ldp		x0, x1, [sp], #16		//pop int x1, x2
	str		x1, [sp, #-16]!			//push x1
	bl		free					//free memory
	ldr		x0, [sp], #16			//pop into x0
	bl		free					//free memory
	mov		x0, x21					//move answer back to x0
*/
