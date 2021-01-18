; generate random numbers is the "linear congruential generation" method

name "random"

data segment
; define m, a and c values in the data segment
    m dw 8191
    a dw 884
    c dw 1
; keep the generated random number in the data segment
    number dw ?
ends

stack segment
    db 30 dup(0)
ends

code segment
start:
; set segment register
    mov     ax, data        ; set AX from the data segment
    mov     ds, ax          ; set DS from AX

; read from the 23 offset in the code segment as seed
    mov     ax, cs:[23]     ; set AX from the 23 offset
    mov     number, ax      ; set random number from AX

; generate 10 random numbers
    mov     cx, 10          ; number of loop repetitions
repeat:    
        call    generate    ; generate the next random number
        mov     ax, number  ; set AX from random number
        call    print_al    ; print number in AL
        call    print_nl    ; print "new line"
    loop repeat             ; repeat the loop
    
; wait for any key
    mov     ah, 0           ; get keystroke from keyboard
    int     16h             ; keyboard interrupt

; terminate the program
    mov     ah, 4ch         ; return control to the operating system
    int     21h             ; DOS services interrupt

; procedure to generate random number
generate proc
generate_loop:    
    mov     ax, number      ; set AX from the previous random number (xt)
    mul     a               ; calculate a*xt in DX:AX
    add     ax, c           ; calculate a*xt+c (low word in AX)
    adc     dx, 0           ; calculate a*xt+c (high word in DX)
    div     m               ; calculate (a*xt+c) mod m in DX
    mov     number, dx      ; set random number from DX
    cmp     number, 256     ; look for numbers 0-255
    jb      generate_end    ; stop generation loop
    jmp     generate_loop   ; generate again
generate_end:
    ret                     ; return from procedure
endp    

; procedure to print number in AL
print_al proc
    cmp     al, 0           ; check for zero
    jne     print_al_r      ; use recursive version if not zero
    push    ax              ; store register
    mov     al, '0'         ; print zero
    mov     ah, 0eh         ; teletype output
    int     10h             ; BIOS interrupt
    pop     ax              ; restore register
    ret                     ; return from procedure
print_al_r:    
    pusha                   ; store all registers
    mov     ah, 0           ; convert byte to word
    cmp     ax, 0           ; check for zero
    je      print_al_done   ; printing done
    mov     dl, 10          ; decimal base
    div     dl              ; set AL to quotient and AH to remainder
    call    print_al_r      ; recursively print the quotient
    mov     al, ah          ; set AL to remainder
    add     al, '0'         ; convert number to symbol
    mov     ah, 0eh         ; teletype output
    int     10h             ; BIOS interrupt
print_al_done:
    popa                    ; restore all registers
    ret                     ; return from procedure
endp

; procedure to print "new line"
print_nl proc 
    pusha                   ; store all registers
    mov     ah, 2           ; write character
    mov     dl, 0Dh         ; carriage return symbol
    int     21h             ; DOS services interrupt
    mov     dl, 0Ah         ; line feed symbol
    int     21h             ; DOS services interrupt
    popa                    ; restore all registers
    ret                     ; return from procedure
endp

ends
end start
