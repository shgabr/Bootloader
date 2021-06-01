check_a20_gate:

    pusha               ;   Save all general purpose registers on the stack
    
    xor dl,dl           ;   Intiate dl with zero
    
.check_gate:             ;   Check A20 Gate

    mov ax,0x2402       ;   Interrupt 0x15, subfunction 0x2402 returns the current status of the A20 gate
    int 0x15
    jc .error           ;   On Failure the carry flag is set--> to know the reason check AH register   
                        ;   AH = 0x1 (Keyboard controller related error) or AH = 0x86  (Function is not supported by the BIOS)
                        ;   AL = current state (00: disabled, 01: enabled)
    cmp al,0x0          ;   If Al == 0x0
    je .enable_a20      ;   Jump to enable the A20 Gate    
    jmp .a20_enabled      ;   Else it is already enabled
    
.enable_a20:            ;   Enable A20 Gate
    
    cmp dl,0x1          ;   If dl==0x1
    je .unknown_error ;   Then we entered ".enable_a20" function for the second time after checking a20 gate which
                        ;   means that a20 gate is not enabled so jump to ".unknown_error" function
    mov dl,0x1          ;   Move 0x1 in dl if this was the first time to enter "enable_a20" function
    
    
    mov ax,0x2401       ;   Interrupt 0x15, subfunction 0x2401 enables the A20 line
    int 0x15
    jc .error           ;   On Failure the carry flag is set--> to know the reason check AH register
                        ;   AH = 0x1 (Keyboard controller related error) or AH = 0x86  (Function is not supported by the BIOS)
    jmp .check_gate     ;   Re-Check whether the A20 Gate was successfully enabled or not
     
.check_a20_gate_end:

    popa                ; Restore all general purpose registers from the stack
    ret


    .a20_not_enabled:
    
        mov si,a20_not_enabled_msg  ;   Move "a20_not_enabled_msg" into si
        call bios_print             ;   Call bios_print to print "a20_not_enabled_msg"
    
    jmp .check_a20_gate_end


    .a20_enabled:
    
        mov si,a20_enabled_msg      ;   Move "a20_enabled_msg" into si
        call bios_print             ;   Call bios_print to print "a20_enabled_msg"

        jmp .check_a20_gate_end

    .error:
    
        cmp AH,0x1                      ;   If (AH = 0x1) Keyboard controller related error
        je .keyboard_controller_error

        cmp AH,0x86                     ;   If (AH = 0x86) Function is not supported by the BIOS
        je .a20_function_not_supported

    .unknown_error:
    
        mov si,unknown_a20_error    ;   Move "unknown_a20_error" into si
        call bios_print             ;   Call bios_print to print "unknown_a20_error"

        jmp .a20_not_enabled

    .keyboard_controller_error:
        
        mov si,keyboard_controller_error_msg    ;   Move "keyboard_controller_error_msg" into si
        call bios_print                         ;   Call bios_print to print "keyboard_controller_error_msg"
        
        jmp .a20_not_enabled

    .a20_function_not_supported:
        
        mov si,a20_function_not_supported_msg   ;   Move "a20_function_not_supported_msg" into si
        call bios_print                         ;   Call bios_print to print "a20_function_not_supported_msg"
        
        jmp .a20_not_enabled
