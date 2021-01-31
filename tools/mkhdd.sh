#!/bin/bash
cat boot1.bin boot2.bin > bootsec.bin
dd if=/dev/zero of=hdd.img bs=512 count=200000
dd if=bootsec.bin of=hdd.img conv=notrunc bs=512
dd if=bootsec.bin of=hdd.img conv=notrunc bs=512 seek=3
#dummy FAT ENTRY
echo -e -n "\xf6\xf6\xf6\xf6\xf6\xf6\xf6\xf6\x00\x00\x00\x00\xf8\xff\xff\xff\xff" | dd of=hdd.img conv=notrunc bs=1 seek=3072 count=16
echo -e -n "\x52\x52\x61\x41" | dd of=hdd.img conv=notrunc bs=1 seek=33553920 count=4
echo -e -n "\x72\x72\x41\x61\x16\x85\x01\x00\x02" | dd of=hdd.img conv=notrunc bs=1 seek=33554404 count=9
echo -e -n "\x55\xaa" | dd of=hdd.img conv=notrunc bs=1 seek=33554430 count=2

echo "bootloader :  hdd.img"
