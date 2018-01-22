TITLE Homework8
;Program Description : Get user input, store it, and create random string, output random color.
;Author : Christina Tsui
;Creation Date : 4/30/17

INCLUDE Irvine32.inc

;Macros to clear all the registers
clearEAX TEXTEQU <mov eax, 0>
clearEBX TEXTEQU <mov ebx, 0>
clearECX TEXTEQU <mov ecx, 0>
clearEDX TEXTEQU <mov edx, 0>
clearESI TEXTEQU <mov esi, 0>
clearEDI TEXTEQU <mov edi, 0>

.data 

prompt byte 'Enter 1 to create a 5x5 Matrix of random letters.', 0Ah, 0Dh,
			'Enter 2 to find pairs of letters. WARNING:YOU MUST CREATE A MATRIX(1) BEFORE DOING THIS STEP!' , 0Ah, 0Dh,
			'Enter 3 to quit.', 0Ah, 0Dh, 0h

oops byte 'Invalid Entry.  Please try again.', 0Ah, 0Dh, 0h
userinput BYTE 0h, 0h

;Matrix data
matrixSize byte 25
x5Matrix BYTE  0h,  0h,  0h,  0h, 0h
RowSize = ($ - x5Matrix);Row major order, starts @ 5
         BYTE  0h,  0h,  0h,  0h, 0h
         BYTE  0h,  0h,  0h,  0h, 0h
         BYTE  0h,  0h,  0h,  0h, 0h
		 BYTE  0h,  0h,  0h,  0h, 0h

.code

randomChar PROTO, parm1:byte, parm2:ptr byte
createMatrix PROTO, parm1:byte, parm2:ptr byte
displayMatrix PROTO, parm1:byte, parm2:ptr byte
cons3vowels2 PROTO parm1:byte

rowSearch PROTO, parm1:byte, parm2:ptr byte
columnSearch PROTO, parm1:byte, parm2:ptr byte
diagonalRLSearch PROTO;, parm1:byte, parm2:ptr byte
diagonalLRSearch PROTO;, parm1:byte, parm2:ptr byte

main PROC

clearEAX
clearEBX
clearECX
clearEDX
clearESI
clearEDI

startHere:
call crlf
mov edx, offset prompt
call writestring
call readdec;get users input 
mov userinput, al 

opt1:;Create 5x5 Matrix
cmp userinput, 1
jne opt2
INVOKE createMatrix, matrixSize, addr x5Matrix;call function 
INVOKE displayMatrix, matrixSize, addr x5Matrix;call function
call crlf
call waitmsg
jmp startHere;return to menu 

opt2:;Find set
cmp userinput, 2
jne done
INVOKE rowSearch, matrixSize, addr x5Matrix;call function 
INVOKE columnSearch, matrixSize, addr x5Matrix;call function 	
INVOKE diagonalRLSearch;, matrixSize, addr x5Matrix;call function
INVOKE diagonalLRSearch;, matrixSize, addr x5Matrix;call function
call crlf
call waitmsg
jmp startHere;return to menu 

done:;Option 3
cmp userinput, 3
je  theEnd;Leave program
mov edx, OFFSET oops;tell user mistake made
call WriteString
call waitmsg
jmp starthere;On return restart menu

theEnd:
call waitmsg
	exit

main ENDP

;-----------------------------------------------------------------
randomChar PROC, parm1:byte, parm2:ptr byte
	;Desc: This function will randomly select a
	;	vowel or a consonat letter. Uses mod2 to 	
	;	to find out of random number is odd or even.
	;Recceives: matrixSize, 
	;			addr x5Matrix
	;Returns: BL - randomLetter
;-----------------------------------------------------------------

.data

vowels byte 'A', 'E', 'I', 'O', 'U', 0h ;Size 6
consonants byte 'B', 'C', 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'M', 'N',
				'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'X', 'Y', 'Z', 0h;Size 22

randomLetter byte 0h

.code

movzx ecx,parm1;sizeof
mov	esi,parm2;matrix


mov eax, 26 ; Random limit set to 26, 26 letters in alpha
call RandomRange ; randomize from 0-26, value in eax
mov bl, 2
div bl;eax/2, divisor = 2, dividend = random number, quotient = al, remainder = ah*

cmp ah, 0;0 = even(vowels), 1 = odd(consonants)
je vowel
jmp consonant

consonant:
mov edi, offset consonants
mov eax, 21 ; Random limit set to 21 for consonants
call RandomRange ; randomize from 0-21, value in eax
mov bl, [edi + eax]
mov randomLetter, bl;store the letter
jmp theEnd 

vowel:
mov edi, offset vowels
mov eax, 5 ; Random limit set to 5 for vowels
call RandomRange ; randomize from 0-5, value in eax
mov bl, [edi + eax]
mov randomLetter, bl;store the letter
jmp theEnd

theEnd:

ret
randomChar ENDP

;-----------------------------------------------------------------
createMatrix PROC, parm1:byte, parm2:ptr byte
	;Desc: Traverses through the 2D array/matrix
	;	Adds the letters generated from randomChar 	
	;	into the matrix
	;Recceives: matrixSize, 
	;			addr x5Matrix
	;Returns: esi - x5Matrix
;-----------------------------------------------------------------

.data

row_index byte 0 ;@0 (0,0)
column_index byte 0

.code

movzx ecx,parm1;sizeof
mov	esi,parm2;offset Matrix

movzx edx, column_index;0, start at begining of row 
mov ecx, RowSize ;should be 5, goes through 1 entire row

call randomize; set the seed,only do once

Neo:;moving through the Matrix
push ecx

INVOKE randomChar, matrixSize, addr x5Matrix;call function 

mov ebx, RowSize * 0;first row
add ebx, edx
mov al, randomLetter;move letter to matrix
mov [ebx + esi], al

inc edx;increases column
pop ecx
LOOP Neo

clearEDX

mov ecx, RowSize ;should be 5, goes through 1 entire row

Neo1:;moving through the Matrix
push ecx

INVOKE randomChar, matrixSize, addr x5Matrix;call function 

mov ebx, RowSize * 1;next row
add ebx, edx
mov al, randomLetter;move letter to matrix
mov [ebx + esi], al

inc edx;increases column
pop ecx
LOOP Neo1

clearEDX

mov ecx, RowSize ;should be 5, goes through 1 entire row

Neo2:;moving through the Matrix
push ecx

INVOKE randomChar, matrixSize, addr x5Matrix;call function 

mov ebx, RowSize * 2;next row
add ebx, edx
mov al, randomLetter;move letter to matrix
mov [ebx + esi], al

inc edx;increases column
pop ecx
LOOP Neo2

clearEDX

mov ecx, RowSize ;should be 5, goes through 1 entire row

Neo3:;moving through the Matrix
push ecx

INVOKE randomChar, matrixSize, addr x5Matrix;call function 

mov ebx, RowSize * 3;Next row
add ebx, edx
mov al, randomLetter;move letter to matrix
mov [ebx + esi], al

inc edx;increases column
pop ecx
LOOP Neo3

clearEDX

mov ecx, RowSize ;should be 5, goes through 1 entire row

Neo4:;moving through the Matrix
push ecx

INVOKE randomChar, matrixSize, addr x5Matrix;call function 

mov ebx, RowSize * 4;next row
add ebx, edx
mov al, randomLetter;move leetter to matrix
mov [ebx + esi], al

inc edx;increases column
pop ecx
LOOP Neo4

ret
createMatrix ENDP

;-----------------------------------------------------------------
displayMatrix PROC, parm1:byte, parm2:ptr byte
	;Desc: Traverses through the 2D array/matrix
	;	otput the character in that element. Will also	
	;	output header and apropriate spaces between letters
	;Recceives: matrixSize, 
	;			addr x5Matrix
	;Returns: esi - x5Matrix
;-----------------------------------------------------------------

.data

matrixOutput byte 'The Matrix is: ', 0ah, 0dh, 0h
tabSpace byte     '              ', 0h

.code

movzx ecx,parm1;sizeof
mov	esi,parm2;offset Matrix

mov edx, offset matrixOutput
call writestring

mov edx, offset tabSpace
call writestring 

movzx edx, column_index;0, start at begining of row 
mov ecx, RowSize ;should be 5, goes through 1 entire row

Neo:;moving through the Matrix
push ecx

mov ebx, RowSize * 0;first row
add ebx, edx
mov al, [ebx + esi]
call writechar
mov al, ' '
call writechar
call writechar
inc edx;increases column

pop ecx
LOOP Neo

call Crlf
mov edx, offset tabSpace;add some space to line up display
call writestring 
clearEDX
mov ecx, RowSize ;should be 5, goes through 1 entire row

Neo1:;moving through the Matrix
push ecx

mov ebx, RowSize * 1;second row
add ebx, edx
mov al, [ebx + esi]
call writechar
mov al, ' '
call writechar
call writechar
inc edx;increases column

pop ecx
LOOP Neo1

call Crlf
mov edx, offset tabSpace;add some space to line up display
call writestring 
clearEDX
mov ecx, RowSize ;should be 5, goes through 1 entire row

Neo2:;moving through the Matrix
push ecx

mov ebx, RowSize * 2;thrid row
add ebx, edx
mov al, [ebx + esi]
call writechar
mov al, ' '
call writechar
call writechar
inc edx;increases column

pop ecx
LOOP Neo2

call Crlf
mov edx, offset tabSpace;add some space to line up display
call writestring 
clearEDX
mov ecx, RowSize ;should be 5, goes through 1 entire row

Neo3:;moving through the Matrix
push ecx

mov ebx, RowSize * 3;fourth row
add ebx, edx
mov al, [ebx + esi]
call writechar
mov al, ' '
call writechar
call writechar
inc edx;increases column

pop ecx
LOOP Neo3

call Crlf
mov edx, offset tabSpace;add some space to line up display
call writestring 
clearEDX
mov ecx, RowSize ;should be 5, goes through 1 entire row

Neo4:;moving through the Matrix
push ecx

mov ebx, RowSize * 4;fifth row
add ebx, edx
mov al, [ebx + esi]
call writechar
mov al, ' '
call writechar
call writechar
inc edx;increases column

pop ecx
LOOP Neo4

ret
displayMatrix ENDP

;-----------------------------------------------------------------
rowSearch PROC, parm1:byte, parm2:ptr byte
	;Desc: Traverses through the 2D array/matrix
	;	one row at a time. Will call a function
	;	that will test the letters to see if 2 vowel, 3 const
	;Recceives: matrixSize, 
	;			addr x5Matrix
	;Returns: esi - x5Matrix
;-----------------------------------------------------------------

.data

searchOutput byte 'The words from this matrix is/are:', 0ah, 0dh, 0h
inbetween byte ',   ', 0h

.code

movzx ecx,parm1;sizeof
mov	esi,parm2;offset Matrix
mov edi, offset itsAMatch

call Crlf
mov edx, offset searchOutput 
call writestring

movzx edx, column_index;0, start at begining of row 
mov ecx, RowSize ;should be 5, goes through 1 entire row

Neo:;moving through the Matrix
push ecx;save loop counter

mov ebx, RowSize * 0;Row one
add ebx, edx
mov al, [ebx + esi]
INVOKE cons3vowels2, al;call testing function 
inc edi 
inc edx;increases column

pop ecx;get loop counter back
LOOP Neo

mov vowelCount, 0;reset counter
mov consanateCount, 0 ;reset counter
clearEDX
mov ecx, RowSize ;should be 5, goes through 1 entire row
mov edi, offset itsAMatch

Neo1:;moving through the Matrix
push ecx;save loop counter 

mov ebx, RowSize * 1;row two 
add ebx, edx
mov al, [ebx + esi]
INVOKE cons3vowels2, al;call test function
inc edi 
inc edx;increases column

pop ecx;move loop counter back
LOOP Neo1

mov vowelCount, 0;reset the counter
mov consanateCount, 0 ;reset the counter 
clearEDX
mov ecx, RowSize ;should be 5, goes through 1 entire row
mov edi, offset itsAMatch

Neo2:;moving through the Matrix
push ecx;save  loop conter 

mov ebx, RowSize * 2;row three 
add ebx, edx
mov al, [ebx + esi]
INVOKE cons3vowels2, al;call test function 
inc edi 
inc edx;increases column

pop ecx;move loop counter back
LOOP Neo2

mov vowelCount, 0;reset the counter
mov consanateCount, 0 ;reset the counter 
clearEDX
mov ecx, RowSize ;should be 5, goes through 1 entire row
mov edi, offset itsAMatch

Neo3:;moving through the Matrix
push ecx;save the loop counter

mov ebx, RowSize * 3;row four
add ebx, edx
mov al, [ebx + esi]
INVOKE cons3vowels2, al;call the test function 
inc edi 
inc edx;increases column

pop ecx;get the loop counter back
LOOP Neo3

mov vowelCount, 0;reset the counter
mov consanateCount, 0 ;reset the counter
clearEDX
mov ecx, RowSize ;should be 5, goes through 1 entire row
mov edi, offset itsAMatch

Neo4:;moving through the Matrix
push ecx;save the loop counter

mov ebx, RowSize * 4;row five
add ebx, edx
mov al, [ebx + esi]
INVOKE cons3vowels2, al;call the test function 
inc edi 
inc edx;increases column

pop ecx;get the loop counter back 
LOOP Neo4

ret
rowSearch ENDP

;-----------------------------------------------------------------
columnSearch PROC, parm1:byte, parm2:ptr byte
	;Desc: Traverses through the 2D array/matrix
	;	go through each collum of the matrix one by one	
	;	Sends the letter into the test to see if 2 vowel ad 3 const
	;Recceives: matrixSize, 
	;			addr x5Matrix
	;Returns: esi - x5Matrix
;-----------------------------------------------------------------

.code

movzx ecx,parm1;sizeof
mov	ebx,parm2;offset Matrix

mov vowelCount, 0;reset the counter
mov consanateCount, 0 ;reset the counter 
clearEDX
mov edi, offset itsAMatch

mov eax, 0;row number
mov	ecx,RowSize
	
mul	ecx			; row index * row size
add	ebx,eax		; row offset 
mov	eax,0		; accumulator
mov	esi,0		; column index

mov	ecx,RowSize;set loop counter 
L1:	movzx edx,BYTE PTR[ebx + esi]; get a byte
	push ecx;dave loop conter 
	mov al, dl 
	INVOKE cons3vowels2, al;call function to test char

	add esi, RowSize; add to accumulator 
	inc edi 
	pop ecx	;retrieve the loop counter 
	loop	L1; next byte in row

mov vowelCount, 0;reset the counter
mov consanateCount, 0 ;reset the counter 
clearEDX
mov edi, offset itsAMatch

mov eax, 0;row number
mov	ecx,RowSize
	
mul	ecx			; row index * row size
add	ebx,eax		; row offset 
mov	eax,0		; accumulator
mov	esi,1		; column index

mov	ecx,RowSize;set the loop counter
L2:	movzx edx,BYTE PTR[ebx + esi]; get a byte
	push ecx;save the loop counter 
	mov al, dl 

	INVOKE cons3vowels2, al;call function to test the char
	inc edi 
	pop ecx;get the loop counter back 
	add esi, RowSize; add to accumulator 
	loop	L2; next byte in row


mov vowelCount, 0;reset the counter
mov consanateCount, 0 ;reset the counver
clearEDX
mov edi, offset itsAMatch

mov eax, 0;row number
mov	ecx,RowSize
	
mul	ecx			; row index * row size
add	ebx,eax		; row offset 
mov	eax,0		; accumulator
mov	esi,2		; column index

mov	ecx,RowSize;set the loop counter 
L3:	movzx edx,BYTE PTR[ebx + esi]; get a byte
	mov al, dl
	push ecx ;save the loop counter
	INVOKE cons3vowels2, al;call the test function 
	
	pop ecx;save the loop counter 
	inc edi 
	add esi, RowSize; add to accumulator 
	loop	L3; next byte in row

mov vowelCount, 0;reset the counter 
mov consanateCount, 0 ;reset the counter 
clearEDX
mov edi, offset itsAMatch

mov eax, 0;row number,start at top
mov	ecx,RowSize
	
mul	ecx			; row index * row size
add	ebx,eax		; row offset 
mov	eax,0		; accumulator
mov	esi,3		; column index

mov	ecx,RowSize;set the loop counter 
L4:	movzx edx,BYTE PTR[ebx + esi]; get a byte
	mov al, dl 
	push ecx;save the loop counter
	INVOKE cons3vowels2, al;call the test function 

	pop ecx;retrieve the loop counter
	inc edi 
	add esi, RowSize; add to accumulator 
	loop	L4; next byte in row

mov vowelCount, 0;reset the counter
mov consanateCount, 0 ;reset the counter
clearEDX
mov edi, offset itsAMatch

mov eax, 0;row number
mov	ecx,RowSize
	
mul	ecx			; row index * row size
add	ebx,eax		; row offset 
mov	eax,0		; accumulator
mov	esi,4		; column index

mov	ecx,RowSize;set the loop counter 
L5:	movzx edx,BYTE PTR[ebx + esi]; get a byte
	mov al, dl 
	push ecx;save the loop counter
	INVOKE cons3vowels2, al;call the test function 

	pop ecx ;retrieve the loop function 
	inc edi 
	add esi, RowSize		; add to accumulator 							
	loop	L5; next byte in row

ret
columnSearch ENDP

;-----------------------------------------------------------------
diagonalRLSearch PROC;, parm1:byte, parm2:ptr byte
	;Desc: Traverses through the 2D array/matrix
	;	Start at top left and goes diagonaly to the bottom right	
	;	At each correct letter, the letter is tested for set
	;Recceives: matrixSize, 
	;			addr x5Matrix
	;Returns: esi - x5Matrix
;-----------------------------------------------------------------

mov vowelCount, 0;reset the counter
mov consanateCount, 0 ;reset the counter
clearEDX
mov edi, offset itsAMatch

row_index0 = 0;Move to R:0
column_index0 = 0;Move to C:0

mov ebx,OFFSET x5Matrix; table offset
add ebx,RowSize * row_index0 ; row offset
mov esi,column_index0
mov al, [ebx + esi]

INVOKE cons3vowels2, al;Call the testing function 

row_index1 = 1;Move to R:1
column_index1 = 1;Move to C:1
inc edi

mov ebx,OFFSET x5Matrix ; table offset
add ebx,RowSize * row_index1 ; row offset
mov esi,column_index1
mov al, [ebx + esi]

INVOKE cons3vowels2, al;call the testing function

row_index2 = 2;Move to R:2
column_index2 = 2;Move to c:2
inc edi

mov ebx,OFFSET x5Matrix ; table offset
add ebx,RowSize * row_index2 ; row offset
mov esi,column_index2
mov al, [ebx + esi]

INVOKE cons3vowels2, al;call the testing function

row_index3 = 3;Move to R:3
column_index3 = 3;Move to CL3
inc edi

mov ebx,OFFSET x5Matrix ; table offset
add ebx,RowSize * row_index3 ; row offset
mov esi,column_index3
mov al, [ebx + esi]

INVOKE cons3vowels2, al;call the testing function

row_index4 = 4;Move to R:4
column_index4 = 4;Move to C:4
inc edi

mov ebx,OFFSET x5Matrix ; table offset
add ebx,RowSize * row_index4 ; row offset
mov esi,column_index4
mov al, [ebx + esi]

INVOKE cons3vowels2, al;Call the testing funtion

ret
diagonalRLSearch ENDP

;-----------------------------------------------------------------
cons3vowels2 PROC parm1:byte
	;Desc: The letter sent in is kept track of 
	;	the letter will change a counter dpending on it's value	
	;	When 2 vowels, and 3 consonants are found, there is a set
	;Recceives: -al - char
	;			
	;Returns: esi - al- char
;-----------------------------------------------------------------

.data

vowelCount byte 0
consanateCount byte 0  
itsAMatch byte 0, 0, 0, 0, 0

.code

mov al,parm1;current letter
push ebx

;save the letters, if it's a match then output, if not a match reset placement for next r/c/d
mov ecx, 0
mov [edi+ecx], al

mov bl, 'A';Move letter to be cmp'd
cmp bl, al;if match, add to vowel couter and keep going 
je addToVowel
mov bl, 'E';Move letter to be cmp'd
cmp bl, al;if match, add to vowel couter and keep going 
je addToVowel
mov bl, 'I';Move letter to be cmp'd
cmp bl, al;if match, add to vowel couter and keep going 
je addToVowel
mov bl, 'O';Move letter to be cmp'd
cmp bl, al;if match, add to vowel couter and keep going 
je addToVowel
mov bl, 'U';Move letter to be cmp'd
cmp bl, al;if match, add to vowel couter and keep going 
je addToVowel
jmp addToConsanante

addToVowel:
add vowelCount,1 ;Add to counter
jmp finalCheck

addToConsanante:
add consanateCount,1 ;Add to counter
jmp finalCheck

finalCheck:
cmp vowelCount, 2;check conditions
jne theEnd 
cmp consanateCount, 3;check conditions
jne theEnd

mov edi, offset itsAMatch;It's a match! out put the string. 
mov ecx, 5

match:
mov al, [edi]
call writechar
inc edi 
loop match 

call Crlf

theEnd:;Not a match, end
pop ebx

ret
cons3vowels2 ENDP

;-----------------------------------------------------------------
diagonalLRSearch PROC;, parm1:byte, parm2:ptr byte
	;Desc: Traverses through the 2D array/matrix
	;	Start at top Right and goes diagonaly to the bottom Left	
	;	At each correct letter, the letter is tested for set
	;Recceives: matrixSize, 
	;			addr x5Matrix
	;Returns: esi - x5Matrix
;-----------------------------------------------------------------

mov vowelCount, 0
mov consanateCount, 0 
clearEDX
mov edi, offset itsAMatch

row_index0 = 0
column_index0 = 4

mov ebx,OFFSET x5Matrix; table offset
add ebx,RowSize * row_index0 ; row offset
mov esi,column_index0
mov al, [ebx + esi]

INVOKE cons3vowels2, al

row_index1 = 1
column_index1 = 3
inc edi

mov ebx,OFFSET x5Matrix ; table offset
add ebx,RowSize * row_index1 ; row offset
mov esi,column_index1
mov al, [ebx + esi]

INVOKE cons3vowels2, al

row_index2 = 2
column_index2 = 2
inc edi

mov ebx,OFFSET x5Matrix ; table offset
add ebx,RowSize * row_index2 ; row offset
mov esi,column_index2
mov al, [ebx + esi]

INVOKE cons3vowels2, al

row_index3 = 3
column_index3 = 1
inc edi

mov ebx,OFFSET x5Matrix ; table offset
add ebx,RowSize * row_index3 ; row offset
mov esi,column_index3
mov al, [ebx + esi]

INVOKE cons3vowels2, al

row_index4 = 4
column_index4 = 0
inc edi

mov ebx,OFFSET x5Matrix ; table offset
add ebx,RowSize * row_index4 ; row offset
mov esi,column_index4
mov al, [ebx + esi]

INVOKE cons3vowels2, al

ret
diagonalLRSearch ENDP


END main