// Only print a 'B' then hang.
// TODO: implement the rest in C.
void main()
{
	*(unsigned short *)0xb8000 = 0x0f42;
	for(;;);
}
