BITS 32

section .text
EXTERN main
GLOBAL _start

_start:
	call main
	jmp $