/*
 * Secondary Program Loader (SPL) for Linux on Samsung GT-E2121B
 */

/* MMIO addresses */
#define PNX4852_REG_BASE	0x70000000
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

	/* set up the bus (ig) */
	ldr r0, =PNX4852_REG_BASE
	ldr r1, =0x1b21b209
	str r1, [r0]
	ldr r1, =0x82110015
	str r1, [r0, #0x20]
	mov r1, #0
	str r1, [r0, #0x90]

	/* enabling UART Handsfree ports */
	ldr r0, =PNX4852_HF_BASE
	mov r1, #0xc0
	str r1, [r0, #0xc]

	/* default baud 9600 */
	ldr r1, =0xa93
	ldr r0, =PNX4852_UART0_BASE
	str r1, [r0, #0x8]
	ldr r0, =PNX4852_UART1_BASE
	str r1, [r0, #0x8]

	/* increase cpu speed */
	ldr r0, =PNX4852_SYS_BASE
	ldr r1, =0x00033251
	str r1, [r0, #0x10]

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
