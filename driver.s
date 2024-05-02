	.global _start

			// File .equs
			.equ NODE_SIZE,	16
			.equ BUFFER, 		31
			.equ MAX, 			30
			.equ AT_FDCWD,		-100		// Local directory
			.equ R,				0			// Read only (int flags)
			.equ RW_______,	0600		// Owner has Read and write permissions

	.data

//pointers, buffers, etc
headPtr:			.quad 0					//head pointer
tailPtr:			.quad 0					//tail pointer
newNodePtr:		.quad 0					// Holds new node ptr
currentPtr:		.quad 0					// Holds current ptr
dbBuffer:		.quad 0					//to hold temp nums
dbNodeCounter:	.quad 0					//holds amount of nodes
dbHeapSize:		.quad 0					//holds total size of heap
szBuffer:		.skip BUFFER			//to hold temp strings
fileBuffer:		.skip 512				// Buffer for file
bFD:				.byte 0					// A singular byte
chLF:				.byte 0x0a				//new line
szClear:			.asciz "\033[2J"		//ANSI escape code for clearing the screen

//header
szHeader1:		.asciz "\n             RASM-4 TEXT EDITOR\n"
szHeader2a:		.asciz "      Data Structure Heap Memory Consumption: "
szHeader2b:		.asciz " bytes\n"
szHeader3:		.asciz "      Number of Nodes: "

//menu
szMenu1:			.asciz "\n<1> View all strings\n\n"
szMenu2:			.asciz "<2> Add string\n"
szMenu2a:		.asciz "    <a> from keyboard\n"
szMenu2b:		.asciz "    <b> from file. Static file named input.txt\n\n"
szMenu3:			.asciz "<3> Delete string. Given an index #, delete the entire string and deallocate memory (including the node).\n\n"
szMenu4:			.asciz "<4> Edit string. Given an index #, replace old string with new string. allocate/deallocate as needed.\n\n"
szMenu5:			.asciz "<5> String search. Regardless of case, return all strings that match the substring given.\n\n"
szMenu6:			.asciz "<6> Save file (output.txt)\n\n"
szMenu7:			.asciz "<7> Quit\n\n\n>  "

//other strings
szWait:			.asciz "\nPress enter to continue..."
szSearch1:		.asciz "Search for: "
szIndex:			.asciz "Enter an index: "				// User is prompted for a string's index to delete
szInput:			.asciz "Input: "							// User is prompted for new string to add to list
szGetIFile:		.asciz "Enter input file name: "		// Prompt user for file name
szGetOFile:		.asciz "Enter output file name: "	//prompt user for output file name
szEOF:			.asciz "Reached the end of file\n"	// Tells user input file ends
szError:			.asciz "FILE READ ERROR\n"				// Tells if error when reading
szWrite1:		.asciz "Writing strings to "
szWrite2:		.asciz "...\n"
szWrite3:		.asciz "Successfully wrote to "

//testing
str1:			.asciz "sce"
str2:			.asciz "y"
str3:			.asciz "r"
str4:			.asciz "\"did you make the tony stark face?\""
str5:			.asciz "he doesn't know what you're talking about. no one does. you never leave the house again"

	.text

_start:
/*
//add temp strings
	ldr		x0, =str1
	bl			String_copy
	ldr		x1, =tailPtr
	ldr		x2, =headPtr
	bl			node_insert

	//update heap size and node counter
	ldr		x2, =dbHeapSize		//load address of dbHeapSize into x1
	ldr		x1, [x2]					//load value of dbHeapSize into x1
	add		x0, x0, x1				//add to dbHeapSize
	str		x0, [x2]					//store in dbHeapSize

	ldr		x1, =dbNodeCounter	//load address of dbNodeCounter into x0
	ldr		x0, [x1]					//load value of dbNodeCounter into x1
	add		x0, x0, #1				//increment by 1
	str		x0, [x1]					//store in dbNodeCounter

	ldr		x0, =str2
	bl			String_copy
	ldr		x1, =tailPtr
	ldr		x2, =headPtr
	bl			node_insert

	//update heap size and node counter
	ldr		x2, =dbHeapSize		//load address of dbHeapSize into x1
	ldr		x1, [x2]					//load value of dbHeapSize into x1
	add		x0, x0, x1				//add to dbHeapSize
	str		x0, [x2]					//store in dbHeapSize

	ldr		x1, =dbNodeCounter	//load address of dbNodeCounter into x0
	ldr		x0, [x1]					//load value of dbNodeCounter into x1
	add		x0, x0, #1				//increment by 1
	str		x0, [x1]					//store in dbNodeCounter



	ldr		x0, =str3
	bl			String_copy
	ldr		x1, =tailPtr
	ldr		x2, =headPtr
	bl			node_insert

	//update heap size and node counter
	ldr		x2, =dbHeapSize		//load address of dbHeapSize into x1
	ldr		x1, [x2]					//load value of dbHeapSize into x1
	add		x0, x0, x1				//add to dbHeapSize
	str		x0, [x2]					//store in dbHeapSize

	ldr		x1, =dbNodeCounter	//load address of dbNodeCounter into x0
	ldr		x0, [x1]					//load value of dbNodeCounter into x1
	add		x0, x0, #1				//increment by 1
	str		x0, [x1]					//store in dbNodeCounter


	ldr		x0, =str4
	bl			String_copy
	ldr		x1, =tailPtr
	ldr		x2, =headPtr
	bl			node_insert

	ldr		x0, =str5
	bl			String_copy
	ldr		x1, =tailPtr
	ldr		x2, =headPtr
	bl			node_insert
*/
open_menu:

	//clear screen, print header, menu, and recieve user input

	ldr		x0, =szClear			//load stirng into x0
	bl			putstring				//display waiting line

	bl			print_menu					//print header info and menu
	bl			menu_selection				//returns the user's input to x0

	cmp		x0, #0					//compare x0 to 0
	beq		view_strings			//if equal, print strings

	// If x0 equals 1, then go to addSK
	// If not contnue through the loop
	cmp		x0, #1					// Compare x0 to 1
	beq		add_String_Keyboard	// Branch to add_String from keyboard

	cmp		x0, #2					// Compare x0 to 1
	beq		add_String_File		//	Branch to add_String from Folder

	cmp		x0, #3					// Compare x0 to 3, if equal:
	beq		delete_string			// Branch to delete_string

	cmp		x0, #5					//compare x0 to 5
	beq		search					//if equal, branch to search

	cmp		x0, #6					//compare x0 to 6
	beq		write_file				//if equal, branch to write_file

	cmp		x0, #7					//compare x0 to 7
	beq		exit_sequence			//if equal, exit

	b			open_menu				//try to get input again

exit_sequence:

	//free memory before exiting
	ldr		x0, =headPtr			//load address of headPtr into x0
	bl			node_free				//free the nodes

	ldr		x0, =chLF				//load address of chLF into x0
	bl			putch						//print new line

	mov		x0, #0					//return code is 0
	mov		x8, #93					//93 terminates program
	svc		#0							//call linus to terminate the program

//DRIVER FUNCTIONS

return_to_menu:

	stp		x29, x30, [sp, #-16]!//push stack frame

	ldr		x0, =chLF				//load address of chLF into x0
	bl			putch						//print new line
	ldr		x0, =szWait				//load stirng into x0
	bl			putstring				//display waiting line

	//wait for input
	mov		x0, 0						//file descriptor
	mov		x1, sp					//buffer to store character
	mov		x2, #1					//number of bytes to read
	mov		x8, #63					//63 means read
	svc		#0							//call up linus

	ldp		x29, x30, [sp], #16	//pop stack frame

	b			open_menu				//back to menu

print_menu:

/* print_menu - prints the menu of the program */

	//save stack frame
	stp		x29, x30, [sp, #-16]!//push stack frame

	ldr		x0, =szHeader1			//load address of szHeader1 into x0
	bl			putstring				//print
	ldr		x0, =szHeader2a		//load address of szHeader2b into x0
	bl			putstring				//print

	//print memory consumption
	ldr		x0, =dbHeapSize		//load address of dbHeapSize into x0
	ldr		x0, [x0]					//load value of dbHeapSize into x0
	ldr		x1, =szBuffer			//put string address in x1
	bl			int64asc					//convert to string
	ldr		x0, =szBuffer			//load address of szBuffer into x0
	bl			putstring				//print

	ldr		x0, =szHeader2b		//load address of szHeader2a into x0
	bl			putstring				//print
	ldr		x0, =szHeader3			//load address of szHeader3 into x0
	bl			putstring				//print

	//print number of nodes
	ldr		x0, =dbNodeCounter	//load address of dbNodeCounter into x0
	ldr		x0, [x0]					//load value of dbNodeCounter into x0
	ldr		x1, =szBuffer			//put string address in x1
	bl			int64asc					//convert to string
	ldr		x0, =szBuffer			//load address of szBuffer into x0
	bl			putstring				//print

	ldr		x0, =chLF				//load address of chLF into x0
	bl			putch						//print new line

	//restore registers
	ldp		x29, x30, [sp], #16	//pop stack frame

	ret		lr							//return

menu_selection:

/*
//	menu_selection - return input to x0
//		x0 return values: a number from 0 to 7, or -1 on invalid input
//		(0 = <1>, 1 = <2a>, 2 = <2b>)
*/
	//save registers to stack
	str		x19, [sp, #-16]!		//push x19
	str		x30, [sp, #-16]!		//push lr

	//print menu
	ldr		x0, =szMenu1
	bl			putstring
	ldr		x0, =szMenu2
	bl			putstring
	ldr		x0, =szMenu2a
	bl			putstring
	ldr		x0, =szMenu2b
	bl			putstring
	ldr		x0, =szMenu3
	bl			putstring
	ldr		x0, =szMenu4
	bl			putstring
	ldr		x0, =szMenu5
	bl			putstring
	ldr		x0, =szMenu6
	bl			putstring
	ldr		x0, =szMenu7
	bl			putstring

	ldr		x0, =szBuffer			//load address of szBuffer into x0
	mov		x1, MAX					//MAX bytes of space allocated
	bl			getstring				//get input

	ldr		x0, =szBuffer			//szBuffer address is in x0
	mov		x1, #-1					//x1 initialized to -1
	ldrb		w2, [x0]					//load first byte from string into w2

	cmp		w2, #'0'					//compare against '1'
	blt		menu_selection_exit	//exit if less than
	cmp		w2, #'8'					//compare against '8'
	bge		menu_selection_exit	//exit if greater than or equal to
	cmp		w2, #'0'					//compare against 0
	beq		m_7						//0 also exits :)
	cmp		w2, #'1'					//compare against 1
	beq		m_1						//assign corresponding value
	cmp		w2, #'2'					//compare against 2
	beq		m_2						//handle 2a and 2b cases
	cmp		w2, #'3'					//compare against 3
	beq		m_3						//assign corresponding value
	cmp		w2, #'4'					//compare against 4
	beq		m_4						//assign corresponding value
	cmp		w2, #'5'					//compare against 5
	beq		m_5						//assign corresponding value
	cmp		w2, #'6'					//compare against 6
	beq		m_6						//assign corresponding value
	cmp		w2, #'7'					//compare against 7
	beq		m_7						//assign corresponding value
	b			menu_selection_exit	//exit

m_1:
	mov		x1, #0					//<1> -> 0
	b			menu_selection_exit
m_2:
	ldrb		w2, [x0, #1]			//load second byte of string
	cmp		w2, #'a'					//check if second byte is 'a'
	beq		m_2a						//if so branch to m_2a
	cmp		w2, #'b'					//check if second byte is 'b'
	beq		m_2b						//if so branch to m_2b

	b			menu_selection_exit
m_2a:
	mov		x1, #1					//<2a> -> 1
	b			menu_selection_exit
m_2b:
	mov		x1, #2					//<2b> -> 2
	b			menu_selection_exit
m_3:
	mov		x1, #3					//<3> -> 3
	b			menu_selection_exit
m_4:
	mov		x1, #4					//<4> -> 4
	b			menu_selection_exit
m_5:
	mov		x1, #5					//<5> -> 5
	b			menu_selection_exit
m_6:
	mov		x1, #6					//<6> -> 6
	b			menu_selection_exit
m_7:
	mov		x1, #7					//<7> -> 7
	b			menu_selection_exit

menu_selection_exit:

	mov		x0, x1					//move x1 to x0

	//restore registers
	ldr		x30, [sp], #16			//pop lr
	ldr		x19, [sp], #16			//pop x19

	ret		lr							//return

view_strings:

/* view_strings - prints all nodes */

	//save stack frame
	stp		x29, x30, [sp, #-16]!//push stack frame

	ldr		x0, =headPtr			//load headPtr into x0
	mov		x1, #1					//index print mode
	bl			node_print				//branch to node_print

	//restore registers
	ldp     x29, x30, [sp], #16	//pop stack frame

	b		return_to_menu				//return to menu

search:

/* search - searches and prints all nodes that contain a string */

	//save stack frame
	stp		x29, x30, [sp, #-16]!//push stack frame

	//get search string
	ldr		x0, =szSearch1			//load search prompt into x0
	bl			putstring				//print prompt
	ldr		x0, =szBuffer			//load szBuffer into x0
	mov		x1, MAX					//use MAX bytes of input
	bl			getstring				//get the string

	ldr		x0, =headPtr			//headPtr goes in x0
	ldr		x1, =szBuffer			//szBuffer goes in x1
	bl			node_search				//search the nodes

	//restore registers
	ldp		x29, x30, [sp], #16	//pop stack frame

	b			return_to_menu

add_String_Keyboard:

	// Prompt the user for an input string
	ldr		x0, =szInput			// Load x0 with the address
	bl			putstring				// Print prompt string to terminal

	// Before we call copy we get szBuffer to have the string to add
	ldr		x0,=szBuffer			// Load x0 with szBuffer address
	mov		x1,MAX					// Move x1 max amount of chars

	bl			getstring				// Calling get string to grab input

	// Call string_copy to make it dynamic
	ldr		x0,=szBuffer			// Load into 0 the address of szBuffer
	bl			String_copy				// Branch and link to String_copy

	// Parameters for node_insert
	ldr		x1, =tailPtr			// Load tail pointer to x1
	ldr		x2, =headPtr			// Load head pointer to x2
	bl			node_insert				// Branch and link to node insert

	//update heap size and node counter
	ldr		x2, =dbHeapSize		//load address of dbHeapSize into x1
	ldr		x1, [x2]					//load value of dbHeapSize into x1
	add		x0, x0, x1				//add to dbHeapSize
	str		x0, [x2]					//store in dbHeapSize

	ldr		x1, =dbNodeCounter	//load address of dbNodeCounter into x0
	ldr		x0, [x1]					//load value of dbNodeCounter into x1
	add		x0, x0, #1				//increment by 1
	str		x0, [x1]					//store in dbNodeCounter

	b			open_menu				// Return to menu

add_String_File:

	//	Add string into linked list from an input file. Potentially input.txt or whatever the
	// User had it as
	ldr		x0,=szGetIFile			// Prompt user for file name
	bl			putstring				// Print string to terminal


	ldr		x0,=szBuffer			// Load x0 with szBuffer address
	mov		x1,MAX					// Move x1 max amount of chars
	bl			getstring				// Calling get string to grab input


	// Get ready to call the service call 'open at' to open the file
	// x0 - current working directory
	// x1 - fileName
	// x2 - int flags
	// x3 - mode permissions
	// x4 - nothing
	// x8 - service call #56
	// Returns file descriptor
	mov		x0,#AT_FDCWD			// Local directory
	mov		x8,#56					// Calls service call 56(open file)

	ldr		x1,=szBuffer			// Load file name

	// Permissions
	mov		x2,#R						// Can only read input file
	mov		x3,#RW_______  		// Owner has Read and write permisions
	svc		0 							// Call linux to make the call

	// Save file descriptor in memory
	// so we can pull it out back later
	ldr		w4,=bFD					// Load x1 with address  of bFD
	strb		w0,[x4]					// x0=bfD
	top1:
	ldr		x1,=fileBuffer			// Load address of file buffer
	// do
	// {
	bl			getline					// Call getline
	cmp		x0,#0						// If x0 is 0 that means the file is at end
	beq		close_File				// If 0 branch to last

	//	ldr		x0,=szBuffer			// Load into 0 the address of szBuffer
	//	bl			putstring				// Branch and link to String_copy

	ldr		x0,=fileBuffer			// Load file buffer address into x0
	bl			String_copy				// Branch and link to string copy
	/****** Insert string to linked list ******/
	// Parameters for node_insert
	ldr		x1, =tailPtr			// Load tail pointer to x1
	ldr		x2, =headPtr			// Load head pointer to x2
	bl			node_insert				// Branch and link to node insert
	// Save file descriptor in memory
	// so we can pull it out back later
	ldr		w0,=bFD					// Load x1 with address  of bFD
	ldrb		w0,[x0]					// x0=bfD

	b			top1						// Continue through loop

	close_File:
	ldr		x0,=bFD					// Load 57 to close
	ldrb		w0,[x0]					// Load a byte

	mov		x8,#57					// Mov 57 into x8
	svc		0							// Call to close
	b			open_menu				// File close


	getChar:
	str		LR,[SP,#-16]!			// Push link register
	mov		x2,#1						// Move into x2, #1(number of bytes to read) (Attempt to read 1 byte)

	// ssize_t read(int fd, void *buf, size_t count);
	//				x0 read(x0,x1,x2_
	mov		x8,#63					// READ
	svc		0							// Does LR change
	ldr		LR,[SP],#16				// pop
	RET									// Return to main

	getline:
	str		LR,[SP,#-16]!			// Push LR to get back to main code

	top:
	bl			getChar					// Try to read in a char
	cmp		w0,#0x0					// Load in a line feed
	beq		EOF						// Branch to end of file

	ldrb		w2,[x1]					// Load a byt into w2
	cmp		w2,#0xa					// If we reach line feed
	beq		EOLINE					// Branch to eoline

	cmp		w0,#0x0					// Compare to null
	blt		ERROR						// Branch and link to file error
	// Move fileBuffer pointer by 1
	add		x1,x1,#1					// We are going to make fileBuffer into a c-string
	ldr		x0,=bFD					// Load address of bFD into x0
	ldrb		w0,[x0]					// Load byte into w0
	b			top						// Continue through loop
	// End of line
	EOLINE:
	mov		w2,#0						// by store null at the end of fileBuffer (i.e. "Cat in the hat.\0"
	strb		w2,[x1]					// Store a byte from x1 into w2
	b			skip						// Unconditional branch to skip
	// End of file
	EOF:
	mov		x19,x0					// Move into x0 into x19
	ldr		x0,=szEOF				// Load szEOF address into x0
	bl			putstring				// Print szEOF
	mov		x0,x19					// Move x19
	b			skip						// Continue through loop
	// File open error
	ERROR:
	mov		x19,x0					// Move x0 into x19
	ldr		x0,=szError				// Load address of szError
	bl			putstring				// Print string to terminal
	mov		x0,x19					// Move x19 into x0

	b			open_menu				// Return to menu

	skip:
	ldr		LR,[SP],#16				// POP
																																																																																						RET									// Return to main
delete_string:

	// Given an index #, delete the entire string and de-allocate/De-allocate as needed

	//get index from user
	ldr		x0, =szIndex			// Load address of index message
	bl			putstring				// Print string to terminal
	ldr		x0, =szBuffer			//load address of szBuffer into x0
	mov		x1, MAX					//give MAX bytes of space for input
	bl			getstring				//get input
	ldr		x0, =szBuffer			//load address of szBuffer into x0
	bl			ascint64					//convert to int

	//call node_delete
	mov		x1, x0					//x1 has index as int
	ldr		x0, =headPtr			//load address of headPtr into x0
	bl			node_delete				//delete node

	//update heap size and node counter
	ldr		x2, =dbHeapSize		//load address of dbHeapSize into x1
	ldr		x1, [x2]					//load value of dbHeapSize into x1
	sub		x0, x1, x0				//subtract from dbHeapSize
	str		x0, [x2]					//store in dbHeapSize

	ldr		x1, =dbNodeCounter	//load address of dbNodeCounter into x0
	ldr		x0, [x1]					//load value of dbNodeCounter into x1
	sub		x0, x0, #1				//decrement by 1
	str		x0, [x1]					//store in dbNodeCounter

	b			open_menu				// Return to menu

edit_String:

	// Given an index, replace old string with new string. Allocate/De-allocate as needed

	b			open_menu				// Return to menu

write_file:

	//get file name to write
	ldr		x0, =szGetOFile		//load address of szGetOFile into x0
	bl			putstring				//print

	ldr		x0, =szBuffer			//load address of szBuffer into x0
	mov		x1, MAX					//allow MAX bytes of space
	bl			getstring				//get input

	//print
	ldr		x0, =szWrite1			//load address of szWrite1 into x0
	bl			putstring				//print
	ldr		x0, =szBuffer			//load address of szBuffer into x0
	bl			putstring				//print
	ldr		x0, =szWrite2			//load address of szWrite2 into x0
	bl			putstring				//print

	//call node_write
	ldr		x0, =headPtr			//load address of headPtr into x0
	ldr		x1, =szBuffer			//load address of szBuffer into x0
	bl			node_write				//write list contents to file

	//print success!
	ldr		x0, =szWrite3			//load address of szWrite3 into x0
	bl			putstring				//print
	ldr		x0, =szBuffer			//load address of szBuffer into x0
	bl			putstring				//print

	b			return_to_menu			//return to menu

.end
