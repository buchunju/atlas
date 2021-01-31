PROJECT_ROOT:=../..

include $(PROJECT_ROOT)/make.config

LEGACY_SRC:=$(wildcard legacy/src/*.c)
LEGACY_ASM:=$(wildcard legacy/src/*.asm)

LEGACY_OBJ+=$(LEGACY_SRC:.c=.o)
LEGACY_OBJ+=$(LEGACY_ASM:.asm=.o)

%.o: %.c
	@echo -n 'compiling $(@F) ...'
	@$(COMPILE.c) -I$(PROJECT_ROOT)/include $^ -o $@
	@echo 'done'

%.o : %.asm
	@echo -n 'compiling $(@F) ...'
	@$(COMPILE.s) -I$(PROJECT_ROOT)/include $^ -o $@
	@echo 'done'

$(STAGE2_BIN): $(LEGACY_OBJ)
	@echo -n 'generating  $@ ...'
	@$(LINK.c) $^ -o $@
	@echo 'done'

$(STAGE1_BIN):
	@echo -n 'generating  $@ ...'
	@$(AS) -f bin legacy/boot.asm -I$(PROJECT_ROOT)/include -o $@
	@echo 'done'

$(LEGACY): $(STAGE1_BIN) $(STAGE2_BIN)
	@echo -n 'finishing  $(@F) ...'
	@$(PROJECT_ROOT)/$(MKHDD)
	@echo 'done'

clean:
	@echo -n 'Cleaning up ....'
	@$(RM) legacy/src/*.o
	@$(RM) *.bin
	@$(RM) *.img
	@echo 'done'