;*******************************************************************************************************************
%define char_to_print   46      ; character to print on screen

Memory_Tester:
    pushaq
        

        mov rdi, 0x200000       ; check if less than 2 mb
        cmp rax, rdi                    
        jl .endT                ; if less, no checking is done

        xor rsi, rsi            ; check if memory is empty, before overwriting it
        cmp qword[rax], rsi
        jne .endT
               

        mov byte[rax],char_to_print         ; Insert a Dot
        mov dil, byte[rax]                  ; Move what is inside [r14] into di to be printed to the screen

       ; mov rsi, colon
       ; call video_print

      
            
    
    .endT:
        popaq
        ret

