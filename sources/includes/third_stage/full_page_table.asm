%define MEM_REGIONS_SEGMENT         0x2000
%define PTR_MEM_REGIONS_COUNT       0x1000
%define PTR_MEM_REGIONS_TABLE       0x0018
%define effective_reg_count_ad      0x21000
%define page_table_address          0x100000
%define present_read_write          0x3



new_page_table:

        pushaq                                          ;

        mov rax, qword[effective_reg_count_ad]          ; get count from first 24 bytes of memory scanner
        mov rbx, 24                                     ; rbx = 24
        mul rbx                                         ; get last memory region offset
        add rax, effective_reg_count_ad                 ; got last memory region effective address
        mov rbx, qword[rax]                             ; got 8 bytes (base address)
        mov rdx, qword[rax + 0x8]                       ; got 8 bytes (size of region)
        add rdx, rbx                                    ; full physical maximum address
        mov qword[max_physical_address],rdx             ; move physical maximum address to memory variable          

        ; Initialize PML4
        mov rdi, 0x100000                               ; save the starting address at rdi
        xor rax, rax                                    ; Zero out rax
        mov rcx, 0x200                                  ; rep stosq needs this as a counter set to 512
        cld                                             ; zero out the direction flag
        rep stosq                                       ; store zero into rdi (0x100000)
                                                        ; this will happen for 512 times and each time increments edi
        mov [new_page_address],rdi                      ; move pml4 address into counter

        xor rdx,rdx                                     ; physical address
        xor rbx,rbx                                     ; virtual address
        
        mov r8,0x18                                     ; r8 = 24
        add r8,effective_reg_count_ad                   ; point to first memory region (r8 = 0x20018)
        mov r9, qword [r8]                              ; base address
        mov r10, qword [r8+8]                           ; size of region
        add r10, r9                                     ; maximum address of region
        xor r11,r11                                     ; zero out r11
        mov r11d, dword [r8+16]                         ; type of region

        add r8,0x18
        add r8,0x18
        mov r10,0x100000
                

        memory_loop:
                

                cmp rdx, 0x200000                       ; compare physical address with 1 mb        
                jl map                                  ; if less than then map

                mov rdi, 0x100000                   ; move pml4 address to rdi
                mov cr3, rdi                        ; move pml4 address to cr3
                
                        
                map:

                    mov r12, rbx                        ; set r12 to virtual address
                    shr r12, 0x27                       ; shift right by 39 to get pml4 offset
                    and r12, 0x1ff
                    shl r12, 0x3                        ; multiply pml4 offset by 8 to get cell index
                    add r12, 0x100000                   ; get effective address of pml4 entry

                    xor rax,rax                         ; zero out rax
                    cmp rax, qword [r12]                ; check if entry in pml4 is empty
                    jne skip_create_pdp                 ; if there is an entry then skip creation of pdp

                    mov rdi,[new_page_address]          ; get physical address of the previous page
                    mov rcx, 0x200                      ; rep stosq needs this as a counter set to 512
                    xor rax, rax                        ; Zero out eax
                    cld                                 ; zero out the direction flag
                    rep stosq                           ; this will happen for 512 times and each time increments edi    
                    mov [new_page_address],rdi          ; update next available location

                    ;and rdi,0xfffffffffffff000          ; remove last 12 bits
                    or rdi,0x3                          ; set present and read/wrte bits
                    sub rdi, 0x1000
                    mov [r12],rdi                       ; mov pdp address to pml4 entry
        

                    skip_create_pdp:
                    
                    mov r13, rbx                        ; set r13 to virtual address
                    shr r13, 0x1E                       ; shift right by 30 to get pdp offset
                    and r13, 0x1ff                      ; to remove 9-bits of pml4 offset
                    shl r13, 0x3                        ; multiply pdp offset by 8 to get cell index
                    mov r14, [r12]                      ; move pdp address to r14
                    and r14,0xfffffffffffff000          ; remove last 12 bits
                    add r13, r14                        ; get full effective address of pdp entry

                    xor rax,rax                         ; zero out rax
                    cmp rax, qword[r13]                 ; check if entry in pdp is empty
                    jne skip_create_pdt                 ; if there is an entry then skip creation of pdt

                    mov rdi,[new_page_address]          ; get physical address of the previous page
                    mov rcx, 0x200                      ; rep stosq needs this as a counter set to 512
                    xor rax, rax                        ; Zero out eax
                    cld                                 ; zero out the direction flag
                    rep stosq                           ; this will happen for 512 times and each time increments edi    
                    mov [new_page_address],rdi          ; update next available location

                    ;and rdi,0xfffffffffffff000          ; remove last 12 bits
                    or rdi,present_read_write           ; set present and read/wrte bits
                    sub rdi, 0x1000
                    mov [r13],rdi                       ; mov pdt address to pdp entry

                    skip_create_pdt: 

                    mov r14, rbx                        ; set r14 to virtual address
                    shr r14, 0x15                       ; shift right by 21 to get pdt offset
                    and r14, 0x1ff                      ; to remove 18-bits of pml4 & pdp offset
                    shl r14, 0x3                        ; multiply pdt offset by 8 to get cell index
                    mov r15, [r13]                      ; move pdt address to r15
                    and r15,0xfffffffffffff000          ; remove last 12 bits     
                    add r14, r15                        ; get full effective address of pdt entry

                    xor rax, rax                        ; zero out rax
                    cmp rax, qword[r14]                 ; check if entry in pdt is empty
                    jne skip_create_pte                 ; if there is an entry then skip creation of pte

                    mov rdi,[new_page_address]          ; get physical address of the previous page
                    mov rcx, 0x200                      ; rep stosq needs this as a counter set to 512
                    xor rax, rax                        ; Zero out eax
                    cld                                 ; zero out the direction flag
                    rep stosq                           ; this will happen for 512 times and each time increments edi    
                    mov [new_page_address],rdi          ; update next available location

                    ;and rdi,0xfffffffffffff000          ; remove last 12 bits
                    or rdi,present_read_write           ; set present and read/wrte bits
                    sub rdi, 0x1000
                    mov [r14],rdi                       ; mov pte address to pdt entry

                    skip_create_pte:

                    mov r15, rbx                        ; set r15 to virtual address
                    shr r15, 0xc                        ; shift right by 12 to get pte offset
                    and r15, 0x1ff                      ; to remove 27-bits of pml4 & pdp & pdt offset
                    shl r15, 0x3                        ; multiply pte offset by 8 to get cell index
                    mov r12, [r14]                      ; move pte address to r12
                    and r12,0xfffffffffffff000          ; remove last 12 bits
                    add r15, r12                        ; get full effective address of pte entry
                        
                    xor rax, rax                        ; zero out rax
                    cmp rax, qword[r15]                 ; check if entry in pte is empty       
                    jne skip_create_entry               ; if there is an entry then skip creation of entry

                    mov rax, rdx                        ; move physical address
                    or rax, present_read_write          ; set present and read/wrte bits
                    mov [r15], rax                      ; move physical address to pte entry

                
                    skip_create_entry:
                    
                    mov rax, [r15]                      ; set rax to physical address stored in pte entry
                    ;and rax,0xfffffffffffff000         ; remove last 12 bits
                    
                    
                    mov rdi, 0x225000                   ; rdi = 2.25 mb
                    cmp rdx, rdi                        ; cmp current physical address wih 2.25mb 
                    jl .contTEST                        ; if we didnt't map the first 2.25 mb, then we do not have a place to load bitmap in it 
                    je .initBitM                        ; if we reached the address, then initalize and load bitmap 
                    jmp .contTEST                       

                    .initBitM:
                    call bitmap_init                        ; call bitmap_init
                    
                    .contTEST:

                    cmp rdx, 0x225000                          ; if we are past 2.25 mb, call bitmap which would mark a bit inside a byte with 1
                    
                    jle no_bitmap
                        call bitmap
                    
                    no_bitmap: 
                    mov rdi, 0xFFFFF000                 ; if greater than FFFFF000, then do not test memory
                    cmp rax, rdi
                    jge .print                          
                    call Memory_Tester                  ; test physical address stored in pte entry by writing and reading from it
                    jmp .contINC                        ; to skip prinitng the colon
                    .print:
                    mov rsi, colon                      ; printt a colon 
                    call video_print                    ; call the prinitng function 
                    .contINC:
                    
                    add rbx,0x1000                      ; if we reached pte then increment virtual address by 4096

                dont_map:

                    add rdx,0x1000                      ; increment physical address by 4096

                    cmp rdx,r10                         ; compare physical address with max physical address of region
                    jl memory_loop                      ; if less than then dont get paramters of region

                    cmp rdx,qword[max_physical_address] ; compare physical address with max physical address
                    jge end                             ; if physical address is equal or greater than max physical address then end
                    
                    next_region:

                    add r8,0x18                         ; increment memory region pointer by 24 bytes
                    mov r9, qword [r8]                  ; base address of region
                    mov r10, qword [r8+8]               ; size of region
                    add r10,r9                          ; maximum address of region
                    xor r11,r11                         ; zero out r11
                    mov r11d, dword [r8+16]             ; get type of region

                    mov rdx, r9


                    cmp r11,0x1
                    jne next_region                     ; check the type 

                    jmp memory_loop                     ; loop again

        end:
 
                call video_cls_64
                mov rdi, rdx       
                call bios_print_hexa
                mov rsi,colon
                call video_print
                mov rdi, rbx
                call bios_print_hexa
                mov rsi, colon
                call video_print
                mov rdi, qword[max_physical_address]       
                call bios_print_hexa
                mov rsi,colon
                call video_print
                mov rsi, newline
                call video_print
         


            popaq                               
            ret





























