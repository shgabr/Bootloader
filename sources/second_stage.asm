;******************************* second_stage.asm ************************************

ORG 0xC000        ; Since this code will be loaded at 0xC000 we need all the addresses to be relative to 0xC000
                  ; The ORG directive tells the linker to generate all addresses relative to 0xC000   
BITS 16

%define M_REGIONS_SEGMENT           0x2000
%define PTR_MEM_REGIONS_COUNT       0x0000
%define PTR_MEM_REGIONS_TABLE       0x18

%define CODE_SEG     0x0008         ; Code segment selector in GDT
%define DATA_SEG     0x0010         ; Data segment selector in GDT
;********************************* Main Program **************************************
      call bios_cls
      mov si, greeting_msg    ; store the address of the string msg into si so we can use lodsb later.
      call bios_print         ; Call the bios_print subroutine to print msg on the screen. 
      call get_key_stroke     ; Wait for key storke to jump to second boot stage
      call check_a20_gate
      
;      call bios_cls
      mov si, long_mode_message    ; store the address of the string msg into si so we can use lodsb later.
      call bios_print         ; Call the bios_print subroutine to print msg on the screen. 
      call get_key_stroke     ; Wait for key storke 
      call check_long_mode
      
;      call bios_cls
      mov si, memory_Scan_message    ; store the address of the string msg into si so we can use lodsb later.
      call bios_print         ; Call the bios_print subroutine to print msg on the screen. 
      call get_key_stroke     ; Wait for key storke 
      call memory_scanner
      
     
;      call bios_cls
      mov si, memory_print_message    ; store the address of the string msg into si so we can use lodsb later.
      call bios_print         ; Call the bios_print subroutine to print msg on the screen. 
      call get_key_stroke     ; Wait for key storke 
      call print_memory_regions
      
      
      call get_key_stroke     ; Wait for key storke 

      call build_page_table 
      mov si, pml4_page_table_msg    ; store the address of the string msg into si so we can use lodsb later.
      call bios_print         ; Call the bios_print subroutine to print msg on the screen.
      call get_key_stroke     ; Wait for key storke 

      call disable_pic

;      mov si, reload_idt    ; store the address of the string msg into si so we can use lodsb later.
;      call bios_print         ; Call the bios_print subroutine to print msg on the screen.

      call load_idt_descriptor
      call video_cls_16_2

      call switch_to_long_mode

      ;call video_cls_16_2

      


      hang:                   ; An infinite loop just in case interrupts are enabled. More on that later.
            hlt               ; Halt will suspend the execution. This will not return unless the processor got interrupted.
            jmp hang          ; Jump to hang so we can halt again.
;************************************* Data ******************************************


greeting_msg      db "___  ___      _____ _____          ___  _   _ _____ ", 13, 10
                  db "|  \/  |     |  _  /  ___|  ____  / _ \| | | /  __ \", 13, 10
                  db "| .  . |_   _| | | \ `--.  / __ \/ /_\ \ | | | /  \/", 13, 10
                  db "| |\/| | | | | | | |`--. \/ / _` |  _  | | | | |    ", 13, 10
                  db "| |  | | |_| \ \_/ /\__/ / | (_| | | | | |_| | \__/\", 13, 10
                  db "\_|  |_/\__, |\___/\____/ \ \__,_\_| |_/\___/ \____/", 13, 10
                  db "         __/ |             \____/                   ", 13, 10
                  db "        |___/                                       ", 13, 10
                  db " _____               _   _                          ", 13, 10
                  db "|  __ \             | | (_)                         ", 13, 10
                  db "| |  \/_ __ ___  ___| |_ _ _ __   __ _ ___          ", 13, 10
                  db "| | __| '__/ _ \/ _ \ __| | '_ \ / _` / __|         ", 13, 10
                  db "| |_\ \ | |  __/  __/ |_| | | | | (_| \__ \         ", 13, 10
                  db " \____/_|  \___|\___|\__|_|_| |_|\__, |___/         ", 13, 10
                  db "                                  __/ |             ", 13, 10
                  db "                                 |___/              ", 13, 10
                  db " _____  _____ _____  _____       _____  _____  __   ", 13, 10
                  db "/  __ \/  ___/  __ \|  ___|     / __  \|____ |/  |  ", 13, 10
                  db "| /  \/\ `--.| /  \/| |__ ______`' / /'    / /`| |  ", 13, 10
                  db "| |     `--. \ |    |  __|______| / /      \ \ | |  ", 13, 10
                  db "| \__/\/\__/ / \__/\| |___      ./ /___.___/ /_| |_ ", 13, 10
                  db " \____/\____/ \____/\____/      \_____/\____/ \___/ ", 13, 10
                  db "Second Stage Boot Loader is ready, press any key to resume",13,10,0  

done_msg    db 'A lot should be done here',13,10,0
long_mode_message db 'I am going to check for long mode now', 13, 10, 0
memory_Scan_message db 'I am going to scan the memory now', 13, 10, 0
memory_print_message db 'I am going to print the scanned memory info',13,10,0
hexa_digits       db "0123456789ABCDEF"         ; An array for displaying hexa decimal numbers
hexa_prefix                   db '0x',0
newline                       db 13,10,0
space                         db ' ',0
double_space                  db '  ',0
unknown_a20_error db 'Unknown A20 error',13,10,0
keyboard_controller_error_msg db 'Keyboard controller is in secure mode',13,10,0
a20_function_not_supported_msg db 'A20 function not supported',13,10,0
a20_enabled_msg db 'A20 is enabled',13,10,0
a20_not_enabled_msg db 'A20 is not enabled',13,10,0
cpuid_not_supported db 'CPUID not supported',13,10,0
cpuid_supported db 'CPUID supported',13,10,0
long_mode_supported_msg db 'Long mode supported',13,10,0
long_mode_not_supported_msg db 'Long mode not supported !!!!',13,10,0
memory_scan_failed_msg db 'Memory Scan Failed',13,10,0
read_region_msg db 'read memory region',13,10,0
pic_disabled_msg db 'PIC disabled',13,10,0
pml4_page_table_msg db 'PML4 page table created successfully',13,10,0
reload_idt db 'reloading_idt. No BIOS interrupts after this point !!',13,10,0
video_x db 0
video_y db 0
;**************************** Subroutines/Functions **********************************
      %include "sources/includes/first_stage/bios_cls.asm"
      %include "sources/includes/first_stage/bios_print.asm"
      %include "sources/includes/first_stage/bios_print_hexa.asm"
      %include "sources/includes/first_stage/get_key_stroke.asm"
      %include "sources/includes/second_stage/a20_gate.asm"
      %include "sources/includes/second_stage/check_long_mode.asm"
      %include "sources/includes/second_stage/memory_scanner.asm"
      %include "sources/includes/second_stage/pic.asm"
      %include "sources/includes/second_stage/idt.asm"
      %include "sources/includes/second_stage/video.asm"
      %include "sources/includes/second_stage/gdt.asm"
      %include "sources/includes/second_stage/page_table.asm"
      %include "sources/includes/second_stage/longmode.asm"
        

;**************************** Long Mode 64-bit  **********************************
[BITS 64]

LM64:

    mov ax, DATA_SEG ; Set data segment to GDT Data Segment selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    jmp 0x10000

lm_hang:             ; Halt Loop
      hlt
      jmp lm_hang

times 4096-($-$$) db 0

