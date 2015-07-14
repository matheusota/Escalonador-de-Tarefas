# ----------------------------------
# Compiling/Assembling/Linking Tools and flags
AS=arm-eabi-as
AS_FLAGS=-g

CC=arm-eabi-gcc
CC_FLAGS=-g

LD=arm-eabi-ld
LD_FLAGS=-g

# ----------------------------------
# Default rule
all: disk.img

# ----------------------------------
# Generic Rules
%.o: %.s
	$(AS) $(AS_FLAGS) $< -o $@

%.o: Testes/%.s
	$(CC) $(CC_FLAGS) -c $< -o $@
	
%.o: Testes/%.c
	$(CC) $(CC_FLAGS) -c $< -o $@


# ----------------------------------
# Specific Rules
ra138889_ra120246: ra138889_ra120246.o
	$(LD) $^ -o $@ $(LD_FLAGS) --section-start=.iv=0x778005e0 -Ttext=0x77800700 -Tdata=0x77801800 -e 0x778005e0

TESTE.x: teste_$(number).o syscaller.o
	$(LD) $^ -o $@ $(LD_FLAGS) -Ttext=0x77802000

disk.img: ra138889_ra120246 TESTE.x
	mksd.sh --so ra138889_ra120246 --user TESTE.x

clean:
	rm -f ra138889_ra120246.o TESTE.x disk.img *.o
