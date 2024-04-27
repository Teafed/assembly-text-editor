	.global _start

			.equ BUFFER, 21
			.equ MAX, 20
	.data

dbBuffer:	.quad 0					//to hold temp nums
szBuffer:	.skip BUFFER			//to hold temp strings
chLF:		.byte 0xa				//new line

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

	.text

_start:

open_menu:

	//print header, menu, and recieve user input

	bl		print_menu				//print header info and menu
	bl		menu_selection			//returns the user's input to x0

	//test

	ldr		x1, =szBuffer
	bl		int64asc
	ldr		x0, =szBuffer
	bl		putstring

exit_sequence:

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
	// Add string. from File. Static file named input.txt
	mov		x1, #2					//<2b> -> 2
	b		menu_selection_exit
m_3:
	// Delete string. Given an index #, delete the entire string and de-allocate memory
	// (Including the node).


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

.end
