        check_long_mode:
            pusha                           ; Save all general purpose registers on the stack
            call check_cpuid_support        ; Check if cpuid instruction is supported by the CPU
            call check_long_mode_with_cpuid ; check long mode using cpuid
            popa                            ; Restore all general purpose registers from the stack
            ret

        check_cpuid_support:
            pusha               ; Save all general purpose registers on the stack
            
            pushfd ; pushing a copy of the eflag into the stack to restore it
            pushfd ; pushing a second copy of the eflag into the stack to use it for comparison
            pushfd ; pushing a third copy of the eflag to update the flag
            
            pop eax ; let eax = a copy of the eflag
            xor eax,0x0200000 ; this will flip the bit number 21
            push eax ; pushing eax into the stack
            popfd ; let flag = value of eax
            pushfd ; pushing the flag again into the stack
            pop eax ; the copy of the value that is modified
            pop ecx ; the copy of the original value
            
            ;comparing the two values 
            
            xor eax,ecx ; if they are different,then it will produce 1
            and eax,0x0200000 ; make all the bits = 0 except for bit number 21 will stay the same 
            
            cmp eax,0x0 ; comparing eax with zero,if eax = 0,then bit number 21 was not flipped and cpuid was not supported
            
            jne .cpuid_supported ; else we have successfully flipped bit number 21,go to label cpuid_supported and print a message
            ; if eax = 0
            
            mov si,cpuid_not_supported ; print a message stating cpuid is not supported
            call bios_print
            jmp hang ; jumping to hang
           
            .cpuid_supported:
            
            mov si,cpuid_supported ; printing a message stating the cpuid is supported
            call bios_print
            popfd ; pop the first copy of the eflag from the stack

            popa                ; Restore all general purpose registers from the stack
            ret


        check_long_mode_with_cpuid:
            pusha                                   ; Save all general purpose registers on the stack
            
            mov eax,0x80000000 ; let eax = max value that can be used in a function
            cpuid ; isa function
            
            cmp eax,0x80000001 ; comaring eax with 80,000,001
            jl .long_mode_not_supported ; if eax < 80,000,001, then go to label long_mode_not_supported
            
            ; else
            
            mov eax,0x80000001 ; function 80,000,001 will copy the value of the internal feature registers into edx
            cpuid ; isa function
            
            and edx,0x20000000 ; checking bit number 29 if it is set or not
            cmp edx,0 ; comparing edx to 0
            je .long_mode_not_supported ; if edx = 0, then long mode is not supported
            
            ;else
            
            mov si,long_mode_supported_msg ; printing a message stating that long mode is supported
            call bios_print
            jmp .exit_check_long_mode_with_cpuid
            
            .long_mode_not_supported:
            
            mov si,long_mode_not_supported_msg ; print a message stating that long mode is not supported
            call bios_print
            jmp hang
            
            .exit_check_long_mode_with_cpuid:
           
           
            popa                                ; Restore all general purpose registers from the stack
            ret
