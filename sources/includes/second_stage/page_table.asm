%define PAGE_TABLE_BASE_ADDRESS 0x0000
%define PAGE_TABLE_BASE_OFFSET 0x1000
%define PAGE_TABLE_EFFECTIVE_ADDRESS 0x1000
%define PAGE_PRESENT_WRITE 0x3  ; 011b
%define MEM_PAGE_4K         0x1000

build_page_table:
    pusha                                   ; Save all general purpose registers on the stack

            ; This function need to be written by you.

 
        mov ax,PAGE_TABLE_BASE_ADDRESS          ; mov segment zero here and set es to it.
        mov es,ax

        mov edi,PAGE_TABLE_BASE_OFFSET          ; set edi to 0x1000 (equal 4k)
       
        ; Initialize 4 memory pages
        mov ecx, 0x1000 ; rep stosd needs this as a counter set to 4096
        xor eax, eax    ; Zero out eax
        cld             ; zero out the direction flag
        rep stosd       ; store zero into es:di (0x0000:0x1000)
                        ; this will happen for 4096 times and each time increments edi


        mov edi,PAGE_TABLE_BASE_OFFSET ; set edi to the offset 0x1000
        ; es:di is now 0x0000:0x1000 which is the address we want to store the page table in 
        ; PML4 is stored in es:di 

        lea eax, [es:di + MEM_PAGE_4K] ; load the effective address of PDP (the next 4k bytes) into eax
        or eax, PAGE_PRESENT_WRITE ; ORing it with 011 mark it as present and writable
        mov [es:di], eax           ; Store eax the address of PDP (0x2003) into the first entry of the PML4.

       
        add di,MEM_PAGE_4K   ; [es:di] = [0x0000:0x2000] now  
        lea eax, [es:di + MEM_PAGE_4K] ;load the effective address of PD (the next 4k bytes) into eax
        or eax, PAGE_PRESENT_WRITE ; ORing it with 011b mark it as present and writable
        mov [es:di], eax ; Store eax the address of PD (0x3003) into the first entry of the PDP.
       
        ; PD is equal to [0x0000:0x3000]
        add di,MEM_PAGE_4K
        lea eax, [es:di + MEM_PAGE_4K] ;load the effective address of PT (the next 4k bytes) into eax
        or eax, PAGE_PRESENT_WRITE ;; ORing it with 011b mark it as present and writable
        mov [es:di], eax ; Store eax the address of PT (0x4003) into the first entry of the PD.

        ; PT is now at [es:di] = [0x0000:0x4000]
        add di,MEM_PAGE_4K
        mov eax, PAGE_PRESENT_WRITE ; set eax to 3 so that each entry later is present and writable 
       
        .pte_loop: ; 512 entries each map 4k = 2 MB
                mov [es:di], eax    ; load eax (3 first time) and 0xX003 in the following iterations
                add eax, MEM_PAGE_4K    ; add 4k to eax 
                add di, 0x8             ; move to the next page table entry as each one is 8 bytes
                cmp eax, 0x200000 ; reached 2 MB ? less than > loop
        jl .pte_loop

    ;mov edi,PAGE_TABLE_EFFECTIVE_ADDRESS    ; store in edi the flat address of the page table
    ;mov cr3, edi                            ; mov value from EDI to cr3

    popa                                ; Restore all general purpose registers from the stack
    ret
