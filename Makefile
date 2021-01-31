PROJECT_ROOT:=.

include $(PROJECT_ROOT)/make.config

### legacy bootloader binary
$(LEGACY) : 
	@$(MAKE) -C boot/x86 $@


### efi not implemented yet




### compile both legacy and efi bootloader files.
all: $(LEGACY)
	@echo "Done compiling the bootloader."


### remove the object and binary files.
clean:
	@$(MAKE) -C boot/x86 $@