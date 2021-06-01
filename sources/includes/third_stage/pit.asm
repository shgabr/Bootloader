%define PIT_DATA0       0x40
%define PIT_DATA1       0x41
%define PIT_DATA2       0x42
%define PIT_COMMAND     0x43

; https://wiki.osdev.org/Programmable_Interval_Timer

pit_counter dq    0x0               ; A variable for counting the PIT ticks
print_pit   dq    0x0               

handle_pit:
       pushaq
            mov byte[pit_bool], 1
            mov rdi,[pit_counter]         ; Value to be printed in hexa
            push qword [start_location]
            mov qword [start_location],0
            
            
            cmp qword[pit_counter], 0
            je .print
            cmp qword[print_pit], 1000         ; if pit_counter reaches multiples of 1000 then print
            jne .here
            .print:
                  call bios_print_hexa          ; Print pit_counter in hexa
                  mov qword[print_pit], 0     
            .here: 
            inc qword [print_pit]

            pop qword [start_location]          
            mov byte[pit_bool], 0
            inc qword [pit_counter]             ; Increment pit_counter
      popaq
      ret

      ; print counter after 1000 interrupts
      ; make print counter compatible with scrolling

configure_pit:
    pushaq
      mov rdi,32                    ; PIT is connected to IRQ0 which corresponds to Interrupt 32
      mov rsi, handle_pit           ; rsi contains the address of the code that should run when the pit fires 
      call register_idt_handler     ; We register handle_pit to be invoked through IRQ32
      mov al,00110110b              ; Configure PIT by setting in command register: binary value, mode 3, access high/low bytes, channel 0 
      out PIT_COMMAND,al            ; Write command port
      xor rdx,rdx                   ; Zero out RDX for division (requried by div instruction)

      mov rcx,50                    
      mov rax,1193180               ; 1.193180 MHz
      div rcx                       ; divide 11931280 by 50. quotient in rax, remainder in rdx
      out PIT_DATA0,al              ; move to channel data port 0 the quotient in the lower bytes
      mov al,ah                     ; move higher 8 bits to lower 8 bits of AL
      out PIT_DATA0,al              ; move to channel data port 0 the quotient in the higher bytes 
    popaq
    ret