#
# makefile for ultimate machine firmware
#
SHELL = /bin/sh
all:
	@echo Building firmware...
	@gpasm -ppic10f220 main.asm && cat main.lst | grep "Program Memory"
	@if [ $$? -ne 1 ]; then \
		echo Build succeded. Programming device...; \
		pk2cmd -M -PPIC10f220 -Fmain.hex; \
	fi
	
build:
	@echo Building firmware...
	@gpasm -ppic10f220 main.asm && cat main.lst | grep "Program Memory"
	
run:
	@pk2cmd -T -R -PPIC10f220

clean:
	@rm *.hex *.cod *.lst
	