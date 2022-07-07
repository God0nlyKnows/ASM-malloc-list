section .data                           ;Data segment
    userMsg db 'Please enter a number: ' ;Ask the user to enter a number
    lenUserMsg equ $-userMsg             ;The length of the message
    dispMsg db 'You have entered: '
    lenDispMsg equ $-dispMsg
    errMsg db 'Thats not a digit! '
    lenErrMsg equ $-errMsg
    exitMsg db 2,3,1,4,2
    numInputed db 0
    numInputedTotal db 0
    mallocErr db "malloc failed!", 10, 0
    lenMallocErr equ $ - mallocErr

section .bss           ;Uninitialized data
    num resb 50
    mptr resd 1 ;malloc pointer 
	

section .text          ;Code Segment
    global main
    extern malloc
    extern free
	
main:    

    mov ecx, userMsg
    mov edx, lenUserMsg
    call write

    ;Read and store the user input
    mov ecx, num  
    mov edx, 10        ;10 bytes (numeric, 1 for sign) of that information
    call read
	
    ;Output the message 'The entered number is: '
    mov ecx, dispMsg
    mov edx, lenDispMsg
    call write

    ;Output the number entered
    mov ecx, num
    mov edx, 10
    call write

    mov ebx, num

    call mallocL

asciiToNumber:
    cmp [ebx], byte 0ah     ; check for end of string \n
    je continue

    cmp [ebx], byte 30h          ; check if digit 
    je setCounter
    jl error
    cmp [ebx], byte 39h          
    jg error

    



    mov ecx, 0

    
    mov cl, byte [ebx]
    
    mov byte [eax], cl    ; write char
    add eax, dword 1      ; advance index by 1 byte

    sub cl, 30h
    mov [ebx], cl


    add ebx, dword 1      ; advance index by 1 byte
    jmp asciiToNumber


continue:

    mov byte [eax], 0ah     ; write \n that we forgot
    push dword [mptr]       ; original pointer save
    mov ecx, numInputedTotal
    add [ecx], byte 1
    mov ecx, 0
    mov ebx, 0
    mov ecx, dword [num]
    mov ebx, dword [exitMsg]
    cmp ebx,ecx
    je exit
    jmp main



error:
    mov ecx, errMsg
    mov edx, lenErrMsg
    call write
    jmp continue

read:
    mov eax, 3
    mov ebx, 2
    int 80h
    ret

write:
    mov eax, 4
    mov ebx, 1
    int 80h
    ret

exit:
    mov eax, 1
    mov ebx, 0
    int 80h

merror:
mov eax, 0x4
mov ebx, 0x1
mov ecx, mallocErr
mov edx, lenMallocErr
int 80h

jmp exit

mallocL:

    push 10       ;allocate 10 bytes
    call malloc
    add esp, 4            ;move top of stack
    
    test eax, eax ;check for malloc error
    jz merror

    mov [mptr], eax ;store address
    ret


printAll:
    mov cl, byte [numInputed]
    cmp cl, byte 0
    jle main
    mov ecx, numInputed
    sub [ecx], byte 1

    pop ecx
    mov edx, 10
    call write

    jmp printAll


setCounter:
    mov cl, byte [numInputedTotal]
    mov byte [numInputed], cl 
    jmp printAll