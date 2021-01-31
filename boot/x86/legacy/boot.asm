BITS 16

org 0x7c00

section .bootsect

; ############## STAGE 1 ####################

global _boot
_boot:
	jmp _begin
	nop

;======== FAT32 BPB =====
oem_name              : dq "MSDOS5.0"
sector_size           : dw 512
sector_per_cluster    : db 2
reserved_sectors      : dw 6
fat_number            : db 1
files_in_root         : dw 0
sectors_in_fs         : dw 0
media_type            : db 0xf0
fat_size_in_sectors   : dw 0
sector_per_track      : dw 32
head_count            : dw 64
sectors_hidden        : dd 0
sectors_in_fs_ext     : dd 200000
fat_32_count          : dd 780
ext_flags             : dw 0b0000000100000000
fs_version            : dw 0
root_cluster          : dd 3
fs_info               : dw 0xFFFF
backup_boot_sector    : dw 3
reserved              : dw 6 dup(0)
drive_number          : db 0
unused                : db 0
ext_boot_signature    : db 0x29
volume_serial_number  : dd 0xdeadbeef
volume_label          : db "ATLAS 0.1  "
fs_type_label         : dq "FAT32   "

_begin:
	cli
	cld
	xor ax, ax
	mov fs, ax
	mov gs, ax
	mov ds, ax
	mov es, ax
	mov sp, 0x7c00
	mov bp, sp

	sti

	mov bx, BOOT1_MSG
	call print

	mov [boot_device], dl

	mov bx, 0x7e00
	mov cl, 0x02
	mov dh, 1
	mov dl, [boot_device]
	call _load_disk

_cont:
	jmp 0x7e00
	jmp $


boot_device db 0

%include "x86/disk.inc"
%include "x86/print.inc"

BOOT1_MSG     db "BOOT1",10,13,0
DISK_ERROR    db "Disk read error",10,13, 0
SECTORS_ERROR db "Incorrect sectors read", 0

times 416 - ($ - $$) db 0

times 510 - ($ - $$) db 0
db 0x55
db 0xaa


; ############### STAGE 2 ###################

_stage2:
	mov bx, STAGE2_MSG
	call print

	mov bx, 0x1000
	mov cl, 0x03
	mov dh, 10
	mov dl, [boot_device]
	call _load_disk
	call _pm_switch

_pm_switch:
	cli
	lgdt[gdt_descriptor]	; Load gdt
	
	mov eax, cr0 		
	or eax, 0x1		; Set bit 0 to 1
	mov cr0, eax
	
	jmp CODE_SEG:init_pm 	; 4. Far jump using a different segment



BITS 32

init_pm:
	mov ax, DATA_SEG 	; 5. Update segment registers
	mov ds, ax		
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax

	mov ebp, 0x90000	; 6. update the stack right at the top of the free space
	mov esp, ebp

	call enable_A20

	call 0x1000

	jmp $

enable_A20:
	call is_A20_on
	cmp eax, 1
	je finish
	; call enable_a20_bios
	; cmp eax, 1
	; je finish
	call enable_a20_keyboard
	cmp eax, 1
	je finish
	call enable_a20_fast
	cmp eax, 1
	je finish
	mov ebx, A20_FAILED
	call print_pm

	jmp $

finish:
	ret

is_A20_on:   
 
	pushad
	mov edi,0x112345  ;odd megabyte address.
	mov esi,0x012345  ;even megabyte address.
	mov [esi],esi     ;making sure that both addresses contain diffrent values.
	mov [edi],edi     ;(if A20 line is cleared the two pointers would point to the address 0x012345 that would contain 0x112345 (edi)) 
	cmpsd             ;compare addresses to see if the're equivalent.
	popad
	jne A20_on        ;if not equivalent , A20 line is set.
	mov eax, 0
	ret               ;if equivalent , the A20 line is cleared.
 
A20_on:

	mov eax, 1
	ret

; enable_a20_bios:

enable_a20_keyboard:
        cli
 
        call    a20wait
        mov     al,0xAD
        out     0x64,al
 
        call    a20wait
        mov     al,0xD0
        out     0x64,al
 
        call    a20wait2
        in      al,0x60
        push    eax
 
        call    a20wait
        mov     al,0xD1
        out     0x64,al
 
        call    a20wait
        pop     eax
        or      al,2
        out     0x60,al
 
        call    a20wait
        mov     al,0xAE
        out     0x64,al
 
        call    a20wait
        sti
        call is_A20_on
        ret
 
a20wait:
        in      al,0x64
        test    al,2
        jnz     a20wait
        ret
 
 
a20wait2:
        in      al,0x64
        test    al,1
        jz      a20wait2
        ret

enable_a20_fast:
	in   al,  0x92
	test al,  2
	jnz  after
	or   al,  2
	and  al,  0xFE
	out  0x92,al
after:
	call is_A20_on
	ret

%include "x86/gdt.inc"
%include "x86/print_pm.inc"

STAGE2_MSG: db "BOOT2",10,13,0
A20_FAILED: db "Failed: A20",0

times 1024 - ($ - $$) db 0
