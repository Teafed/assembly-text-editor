//subroutine node_print - prints all linked list contents to
// console. if x1 is equal to 2, then x2 must have a linked list
// of index nodes
//x0 contains address of headPtr
//x1 contains an int that specifies the output mode
//x2 (only if x1 == 2) contains the headPtr to linked list of indexes

//example outputs:

//default - x1 == 0
//The sun did not shine
//It was too wet to play.
//So we sat in the house
//All that cold, cold, wet day.

//index mode - x1 == 1
//    [4] The sun did not shine
//    [5] It was too wet to play.
//    [6] So we sat in the house
//    [7] All that cold, cold, wet day.

//line mode - x1 == 2 (used for search, line number is index + 1)
//    Line 777: "Tomorrow is Christmas! It's practically here!"
//    Line 780: For Tomorrow, he knew, all the Who girls and boys,
//    Line 965: Ask me tomorrow but not today.
//    Line 1166: Tomorrow is another one.

	.global node_print

	.data

szBuffer:	.skip 21 //for int64asc conversion
chLF:			.byte 0xa

//print index format
szIndex1:	.asciz "  ["
szIndex2:	.asciz "] "

//print line format
szLine1:		.asciz "    Line "
szLine2:		.asciz ": "

	.text

node_print:

	stp		x19, x20, [sp, #-16]!//push x19, x20
	stp		x21, x22, [sp, #-16]!//push x21, x22
	str		x30, [sp, #-16]!		//pop lr

	mov		x19, #0
	mov		x19, x0					//keep headPtr into x19
	mov		x22, x2					//put index head into x22

	mov		x21, #-1					//x21 is index counter init to -1

	cmp		x1, #1					//check if mode is 1
	beq		node_print_index		//if true, print keys as strings

	cmp		x1, #2					//check if mode is 2
	beq		node_print_line		//if true, print keys as line numbers

node_print_string:

	//get next node, break if null
	ldr		x19, [x19]				//load value of pointer into x19
	cmp		x19, #0					//check for empty list
	beq		node_print_exit		//if so, exit loop

	//get node key
	ldr		x0, [x19]				//double-dereference
	bl			putstring				//print string
	ldr		x0, =chLF				//load address of chLF into x0
	bl			putch						//print new line

	//jump to next field
	add		x19, x19, #8			//bitshift by 8
	b			node_print_string		//loop again

node_print_index:

	add		x21, x21, #1			//increment index

	//get next node, break if null
	ldr		x19, [x19]				//load value of pointer into x19
	cmp		x19, #0					//check for empty list
	beq		node_print_exit		//if so, exit loop

	//print index
	ldr		x0, =szIndex1			//load address of szIndex1 into x0
	bl			putstring				//print
	mov		x0, x21					//put index counter in x0
	ldr		x1, =szBuffer			//load address of szBuffer into x1
	bl			int64asc					//convert to ascii
	ldr		x0, =szBuffer			//load address of szBuffer into x0
	bl			putstring				//print string
	ldr		x0, =szIndex2			//load address of szIndex2 into x0
	bl			putstring				//print

	//print node key
	ldr		x0, [x19]				//double-dereference
	bl			putstring				//print string
	ldr		x0, =chLF				//load address of chLF into x0
	bl			putch						//print new line

	//jump to next field
	add		x19, x19, #8			//bitshift by 8

	b			node_print_index		//loop again

node_print_line:

	add		x21, x21, #1			//increment index

	//is the next key in the index list null?
	ldr		x0, [x22]				//load value of pointer into x22
	cbz		x0, node_print_exit	//if so, exit loop

	//is the next key in the string list null?
	ldr		x0, [x19]				//load value of pointer into x19
	cbz		x0, node_print_exit	//if so, exit loop

	//is the next key in the index list equal to the counter?

	//does this one instruction always load the key or do i need the second ldr?
	ldr		x0, [x22]				//load address of index node
	ldr		x0, [x0]					//load key address of index node
	ldr		x0, [x0]					//load key of index node
	cmp		x0, x21					//compare index and counter
	bne		node_print_line_skip //branch to node_print_line_skip

	//print line
	ldr		x0, =szLine1			//load address of szLine1 into x0
	bl			putstring				//print
	ldr		x0, [x22]				//dereference
	ldr		x0, [x0]					//double-dereference
	ldr		x0, [x0]					//load key value of index node
	add		x0, x0, #1				//change index to line number
	ldr		x1, =szBuffer			//load address of szBuffer into x1
	bl			int64asc					//convert to ascii
	ldr		x0, =szBuffer			//load address of szBuffer into x0
	bl			putstring				//print string
	ldr		x0, =szLine2			//load address of szLine2 into x0
	bl			putstring				//print

	//get string at index
	ldr		x0, [x19]				//load node address
	ldr		x0, [x0]					//double-dereference
	bl			putstring				//print string
	ldr		x0, =chLF				//load address of chLF into x0
	bl			putch						//print new line

	//jump to next field
	ldr		x22, [x22]				//dereference
	add		x22, x22, #8			//bitshift by 8
	ldr		x19, [x19]				//dereference
	add		x19, x19, #8			//bitshift by 8
	b			node_print_line		//loop again

node_print_line_skip:

	//only jump string linked list to next field
	ldr		x19, [x19]				//dereference
	add		x19, x19, #8			//bitshift by 8
	b			node_print_line		//loop again

node_print_exit:

	ldr		x30, [sp], #16			//pop lr
	ldp		x21, x22, [sp], #16	//pop x21, x22
	ldp		x19, x20, [sp], #16	//pop x19, x21

	ret		lr							//return to sender

.end
