%define IDT_BASE_ADDRESS            0x40000 ;  0x4000:0x0000 which is free
%define IDT_HANDLERS_BASE_ADDRESS   0x41000 ;  0x4000:0x1000 which is free
%define IDT_P_KERNEL_INTERRUPT_GATE 0x8E; 1 00 0 1110 -> P DPL Z Int_Gate

struc IDT_ENTRY
.base_low         resw  1
.selector         resw  1
.reserved_ist     resb  1
.flags            resb  1
.base_mid         resw  1
.base_high        resd  1
.reserved         resd  1
endstruc

ALIGN 4                                    ; Make sure that the IDT starts at a 4-byte aligned address    
IDT_DESCRIPTOR:                            ; The label indicating the address of the IDT descriptor to be used with lidt
      .Size dw    0x1000                   ; Table size is zero (word, 16-bit) -> 256 x 16 bytes
      .Base dq    IDT_BASE_ADDRESS         ; Table base address is NULL (Double word, 64-bit)

; just in case if there are wrong entries in the array,it is just for verification
load_idt_descriptor:
   pushaq                   ; save all general purpose registers
      lidt [IDT_DESCRIPTOR] ; load the IDT descriptor
   popaq                    ; restore all general purpose registers
   ret
   


init_idt:         ; Intialize the IDT which is 256 entries each entry corresponds to an interrupt number
                  ; Each entry is 16 bytes long
                  ; Table total size if 4KB = 256 * 16 = 4096 bytes 
      pushaq

      ; save 4096 bytes using rep stosq like page table (0x400) from base

      mov rsi,reserve_idt
      call video_print
      mov rdi, IDT_BASE_ADDRESS                       ; save the starting address at rdi
      xor rax, rax                                    ; Zero out rax (value to be stored)
      mov rcx, 0x200                                  ; rep stosq needs this as a counter set to 1024
      cld                                             ; zero out the direction flag
      rep stosq                                       ; this will happen for 1024 times and each time increments edi
      
      popaq
      ret


register_idt_handler:                                     ; Store a handler into the handler array
                                                          ; RDI contains the interrupt number
                                                          ; RSI contains the handler address
      pushaq                                              ; Pushing the general registers into the stack
            shl rdi,3                                     ; multiply the interrupt number by 8
            mov [rdi+IDT_HANDLERS_BASE_ADDRESS],rsi       ; add interrupt number to  the base adress of the array and store the handler address in it
      popaq                                               ; pop out the registers from the stack
      ret

setup_idt:
             ; Setup and interrupt entry in the IDT
             ; RDI: Interrupt Number
             ; RSI: Address of the handler
      pushaq
            call configure_pic                  ; configure pic
            call set_irq_mask                   ; setup irq masks
            call setup_idt_irqs                 ; setup idt irqs
            call setup_idt_exceptions           ; setup idt exceptions
            call load_idt_descriptor            ; load idt descriptor
            call configure_pit                  ; configure pit
            call clear_irq_mask                 ; clear_irq_mask
      popaq
      ret


setup_idt_entry:                                                              ; RDI contains interrupt number
                                                                              ; RSI contains address of the handler

      pushaq
            shl rdi,4                                                         ; multiplying the interrupt number by 16
            add rdi,IDT_BASE_ADDRESS                                          ; adding rdi to the location where the table is stored,to get absolute address of the first byte
            mov rax,rsi                                                       ; let rax = address of the handler
            and ax,0xFFFF                                                     ; extracting the lower 16-bits
            mov [rdi+IDT_ENTRY.base_low],ax                                   ; moving lower 16-bits into rdi
            mov rax,rsi                                                       ; let rax = address of the handler
            shr rax, 16                                                       ; dividing it by 65536,to remove the lower 16-bits
            and ax,0xFFFF                                                     ; extracting the 16 bits
            mov [rdi+IDT_ENTRY.base_mid],ax                                   ; moving the 16 bits into base mid
            mov rax,rsi                                                       ; let rax = address of the handler
            shr rax, 32                                                       ; removing the 32 bits that was used
            and eax,0xFFFFFFFF                                                ; getting the last 32 bits
            mov [rdi+IDT_ENTRY.base_high],eax                                 ; moving the last 32 bits into base high
            mov [rdi+IDT_ENTRY.selector], byte 0x8                            ; storing in the selector value 8
            mov [rdi+IDT_ENTRY.reserved_ist], byte 0x0                        ; storing zero in reserved_ist
            mov [rdi+IDT_ENTRY.reserved], dword 0x0                           ; storing zero in reserved
            mov [rdi+IDT_ENTRY.flags], byte IDT_P_KERNEL_INTERRUPT_GATE       ; flags will automatically set to 0x8E
      popaq
      ret

idt_default_handler:
      pushaq
;            This is the default
      popaq
      ret

isr_common_stub:
     pushaq                                                 ; pushing the registers into the stack     
            cli                                             ; clear interrupt
            mov rdi,rsp                                     ; retrieving the interrupt number from the stack
            mov rax,[rdi+120]                               ; let rax = interrupt number
            shl rax,3                                       ; multiply the interrupt number by 8
            mov rax,[IDT_HANDLERS_BASE_ADDRESS+rax]         ; retrieve the entry corresponding to the interrupt number,rax should have the value of isr the is needed to be executed
            cmp rax,0                                       ; compare value of isr address to 0
            je .call_default                                ; if equal,then the entry is not configured ,jump to call default_handler
            call rax                                        ; else, call the value stored in rax
            jmp .out                                        ; exit the label
      .call_default:
             call idt_default_handler                       ; calling default_handler
      .out:
            popaq                                           ; pop out the general registers from the stack
            add rsp,16                                      ; getting rid of the two values: interrupt number and error code
            sti                                             ; not necessary to do this,as iretq will restore the eflag that contains the interrupt bit of original bit before the cli
            iretq                                           ; restore 5 values from the stack: EFlags,CS,EIP,SS,ESP

; need to be called in case of hardware interrupt
irq_common_stub:
    pushaq                                                  ; pushing the general registers into the stack
            cli                                             ; clear interrupt
            mov rdi,rsp                                     ; retrieving the interrupt number from the stack
            mov rax,[rdi+120]                               ; let rax = interrupt number
            shl rax,3                                       ; multiply the interrupt number by 8
            mov rax,[IDT_HANDLERS_BASE_ADDRESS+rax]         ; retrieve the entry corresponding to the interrupt number,rax should have the value of irq the is needed to be executed
            cmp rax,0                                       ; compare value of irq address to 0
            je .call_default                                ; if equal,then the entry is not configured ,jump to call default_handler 
            call rax                                        ; else, call the value stored in rax
            mov al,0x20                                     ; sending the end of interrupt (EOI) to the PIC controller
            out MASTER_PIC_COMMAND_PORT,al                  ; writing the value 32 to both ports of the PIC which will unlock the IRR (pending interrupt will stay pending until it receives the EOI)
            out SLAVE_PIC_COMMAND_PORT,al                   ; writing the value 32
            jmp .out                                        ; skip calling the default_handler
      .call_default:
            call idt_default_handler                        ; calling default_handler
      .out:
            popaq                  ; pop out the general registers from the stack
            add rsp,16             ; getting rid of the two values: interrupt number and error code
            sti                    ; not necessary to do this,as iretq will restore the eflag that contains the interrupt bit of original bit before the cli
            iretq                  ; restore 5 values from the stack: EFlags,CS,EIP,SS,ESP


setup_idt_irqs:
      pushaq
   
      mov rsi,irq0
      mov rdi,32
      call setup_idt_entry

      mov rsi,irq1
      mov rdi,33
      call setup_idt_entry

      mov rsi,irq2
      mov rdi,34
      call setup_idt_entry

      mov rsi,irq3
      mov rdi,35
      call setup_idt_entry

      mov rsi,irq4
      mov rdi,36
      call setup_idt_entry

      mov rsi,irq5
      mov rdi,37
      call setup_idt_entry

      mov rsi,irq6
      mov rdi,38
      call setup_idt_entry

      mov rsi,irq7
      mov rdi,39
      call setup_idt_entry

      mov rsi,irq8
      mov rdi,40
      call setup_idt_entry
      
      mov rsi,irq9
      mov rdi,41
      call setup_idt_entry

      mov rsi,irq10
      mov rdi,42
      call setup_idt_entry

      mov rsi,irq11
      mov rdi,43
      call setup_idt_entry

      mov rsi,irq12
      mov rdi,44
      call setup_idt_entry

      mov rsi,irq13
      mov rdi,45
      call setup_idt_entry
      
      mov rsi,irq14
      mov rdi,46
      call setup_idt_entry

      mov rsi,irq15
      mov rdi,47
      call setup_idt_entry

      popaq
      ret


setup_idt_exceptions:
      pushaq
      
      mov rsi,isr0
      mov rdi,0
      call setup_idt_entry
      
      mov rsi,isr1
      mov rdi,1
      call setup_idt_entry 
      
      mov rsi,isr2
      mov rdi,2
      call setup_idt_entry
      
      mov rsi,isr3
      mov rdi,3
      call setup_idt_entry 
      
      mov rsi,isr4
      mov rdi,4
      call setup_idt_entry

      mov rsi,isr5
      mov rdi,5
      call setup_idt_entry

      mov rsi,isr6
      mov rdi,6
      call setup_idt_entry

      mov rsi,isr7
      mov rdi,7
      call setup_idt_entry

      mov rsi,isr8
      mov rdi,8
      call setup_idt_entry

      mov rsi,isr9
      mov rdi,9
      call setup_idt_entry

      mov rsi,isr10
      mov rdi,10
      call setup_idt_entry

      mov rsi,isr11
      mov rdi,11
      call setup_idt_entry
      
      mov rsi,isr12
      mov rdi,12
      call setup_idt_entry

      mov rsi,isr13
      mov rdi,13
      call setup_idt_entry

      mov rsi,isr14
      mov rdi,14
      call setup_idt_entry
      
      mov rsi,isr15
      mov rdi,15
      call setup_idt_entry

      mov rsi,isr16
      mov rdi,16
      call setup_idt_entry

      mov rsi,isr17
      mov rdi,17
      call setup_idt_entry

      mov rsi,isr18
      mov rdi,18
      call setup_idt_entry

      mov rsi,isr19
      mov rdi,19
      call setup_idt_entry

      mov rsi,isr20
      mov rdi,20
      call setup_idt_entry

      mov rsi,isr21
      mov rdi,21
      call setup_idt_entry

      mov rsi,isr22
      mov rdi,22
      call setup_idt_entry

      mov rsi,isr23
      mov rdi,23
      call setup_idt_entry

      mov rsi,isr24
      mov rdi,24
      call setup_idt_entry

      mov rsi,isr25
      mov rdi,25
      call setup_idt_entry

      mov rsi,isr26
      mov rdi,26
      call setup_idt_entry

      mov rsi,isr27
      mov rdi,27
      call setup_idt_entry

      mov rsi,isr28
      mov rdi,28
      call setup_idt_entry

      mov rsi,isr29
      mov rdi,29
      call setup_idt_entry

      mov rsi,isr30
      mov rdi,30
      call setup_idt_entry

      mov rsi,isr31
      mov rdi,31
      call setup_idt_entry

      popaq
      ret

; This macro will be used with exceptions that does not push error codes on the stack
; NOtice that we push first a zero on the stack to make it consistent with other excptions
; that pushes an error code on the stack
%macro ISR_NOERRCODE 1
  [GLOBAL isr%1]
  isr%1:
      cli
      push qword 0
      push qword %1
      jmp isr_common_stub
%endmacro

; This macro will be used with exceptions that push error codes on the stack
; Notice that we here push only the interrupt number which is passed as a parameter to the macro
%macro ISR_ERRCODE 1
  [GLOBAL isr%1]
  isr%1:
      cli
      push qword %1
      jmp isr_common_stub
%endmacro


; This macro will be used with the IRQs generated by the PIC
%macro IRQ 2
  global irq%1
  irq%1:
      cli
      push qword 0
      push qword %2
      jmp irq_common_stub
%endmacro



ISR_NOERRCODE 0
ISR_NOERRCODE 1
ISR_NOERRCODE 2
ISR_NOERRCODE 3
ISR_NOERRCODE 4
ISR_NOERRCODE 5
ISR_NOERRCODE 6
ISR_NOERRCODE 7
ISR_ERRCODE   8
ISR_NOERRCODE 9
ISR_ERRCODE   10
ISR_ERRCODE   11
ISR_ERRCODE   12
ISR_ERRCODE   13
ISR_ERRCODE   14
ISR_NOERRCODE 15
ISR_NOERRCODE 16
ISR_NOERRCODE 17
ISR_NOERRCODE 18
ISR_NOERRCODE 19
ISR_NOERRCODE 20
ISR_NOERRCODE 21
ISR_NOERRCODE 22
ISR_NOERRCODE 23
ISR_NOERRCODE 24
ISR_NOERRCODE 25
ISR_NOERRCODE 26
ISR_NOERRCODE 27
ISR_NOERRCODE 28
ISR_NOERRCODE 29
ISR_NOERRCODE 30
ISR_NOERRCODE 31


IRQ   0,    32
IRQ   1,    33
IRQ   2,    34
IRQ   3,    35
IRQ   4,    36
IRQ   5,    37
IRQ   6,    38
IRQ   7,    39
IRQ   8,    40
IRQ   9,    41
IRQ  10,    42
IRQ  11,    43
IRQ  12,    44
IRQ  13,    45
IRQ  14,    46
IRQ  15,    47


isr255:
        iretq
