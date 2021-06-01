;************************************** bios_print.asm **************************************      
      bios_print:       ; A subroutine to print a string on the screen using the bios int 0x10.
                        ; Expects si to have the address of the string to be printed.
                        ; Will loop on the string characters, printing one by one. 
                        ; Will Stop when encountering character 0..    
          
           pusha ; pushes all the registers into the stack
           .print_loop: ; local label
           xor ax,ax  ; let ax = 0
           lodsb  ; it will load the byte or char that is contained by si into al and then will increment si by 1 to point to the next byte or char
           or al,al ; checking the value of al
           jz .done ; if al = 0,then we reached the end of the string and jump to .done
           ; else
           mov ah,0x0E ; let ah = 0x0E,interrupt 10 function E
           int 0x10 ; interrupt 0x10 which prints a character into the screen
           jmp .print_loop ; looping and executing until al = 0
           .done: ; exit the bios_print
            popa              ; pop the registers from the stack 
           ret ; return to the place where this function is called
