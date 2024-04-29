	.global _start
			.equ NODE_SIZE,16
			.equ BUFFER, 21
			.equ MAX, 20
			.equ MAX2,30
			.equ BUFFER2,31
	.data

headPtr:	.quad 0					//head pointer
tailPtr:	.quad 0					//tail pointer
newNodePtr:	.quad 0					// Holds new node ptr
currentPtr:	.quad 0					// Holds current ptr
dbBuffer:	.quad 0					//to hold temp nums
szBuffer:	.skip BUFFER			//to hold temp strings
szBuffer2:	.skip BUFFER2			// Testing something right quick
chLF:			.byte 0x0a				//new line

//header
szHeader1:	.asciz "\n             RASM-4 TEXT EDITOR\n"
szHeader2a:	.asciz "      Data Structure Heap Memory Consumption: "
szHeader2b:	.asciz " bytes\n"
szHeader3:	.asciz "      Number of Nodes: "

//menu
szMenu1:	.asciz "<1> View all strings\n\n"
szMenu2:	.asciz "<2> Add string\n"
szMenu2a:	.asciz "    <a> from keyboard\n"
szMenu2b:	.asciz "    <b> from file. Static file named input.txt\n\n"
szMenu3:	.asciz "<3> Delete string. Given an index #, delete the entire string and deallocate memory (including the node).\n\n"
szMenu4:	.asciz "<4> Edit string. Given an index #, replace old string with new string. allocate/deallocate as needed.\n\n"
szMenu5:	.asciz "<5> String search. Regardless of case, return all strings that match the substring given.\n\n"
szMenu6:	.asciz "<6> Save file (output.txt)\n\n"
szMenu7:	.asciz "<7> Quit\n\n\n>  "


str1:		.asciz "this is the first string\n"
str2:		.asciz "and this is the second\n"
str3:		.asciz "this is the third!\n"


strIn:	.asciz "Enter an index: "				// User is prompted for a string's index to delete
strInput:.asciz "Input: "							// User is prompted for new string to add to list
	.text

_start:

//add temp strings
	ldr		x0, =str1
	bl		String_copy
	ldr		x1, =tailPtr
	ldr		x2, =headPtr
	bl		node_insert

	ldr		x0, =str2
	bl		String_copy
	ldr		x1, =tailPtr
	ldr		x2, =headPtr
	bl		node_insert

	ldr		x0, =str3
	bl		String_copy
	ldr		x1, =tailPtr
	ldr		x2, =headPtr
	bl		node_insert

open_menu:

	//print header, menu, and recieve user input

	bl		print_menu				//print header info and menu
	bl		menu_selection			//returns the user's input to x0

	cmp		x0, #0					//compare x0 to 0
	beq		view_strings			//if equal, print strings

	// If x0 equals 1, then go to addSK
	// If not contnue through the loop
	cmp		x0,#1						// Compare x0 to 1
	beq		add_String_Keyboard	// Branch to add_String from keyboard


//	cmp		x0,#2						// Compare x0 to 1
//	beq		add_String_File		//	Branch to add_String from Folder

//	cmp		x0,#3						// Compare x0 to 3, if equal:
//	beq		delete_String			// Branch to delete_string



	cmp		x0, #7					//compare x0 to 7
	beq		exit_sequence			//if equal, exit

exit_sequence:

	//free memory before exiting
	ldr		x0, =headPtr			//load address of headPtr into x0
	bl		node_free				//free the nodes

	ldr		x0, =chLF				//load address of chLF into x0
	bl		putch					//print new line

	mov		x0, #0					//return code is 0
	mov		x8, #93					//93 terminates program
	svc		#0						//call linus to terminate the program

//DRIVER FUNCTIONS

print_menu:

/* print_menu - prints the menu of the program */

    //save registers to stack
    str     x19, [sp, #-16]!        //push x19
    str     x30, [sp, #-16]!        //push lr

	ldr		x0, =szHeader1			//load address of szHeader1 into x0
	bl		putstring				//print
	ldr		x0, =szHeader2a			//load address of szHeader2b into x0
	bl		putstring				//print

	//TODO: get memory consumption into x1 as int
	mov		x1, #0

	//convert mem consumption to ascii
	mov		x0, x1					//move mem consumption to x0
	ldr		x1, =szBuffer			//put string address in x1
	bl		int64asc				//convert to string
	ldr		x0, =szBuffer			//load address of szBuffer into x0
	bl		putstring				//print

	ldr		x0, =szHeader2b			//load address of szHeader2a into x0
	bl		putstring				//print
	ldr		x0, =szHeader3			//load address of szHeader3 into x0
	bl		putstring				//print

	//TODO: get number of nodes into x2 as int
	mov		x2, #0

	//convert node count to ascii
	mov		x0, x2					//move node count to x0
	ldr		x1, =szBuffer			//put string address in x1
	bl		int64asc				//convert to string
	ldr		x0, =szBuffer			//load address of szBuffer into x0
	bl		putstring				//print

	ldr		x0, =chLF				//load address of chLF into x0
	bl		putch					//print new line

	//restore registers
    ldr     x30, [sp], #16          //pop lr
    ldr     x19, [sp], #16          //pop x19

	ret		lr						//return

menu_selection:

/*
//	menu_selection - return input to x0
//		x0 return values: a number from 0 to 7, or -1 on invalid input
//		(0 = <1>, 1 = <2a>, 2 = <2b>)
*/
    //save registers to stack
    str     x19, [sp, #-16]!        //push x19
    str     x30, [sp, #-16]!        //push lr

	//print menu
	ldr		x0, =szMenu1
	bl		putstring
	ldr		x0, =szMenu2
	bl		putstring
	ldr		x0, =szMenu2a
	bl		putstring
	ldr		x0, =szMenu2b
	bl		putstring
	ldr		x0, =szMenu3
	bl		putstring
	ldr		x0, =szMenu4
	bl		putstring
	ldr		x0, =szMenu5
	bl		putstring
	ldr		x0, =szMenu6
	bl		putstring
	ldr		x0, =szMenu7
	bl		putstring

	ldr		x0, =szBuffer			//load address of szBuffer into x0
	mov		x1, MAX					//MAX bytes of space allocated
	bl		getstring				//get input

	ldr		x0, =szBuffer			//szBuffer address is in x0
	mov		x1, #-1					//x1 initialized to -1
	ldrb	w2, [x0]				//load first byte from string into w2

	cmp		w2, #'1'				//compare against '1'
	blt		menu_selection_exit		//exit if less than
	cmp		w2, #'8'				//compare against '8'
	bge		menu_selection_exit		//exit if greater than or equal to
	cmp		w2, #'1'				//compare against 1
	beq		m_1						//assign corresponding value
	cmp		w2, #'2'				//compare against 2
	beq		m_2						//handle 2a and 2b cases
	cmp		w2, #'3'				//compare against 3
	beq		m_3						//assign corresponding value
	cmp		w2, #'4'				//compare against 4
	beq		m_4						//assign corresponding value
	cmp		w2, #'5'				//compare against 5
	beq		m_5						//assign corresponding value
	cmp		w2, #'6'				//compare against 6
	beq		m_6						//assign corresponding value
	cmp		w2, #'7'				//compare against 7
	beq		m_7						//assign corresponding value
	b		menu_selection_exit		//exit

m_1:
	mov		x1, #0					//<1> -> 0
	b		menu_selection_exit
m_2:
	ldrb	w2, [x0, #1]			//load second byte of string
	cmp		w2, #'a'				//check if second byte is 'a'
	beq		m_2a					//if so branch to m_2a
	cmp		w2, #'b'				//check if second byte is 'b'
	beq		m_2b					//if so branch to m_2b
	b		menu_selection_exit
m_2a:
	mov		x1, #1					//<2a> -> 1
	b		menu_selection_exit
m_2b:
	mov		x1, #2					//<2b> -> 2
	b		menu_selection_exit
m_3:
	mov		x1, #3					//<3> -> 3

	b		menu_selection_exit
m_4:
	mov		x1, #4					//<4> -> 4
	b		menu_selection_exit
m_5:
	mov		x1, #5					//<5> -> 5
	b		menu_selection_exit
m_6:
	mov		x1, #6					//<6> -> 6
	b		menu_selection_exit
m_7:
	mov		x1, #7					//<7> -> 7
	b		menu_selection_exit

menu_selection_exit:

	mov		x0, x1					//move x1 to x0

	//restore registers
    ldr     x30, [sp], #16          //pop lr
    ldr     x19, [sp], #16          //pop x19

	ret		lr						//return

//<<<<<<< HEAD
//=======
view_strings:

/* view_strings - prints all nodes */

	ldr		x0, =headPtr			//load headPtr into x0
	bl		node_print				//branch to node_print
	b		open_menu				//return to menu
//>>>>>>> c0253c309ccdd54672d1f47005eed24e02c5709c

add_String_Keyboard:
	// Prompt the user for an input string
	ldr		x0,=strInput		// Load x0 with the address
	bl			putstring			// Print prompt string to terminal
	// Before we call copy we get szBuffer to have the string to add
	ldr		x0,=szBuffer2		// Load x0 with szBuffer address
	mov		x1,MAX2				// Move x1 max amount of chars

	bl			getstring			// Calling get string to grab input

	// Store values into memory(?)
	ldr		x0,=szBuffer2		// Load into 0 the address of szBuffer
	bl			String_copy			// Branch and link to String_copy

	// Parameters for node_insert
	ldr		x1,=tailPtr			// Load tail pointer to x1
	ldr		x2,=headPtr			// Load head pointer to x2
	bl			node_insert			// Branch and link to node insert

	b			open_menu			// Return to menu
add_String_File:
	//	Add string into linked list from an input file. Potentially input.txt or whatever the
	// User had it as
	b			open_menu			// Return to menu
delete_String:
	// Given an index #, delete the entire string and de-allocate/De-allocate as needed

	// Prompt the user for a string index
	ldr		x0,=strIn			// Load address of index message
	bl			putstring			// Print string to terminal

	b			open_menu			// Return to menu

edit_String:
	// Given an index, replace old string with new string. Allocate/De-allocate as needed
	b			open_menu			// Return to menu

.end
