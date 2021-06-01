%define MEM_REGIONS_SEGMENT         0x2000
%define PTR_MEM_REGIONS_COUNT       0x0000
%define PTR_MEM_REGIONS_TABLE       0x0018
%define effective_reg_count_ad      0x20000
%define page_table_address          0x100000

;    24 bytes 
;    8 bytes = address
;    8 bytes = length or size
;    4 bytes = type 1 or type 2 

;       example of virtual address
;        000000000,000000000,000000000,000000001,001000010000
;       PML4 9bits|PDP 9bits|PDT 9bits|PTE 9bits|Offset 12bits
;

; parameters:
; [vaddress] -> virtual address
; [paddress] -> physical address


    map_page:
        pushaq
            mov rbx, [vaddress]
            mov rdx, [paddress]

            mov r12, rbx                        ; set r12 to virtual address
            shr r12, 0x27                       ; shift right by 39 to get pml4 offset
            and r12, 0x1ff
            shl r12, 0x3                        ; multiply pml4 offset by 8 to get cell index
            add r12, 0x100000                   ; get effective address of pml4 entry
            xor rax,rax                         ; zero out rax
            cmp rax, qword [r12]                ; check if entry in pml4 is empty
            jne .skip_create_pdp                 ; if there is an entry then skip creation of pdp
            mov rdi,[new_page_address]          ; get physical address of the previous page
            mov rcx, 0x200                      ; rep stosq needs this as a counter set to 512
            xor rax, rax                        ; Zero out eax
            cld                                 ; zero out the direction flag
            rep stosq                           ; this will happen for 512 times and each time increments edi    
            mov [new_page_address],rdi          ; update next available location
            or rdi,0x3                          ; set present and read/wrte bits
            sub rdi, 0x1000
            mov [r12],rdi                       ; mov pdp address to pml4 entry

            .skip_create_pdp:
            
            mov r13, rbx                        ; set r13 to virtual address
            shr r13, 0x1E                       ; shift right by 30 to get pdp offset
            and r13, 0x1ff                      ; to remove 9-bits of pml4 offset
            shl r13, 0x3                        ; multiply pdp offset by 8 to get cell index
            mov r14, [r12]                      ; move pdp address to r14
            and r14,0xfffffffffffff000          ; remove last 12 bits
            add r13, r14                        ; get full effective address of pdp entry
            xor rax,rax                         ; zero out rax
            cmp rax, qword[r13]                 ; check if entry in pdp is empty
            jne .skip_create_pdt                 ; if there is an entry then skip creation of pdt
            mov rdi,[new_page_address]          ; get physical address of the previous page
            mov rcx, 0x200                      ; rep stosq needs this as a counter set to 512
            xor rax, rax                        ; Zero out eax
            cld                                 ; zero out the direction flag
            rep stosq                           ; this will happen for 512 times and each time increments edi    
            mov [new_page_address],rdi          ; update next available location
            or rdi,present_read_write           ; set present and read/wrte bits
            sub rdi, 0x1000
            mov [r13],rdi                       ; mov pdt address to pdp entry

            .skip_create_pdt: 

            mov r14, rbx                        ; set r14 to virtual address
            shr r14, 0x15                       ; shift right by 21 to get pdt offset
            and r14, 0x1ff                      ; to remove 18-bits of pml4 & pdp offset
            shl r14, 0x3                        ; multiply pdt offset by 8 to get cell index
            mov r15, [r13]                      ; move pdt address to r15
            and r15,0xfffffffffffff000          ; remove last 12 bits     
            add r14, r15                        ; get full effective address of pdt entry
            xor rax, rax                        ; zero out rax
            cmp rax, qword[r14]                 ; check if entry in pdt is empty
            jne .skip_create_pte                 ; if there is an entry then skip creation of pte
            mov rdi,[new_page_address]          ; get physical address of the previous page
            mov rcx, 0x200                      ; rep stosq needs this as a counter set to 512
            xor rax, rax                        ; Zero out eax
            cld                                 ; zero out the direction flag
            rep stosq                           ; this will happen for 512 times and each time increments edi    
            mov [new_page_address],rdi          ; update next available location
            or rdi,present_read_write           ; set present and read/wrte bits
            sub rdi, 0x1000
            mov [r14],rdi                       ; mov pte address to pdt entry

            .skip_create_pte:

            mov r15, rbx                        ; set r15 to virtual address
            shr r15, 0xc                        ; shift right by 12 to get pte offset
            and r15, 0x1ff                      ; to remove 27-bits of pml4 & pdp & pdt offset
            shl r15, 0x3                        ; multiply pte offset by 8 to get cell index
            mov r12, [r14]                      ; move pte address to r12
            and r12,0xfffffffffffff000          ; remove last 12 bits
            add r15, r12                        ; get full effective address of pte entry
            xor rax, rax                        ; zero out rax

            mov rax, rdx                        ; move physical address
            or rax, present_read_write          ; set present and read/wrte bits
            mov [r15], rax                      ; move physical address to pte entry

            mov rdi, 0x100000                   ; move pml4 address to rdi
            mov cr3, rdi                        ; move pml4 address to cr3            

        popaq 
        ret 


reload_page_table:
    pushaq

    mov rdi, 0x100000                   ; move pml4 address to rdi
    mov cr3, rdi                        ; move pml4 address to cr3

    popaq
    ret