%define VIDEO_BUFFER_EFFECTIVE_ADDRESS          0xB8000
%define VIDEO_SIZE      0X0FA0    ; 25*80*2


;*******************************************************************************************************************
bios_print_hexa:  ; A routine to print a 64-bit value stored in rdi in hexa decimal (4*4 = 16 hexa digits)
pushaq
mov rbx,0x0B8000                ; set RBX to the start of the video memory-mapped I/O
    add bx,[start_location]     ; Store the start location for printing in BX
    xor rcx,rcx
    mov cl,byte [hexa_pad]                                ; Set loop counter for 16 iterations, one for each digit (16 * 4 = 64 max reg size)
    ;mov rcx, 0x10

    mov rax, VIDEO_BUFFER_EFFECTIVE_ADDRESS         ; set rax to video buffer io
    cmp byte [pit_bool], 1                          ; compare boolean variable to 1 
        jne .loop
            xor rdx, rdx
            .reset_first_line:
                mov word[rax], 0x1020
                inc rdx
                add rax, 2
                cmp rdx, 80
                jl .reset_first_line
    .loop:                                      ; Loop on all 4 digits
            mov rsi,rdi                         ; Move rdi into rsi
            shr rsi,0x3C                        ; Shift rsi 60 bits right so that we are left with 4 bits (0-15) which is the index of the hexa digit in a created array 
            mov al,[hexa_digits+rsi]            ; get the corresponding hexadcimal digit from the stored array           
            mov byte [rbx],al      ; move the hexadecimal digit into the memory buffer
            inc rbx                ; Increment current video location
            mov byte [rbx], 1Eh    ; Background = Blue , font color = yellow
            inc rbx                ; Increment current video location

            shl rdi,0x4                          ; Shift rdi 4 bits to the left to position the next digit corectly 
            dec rcx                              ; decrement loop counter by 1
            cmp rcx,0x0                          ; check if counter == 0
            jg .loop                             ; if greater, then Loop again until we finish print 4 digits
    add [start_location],word 0x20               ; increment the prinitng location with 32 = 16 iteration * 2 bytes each to avoid overwriting memory 
    add qword[screen_counter], 0x20 ; 
    cmp qword[screen_counter], VIDEO_SIZE
    jl .quit 
        call video_scrolling
        sub qword[screen_counter], 160
    .quit:
    popaq
    ret
;*******************************************************************************************************************

print_mac_address:  ; A routine to print a 64-bit value stored in rdi in hexa decimal (4*4 = 16 hexa digits)
pushaq
mov rbx,0x0B8000                ; set RBX to the start of the video memory-mapped I/O
    add bx,[start_location]     ; Store the start location for printing in BX
    xor rcx,rcx
    mov cl,byte [hexa_pad]                                ; Set loop counter for 16 iterations, one for each digit (16 * 4 = 64 max reg size)

    mov rax, VIDEO_BUFFER_EFFECTIVE_ADDRESS         ; set rax to video buffer io
    cmp byte [pit_bool], 1                          ; compare boolean variable to 1 
        jne .loop
            xor rdx, rdx
            .reset_first_line:
                mov word[rax], 0x1020
                inc rdx
                add rax, 2
                cmp rdx, 80
                jl .reset_first_line
    .loop:                                      ; Loop on all 4 digits
            mov rsi,rdi                         ; Move rdi into rsi
            shr rsi,0x4                         ; Shift rsi 4 bits right so that we are left with 4 bits (0-15) which is the index of the hexa digit in a created array 
            and rsi,0xF                         ; and with 1111 b
            mov al,[hexa_digits+rsi]            ; get the corresponding hexadcimal digit from the stored array           
            mov byte [rbx],al      ; move the hexadecimal digit into the memory buffer
            inc rbx                ; Increment current video location
            mov byte [rbx], 1Eh    ; Background = Blue , font color = yellow
            inc rbx                ; Increment current video location

            shl rdi,0x4                          ; Shift rdi 4 bits to the left to position the next digit corectly 
            dec rcx                              ; decrement loop counter by 1
            cmp rcx,0x0                          ; check if counter == 0
            jg .loop                             ; if greater, then Loop again until we finish print 4 digits
    add [start_location],word 0x4                ; increment the prinitng location with 32 = 16 iteration * 2 bytes each to avoid overwriting memory 
    add qword[screen_counter], 0x8 ; 
    cmp qword[screen_counter], VIDEO_SIZE
    jl .quit 
        call video_scrolling
        sub qword[screen_counter], 160
    .quit:
    popaq
    ret

;*******************************************************************************************************************

;;;     parameter is rsi 

video_print:
    pushaq                    ; takes a snapshot of the registers 
    mov rbx,0x0B8000          ; move into RBX the start location of the video memory of the text mode
    add bx,[start_location]   ; Store the start location for printing in BX
    xor rcx,rcx               ; zero out rcx 

video_print_loop:           ; Loop for a character by charcater processing
    lodsb                   ; store al into si 
    cmp al,13               ; Check carriage return character to stop printing
    je out_video_print_loop ; If so get out
    cmp al,0                ; Check null terminator character to stop printing
    je out_video_print_loop1 ; If so get out
    
    
    cmp al, 10             ; new line char 
    jne sk                  ; if it is not a new line character, then jmp to skip
        mov ax, bx              ; set ax to bx which is the location 
        mov r8, 0xA0            ; set r8 = 160 d
        xor rdx,rdx             ; zero rdx for division
        div r8                  ; divide the location by 160 and get the remainder 
        sub r8, rdx             ; see how far from the end of the line are we
        ;mov rdi, r8
        ;call bios_print_hexa
        .loop:
            mov word[rbx], 0x1020
            add rbx, 2
            sub r8, 0x2
            cmp r8, 0x0
            jg .loop        
            ;mov qword[start_location],rbx
        ;add rbx, r8             ; move the cursor by this amount (now we are in the first byte off the new line)
    sk:


    mov byte [rbx],al    ; if not new line or carriage return or null then Store the charcater into current video location
    inc rbx                ; Increment current video location
    mov byte [rbx],1Eh    ; Blue Backgroun Yellow font
    inc rbx                ; Increment current video location
    add rcx, 2              ; increment rcx by 2 
    add qword[screen_counter], 2 ; 
    cmp qword[screen_counter], VIDEO_SIZE
    jl s 
        call video_scrolling
        sub qword[screen_counter], 160
    s:
    jmp video_print_loop    ; Loop again to print next character
    
out_video_print_loop:           ; if carriage return 
    xor rax,rax             ; zero out rax
    mov ax,[start_location] ; set ax to the starting point for printing 
    mov r8, 160             ; set r8 to 160 d
    xor rdx,rdx             ; zero rdx for division
    add ax, 0xA0            ; Add a line to the value of start location (80 x 2 bytes)
    div r8                  ; get index of which row we are in 
    xor rdx,rdx             ; zero out remainder (not used)
    mul r8                  ; multiply row index by 160 to get index of the new line        
    mov [start_location],ax         ; move index to starting location
    jmp finish_video_print_loop     ; exit
out_video_print_loop1:
    mov ax,[start_location]     ; set ax to the starting point for printing
    add ax,cx                   ; add the number of characters we printed to the current location
    mov [start_location],ax     ; set the start_location to the next available offset to print
finish_video_print_loop:
    popaq                   ; restore back registers
ret                         ; return

;*******************************************************************************************************************

video_cls_64: 
        pushaq
            
            xor edx, edx                                ; zero out edx used as a counter
            mov ecx, VIDEO_BUFFER_EFFECTIVE_ADDRESS     ; set ecx to the start of the video memory-mapped I/O 
            mov ax, 0x1020                              ; blue background, empty space

            clear_loop:

            mov word[ecx], ax           ; move value to printed to ECX (empty space)
            add edx, 2                  ; increment loop counter by 2
            add ecx, 2                  ; move printing location by 2 bytes

            cmp edx, VIDEO_SIZE         ; if we hit the end of the screen, exit. else, loop
            jl clear_loop       

            mov qword[start_location],0x0    ; set offset to 0 to set the cursor to the top-left corner of the screen    
            mov qword[screen_counter], 0x0    
        popaq
        ret

;*******************************************************************************************************************


video_scrolling:
        pushaq
        mov rax, VIDEO_BUFFER_EFFECTIVE_ADDRESS         ; set rax to video buffer io
        cmp byte [pit_bool], 1                          ; compare boolean variable to 1 
        jne .pit_skip
            xor rdx, rdx
            .reset_first_line:
                mov word[rax], 0x1020
                inc rdx
                add rax, 2
                cmp rdx, 80
                jl .reset_first_line
        .pit_skip:
        xor rbx, rbx                                    ; zero out rbx
        add rbx, rax                                    ; rbx = rax (memory mapped for video printing)
        add rbx, 160                                    ; set it to the start of the next line

        mov rcx, VIDEO_BUFFER_EFFECTIVE_ADDRESS         ; rcx equal the start of the memory
        add rcx, VIDEO_SIZE                             ; rcx += the bytes on the screen (now points at the start of the first line under the display)
        add rcx, 160                                    ; add 160 to rcx to point to the last character of this new line
        
        copy_loop:
        
            mov r8, qword[rbx]          ; read value from rbx to r8 (8 bytes = 4 entries)
            mov qword[rax], r8          ; write value from r8 to rax (8 bytes = 4 entries)
            add rbx, 8                  ; increment reading pointer by 8 bytes (4 entries)
            add rax, 8                  ; increment writing pointer by 8 bytes (4 entries)
        cmp rbx, rcx                    ; compare reading pointer to max screen size 
        jl copy_loop                    ; if less continue looping until the reading pointer reaches end of screen

        mov r8, 0xA0                    ; set r8 to 160
        sub qword [start_location], r8  ; subtract from the offset 160 to point to previous row

        popaq
        ret
