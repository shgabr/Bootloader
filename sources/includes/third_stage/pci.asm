;*******************************************************************************************************************
%define CONFIG_ADDRESS  0xcf8
%define CONFIG_DATA     0xcfc

ata_device_msg db 'Found ATA Controller',13,10,0
testing_msg db 'Working...',13,10,0
pci_header times 512 db 0

struc PCI_CONF_SPACE
.vendor_id          resw    1
.device_id          resw    1
.command            resw    1
.status             resw    1
.rev                resb    1
.prog_if            resb    1
.subclass           resb    1
.class              resb    1
.cache_line_size    resb    1
.latency            resb    1
.header_type        resb    1
.bist               resb    1
.bar0               resd    1
.bar1               resd    1
.bar2               resd    1
.bar3               resd    1
.bar4               resd    1
.bar5               resd    1
.reserved           resd    2
.int_line           resb    1
.int_pin            resb    1
.min_grant          resb    1
.max_latency        resb    1
.data               resb    192
endstruc

; al---> bus
; cl---> device
; dl---> function


PCI_read:

pushaq
xor al,al                                   ; initiate bus number by 0
mov byte[bus],al

LoopA:                                      ; 256 buses loop

    ;mov rsi,testing_msg
    ;call video_print

    xor cl,cl
    mov byte[device],cl                     ; initiate device number by 0
    LoopB:                                  ; 32 devices loop
        
        xor dl,dl
        mov byte[function],dl               ; initiate function number by 0

        LoopC:                              ; 8 functions loop
            
            call get_pci_device

            inc dl                          ; incrementing function number
            cmp dl,0x8                      ; if reached 8
            je Skip_LoopC                   ; then exit loopc
            mov byte[function],dl

            ;mov rsi,2
            xor rbx,rbx
            mov bx, [pci_header+rsi]    ; getting the Device ID ;PCI_CONF_SPACE.device_id
            cmp bx,0xffff               ; if equal 0xffff then there is no device connected
            
            
            je Skip_LoopC

            
            mov rsi,14
            mov bl, byte[pci_header+rsi]    ; getting the header ;PCI_CONF_SPACE.device_id.header_type
            cmp bl,0x0

            
            je Skip_LoopB
            

            mov rbx, [pci_header]
            add rbx, 0x100                  ; incrementing the memory pci_header memory address
            mov [pci_header], rbx

        jmp LoopC
        Skip_LoopC:

        inc cl                              ; incrementing device number
        cmp cl,0x20                         ; if reached 32
        je Skip_LoopB                       ; then exit loopc                 
        mov byte[device],cl

    jmp LoopB

    Skip_LoopB:

    inc al                                  ; increment the bus number
    cmp al,255                              ; if reached 255 then skip
    jge Skip_LoopA
    mov byte[bus],al                        ; update the memory label bus by the new al (bus) value

jmp LoopA

Skip_LoopA:
popaq
ret


get_pci_device:

    pushaq

    xor rax,rax                         ; let rax = 0
    xor rbx,rbx                         ; let rbx = 0
    mov bl,[bus]                        ; moving the bus into bl
    shl ebx,16                          ; shift left ebx 16 bit to move the bus into the right place (23-16)
    or eax,ebx                          ; putiting the bus in eax
    xor rbx,rbx                         ; let rbx = 0
    mov bl,[device]                     ; moving the device into bl
    shl ebx,11                          ; shifting left by 11 bit to move the device into the right place (15-11)
    or eax,ebx                          ; now eax has the bus and the device  
    xor rbx,rbx                         ; let rbx = 0
    mov bl,[function]                   ; moving the function into bl
    shl ebx,8                           ; shift let ebx by 8 bit to move the function into the right place (10-8)
    or eax,ebx                          ; eax now has the bus,device and the function
    or eax,0x80000000                   ; setting Enable Bit (31) to 1 as it is needed to be set 
    xor rsi,rsi                         ; let rsi = 0, rsi will be the offset

    pci_config_space_read_loop:

        push rax                    ; pusing rax into the stack
        or rax,rsi                  ; or rax with the offset rsi which is zero
        and al,0xfc                 ; bits 0-1 need to be always zero as the addresses is always divisble by 4
        mov dx,CONFIG_ADDRESS       ; 
        out dx,eax                  ; out the command register on the configuration address port
        mov dx,CONFIG_DATA          ; Reading from the configuration data into eax
        xor rax,rax                 ; let rax = 0
        in eax,dx                   ; Will return the double word corresponding to the offset within the device
        mov [pci_header + rsi],eax  ; store pci_header which is a place in memory the 256 bytes
        add rsi,0x4                 ; incrementing the offset by 4
        pop rax                     ; restore rax value
        cmp rsi,0xff                ; compare the offset with 256,then we have read the configuration space
        jl pci_config_space_read_loop ; if less,then loop again until we read the 256 bytes        

    ;mov r9,[pci_header]                                 ; Checking if the VENDOR ID is INTEL_VEND
    ;cmp word[pci_header],0x8086
    call e1000_pci_config

    popaq
    ret
