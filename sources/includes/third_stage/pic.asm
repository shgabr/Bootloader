%define MASTER_PIC_COMMAND_PORT     0x20
%define SLAVE_PIC_COMMAND_PORT      0xA0
%define MASTER_PIC_DATA_PORT        0x21
%define SLAVE_PIC_DATA_PORT         0xA1

; https://wiki.osdev.org/8259_PIC
; http://www.brokenthorn.com/Resources/OSDevPic.html 

    configure_pic:
        pushaq
    
        mov al,11111111b                    ; masking IRQs to disable pic 
        out MASTER_PIC_DATA_PORT,al         ; write to the data port of the pic 
        out SLAVE_PIC_DATA_PORT,al          ; write the same value to the slave controller 

        mov al,00010001b                    ; Set ICW1 with bit0: expect ICW4, set bit 4 to 1 for pic initialization 
        out MASTER_PIC_COMMAND_PORT,al      ; if more than 1 pic is there, write to all of them
        out SLAVE_PIC_COMMAND_PORT,al       ; so, we write to the master and the slave 
    
    ; write ICW2-4 to the data port 

    ; base address of the pic is in ICW-2
    ; since we have 8 IRQs for each pic, then we initialize master at 32 decimal then, slave would be at 40 decimal ( 32 + 8)
        mov al,0x20                         ; master on 32
        out MASTER_PIC_DATA_PORT,al
        mov al,0x28                         ; slave on 40
        out SLAVE_PIC_DATA_PORT,al

    ; ICW3 defines the pins that the pic controllers would use for communciation with each other  
        mov al,00000100b                    ; 80x86 architecture needs line 2 to for master-salave connection (IRQ2 is bit 2 0100b)
        out MASTER_PIC_DATA_PORT,al
        mov al,00000010b                    ; 2 is for IR line 2. we tell the data register of the slave 
        out SLAVE_PIC_DATA_PORT,al          ; Secondary PIC represents IR lines in 3 bits so for line 2 it is 10b

    ; ICW4 to set 80x86 mode
        mov al,00000001b                    ; bit0 sets 80x86 mode
        out MASTER_PIC_DATA_PORT,al
        out SLAVE_PIC_DATA_PORT,al
        
        mov al,0x0                          ; zero out the data registers of both PICs
        out MASTER_PIC_DATA_PORT,al         ; unmask IRQs
        out SLAVE_PIC_DATA_PORT,al
        
        popaq
        ret


    set_irq_mask:
        pushaq                                  ; Save general purpose registers on the stack
            mov rdx,MASTER_PIC_DATA_PORT      
            cmp rdi,15                          ; check if interrupt number is greater than 15 (0 -> 15 = 16 interrupt)
            jg .out                             ; if greater than 15, then exit
            cmp rdi,8                           ; if less than 8, then we are still at the master (first 8)
            jl .master                      
            sub rdi,8                           ; if greater than 8, then we are at the slave, so subtract 8 from the counter
            mov rdx,SLAVE_PIC_DATA_PORT         ; and get the data port of the slave in rdx 
        .master:
            in eax,dx                           ; move the IMR from the correct port (master or slave) 
            mov rcx,rdi                         ; move the port relative interrupt number (0 -> 7)
            mov rdi,0x1                         
            shl rdi,cl                          ; (1 << interrupt number)
            or rax,rdi                          ; IMR = IMR | (1 << interrupt number)
            out dx,eax                          ; write masked IMR to the data port
        .out:    
        popaq
        ret


    clear_irq_mask:
       pushaq                                   ; Save general purpose registers on the stack
            mov rdx,MASTER_PIC_DATA_PORT      
            cmp rdi,15                          ; check if interrupt number is greater than 15 (0 -> 15 = 16 interrupt)
            jg .out                             ; if greater than 15, then exit
            cmp rdi,8                           ; if less than 8, then we are still at the master (first 8)
            jl .master                      
            sub rdi,8                           ; if greater than 8, then we are at the slave, so subtract 8 from the counter
            mov rdx,SLAVE_PIC_DATA_PORT         ; and get the data port of the slave in rdx 
        .master:
            in eax,dx                           ; move the IMR from the correct port (master or slave) 
            mov rcx,rdi                         ; move the port relative interrupt number (0 -> 7)
            mov rdi,0x1                         
            shl rdi,cl                          ; (1 << interrupt number)
            not rdi                             ; ~(1 << interrupt number)
            and rax,rdi                         ; IMR = IMR & ~(1 << interrupt number)
            out dx,eax                          ; write unmasked IMR to the data port
        .out:    
        popaq
        ret
