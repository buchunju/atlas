BITS 16
_load_disk:
	pusha
	push dx
	

load_again:
	mov ah, 0x02	; ah <- int 0x13 function. 0x02 = 'read'
	mov al, dh		; al <- number of sectors to read
	mov ch, 0x00	; ch <- cylinder
	mov dh, 0x00	; dh <- head number

	int 0x13 		; BIOS interrupt

	jc disk_error

	pop dx

	cmp al, dh		; BIOS also sets 'al' to the number of sectors read. Compare it.
	jne sectors_error

	popa
	ret


disk_error:
	mov bx, DISK_ERROR
	call print
	mov dh, ah		; ah = error code, dl = disk drive that dropped the error
	call print_hex	
	jmp disk_loop



sectors_error:
	mov bx, SECTORS_ERROR
	call print

disk_loop:
	jmp $