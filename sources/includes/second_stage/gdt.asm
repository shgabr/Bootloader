GDT64:                          ; Global Descriptor Table.
 .Null: equ $ - GDT64           ; The null descriptor identifying the null.
        dw 0                    ; Lower 2 bytes of the descriptor's limit.
        dw 0                    ; Lower 2 bytes of the descriptor's base address.
        db 0                    ; Middle byte of the descriptor's base
        db 0                    ; A group of bit flags defining who has access to the memory
        db 0                    ; Upper 4 bits of the descriptor's limit.
        db 0                    ; Upper byte of the descriptor's base address.
 .Code: equ $ - GDT64           ; Code segment,The Kernel code descriptor.
        dw 0                    ; Lower 2 bytes of the code segment's limit
        dw 0                    ; Lower 2 bytes of the code segment's base address.
        db 0                    ; Middle byte of the code segment's base)
        db 10011000b            ; Set Present for valid selectors,Privilege 2 bits into 00 which is ring0,S which is the descriptor type,Executable to execture the code in this segment.
        db 00100000b            ; L=1 as we will use long mode.
        db 0                    ; Upper byte of the code segement's base address
 .Data: equ $ - GDT64           ; The Kernel data descriptor.
        dw 0                    ; Lower 2 bytes of the data descriptor's limit.
        dw 0                    ; Lower 2 bytes of the data descriptor's base address.
        db 0                    ; Middle byte of the descriptor's base.
        db 10010011b            ; Set present,ring0,RW(read/write) it is usually set in the data segment,Access bit to 1.
        db 00000000b            ; Zero out the flag.
        db 0                    ; Upper byte of the data descriptor's base address.
        
ALIGN 4                         ; The gdt table need to be padded on a four-byte boundary.
 dw 0                           ; Padding to make the "address of the GDT" field aligned on a 4-byte boundary
.Pointer:                       ; The GDT-pointer
 dw $ - GDT64 - 1               ; Size 16 bit which is Limit of the gdt, it is always 1 less than its true value.
 dd GDT64                       ; Base address of 32 bit and it will be extended to 64 bit.

 
