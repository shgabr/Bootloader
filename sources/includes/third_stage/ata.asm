; The Command Register and trhe BASE I/O ports can be retrieved from the PCI BARs, but they are kind of standard and we will define them here for better code presentability
; When we write it is considered CR, and when we read what is returned is the AS Register
%define ATA_PRIMARY_CR_AS        0x3F6 ; ATA Primary Control Register/Alternate Status Port
%define ATA_SECONDARY_CR_AS      0x376 ; ATA Secondary Control Register/Alternate Status Port

%define ATA_PRIMARY_BASE_IO          0x1F0 ; ATA Primary Base I/O Port, up to 8 ports available to 0x1F7
%define ATA_SECONDARY_BASE_IO          0x170 ; ATA Primary Base I/O Port, up to 8 ports available to 0x177

%define ATA_MASTER              0x0     ; Mastrer Drive Indicator
%define ATA_SLAVE               0x1     ; SLave Drive Indicator

%define ATA_MASTER_DRV_SELECTOR    0xA0     ; Sent to ATA_REG_HDDEVSEL for master
%define ATA_SLAVE_DRV_SELECTOR     0xB0     ; sent to ATA_REG_HDDEVSEL for slave


; Commands to issue to the controller channels
%define ATA_CMD_READ_PIO          0x20      ; PIO LBA-28 Read
%define ATA_CMD_READ_PIO_EXT      0x24      ; PIO LBA-48 Read
%define ATA_CMD_READ_DMA          0xC8      ; DMA LBA-28 Read
%define ATA_CMD_READ_DMA_EXT      0x25      ; DMA LBA-48 Read
%define ATA_CMD_WRITE_PIO         0x30      ; PIO LBA-28 Write
%define ATA_CMD_WRITE_PIO_EXT     0x34      ; PIO LBA-48 Write
%define ATA_CMD_WRITE_DMA         0xCA      ; DMA LBA-28 Write
%define ATA_CMD_WRITE_DMA_EXT     0x35      ; DMA LBA-48 Write
%define ATA_CMD_IDENTIFY          0xEC      ; Identify Command

; Different Status values where each bit represents a status
%define ATA_SR_BSY 0x80             ; 10000000b     Busy
%define ATA_SR_DRDY 0x40            ; 01000000b     Drive Ready
%define ATA_SR_DF 0x20              ; 00100000b     Drive Fault
%define ATA_SR_DSC 0x10             ; 00010000b     Overlapped mde
%define ATA_SR_DRQ 0x08             ; 00001000b     Set when the drive has PIO data to transfer
%define ATA_SR_CORR 0x04            ; 00000100b     Corrected Data; always set to zero
%define ATA_SR_IDX 0x02             ; 00000010b     Index Status always set to Zero
%define ATA_SR_ERR 0x01             ; 00000001b     Error


; Ports offsets that can be used relative to the I/O base ports above.
; The use of the offset is defined by the ATA data sheet specifications.
%define ATA_REG_DATA       0x00
%define ATA_REG_ERROR      0x01
%define ATA_REG_FEATURES   0x01
%define ATA_REG_SECCOUNT0  0x02     ; Used to send the number of sectors to read, max 256
%define ATA_REG_LBA0       0x03     ; LBA0,1,2 are used to store the address of the first sector (24-bits)
%define ATA_REG_LBA1       0x04     ; Incase of LBA-28 the remaining 4 bits are sent as the higher 4 bits of
%define ATA_REG_LBA2       0x05     ; ATA_REG_HDDEVSEL when selecting the drive
%define ATA_REG_SECCOUNT1  0x02     ; Used for LBA-48 which allows 16 bit for the number of sector to be read, max 65536 
%define ATA_REG_LBA3       0x03     ; The rmaining 20-bit to acheive LBA-48 and nothing is written to  ATA_REG_HDDEVSEL
%define ATA_REG_LBA4       0x04
%define ATA_REG_LBA5       0x05
%define ATA_REG_HDDEVSEL   0x06     ; The register for selecting the drive, master of slave
%define ATA_REG_COMMAND    0x07     ; This register for sending the command to be performed after filling up the rest of the registers
%define ATA_REG_STATUS     0x07     ; This register is used to read the status of the channel

ata_pci_header times 1024 db 0      ; A memory space to store ATA Controller PCI Header (4*256),it is 4 buffers

ata_identify_buffer times 2048 db 0 ; A memory space to store the 4 ATA devices identify details (4*512)
ata_identify_buffer_index dw 0x0    ; it acts like an offset,points to one of the drives within the buffer

; Indexed values
ata_control_ports dw ATA_PRIMARY_CR_AS,ATA_SECONDARY_CR_AS,0          ; array of 3 elements stores a cr of the primary,followed by cr of secondary
ata_base_io_ports dw ATA_PRIMARY_BASE_IO,ATA_SECONDARY_BASE_IO,0      ; array of 3 elements stores base of the primary,secondary base
ata_slave_identifier db ATA_MASTER,ATA_SLAVE,0                        ; array stores the master and slave
ata_drv_selector db ATA_MASTER_DRV_SELECTOR,ATA_SLAVE_DRV_SELECTOR,0  ; array contains the selector codes of the master and the slave

ata_error_msg       db "Error Identifying Drive",13,10,0
ata_identify_msg    db "Found Drive",0
;ata_identify_buffer times 2048 db 0                                   ; A memory space to store the 4 ATA devices identify details (4*512)
;ata_identify_buffer_index dw 0x0
ata_channel db 0
ata_slave db 0  
lba_48_supported db 'LBA-48 Supported',0
align 4


struc ATA_IDENTIFY_DEV_DUMP                     ; Starts at
.device_type                resw              1
.cylinders                  resw              1 ; 1
.gap0                       resw              1 ; 2
.heads                      resw              1 ; 3
.gap1                       resw              2 ; 4
.sectors                    resw              1 ; 6
.gap2                       resw              3 ; 7
.serial                     resw              10 ; 10
.gap3                       resw              3  ; 20
.fw_version                 resw              4  ; 23
.model_number               resw              20 ; 27
.gap4                       resw              2  ; 47
.capabilities               resw              1  ; 49       Bit-9 set for LBA Support, Bit-8 for DMA Support
.gap5                       resw              3  ; 50
.avail_bf                   resw              1  ; 53
.current_cyl                resw              1  ; 54
.current_hdr                resw              1  ; 55
.current_sec                resw              1  ; 56
.total_sec_obs              resd              1  ; 57
.gap6                       resw              1  ; 59
.total_sec                  resd              1  ; 60       Number of sectors when in LBA-28 mode
.gap7                       resw              1  ; 62
.dma_mode                   resw              1  ; 63
.gap8                       resw              16 ; 64
.major_ver_num              resw              1  ; 80
.minor_ver_num              resw              1  ; 81
.command_set1               resw              1  ; 82
.command_set2               resw              1  ; 83
.command_set3               resw              1  ; 84
.command_set4               resw              1  ; 85
.command_set5               resw              1  ; 86       Bit-10 is set if LBA-48 is supported
.command_set6               resw              1  ; 87
.ultra_dma_reporting        resw              1  ; 88
.gap9                       resw              11 ; 89
.lba_48_sectors             resq              1  ; 100      Number of sectors when in LBA-48 mode
.gap10                      resw              23 ; 104
.rem_media_status_notif     resw              1  ; 127
.gap11                      resw              48 ; 128
.curret_media_serial_number resw              1  ; 176
.gap12                       resw             78 ; 177
.integrity_word             resw              1  ; 255      Checksum
endstruc

; it will copy the pci_header to a special memory buffer in the ata_pci_header upon finding a device with class 0x1 

ata_copy_pci_header: ; need to be called in every iteration of the PCI Scan
 pushaq
    mov rdi,ata_pci_header   
    mov rsi,pci_header
    mov rcx, 0x20           ; rep stosq needs this as a counter set to 256
    xor rax, rax            ; let rax = 0
    cld                     ; zero out the direction flag 
    rep stosq               ; this will happen for 256 and each time increments edi  
 popaq
 ret

; function responsible for selecting a disk from a channel

select_ata_disk:                         ; this function takes as a parameter, rdi as a channel,rsi as master/slave,0 for master,1 for slave
 pushaq
    xor rax,rax                          ; let rax = 0
    ; to eliminate too many if conditions
    mov dx,[ata_base_io_ports+rdi]       ; if rdi=0,it will fetch the primary_base_io,else if rdi=2,it will fetch the secondary_base_io and storing in dx
    add dx,ATA_REG_HDDEVSEL              ; adding dx which is either primary base or secondary base io to offset 0x06
    mov al,byte [ata_drv_selector+rsi]   ;  if rsi=0,selector for the master,else if rsi=1,selector for the slave
    out dx,al                            ;  writing to the port number either 0xA0 or 0xB0 based on whether it is master or slave 
 popaq
 ret

; printing some of the informations 
ata_print_size:
 pushaq
    mov byte [ata_identify_buffer+39],0x0                                       ; moving zero before printing serial number
    mov rsi, ata_identify_buffer+ATA_IDENTIFY_DEV_DUMP.serial                   ; printing serial number 
    call video_print
    mov rsi,comma
    call video_print                                                            ; printing a comma
    mov byte [ata_identify_buffer+50],0x0
    mov rsi, ata_identify_buffer+ATA_IDENTIFY_DEV_DUMP.fw_version               ; printing the firmware version
    call video_print
    mov rsi,comma
    call video_print                                                            ; printing a comma
    xor rdi,rdi                                                                 ; let rdi = 0
    mov rdi, qword [ata_identify_buffer+ATA_IDENTIFY_DEV_DUMP.lba_48_sectors]   ; printing the number of lba sectors
    call bios_print_hexa
    mov ax, 0000010000000000b
    and ax,word [ata_identify_buffer+ATA_IDENTIFY_DEV_DUMP.command_set5]        ; checking whether lba 48 is supported or not 
    cmp ax,0x0                                                                  ; comparing with 0
    je .out                                                                     ; if equal to zero,then lba 48 is not supported
    mov rsi,comma
    call video_print                                                            ; printing a comma
    mov rsi,lba_48_supported
    call video_print                                                            ; printing a msg states that lba 48 is supported
    ; if lba48 not supported
 .out:
    mov rsi,newline
    call video_print                                                            ; printing a newline
 popaq
 ret

ata_identify_disk:                         ; this function takes as a parameter, rdi as a channel,rsi as master/slave,0 for master,1 for slave
 
    pushaq
    xor rax,00000000b                      ; reintialize the channel ,writing value zero to the control port to the corresponding channel
    mov dx,[ata_control_ports+rdi]         ; getting the corresponding channel by adding the index (Rdi) to the array control port
    out dx,al                              
    call select_ata_disk                   ; selecting the disk for identification
    xor rax,rax                            ; let rax = 0
                                           ; writing 0 to all of these port offsets 
    mov dx,[ata_base_io_ports+rdi]         
    add dx,ATA_REG_SECCOUNT0               
    out dx,al                              
    mov dx,[ata_base_io_ports+rdi]         
    add dx,ATA_REG_LBA0                    
    out dx,al                              
    mov dx,[ata_base_io_ports+rdi]         
    add dx,ATA_REG_LBA1                    
    out dx,al                              
    mov dx,[ata_base_io_ports+rdi]         
    add dx,ATA_REG_LBA2                    
    out dx,al                              
    mov dx,[ata_base_io_ports+rdi]                   
    add dx,ATA_REG_COMMAND                 ; fetching the command register 
    mov al,ATA_CMD_IDENTIFY                ; writing the idenity command to it,to identify the disk
    out dx,al                              
    mov dx,[ata_base_io_ports+rdi]         
    add dx,ATA_REG_STATUS                  
    in al, dx                              
    cmp al, 0x2                            ; comparing status register
    jl .error                              ; if it is less than 2,it is an error
                                           ; else
.check_ready:                                           ; loop over the status until the drq is set,drq means that the drive has data to transfer to the software
    mov dx,[ata_base_io_ports+rdi]
    add dx,ATA_REG_STATUS
    in al, dx
    xor rcx,rcx
    mov cl,ATA_SR_ERR
    and cl,al
    cmp cl,ATA_SR_ERR
    je .error                                 ; checking for the error
    mov cl,ATA_SR_DRQ
    and cl,al
    cmp cl,ATA_SR_DRQ
    jne .check_ready
    jmp .ready

.error:                                   ; printing error message
    mov rsi,ata_error_msg                     
    call video_print
    jmp .out
                                          ; reading 512 bytes,which is 256 words
 .ready: 
    mov rsi,ata_identify_msg
    call video_print                         ; printing found drive msg
    mov rdx,[ata_base_io_ports+rdi]
    mov si,word [ata_identify_buffer_index]  ; storing in si the index of the buffer that is going to be read
    add rdi,ata_identify_buffer              ; rdi points to the buffer
    mov rcx, 256                             ; let rcx = 256
    xor rbx,rbx                              ; let rbx = 0
    rep insw                                 ; reading 256 words in a loop that will retrieve 512 bytes into the buffer
    add word [ata_identify_buffer_index],256 
    call ata_print_size                      ; printing the readed info
 .out:
 popaq
 ret
