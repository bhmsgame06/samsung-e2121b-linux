#!/usr/bin/bash

arm-none-eabi-gcc -c -o spl.o spl.S && \
	arm-none-eabi-objcopy -I elf32-littlearm -O binary spl.o spl.bin
