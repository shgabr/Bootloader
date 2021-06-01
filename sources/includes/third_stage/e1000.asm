%define INTEL_VEND 0x8086
%define E1000_DEV 0x100E
%define E1000_DEV1 0x153A
%define E1000_DEV2 0x10EA
%define E1000_DEV3 0x100F
%define E1000_DEV4 0x1004
%define E1000_MODELS_COUNT 0x5

%define e1000_desc_size 16
%define e1000_desc_array_count 0x800
%define e1000_desc_array_size 0x8000
%define e1000_packet_area_size 0x400000
%define e1000_bar0_mem_size 0x200000
%define e1000_packet_size 0x800

%define E1000_CTRL_PHY_RST 0x80000000

%define FCAL 0x0028
%define FCAH 0x002C
%define FCT 0x0030
%define FCTT 0x0170
%define THROT 0x00C4
%define MULTICAST_VT 0x5200

%define REG_CTRL 0x0000
%define REG_STATUS 0x0008
%define REG_EEPROM 0x0014
%define REG_CTRL_EXT 0x0018
%define REG_ICR 0x00C0
%define REG_IMASK 0x00D0
%define REG_RCTRL 0x0100
%define REG_RXDESCLO 0x2800
%define REG_RXDESCHI 0x2804
%define REG_RXDESCLEN 0x2808
%define REG_RXDESCHEAD 0x2810
%define REG_RXDESCTAIL 0x2818

%define REG_TCTRL 0x0400
%define REG_TXDESCLO 0x3800
%define REG_TXDESCHI 0x3804
%define REG_TXDESCLEN 0x3808
%define REG_TXDESCHEAD 0x3810
%define REG_TXDESCTAIL 0x3818

%define REG_RDTR 0x2820
%define REG_RXDCTL 0x3828
%define REG_RADV 0x282C
%define REG_RSRPD 0x2C00

;*******************************************************************************************************************

%define REG_TIPG 0x0410 ; Transmit Inter Packet Gap

%define ECTRL_FD            0x01    ;FULL DUPLEX
%define ECTRL_SLU           0x40    ;set link up     
%define ECTRL_100M          0x100   ;set speed to 100 Mb/sec
%define ECTRL_1000M         0x200   ;set speed to 1000 Mb/sec
%define ECTRL_FRCSPD        0x800   ;Force Speed
%define ECTRL_ASDE          0x20    ;auto speed enable


%define RCTL_EN                 (1 << 1)
%define RCTL_SBP                (1 << 2)
%define RCTL_UPE                (1 << 3)
%define RCTL_MPE                (1 << 4)
%define RCTL_LPE                (1 << 5)
%define RCTL_LBM_NONE           (0 << 6)
%define RCTL_LBM_PHY            (3 << 6)
%define RTCL_RDMTS_HALF         (0 << 8)
%define RTCL_RDMTS_QUARTER      (1 << 8)
%define RTCL_RDMTS_EIGHTH       (2 << 8)
%define RCTL_MO_36              (0 << 12)
%define RCTL_MO_35              (1 << 12)
%define RCTL_MO_34              (2 << 12)
%define RCTL_MO_32              (3 << 12)
%define RCTL_BAM                (1 << 15)
%define RCTL_VFE                (1 << 18)
%define RCTL_CFIEN              (1 << 19)
%define RCTL_CFI                (1 << 20)
%define RCTL_DPF                (1 << 22)
%define RCTL_PMCF               (1 << 23)
%define RCTL_SECRC              (1 << 26)


; Buffer Sizes
%define RCTL_BSIZE_256          (3 << 16)
%define RCTL_BSIZE_512          (2 << 16)
%define RCTL_BSIZE_1024         (1 << 16)
%define RCTL_BSIZE_2048         (0 << 16)
%define RCTL_BSIZE_4096         ((3 << 16) | (1 << 25))
%define RCTL_BSIZE_8192         ((2 << 16) | (1 << 25))
%define RCTL_BSIZE_16384        ((1 << 16) | (1 << 25))


; Transmit Command
%define CMD_EOP                 (1 << 0)
%define CMD_IFCS                (1 << 1)
%define CMD_IC                  (1 << 2)
%define CMD_RS                  (1 << 3)
%define CMD_RPS                 (1 << 4)
%define CMD_VLE                 (1 << 6)
%define CMD_IDE                 (1 << 7)


; TCTL Register
%define TCTL_EN                 (1 << 1)
%define TCTL_PSP                (1 << 3)
%define TCTL_CT_SHIFT           4
%define TCTL_COLD_SHIFT         12
%define TCTL_SWXOFF             (1 << 22)
%define TCTL_RTLC               (1 << 24)


%define TSTA_DD                 (1 << 0)
%define TSTA_EC                 (1 << 1)
%define TSTA_LC                 (1 << 2)
%define LSTA_TU                 (1 << 3)

;*******************************************************************************************************************

; Ethernet Protocol packet
%define ETHERTYPE_IP    0x0800  ; IP protocol
%define ETHERTYPE_ARP   0x0806  ; ARP protocol

struc ethernet_packet 
    .h_dest     resb 6 
    .h_src      resb 6 
    .h_type     resw 1
endstruc

; Address Resolution Protocol (ARP)
%define ARPHRD_ETHER            1 
%define ARPHRD_IEEE802          6 
%define ARPHRD_FRELAY           15 
%define ARPHRD_IEEE1394         24 
%define ARPHRD_IEEE1394_EUI64   27
%define ARPOP_REQUEST           1 
%define ARPOP_REPLY             2 
%define ARPOP_REVREQUEST        3 
%define ARPOP_REVREPLY          4 
%define ARPOP_INVREQUEST        8 
%define ARPOP_INVREPLY          9

struc arp_packet
    .ethernet           resb 14  
    .ar_hdr             resw 1 
    .ar_pro             resw 1 
    .ar_hln             resb 1 
    .ar_pln             resb 1 
    .ar_op              resw 1 
    .sender_hw_addr     resb 6 
    .sender_proto_addr  resb 4 
    .target_hw_addr     resb 6
    .target_proto_addr  resb 4
endstruc



;*******************************************************************************************************************


e1000_found_msg db 'E1000_found !',13,10,0
e1000_not_found_msg db 'E1000 not found...',13,10,0
e1000_reached_msg db 'Reached E1000',13,10,0

; For every device we detect in the PCI loop we call this 
; function to make sure that we have that a device from E1000 NIC
; family exists on the machine in order to write a driver for it

e1000_pci_config:                                           

    pushaq
    

    mov r9,pci_header                                 ; Compare the found vendor ID with Intel's vendor ID
    cmp word[r9+PCI_CONF_SPACE.vendor_id],INTEL_VEND
    jne .quit                                               ; Quit if they don't match
                                                            ; Then we check whether the detected device has any of the valid
                                                            ; Device IDs that corresponds to an Intel E1000 NIC
    cmp word[r9+PCI_CONF_SPACE.device_id],E1000_DEV         ; Device ID == 0x100E ?
    je .found
    cmp word[r9+PCI_CONF_SPACE.device_id],E1000_DEV1        ; Device ID == 0x153A ?
    je .found
    cmp word[r9+PCI_CONF_SPACE.device_id],E1000_DEV2        ; Device ID == 0x10EA ?
    je .found
    cmp word[r9+PCI_CONF_SPACE.device_id],E1000_DEV3        ; Device ID == 0x100F ?
    je .found
    cmp word[r9+PCI_CONF_SPACE.device_id],E1000_DEV4        ; Device ID == 0x1004 ?
    je .found
    jmp .quit

    .found:                                                  ; The E1000 NIC has been found when we reach here

        mov byte[e1000_flag],0x1                             ; In order to know that we have detected e1000 successfully we set e1000_flag flag to 1
        xor rax,rax
                                                             
                                                             
        mov al,byte[r9+PCI_CONF_SPACE.bar0]                  ; In order to know whether the device is PORT/IO or MMIO
        and al,0x1                                           ; We have to check the first bit in the BAR0 
        mov [e1000_ioport_flag],al                           ; If (BAR0 bit-0 is set) { the device is Port/IO mapped and we have to set e1000_ioport_flag }
                                                             ; Else { the device is MMIO }
        

        mov eax,[r9+PCI_CONF_SPACE.bar1]                     
        and eax,~0x1
        mov [e1000_io_base],ax
        xor rax,rax
        mov eax,[r9+PCI_CONF_SPACE.bar0]                     
        and eax,~0x3
        mov [e1000_mem_base],rax
        xor rax,rax                     
        mov al,byte[r9+PCI_CONF_SPACE.int_line]
        or al,byte[r9+PCI_CONF_SPACE.int_pin]                ; In order to get the e1000 interrupt number, we OR "int_line" with "int_pin"
        mov [e1000_int_no],al                            
        mov rsi,found_intel_e1000_msg                        ; We Print a message that idicates that we successfully found the E1000 device
        call video_print
        mov al,[bus]                                         ; We need to store the bus, device, function that we detected in the PCI loop
        mov [e1000_bus],al                                   
        mov al,[device]
        mov [e1000_device],al
        mov al,[function]
        mov [e1000_function],al
        
        call e1000_init

    .quit:
    popaq
    ret


e1000_init:                                                 ; This is the e1000 driver main entry function in which we call all the needded functions

    pushaq

        cmp byte[e1000_flag],0x0
        je .quit                                            ; If the e1000_flag is not set this means that we did not detect the device in the first place
        mov rsi,e1000_configure_msg                         ; printing a message
        call video_print
        call e1000_map_mem                                  ; if the device is a memory MMIO we need to map its physical memory in order to be accessible by the CPU
        call e1000_init_mem                                 ; Here, we allocate memory for the ring buffers in order to be used by the NIC
        call e1000_bus_master                               ; Bus Master function allows the NIC device to fire interrupts

        call e1000_detect_eeprom                            ; Here, we should make sure that we have an eeprom in the first place as without 
        
                                                            ; it we will not have the MAC address of the device
        cmp byte [e1000_eeprom_flag],0x1
        jne .quit
        

        call e1000_read_mac_address                         ; reading the MAC address of the NIC device found on the eeprom
        
        call e1000_startlink                                ; This Starts the physical link --> makes sure it is working
        call e1000_setup_interrupt_throttling
        call e1000_clear_multicast_table                    ; In order not to filter any packets on the card level, we clear the multicast table
                                                            ; clearing this table issures that we can recieve any packet from any sender, no exceptions
        call e1000_rx_init                                  ; initialize the recieving buffer
        call e1000_tx_init                                  ; initialize the transmitting buffer
        call e1000_enable_interrupts                        ; enabling the e100 interrupts

    .quit:
    popaq
        
ret


e1000_map_mem:                                              ; Mapping the MMIO into my page table

    pushaq
        mov r9,0x0                                          ; r9 is the counter of the loop
    
        .loop:
    
            mov rax,[e1000_vaddress]                        ; fill rax with the manually set e1000_vaddress
            add rax,r9                                      ; add to rax the counter value
            mov [vaddress],rax
            mov rax,[e1000_mem_base]
            add rax,r9
            mov [paddress],rax
            call map_page                                   ; map_page function takes two prams : 1) vaddress 2) paddress
                                                            ; then it will map those pages into our page table
            add r9,0x1000                                   ; add 4k each time (size of a page)

            cmp r9,e1000_bar0_mem_size                      ; stop when we reach the manual specified end of the MMIO space
                                                            ; checking if we mapped 128 kb = 32 physical pages
            jl .loop
    
        call reload_page_table
    
        mov rsi,e1000_map_memio_msg
        call video_print
    
    popaq

ret




e1000_init_mem:

    pushaq 

        ;current_memory_address = new_page_address
        ; The following code basicly build the two ring buffers and make them ready for future use

        add qword[new_page_address],0x10000                   ; This creates a gap of 10 KB to make sure that any bug in the driver does not overwrite the page table
        mov rax,[new_page_address]                            ; rax = address value pointed to memory area available to be used
        mov [e1000_rx_desc_ptr],rax
        add rax,e1000_desc_array_size
        mov [e1000_tx_desc_ptr],rax
        add rax,e1000_desc_array_size
        mov [e1000_rx_packets_ptr],rax
        add rax,e1000_packet_area_size
        mov [e1000_tx_packets_ptr],rax
        add rax,e1000_packet_area_size
        mov [e1000_recv_packet],rax
        add rax,e1000_packet_size
        mov [e1000_send_packet],rax
        add rax,e1000_packet_size
        mov [new_page_address],rax

        ; In the following loop the recieve ring buffer discriptors are intialized and the packets are availed

        mov r8,[e1000_rx_desc_ptr]
        mov r9,[e1000_rx_packets_ptr]
        mov rcx,e1000_desc_array_count
        .rx_loop:
            mov [r8+e1000_rx_desc.addr],r9
            mov byte[r8+e1000_rx_desc.status],0x0
            add r8,e1000_desc_size
            add r9,e1000_packet_size
            dec rcx
            cmp rcx,0x0
        jg .rx_loop

        ; In the following loop the transmit ring buffer discriptors are intialized and the packets are availed

        mov r8,[e1000_tx_desc_ptr]
        mov r9,[e1000_tx_packets_ptr]
        mov rcx,e1000_desc_array_count
        .tx_loop:
            mov [r8+e1000_tx_desc.addr],r9
            mov byte[r8+e1000_tx_desc.cmd],0x0
            mov byte[r8+e1000_tx_desc.status],TSTA_DD ; Descriptor Done
            add r8,e1000_desc_size
            add r9,e1000_packet_size
            dec rcx
            cmp rcx,0x0
        jg .tx_loop
        mov rsi,e1000_mem_init_msg
        call video_print ; Print a message indicating the memory buffer reservation and setup has been done

    popaq

ret




pci_bus_master:     ; This function is what makes the NIC able to fire interrupts

pushaq


    ; Loading the bus, device, and function with 16 makes us able to write to the command register which enable us to write commands to the device
    ; here, we are composing the command
    xor rbx,rbx                                 ;((bus << 16)
    mov bl,[bus]
    shl ebx,16
    or eax,ebx
    xor rbx,rbx                                 ;|(device << 11)
    mov bl,[device]
    shl ebx,11
    or eax,ebx
    xor rbx,rbx                                 ;| (function << 8)
    mov bl,[function]
    shl ebx,8
    or eax,ebx
    or eax,0x80000000                           ;| ( 0x80000000)
    mov rsi,0x4
    or rax,rsi
    and al,0xfc                                 ; We should make sure that the last 2 bits are zeros
    
    mov rsi,start_bus_mastering_msg
    call video_print
    
    mov rdi,rax
    call bios_print_hexa
    mov rsi,newline
    call video_print

    push rax                                   ; Pushing rax on the stack in order to save the Config value
    mov dx,CONFIG_ADDRESS                      ; This enables us ti read the Command Register
    out dx,eax
    xor rax,rax
    mov dx,CONFIG_DATA
    in eax,dx
    mov rcx,rax                                ; saving the command register value in rcx
    or rcx,0x06                                ; Oring with 0x06 sets the second and third Bus-Master bits
    pop rax                                    ; Pop the Config value from the stack inside rax
    push rax                                   ; Push it again to save it
    mov dx,CONFIG_ADDRESS                      
    out dx,eax
    mov dx,CONFIG_DATA
    mov rax,rcx
    out dx,eax
    pop rax                                    ; Pop from the stack the config valuein dx
    mov dx,CONFIG_ADDRESS                      
    out dx,eax
    xor rax,rax
    mov dx,CONFIG_DATA
    in eax,dx
    mov rdi,rax
    call bios_print_hexa
    mov rsi,newline
    call video_print
    cmp rax,rcx                                
    jne .quit
    mov rsi,bus_mastering_msg                  ; print a message to show that Bus-Mastering was enabled
    call video_print
    .quit:

popaq
ret





e1000_bus_master:
    pushaq
        ; save inside bus, device, function the current scanned params
        mov al,[e1000_bus]
        mov [bus],al
        mov al,[e1000_device]
        mov [device],al
        mov al,[e1000_function]
        mov [function],al        
        call pci_bus_master
        ; call pci_bus_master in order to do the bus mastering
    popaq
ret



e1000_read_command:                         ; This function takes as an input an address and gives the value found in that address
    pushaq
        cmp byte[e1000_ioport_flag],0x1     ; If NIC is PortIO then continue
        je .use_ports                       ; If not use MMIO
            xor rax,rax
            mov ax,word[e1000_rw_address]       ; Use e1000_vaddress as the base addres
            add rax,[e1000_vaddress]            ; and use e1000_rw_address as offset
            xor rbx,rbx
            mov ebx,[rax]
            mov [e1000_rw_data],ebx             ; read into e1000_rw_data from the MMIO address
        jmp .quit
        .use_ports:
            mov dx,[e1000_io_base]              ; Use e1000_io_base to write the address
            add ax,[e1000_rw_address]           ; you want to read from
            out dx,eax
            mov dx,[e1000_io_base+0x4]          ; read value ofrom port address e1000_io_base+0x4
            in eax,dx                           ; to e1000_rw_data
            add [e1000_rw_data],eax
        .quit:

        ;mov rsi, hello_world_str
        ;call video_print
    popaq
ret



e1000_write_command:                            ; This function takes as input the card address space
pushaq 
cmp byte[e1000_ioport_flag],0x1                   ; If the NIC is PortIO then continue
    je .use_ports                                   ; Else use MIMO
        xor rax,rax
        mov ax,word[e1000_rw_address]                   ; we use the e1000 virtual address as the base address
        add rax,[e1000_vaddress]                        ; and use e1000_rw_address as offset
        xor rbx,rbx
        mov ebx,[e1000_rw_data]                         ; now we write what is inside e1000_rw_data to the beggining memory mapped address of the device
        mov [rax],ebx
    jmp .quit
    .use_ports:
        mov dx,[e1000_io_base]                          ; Use e1000_io_base to write the address
        add ax,[e1000_rw_address]                       ; you want to write to
        out dx,eax
        mov dx,[e1000_io_base+0x4]                      ; write the value of e1000_rw_data to e1000_io_base+0x4
        add eax,[e1000_rw_data]
        out dx,eax
    .quit:
    popaq

ret



e1000_detect_eeprom:                                        ; The eeprm is detectable when we write 0x1 to the EEPROM register

    pushaq

        mov word[e1000_rw_address],REG_EEPROM               
        mov dword[e1000_rw_data],0x1
        call e1000_write_command
        mov rcx,0xFFFFFFFF                                  ; Number of count of tries
        .loop:                                              ; read from the EEProm untill we reach 0 in rcx
            cmp rcx,0x0                                         
            je .no_eprom                                        
            mov word[e1000_rw_address],REG_EEPROM
            call e1000_read_command
            xor rdi,rdi
            mov edi,dword[e1000_rw_data]
            and rdi,0x10
            dec rcx
            cmp rdi,0x10
        jne .loop
        mov rsi,e1000_eeprom_detected_msg                   ; Reaching this message means that we have an EEPROM
        call video_print 
        mov byte [e1000_eeprom_flag],0x1
        jmp .quit
        .no_eprom:
            mov byte [e1000_eeprom_flag],0x0                    ; Else then we did not detect it in the first place
            mov rsi,e1000_eeprom_not_detected_msg                   
            call video_print
        .quit:
    popaq
ret


e1000_eeprom_read:                                                ; reaching this functino means that we already detceted an EEProm and we need to read info from it

    pushaq                                                              
                                                                        
        xor rax,rax
        mov al,[e1000_eeprom_addr]                                      ; Here, we read from the beginning of the address "e1000_eeprom_addr"
        shl eax,0x8                                                     
        or eax,0x1                                                      
        mov word[e1000_rw_address],REG_EEPROM
        mov dword[e1000_rw_data],eax                                    
        call e1000_write_command                                        
        .loop:
            mov word[e1000_rw_address],REG_EEPROM
            call e1000_read_command                                         ; reading from EEProm reg
            xor rdi,rdi
            mov edi,dword[e1000_rw_data]                                    ; If we read a value then it will be stored in e1000_rw_data
            and rdi, (1 << 4)                                           
            cmp rdi,0x0                                                     ; else try again
        je .loop
        xor rdi,rdi
        mov edi,dword[e1000_rw_data]
        shr edi,16
        and edi,0xFFFF
        mov dword[e1000_rw_data],edi                                    ; Store high word in e1000_rw_data
        
    popaq
ret


e1000_read_mac_address:                                                 ; This function will read 6-octets from e1000_eeprom_addr
    
    pushaq
    
        mov r9,0x0                                                              
        mov r10,0x0                                                             ; r10 is the place in memory where we will store the mac address octet
    
        .loop:
            mov byte[e1000_eeprom_addr],r9b                                         ; Read register 0x0
            call e1000_eeprom_read
            xor rdi,rdi
            mov edi,dword[e1000_rw_data]
            and edi,0xff                                                            ; we store the first byte in e1000_mac_address after being extracted
            mov [e1000_mac_address+r10],dil                                         
            inc r10                                                                 
            xor rdi,rdi                                                             ; e1000_mac_address
            mov edi,dword[e1000_rw_data]
            shr edi,0x8                                                             ; Shifting by 0x8 allows us to access the next byte of the low register
            and edi,0xff                                                            
            mov [e1000_mac_address+r10],dil                                         
            inc r10                                                                 ; Inc r10 to point to the next byte and r9 to point to the next address
            inc r9                                                                  
            cmp r9,0x3                                                              
        jne .loop                                                               ; only exit the loop when we have 3 (2-octets)
    
        call e1000_print_mac_address                                            ; call print mac address to print the mac address
    
    popaq

ret


e1000_print_mac_address:                            ; this function print the mac address of the NIC found in the EEProm
    
    pushaq

        mov byte[hexa_pad],0x2

        mov r9,0x0
        
        .loop:
            xor rdi,rdi
            mov dil,byte[e1000_mac_address+r9]
            call print_mac_address
            inc r9
            cmp r9,0x6
            je .skip_colon
                mov rsi,colon
                call video_print
            .skip_colon:
            cmp r9,0x6
        jl .loop

        mov byte[hexa_pad],0x10

        mov rsi,newline
        call video_print

    popaq

ret


e1000_startlink:

    pushaq

        mov word[e1000_rw_address],REG_CTRL                                         
        call e1000_read_command
        xor rax,rax
        mov eax,dword[e1000_rw_data]
        or eax, ECTRL_SLU | ECTRL_ASDE | ECTRL_FD | ECTRL_100M| ECTRL_FRCSPD        ; Setting the Link Up
        mov dword[e1000_rw_data],eax
        call e1000_write_command

        xor rax,rax                                                                 ; Filling every register by zeros will insure that the flow control is disabled
        mov dword[e1000_rw_data],eax
        mov word[e1000_rw_address],FCAL
        call e1000_write_command
        mov word[e1000_rw_address],FCAH
        call e1000_write_command
        mov word[e1000_rw_address],FCT
        call e1000_write_command
        mov word[e1000_rw_address],FCTT
        call e1000_write_command
        mov word[e1000_rw_address],REG_STATUS
        call e1000_read_command
        xor rdi,rdi                                                                 ; Print the status register after reading it successfully
        
        mov edi,dword[e1000_rw_data]
        call bios_print_hexa
                                                                                    ; print a msg to indicate that the link is done
        mov rsi,newline
        call video_print
        
        mov rsi,e1000_start_up_link_msg
        call video_print

    popaq

ret


; Throttling is the amount of interrupts fired by the card
; Its interval is in 256 ns.
; The following equationis used to clalculate it
; Interrupts/seconds = (256x10 -9 x interval) -1

e1000_setup_interrupt_throttling:
    
    pushaq
        mov rax,0x3B9ACA00                  ; 10^9
        shr rax,10                          ; 256*4 = 1024 = 2^10
        mov dword[e1000_rw_data],eax
        mov word[e1000_rw_address],THROT
        call e1000_write_command
        mov rsi,e1000_setup_throttling_msg  ; Print a message to indicate that Throttling setting is done
        call video_print
    popaq

ret


; Clearing multicast filter addresses inssures that no address is blocked and the NIC can receive from any device

e1000_clear_multicast_table:
    
    pushaq
    
        mov rcx,0x80                         ; Down Counter with size equal to number of MTA Table entries ( 0x80 = 128 )
        mov r9,MULTICAST_VT                  
        .loop:
        
            mov dword[e1000_rw_data],0x0         
            mov word[e1000_rw_address],r9w
            call e1000_write_command
            add r9,0x4                           ; Increment register by 4
            dec rcx                              ; Decrement counter
            
            cmp rcx,0x0                          ; if the counter reached 0 we will exit
        
        jne .loop
        mov rsi,e1000_multicast_vt_msg       ; Print a message to indicate that we finished the multicast clearing
        call video_print

    popaq

ret



e1000_rx_init:                                  ; We assume here identity memory mapping, or else we need to use v2p

    pushaq

        mov rax,[e1000_rx_desc_ptr]                     ; This sets the low 32-bits of the Ring Buffer
        mov word[e1000_rw_address],REG_RXDESCLO         
        mov dword[e1000_rw_data],eax                    
        call e1000_write_command
        xor rax,rax                                     ; We store  0x0 in the higher 32 bits
        mov word[e1000_rw_address],REG_RXDESCHI         
        mov dword[e1000_rw_data],eax                     
        call e1000_write_command 


        mov rax,e1000_desc_array_size                   ; rax now contains the size of the ring
        mov word[e1000_rw_address],REG_RXDESCLEN
        mov dword[e1000_rw_data],eax
        call e1000_write_command


        xor rax,rax
        mov word[e1000_rw_address],REG_RXDESCHEAD
        mov dword[e1000_rw_data],eax
        call e1000_write_command                        ; the head pointer size is written in the command register to the NIC

        xor rax,e1000_desc_array_count-1
        mov word[e1000_rw_address],REG_RXDESCTAIL
        mov dword[e1000_rw_data],eax
        call e1000_write_command                        ; The index of the tail isset

        mov rax, RCTL_EN| RCTL_UPE | RCTL_MPE | RCTL_LBM_NONE | RTCL_RDMTS_HALF | RCTL_BAM | RCTL_SECRC|RCTL_BSIZE_16384
        
        mov word[e1000_rw_address],REG_RCTRL
        mov dword[e1000_rw_data],eax
        call e1000_write_command

        mov rsi,e1000_rx_init_msg
        call video_print

    popaq

ret



e1000_tx_init:
    
    pushaq

        mov rax,[e1000_tx_desc_ptr]                             ; Set the low 32-bits of the Ring Buffer
        mov word[e1000_rw_address],REG_TXDESCLO                 ; address to the memory area we already
        mov dword[e1000_rw_data],eax                            ; reserved in e1000_init_mem
        call e1000_write_command

        xor rax,rax
        mov word[e1000_rw_address],REG_TXDESCHI
        mov dword[e1000_rw_data],eax
        call e1000_write_command

        mov rax,e1000_desc_array_size
        mov word[e1000_rw_address],REG_TXDESCLEN
        mov dword[e1000_rw_data],eax
        call e1000_write_command

        xor rax,rax
        mov word[e1000_rw_address],REG_TXDESCHEAD
        mov dword[e1000_rw_data],eax
        call e1000_write_command

        xor rax,rax
        mov word[e1000_rw_address],REG_TXDESCTAIL
        mov dword[e1000_rw_data],eax
        call e1000_write_command


        mov rax,TCTL_EN | TCTL_PSP | (0xF << TCTL_CT_SHIFT) | (0x3F << TCTL_COLD_SHIFT) | TCTL_SWXOFF | TCTL_RTLC                                           ; Enable Transmission, Pad short packets, Collision Threshold, Collision Distance, SW XOFF
                                                            ; Transmission, Retransmit on Late Collision
        mov word[e1000_rw_address],REG_TCTRL
        mov dword[e1000_rw_data],eax
        call e1000_write_command
                                                            ; Configure Inter Packet Gap Timer
        mov rax,0x00602006
        mov word[e1000_rw_address],REG_TIPG
        mov dword[e1000_rw_data],eax
        call e1000_write_command
                                                            ; Print a message
        mov rsi,e1000_tx_init_msg
        call video_print

    popaq
ret



e1000_enable_interrupts:

    pushaq

        xor rdi,rdi
        mov dil,[e1000_int_no]
        add rdi,32
        mov rsi, e1000_int_handler                              ; register interrupt handler e1000_int_handler
        call register_idt_handler                               
        xor rdi,rdi
        mov dil,[e1000_int_no]
        call clear_irq_mask                                     ; For the e1000 interrupt number, we should clear the PIC interrupt mask
        mov rax,0x1F6DC
                                                                
        mov word[e1000_rw_address],REG_IMASK
        mov dword[e1000_rw_data],eax
        call e1000_write_command
                                                                ; print the status after Reading it
        mov word[e1000_rw_address],REG_ICR
        call e1000_read_command
        xor rdi,rdi
        mov edi,dword[e1000_rw_data]
        call bios_print_hexa
        mov rsi,newline
        call video_print
                                                                ; print message indicating that we finished this function
        mov rsi,e1000_enable_interrupt_msg
        call video_print

    popaq

ret



e1000_send_out_packet:

    pushaq

        xor r11,r11                                                     ; store e1000_tx_cur in r11 and multiply the value by 16
        mov r11w,word[e1000_tx_cur]
        shl r11,0x4

        xor r9,r9                                                       ; Store e1000_tx_desc_ptr (Ring Base address) into r9
        mov r9,[e1000_tx_desc_ptr]
        add r9,r11                                                      ; Add e1000_tx_cur which is the current Ring Buffer index

        mov rcx,e1000_packet_size ; Get Packet size and store in rcx (Counter Register)
        cld 
        mov rsi,[e1000_send_packet]                                     ; copy the packet into the ring buffer
        mov rdi,[r9+e1000_tx_desc.addr]
        rep movsb

        mov byte[r9+e1000_tx_desc.status],0x0                                   ; Set status to 0x0 so the card can reset it
                                                                                ; when packet is sent
        mov byte[r9+e1000_tx_desc.cmd],CMD_EOP | CMD_IFCS | CMD_RS | CMD_RPS
        ; Set cmd: End of Packet, Insert CRC in ether net packet, report Status, Report Packet Sent

        mov bx,[e1000_send_packet_len] ; Store the length into the ring buffer descriptor
        mov [r9+e1000_tx_desc.length],bx

        inc word[e1000_tx_cur]                                                  ; Advance e1000_tx_cur and reset it to the
        cmp word[e1000_tx_cur],0x800                                            ; beginning of the ring buffer in case
        jl .skip_mod                                                            ; end of buffer is reached
            mov dword[e1000_tx_cur],0x0
        .skip_mod:

        mov word[e1000_rw_address],REG_TXDESCTAIL                               ; Update the tail with e1000_tx_cur
        mov r8d,[e1000_tx_cur]
        mov [e1000_rw_data],r8d
        call e1000_write_command
        .loop:                                                                  ; Loop until status not equal to zero
            cmp byte[r9+e1000_tx_desc.status],0x0
        je .loop
        mov rsi,e1000_sent_packet_msg                                           ; print a message
        call video_print

    .quit:

    popaq

ret





e1000_int_handler:                              ; This is the entry point when an interrupt is invoked

    pushaq
    
        mov word[e1000_rw_address],REG_ICR              ; Read the status register
        call e1000_read_command
        xor rax,rax
        mov eax,dword[e1000_rw_data]
        and eax,0x04
        cmp eax,0x04                                    ; Check status bit 3
        jne .skip_link_started
        mov rsi,e1000_link_restarted_int_msg            ; If set then link is restarted
        call video_print
        jmp .out
        .skip_link_started:
        mov eax,dword[e1000_rw_data]
        and eax,0x10                                    ; Else check bit 5
        cmp eax,0x10
        jne .skip_good_threshold                        ; If set then the packets are arriving
        mov rsi,e1000_good_threshold_int_msg            ; at a relatively high rate
        call video_print
        jmp .out
        .skip_good_threshold:
        mov eax,dword[e1000_rw_data]
        and eax,0x80
        cmp eax,0x80                                    ; Else check bit 7
        jne .skip_process_packet
        mov rsi,e1000_process_packet_int_msg            ; Packet received and should be processed
        call video_print
        call e1000_process_packet                       ; Call process packet which will call the stack
        jmp .out
        .skip_process_packet:                           ; Else exit
        .out:
    
    popaq

ret




e1000_process_packet:

    pushaq

        mov word[e1000_rw_address],REG_RXDESCHEAD
        call e1000_read_command
        xor r8,r8
        mov r8d,[e1000_rw_data]
        cmp r8w,[e1000_rx_cur]
        je .quit

        .loop:

            xor r8,r8
            mov r8w,[e1000_rx_cur]
            shl r8,0x4
            xor r9,r9
            mov r9,[e1000_rx_desc_ptr]
            add r9,r8
            xor rax,rax
            mov al,byte[r9+e1000_rx_desc.status]
            and al,0x1
            cmp al,0x1
            jne .update_tail

            mov rcx,e1000_packet_size
            shr rcx,8
            cld
            mov rsi,[r9+e1000_rx_desc.addr]
            mov rdi,[e1000_recv_packet]
            rep movsq


            mov bx,[r9+e1000_rx_desc.length]
            mov [e1000_recv_packet_len],bx
            call network_stack

            mov byte[r9+e1000_rx_desc.status],0x0
            inc word[e1000_rx_cur]
            cmp word[e1000_rx_cur],0x800
            jl .skip_mod
                mov dword[e1000_rx_cur],0x0
            .skip_mod:

        jmp .loop

        .update_tail: ; Update the tail of the ring buffer by writing

            mov word[e1000_rw_address],REG_RXDESCTAIL
            mov r8d,[e1000_rx_cur]
            mov [e1000_rw_data],r8d
            call e1000_write_command

        .quit:

    popaq

ret





network_stack:

    pushaq

        xor rdi,rdi
        mov di,[r9+ethernet_packet.h_type]
        rol di,0x8

        cmp di,ETHERTYPE_ARP
        jne .skip_arp
            call process_arp
            jmp .quit

        .skip_arp:

        cmp di,ETHERTYPE_IP
        jne .quit
            call process_ip
        .quit:

    popaq

ret




process_arp:

    pushaq

        mov r9,[e1000_recv_packet]
        mov ax,word [r9+arp_packet.ar_op]
        rol ax,0x8
        cmp ax,ARPOP_REQUEST
        jne .quit
        mov ax,word [r9+arp_packet.ar_hdr]
        rol ax,0x8
        cmp ax,ARPHRD_ETHER
        jne .quit

        xor r8,r8
        xor rbx,rbx
        mov r8d,dword[r9+arp_packet.target_proto_addr]  ; Extract IP address from the ARP packet header
        mov ebx,dword[my_ip_address]
        cmp r8,rbx                                      ; Compare with my own IP address
        jne .quit                                       ; If not equal get out, else send ARP reply
        mov rsi,my_ip_msg
        call video_print                                

        ; Store addresses of Send/Recv packet buffers into r9 and r8
        mov r8,[e1000_recv_packet]
        mov r9,[e1000_send_packet]                      

        ; Copy the source of the Recv buffer into the dest of the Send buffer
        lea rsi,[r8+ethernet_packet.h_src]
        lea rdi,[r9+ethernet_packet.h_dest]
        mov rcx,0x6
        cld
        rep movsb


        ; Copy my MAC address into the source of the Send buffer
        lea rsi,[e1000_mac_address]
        lea rdi,[r9+ethernet_packet.h_src]
        mov rcx,0x6
        cld
        rep movsb


        ; Copy the ARP type from Recv to Send buffer
        xor rax,rax
        mov ax,[r8+ethernet_packet.h_type]
        mov [r9+ethernet_packet.h_type],ax


        ; Set the ARP operation field in the Send buffer to ARPOP_REPLY
        mov ax, ARPOP_REPLY
        rol ax,0x8                                  ; Apply HTON (Host to Network)
        mov [r9+arp_packet.ar_op],ax

        mov word[r9+arp_packet.ar_hdr],ARPHRD_ETHER
        mov word[r9+arp_packet.ar_pro],ETHERTYPE_IP
        mov byte[r9+arp_packet.ar_hln],0x6
        mov byte[r9+arp_packet.ar_pln],0x4

        lea rsi,[r8+arp_packet.sender_hw_addr]
        lea rdi,[r9+arp_packet.target_hw_addr]
        mov rcx,0x6
        cld
        rep movsb

        ; Copy my MAC address to the sender source HW address
        lea rsi,[e1000_mac_address]
        lea rdi,[r9+arp_packet.sender_hw_addr]
        mov rcx,0x6
        cld
        rep movsb                                   ; Store sender IP of the receive buffer into the target IP of the sender buffer
        mov eax,[r8+arp_packet.sender_proto_addr]
        mov [r9+arp_packet.target_proto_addr],eax   ; Store target IP of the receive buffer into the sender IP of the sender buffer
        mov eax,[r8+arp_packet.target_proto_addr]
        mov [r9+arp_packet.sender_proto_addr],eax   ; Copy the length of the Receive Buffer into sender
        mov bx,[e1000_recv_packet_len]
        mov [e1000_send_packet_len],bx              ; Call e1000_send_out_packet to store the packet in the NIC send ring buffer and fire it out
        call e1000_send_out_packet
        .quit:

    popaq
ret



;*******************************************************************************************************************

e1000_mem_base dq 0x0                                      ; The base address of the MMIO physcial memory
e1000_rw_data dd 0x0                                       ; read or written data will be saved here
e1000_rw_address dw 0x0                                    ; Offset address into MMIO or Port I/O address space which I am going to read to
e1000_io_base dw 0x0                                       ; Base address of the Port
e1000_vaddress dq 0x2000000000                             ; Starting virtual address to map MMIO Physical Memory to
e1000_flag db 0x0                                          ; If the E1000 NIC is detected this flag will be set
e1000_ioport_flag db 0x0                                   ; If the NIC is PortIO based then this flag will be set
e1000_mac_address db 0x0,0x0,0x0,0x0,0x0,0x0               ; This stores the E1000 NIC 6-octet MAC address detected inside the EEProm
e1000_eeprom_addr db 0x0                                   ; Address of the EEProm that contains the MAC address of the device
e1000_int_no db 0x0                                        ; Interrupt number
e1000_eeprom_flag db 0x0                                   ; eeprom checking flag

; Messages To be printed

found_intel_e1000_msg db 'Found e1000 NIC device',13,10,0
e1000_configure_msg db 'Configuring e1000',13,10,0
e1000_map_memio_msg db 'Mapping e1000 MemIO',13,10,0
e1000_eeprom_detected_msg db 'e1000 EEProm Detected',13,10,0
e1000_eeprom_not_detected_msg db 'e1000 EEProm NOT Detected',13,10,0
e1000_start_up_link_msg db 'e1000 Started Link',13,10,0
e1000_setup_throttling_msg db 'e1000 Throttling setup done',13,10,0
e1000_multicast_vt_msg db 'e1000 clear Multicast VT done',13,10,0
e1000_mem_init_msg db 'e1000 memory setup done',13,10,0
e1000_rx_init_msg db 'e1000 init RX',13,10,0
e1000_tx_init_msg db 'e1000 init TX',13,10,0
e1000_enable_interrupt_msg db 'e1000 interrupts enabled',13,10,0
e1000_got_packet_msg db 'e1000 got interrupt',13,10,0
e1000_link_restarted_int_msg db 'e1000(int) link restarted',13,10,0
e1000_good_threshold_int_msg db 'e1000(int) good threshold',13,10,0
e1000_process_packet_int_msg db 'e1000(int) process packet',13,10,0
e1000_sent_packet_msg db 'e1000 sent packet',13,10,0
my_ip_msg db 'got ARP Packet',13,10,0
start_bus_mastering_msg db 'start bus mastering',13,10,0
bus_mastering_msg db 'bus mastering',13,10,0
my_icmp_msg db 'ICMP packet successfull',13,10,0

;*******************************************************************************************************************




; PCI bus/device/function of slot that the detected E1000 NIC is connected to

e1000_bus db 0
e1000_device db 0
e1000_function db 0

e1000_rx_cur dw 0x0
e1000_tx_cur dw 0x0

e1000_rx_desc_ptr dq 0x0
e1000_tx_desc_ptr dq 0x0


e1000_rx_packets_ptr dq 0x0
e1000_tx_packets_ptr dq 0x0

e1000_recv_packet dq 0x0
e1000_send_packet dq 0x0

e1000_recv_packet_len dw 0x0
e1000_send_packet_len dw 0x0

my_ip_address db 192,168,1,88               ; IP address assigned to the E1000 NIC


;*******************************************************************************************************************

; Receive Ring Buffer Descriptor Structure

struc e1000_rx_desc
    .addr resq 1        ; address of the packet connected to the Descriptor
    .length resw 1      ; The length of the packet 
    .checksum resw 1    ; Thus is used by the software to check the packet
    .status resb 1      ; Eevery time a packet is consumed from the ring buffer the status value is set to zero
    .errors resb 1      ; errors is stored in this flag
    .special resw 1     ; area used to store extra area used by the software
endstruc

; Transmit Ring Buffer Descriptor Structure

struc e1000_tx_desc
    .addr resq 1        ; address of the packet connected to the Descriptor in the transmitting buffer
    .length resw 1      ; The length of the packet 
    .cso resb 1         ; In case of TCP this will be used as a checksum field
    .cmd resb 1         ; sets the card with the way how to send a packet
    .status resb 1      ; status of sending
    .css resb 1         ; Tells us wehere to begin to compute the checksum
    .special resw 1     ; area used to store extra area used by the software
endstruc

;*******************************************************************************************************************
