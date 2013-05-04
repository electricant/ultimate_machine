#
# makefile for ultimate machine firmware
#
SHELL = /bin/sh
all:
	@echo Building firmware...
	@gpasm -ppic10f220 main.asm
	@if [ $$? -ne 1 ]; then \
		echo Build succeded. Programming device...; \
		pk2cmd -M -PPIC10f220 -Fmain.hex; \
	fi
	
build:
	@gpasm -ppic10f220 main.asm
	
run:
	@pk2cmd -T -R -PPIC10f220

clean:
	@rm *.hex *.cod *.lst
	