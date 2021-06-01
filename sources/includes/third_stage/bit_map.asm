%define bitmap_base_address          0x200000
%define max_bits_size                0x100000    ; i.e. 2^17 = 2^32 / (2^12)
%define max_bytes_size               0x20000     ; i.e. 2^17 = 2^32 / (8 * 2^12)
%define physcial_frame_size          0x1000
%define byte_size                    0x8

bitmap_init:

    pushaq

    mov rdi, bitmap_base_address    ; add 4k to get the next available location to create a memory page
    mov rcx, max_bytes_size         ; rep stosd needs this as a counter set to 4096
    shr rcx,3                       ; because the rep stosq stores 8 bytes of zeros each iteration
    xor rax, rax                    ; Zero out eax
    cld                             ; zero out the direction flag
    rep stosq                       ; this will happen for 4096 times and each time increments edi

    popaq

ret

bitmap:
    
    pushaq

    ; rbx --> bit index
    ; rax --> byte index
    ; rdx --> bit index inside byte
    ; rcx --> base_address + byte index

        mov rax, rdx

    ;   physical address (rax) / 4k = index of bit in the bitmap
        xor rdx, rdx
        mov r11, physcial_frame_size
        div r11                         ; rax / 4k --> quotient in rax = index of bit inside the bitmap array
        mov rbx,rax                     ; now, ebx contains the index of bit inside the bitmap array
    
    
    ;   bit index / byte size (8) = byte index in the bitmap
        xor rdx, rdx
        mov r11, byte_size
        div r11

    ;   base_address + byte ----> bit mod 8    

        mov rcx,bitmap_base_address
        add rcx,rax
    
    ;   setting the rdx bit to 1

        mov sil,byte[rcx]
        xor rdi,rdi
        mov rdi,7
        sub rdi,rdx     ; rdi = 7 - rdx
        xor rdx,rdx
        mov rdx,2
        
        push rcx
        mov cl,dil
        shl rdx,cl     ; rdx = 2^(rdi)
        pop rcx

    xor r8,r8   ; indicator of whether the bit is free or not
    mov r8,1       ; we assume that the default is that it is available noted by '1'
    call check

        cmp r8,0
        je .skip_fill

        or sil,dl
        mov byte[rcx],sil
    

    .skip_fill:
    mov qword[check_byte], r8
    popaq

    ret


    check:

        mov rdi,rsi                   ; checking whether the index for the current physical frame contains 1 or not
        and rdi,rdx
        cmp rdi,0
        je .return

        mov r8,0

        .return:
    ret