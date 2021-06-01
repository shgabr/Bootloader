%define MEM_REGIONS_SEGMENT         0x2000
%define PTR_MEM_REGIONS_COUNT       0x1000
%define PTR_MEM_REGIONS_TABLE       0x1018
%define MEM_MAGIC_NUMBER            0x0534D4150                
    memory_scanner:
            pusha                                       ; Save all general purpose registers on the stack

            mov ax,MEM_REGIONS_SEGMENT                  ;we cannot set EX directly from memory variable so we set AX to the segment memory segment
            mov es,ax                                   ;then set EX to AX because INT 0x18 expects memory segment to be in EX
            xor ebx,ebx                                 ;set EBX to 0 before first INT function call
            mov [es:PTR_MEM_REGIONS_COUNT],word 0x0     ;let the memory region [es:0] be a counter for the number of memory regions scanned
            mov di, PTR_MEM_REGIONS_TABLE               ;set offest (DI) to 0x18 or 24 bytes to store memory regions information
            .memory_scanner_loop:
                mov edx,MEM_MAGIC_NUMBER                ;the INT requires that EDX must be the magic number (0x0534D4150="SMAP") before call
                mov word [es:di+20], 0x1                ;the INT also requires that the 21st bit to be 1
                mov eax, 0xE820                         ;the INT 0x15 memory scanner function number
                mov ecx,0x18                            ;the memory storage buffer size
                int 0x15                                ;issue interupt number 0x15
                jc .memory_scan_failed                  ;if carry flag is high then an error occurred so go to memory_scan_failed
                cmp eax,MEM_MAGIC_NUMBER                ;after a successful int call, reg EAX should be the magic number
                jnz .memory_scan_failed                 ;if they are not equal then an error occurred so go to memory_scan_failed
                add di,0x18                             ;increment offset by 0x18 to store next memory region information
                inc word [es:PTR_MEM_REGIONS_COUNT]     ;increment scanned memory counter by 1
                cmp ebx,0x0                             ;compare EBX to 0
                jne .memory_scanner_loop                ;if EBX is not 0 then there is still memory to be scanned so loop again 
                jmp .finish_memory_scan                 ;else we finished scanning all memory regions so go to finish_memory_scan
            .memory_scan_failed: 
                mov si,memory_scan_failed_msg           ;set SI to memory_scan_failed_msg
                call bios_print                         ;call bios_print to print error message to indicate an error has occurred while scanning memory                
                jmp lm_hang                             ;then go to lm_hang in second_stage.asm
            .finish_memory_scan:
                popa                                    ; Restore all general purpose registers from the stack
                ret




    print_memory_regions:
            pusha                                       ; take a snapshot of the selector registers on the stack 
            mov ax,MEM_REGIONS_SEGMENT                  ; move 0x2000 into ax 
            mov es,ax                                   ; set es to 0x2000
            xor edi,edi                                 ; zero out edi 
          
            mov di,word [es:PTR_MEM_REGIONS_COUNT]      ; load the word stored in the third segmedt (0x2000) with offset 24 or 18h into di 
          
            call bios_print_hexa                        ; and call bios_print_hexa to display what is written into it 
          
            mov si,newline                              ; print a new line character 
            call bios_print
          
            mov ecx,[es:PTR_MEM_REGIONS_COUNT]          ; load ecx with the number of memory regions variable 
            
            mov si,PTR_MEM_REGIONS_TABLE                               
            
            .print_memory_regions_loop:
              
                mov edi,dword [es:si+4]                 ; the first 8 bytes contain the base address of the memory region 
                call bios_print_hexa_with_prefix        ; so we print the last 4 of them with the hexa prefix 

                mov edi,dword [es:si]                   ; then the first 4 bytes without the prefix 
                call bios_print_hexa
                
                push si                                 ; save current si on stack to be able to print next 

                mov si,double_space                     ; print double_space 
                call bios_print

                pop si                                  ; restore si from the stack 

                mov edi,dword [es:si+12]                ; the next 8 bytes contain the length 
                call bios_print_hexa_with_prefix        ; so, we print the last 4 of them with the hexa prefix 
               
                mov edi,dword [es:si+8]             ; and then the first 4 without a prefix 
                call bios_print_hexa

                push si                             ; save current si on stack 
                mov si,double_space                 ; print double space 
                call bios_print
                pop si                              ; restore si from the stack 

                mov edi,dword [es:si+16]            ; then another 4 bytes that contain the region type 
                call bios_print_hexa_with_prefix    ; we print them with hexa prefix 


                push si                              ; save current si on stack to print new_line
                mov si,newline                       ; print a new line  
                call bios_print
                pop si                               ; restore si from stack 
               
                add si,0x18                         ; increment the offset by another 24 bytes to read the info of the next memory region 

                dec ecx                             ; decrement the loop counter by 1, and loop if we didn't hit zero yet.
                cmp ecx,0x0
                jne .print_memory_regions_loop
            popa
            ret