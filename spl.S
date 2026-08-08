/*
 * Secondary Program Loader (SPL) for Linux on Samsung GT-E2121B
 */

/* MMIO addresses */
#define PNX4852_BUS_BASE	0x70000000
#define PNX4852_SYS_BASE	0x70002000
#define PNX4852_HF_BASE		0x70004000
#define PNX4852_UART0_BASE	0x70007000
#define PNX4852_UART1_BASE	0x70006000
#define PNX4852_PSEQ_BASE	0x7001b000

/* partitions */
#define FLASH_BASE	0x90000000
#define FDT_BASE	0x90040000
#define KERNEL_BASE	0x90080000

_start:
	/* locking power */
	ldr r0, =PNX4852_PSEQ_BASE
	ldr r1, =0x01000000
	str r1, [r0, #0x30]


	ldr r0, =PNX4852_BUS_BASE

	/* set up bus 0 (LCD), Motorola 6800 8-bit parallel interface */
	ldr r1, =0x1b21b209
	str r1, [r0]
	ldr r1, =0x82110015
	str r1, [r0, #0x20]
	mov r1, #0
	str r1, [r0, #0x90]


	/* set up bus 1 (Flash) and enable the burst mode */
	ldr r1, =(FLASH_BASE | 0x01000aaa)
	mov r2, #0xaa
	strh r2, [r1]
	ldr r1, =(FLASH_BASE | 0x01000554)
	mov r2, #0x55
	strh r2, [r1]
	ldr r1, =(FLASH_BASE | 0x011a4aaa)
	mov r2, #0xc0
	strh r2, [r1]

	ldr r1, =0x484000c9
	str r1, [r0, #0x4]
	ldr r1, =0x404
	str r1, [r0, #0x44]
	ldr r1, =0x143d3dd7
	str r1, [r0, #0x94]
	ldr r1, =0x82337259
	str r1, [r0, #0x24]


	/* set up bus 2 (CRAM) and enable the burst mode */
	ldr r1, [r0, #0x8]
	ldr r2, =0xff0fffff
	and r1, r2
	str r1, [r0, #0x8]

	ldr r1, =0xa0fffffe
	ldrh r2, [r1]
	ldrh r2, [r1]
	mov r2, #1
	strh r2, [r1]
	ldr r2, =0x1903
	strh r2, [r1]

	mov r1, #0xc9
	str r1, [r0, #0x8]
	ldr r1, =0x404
	str r1, [r0, #0x48]
	ldr r1, =0x14ff1ff3
	str r1, [r0, #0x98]
	ldr r1, =0x822232d8
	str r1, [r0, #0x28]


	/* enable 156 MHz clocking */
	ldr r0, =PNX4852_SYS_BASE
	ldr r1, =0x00033151
	str r1, [r0, #0x10]


	/* enabling UART Handsfree ports */
	ldr r0, =PNX4852_HF_BASE
	mov r1, #0xc0
	str r1, [r0, #0xc]

	/* default baud 115200 */
	ldr r1, =0xe0
	ldr r0, =PNX4852_UART0_BASE
	str r1, [r0, #0x8]
	ldr r0, =PNX4852_UART1_BASE
	str r1, [r0, #0x8]


	/* unprotect the flash chip */
	ldr r0, =FLASH_BASE
	mov r1, #0x84
	ldr r2, =0x02000000
	mov r3, #0x60
	ldr r4, =0x01fe0000

0:	strh r3, [r0, r1]
	strh r3, [r0, r1]
	strh r3, [r0, r1]

	cmp r1, r4
	addlt r1, #0x20000
	addge r1, #0x8000

	cmp r1, r2
	blt 0b


	/* set up registers and jump to the kernel */
	mov r0, #0
	mvn r1, #0
	ldr r2, =FDT_BASE
	mov r3, #0
	ldr pc, =KERNEL_BASE
