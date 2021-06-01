%define CODE_SEG     0x0008         ; Code segment selector in GDT
%define DATA_SEG     0x0010         ; Data segment selector in GDT

%define PAGE_TABLE_EFFECTIVE_ADDRESS    0x1000  ; Flat address of page table

switch_to_long_mode:

        ; configuring CR4 (responsible for enabling/disabling processor operations and extensions)
        ;mov eax, cr4
        mov eax, 10100000b                       ; set bit 5 and bit 7 (PAE & PGE)     
        mov cr4, eax                            ; move value from EAX to cr4

        ; configuring CR3 (should contain flat address of PML4 page table)
        mov edi,PAGE_TABLE_EFFECTIVE_ADDRESS    ; store in edi the flat address of the page table
        mov edx, edi
        mov cr3, edx                            ; mov value from EDI to cr3

        ; configuring EFER MSR (need to enable bit 8 which is the Long Mode Enablement bit)
        mov ecx, 0xC0000080                     ; store the EFER MSR identifier to ECX
        rdmsr                                   ; reads a MSR whose identifier is in ECX and stores MSR value in EDX:EAX
        or eax, 0x00000100                      ; to enable bit 8 of EFER MSR
        wrmsr                                   ; writes value in EDX:EAX back to EFER MSR

        ; configuring CR0 (enable paging and protected mode)
        mov ebx, cr0                            ; move value of CR0 to EBX
        or ebx, 0x80000001                      ; enable bit 0 and bit 31
        mov cr0, ebx                            ; set new value of CR0

        lgdt [GDT64.Pointer]    ; load GDT to register GDTR
        jmp CODE_SEG:LM64       ; set CS to the code segment in GDT and flush intruction cache

        ret                                     ; return