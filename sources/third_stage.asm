[ORG 0x10000]

[BITS 64]


mov rsi,hello_third_stage
call video_print

call new_page_table

;call video_cls_64
mov rsi,finished_page_walk
call video_print

;call video_cls_64
;mov byte[pit_bool], 1
;xor r8,r8
;xor rax,rax
;xor rsi,rsi
;scroll_test: 
;    mov rsi, r8
;    call bios_print_hexa
;    mov rsi, newline2
;    call video_print
;    add rax, 1
;    inc r8
;    cmp r8, 40 
;    jge Kernel
;    cmp rax, 14
;    jle skipper
;    xor rax, rax
;    skipper:
;    jmp scroll_test
;mov byte[pit_bool], 0
;
;jmp kernel_halt

Kernel:

;call PCI_read
bus_loop:
    device_loop:
        function_loop:
            call get_pci_device
            inc byte [function]
            cmp byte [function],8
        jne device_loop
        inc byte [device]
        mov byte [function],0x0
        cmp byte [device],32
        jne device_loop
    inc byte [bus]
    mov byte [device],0x0
    cmp byte [bus],255
    jne bus_loop

channel_loop:
    mov qword [ata_master_var],0x0
    master_slave_loop:
        mov rdi,[ata_channel_var]
        mov rsi,[ata_master_var]
        call ata_identify_disk
        inc qword [ata_master_var]
        cmp qword [ata_master_var],0x2
        jl master_slave_loop

    inc qword [ata_channel_var]
    inc qword [ata_channel_var]
    cmp qword [ata_channel_var],0x4
    jl channel_loop
    
; ata (bonus part); to be called here
;mov rax, 15000
;loop:
;mov rsi,hello_world_str
;call video_print
;dec rax
;cmp rax,0x0
;jl loop

call init_idt

call setup_idt

mov rsi,hello_world_str
call video_print

kernel_halt: 
    hlt
    jmp kernel_halt


;*******************************************************************************************************************
      %include "sources/includes/third_stage/pushaq.asm"
      %include "sources/includes/third_stage/pic.asm"
      %include "sources/includes/third_stage/idt.asm"
      %include "sources/includes/third_stage/pci.asm"
      %include "sources/includes/third_stage/video.asm"
      %include "sources/includes/third_stage/pit.asm"
      %include "sources/includes/third_stage/ata.asm"
      %include "sources/includes/third_stage/Memory_Tester.asm"      
      %include "sources/includes/third_stage/full_page_table.asm"
      %include "sources/includes/third_stage/page_table.asm"
      %include "sources/includes/third_stage/bit_map.asm"
      %include "sources/includes/third_stage/e1000.asm"
      %include "sources/includes/third_stage/ip.asm"

;*******************************************************************************************************************


colon db ':' , 0
comma db ',' , 0
newline db 13,0
newline2 db 10,0
screen_counter dq 0
pit_bool db 0
end_of_string  db 13        ; The end of the string indicator
start_location   dq  0x0  ; A default start position (Line # 8)
hexa_pad db 0x10

    hello_world_str db 'Hello all here',13, 0
    hello_third_stage db "Welcome to 64-bit Mode :) ",13,0
    finished_page_walk db 'Finished memory mapping and testing',13,0
    reserve_idt db 'Reserving space for idt...',10,10,0
    entered_pit db 'Entered pit counter...',13,0

    ata_channel_var dq 0
    ata_master_var dq 0

    new_page_address dq 0
    check_byte dq 0
    max_physical_address dq 0

    vaddress dq 0
    paddress dq 0

    bus db 0
    device db 0
    function db 0
    offset db 0
    hexa_digits       db "0123456789ABCDEF"         ; An array for displaying hexa decimal numbers
    ALIGN 4


times 65024-($-$$) db 0
