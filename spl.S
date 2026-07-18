/*
 * Secondary Program Loader (SPL) for Linux on NXP PNX49xx SoC
 */

/* MMIO addresses */
#define PNX49XX_CLK_BASE	0x70002000
#define PNX49XX_HF_BASE		0x70004000
#define PNX49XX_UART0_BASE	0x70007000
#define PNX49XX_UART1_BASE	0x70006000
#define PNX49XX_PSEQ_BASE	0x7001b000

/* partitions */
#define FDT_BASE	0x90040000
#define KERNEL_BASE	0x90080000

_start:
	/* locking power */
	ldr r0, =PNX49XX_PSEQ_BASE
	mov r1, #0x01000000
	str r1, [r0, #0x30]

	/* enabling UART Handsfree ports */
	ldr r0, =PNX49XX_HF_BASE
	mov r1, #0xc0
	str r1, [r0, #0xc]

	/* default baud 9600 */
	ldr r1, =0xa93
	ldr r0, =PNX49XX_UART0_BASE
	str r1, [r0, #0x8]
	ldr r0, =PNX49XX_UART1_BASE
	str r1, [r0, #0x8]

	/* increase cpu speed */
	ldr r0, =PNX49XX_CLK_BASE
	ldr r1, =0x00033251
	str r1, [r0, #0x10]

	/* set up registers and jump to the kernel */
	mov r0, #0
	mvn r1, #0
	ldr r2, =FDT_BASE
	mov r3, #0
	ldr pc, =KERNEL_BASE
