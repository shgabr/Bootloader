%define VIDEO_BUFFER_SEGMENT                    0xB000
%define VIDEO_BUFFER_OFFSET                     0x8000
%define VIDEO_BUFFER_EFFECTIVE_ADDRESS          0xB8000
%define VIDEO_SIZE      0X0FA0    ; 25*80*2


    video_cls_16_2: 
        pusha                                         ; pushing all registers into the stack
            
            xor edx, edx                              ; let edx = 0
            mov ecx, VIDEO_BUFFER_EFFECTIVE_ADDRESS   ; let ecx = 0xB8000
            mov ax, 0x1020                            ; moving the 0x10 which is colour blue and 0x20 which is the space ascii value to ax

            clear_loop: 

            mov word[ecx], ax                         ; store the value of ax into the memory at address ecx
            add edx, 2                                ; incrementing edx by 2 to compare with the video size
            add ecx, 2                                ; incrementing ecx by 2 as every location on the screen is represented by 2 bytes. 
            
            cmp edx, VIDEO_SIZE                       ; comparing edx with 0x0FA0.
            jl clear_loop                             ; if edx is still less than the video size,then loop again 

        popa                                          ; pop all the registers from the stack
        ret 
