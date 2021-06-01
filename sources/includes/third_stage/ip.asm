%define IP_PACKET_TYPE_ICMP 0x1 ; ICMP Protocol number in IP header
%define IP_PACKET_TYPE_TCP 0x6 ; TCP Protocol number in IP header
%define IP_PACKET_TYPE_UDP 0x11 ; UDP Protocol number in IP header

%define ICMP_ECHOREPLY 0
%define ICMP_ECHO 8
%define ICMP_INFO_REQUEST 15
%define ICMP_INFO_REPLY 16

checksum_counter dw 0x0
checksum_failed db 'Checksum failed: Message corrupted',13,10,0

struc ip_hdr
        .ethernet       resb 14         ; header from network layer (ethernet)
        .ihlv           resb 1          ; contains higher 4-bits is IP header length and lower 4-bits is IP version 
        .tos            resb 1          ; type of service
        .tot_len        resw 1          ; total length (header+data)
        .id             resw 1          ; Identification
        .flgs           resb 1          ; Flags
        .frag_offset    resb 1          ; Fragment offset
        .ttl            resb 1          ; Time to live
        .protocol       resb 1          ; contains protocol number of transport layer (UDP, TCP, ICMP)
        .check          resw 1          ; header checksum
        .saddr          resd 1          ; source IP address
        .daddr          resd 1          ; destination address
endstruc


struc ip_icmp_echo ; Echo Datagrams
        .type           resb 1          ; Type of protocol (Reply or request)
        .code           resb 1          ; sub-code (usually 0 in echo)
        .checksum       resw 1          ; Checksum of ICMP header and data
        .id             resw 1          ; Used for time stamp matching by the client
        .sequence       resw 1          ; Used for time stamp matching by the client
endstruc

struc ip_icmp_frag ; MTU Discovery
        .type          resb 1 
        .code          resb 1 
        .checksum      resw 1 
        .unused        resw 1 
        .mtu           resw 1 
endstruc

struc ip_icmp_gw ; Gateway Diagnostics
        .type           resb 1 
        .code           resb 1 
        .checksum       resw 1 
        .gate           resd 1 
endstruc




process_ip:

        pushaq
        
                mov r9,[e1000_recv_packet]              ; get recieved packet
                mov al, byte[r9+ip_hdr.protocol]        ; extract protocol number from IP header
                ;rol ax, 0x4
                cmp al, IP_PACKET_TYPE_ICMP             ; compare protocol number with ICMP protocol number
                jne .quit                               ; if not ICMP protocol then quit

                ; how to detect ICMP type
                mov al, byte[r9+ip_icmp_echo.type]
                ;rol ax, 0x4
                cmp al, ICMP_ECHO                       ; compare ICMP type number with ICMP type 8 (request)
                jne .quit                               ; if not ICMP echo request then quit

                xor r8, r8
                xor rbx, rbx
                mov r8d, dword[r9+ip_hdr.daddr]         ; retrieve destination IP address from recieved IP packet
                mov ebx, dword[my_ip_address]           ; get my IP address
                cmp r8, rbx                             ; compare IP addresses
                jne .quit                               ; if my IP addresses are not equal then quit
                mov rsi, my_icmp_msg                       
                call video_print                        ; print success message

                ; load recieve and send packets
                mov r8,[e1000_recv_packet]
                mov r9,[e1000_send_packet]
                
                ;Ethernet Packet: set the destination of the send buffer with the source of the recieve buffer
                lea rsi,[r8+ethernet_packet.h_src] 
                lea rdi,[r9+ethernet_packet.h_dest]
                mov rcx,0x6 
                cld
                rep movsb

                ;Ethernet Packet: set the source of the send buffer with our mac address
                lea rsi,[e1000_mac_address]
                lea rdi,[r9+ethernet_packet.h_src]
                mov rcx,0x6 
                cld
                rep movsb

                ;Ethernet Packet: set the type of the send buffer with the type of the recieve buffer (type -> IP)
                xor rax,rax
                mov ax,[r8+ethernet_packet.h_type]
                mov [r9+ethernet_packet.h_type],ax


                ;ICMP: Type and Code of ICMP
                mov al, ICMP_ECHOREPLY                           
                ; rol al,0x4
                mov [r9+ip_icmp_echo.type], al                  ; set protocol type in ip_icmp_echo to echo_reply (0)
                mov byte [r9+ip_icmp_echo.code], 0x0            ; set code in ip_icmp_echo to 0

                ;ICMP: checksum of ICMP
                xor rax, rax
                mov ax, [r8+ip_icmp_echo.checksum]
                call calcChecksum
                cmp ax, word[checksum_counter]
                jne .checksum_error
                mov [r9+ip_icmp_echo.checksum], ax

                ;ICMP: set identifier in ip_icmp_echo to the sender ip_icmp_echo.id
                xor rax, rax                                    
                mov ax, [r8+ip_icmp_echo.id]                    
                mov [r9+ip_icmp_echo.id], ax

                ;ICMP: sequence number of ICMP
                xor rax, rax                                    
                mov ax, [r8+ip_icmp_echo.sequence]                    
                inc ax
                mov [r9+ip_icmp_echo.sequence], ax


                ; IP header 

                ;IP-Header: Move source IP address to dest
                lea rsi,[r8+ip_hdr.saddr] 
                lea rdi,[r9+ip_hdr.daddr]
                mov rcx,0x4 
                cld
                rep movsb

                ;IP-Header: Move dest IP address to source
                lea rsi,[r8+ip_hdr.daddr] 
                lea rdi,[r9+ip_hdr.saddr]
                mov rcx,0x4 
                cld
                rep movsb

                ;IP-Header: Header length and IP Version
                xor rax,rax
                mov al,[r8+ip_hdr.ihlv]
                mov [r9+ip_hdr.ihlv],al

                ;IP-Header: Type of service
                xor rax,rax
                mov al,[r8+ip_hdr.tos]
                mov [r9+ip_hdr.tos],al

                ;IP-Header: Total size of packet 
                xor rax,rax
                mov ax,[r8+ip_hdr.tot_len]
                mov [r9+ip_hdr.tot_len],ax

                ;IP-Header: Indentifier for fragmentation 
                xor rax,rax
                mov ax,[r8+ip_hdr.id]
                mov [r9+ip_hdr.id],ax

                ;IP-Header: Indentifier for fragmentation 
                xor rax,rax
                mov al,[r8+ip_hdr.flgs]
                mov [r9+ip_hdr.flgs],al

                ;IP-Header: Fragment offset 
                xor rax,rax
                mov al,[r8+ip_hdr.frag_offset]
                mov [r9+ip_hdr.frag_offset],al

                ;IP-Header: Time-to-live
                xor rax,rax
                mov al,[r8+ip_hdr.ttl]
                mov [r9+ip_hdr.ttl],al

                ;IP-Header: Protocol number 
                xor rax,rax
                mov al,[r8+ip_hdr.protocol]
                mov [r9+ip_hdr.protocol],al

                ;IP-Header: Calculate IP-Header checksum 
                xor rax,rax
                mov ax,[r8+ip_hdr.check]
                call checksum_IP_Header
                mov [r9+ip_hdr.check],ax


                ;Send Packet: Sent length of send packet as recieve packet 
                mov bx,[e1000_recv_packet_len] 
                mov [e1000_send_packet_len],bx

                ;Send Packet: all parameters are loaded so send packet
                call e1000_send_out_packet

                jmp .quit
                .checksum_error:
                        mov rsi, checksum_failed
                        call video_print

                .quit:
        popaq
        ret


calcChecksum:
        pushaq
                xor ebx, ebx                            ; set counter to 0
                xor rcx, rcx
                mov cx, [r8+ip_hdr.tot_len]             ; get total size of ip packet (header+data)
                rol cx, 0x8                             ; convert endians
                sub cx, 34                              ; now we have the size of payload

                lea rsi, [r8+ip_hdr]                    ; get address of start of ip packet 
                add rsi, 34                             ; add 34 to skip the ip header
                ; rsi now has payload address

                .loop:
                        xor rax,rax
                        mov ax, word[rsi]               ; get data stored in rsi 
                        add ebx, eax                    ; add every word in data
                        add rsi, 2                      ; increment by word                 
                        sub cx, 2                       ; decrement size counter by word
                        cmp cx, 0x1                     
                        jg .loop                        ; continue to loop while size is not 0
                        jne .skipODD
                        xor rax,rax
                        mov al, byte[rsi]               ; if odd then add byte
                        add ebx, eax
                .skipODD:
                        xor rax, rax
                        xor rdx, rdx
                        mov eax, ebx                    
                        mov edx, ebx
                        shr eax, 16                     ; remove lower 16-bits
                        and edx, 0xffff                 ; remove upper 16-bits
                        add eax, edx                    
                        mov ebx, eax                    ; add lower 16-bits with upper 16-bits

                        xor rax, rax
                        mov eax, ebx
                        shr eax, 16                     ; shift upper 16-bits to lower 16-bits
                        add ebx, eax
                        not ebx                         ; 1's complement of ebx

                        mov word[checksum_counter], bx
        popaq
        ret


 checksum_IP_Header:

        pushaq
                ;xor rcx, rcx
                lea rsi, [r8+ip_hdr]
                add rsi, 14
                xor rdx, rdx
                xor rbx, rbx
                
                .loop: 
                        xor rax, rax
                        mov ax, word[rsi]               ; move word to ax
                        add ebx, eax                    ; add to counter
                        mov eax, ebx                    
                        shr eax, 16                     ; shift right to move upper 16-bits to lower 16-bits (folding)
                        add ebx, eax                    ; add upper 16-bits to lower 16-bits
                        add rsi, 0x2                    ; increment IP header pointer by word (2 bytes)
                        add rdx, 0x2                    ; increment counter by 2
                        cmp rdx, 20                     ; compare with IP_header size (20 bytes)
                        jl .loop

                        not ebx                         ; 1's complement of ebx
                        mov word[checksum_counter], bx  

        popaq
        ret

