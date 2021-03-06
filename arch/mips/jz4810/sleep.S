/*
 * linux/arch/mips/jz4810/sleep.S
 *
 * jz4730 Assembler Sleep/WakeUp Management Routines
 *
 * Copyright (C) 2005 Ingenic Semiconductor
 * Author: <jlwei@ingenic.cn>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */
#define __MIPS_ASSEMBLER
#include <asm/regdef.h>
#include <asm/mipsregs.h>
#include <asm/mach-jz4810/jz4810cpm.h>
#inclede <asm/mach-jz4810/jz4810emc.h>
	.text
	.set	noreorder
	.set	noat

	.extern jz_flush_cache_all

/*
 * jz_cpu_sleep()
 *
 * Forces CPU into sleep mode,and we will power down p0 in this mode!
 */

	.globl	jz_cpu_sleep
jz_cpu_sleep:

	/* save hi, lo and general registers except k0($26) and k1($27) (total 32) */
	move	k0, sp
	addiu	k0, k0, -(32*4)
	mfhi	k1
	sw	$0,  0(k0)
	sw	$1,  4(k0)
	sw	k1,  120(k0)		/* hi */
	mflo	k1
	sw	$2,  8(k0)
	sw	$3,  12(k0)
	sw	k1,  124(k0)		/* lo */
	sw	$4,  16(k0)
	sw	$5,  20(k0)
	sw	$6,  24(k0)
	sw	$7,  28(k0)
	sw	$8,  32(k0)
	sw	$9,  36(k0)
	sw	$10, 40(k0)
	sw	$11, 44(k0)
	sw	$12, 48(k0)
	sw	$13, 52(k0)
	sw	$14, 56(k0)
	sw	$15, 60(k0)
	sw	$16, 64(k0)
	sw	$17, 68(k0)
	sw	$18, 72(k0)
	sw	$19, 76(k0)
	sw	$20, 80(k0)
	sw	$21, 84(k0)
	sw	$22, 88(k0)
	sw	$23, 92(k0)
	sw	$24, 96(k0)
	sw	$25, 100(k0)
	sw	$28, 104(k0)
	sw	$29, 108(k0)		/* saved sp */
	sw	$30, 112(k0)
	sw	$31, 116(k0)		/* saved ra */
	move	sp, k0

	/* save CP0 registers and sp (total 26) */
	move	k0, sp
	addiu	k0, k0, -(26*4)

	mfc0	$1, CP0_INDEX
	mfc0	$2, CP0_RANDOM
	mfc0	$3, CP0_ENTRYLO0
	mfc0	$4, CP0_ENTRYLO1
	mfc0	$5, CP0_CONTEXT
	mfc0	$6, CP0_PAGEMASK
	mfc0	$7, CP0_WIRED
	mfc0	$8, CP0_BADVADDR
	mfc0	$9, CP0_ENTRYHI
	mfc0	$10, CP0_STATUS
/*	mfc0	$11, $12, 1*/		/* IntCtl */
	mfc0	$12, CP0_CAUSE
	mfc0	$13, CP0_EPC
/*	mfc0	$14, $15, 1*/		/* EBase */
	mfc0	$15, CP0_CONFIG
/*	mfc0	$16, CP0_CONFIG, 7*/	/* Config 7 */
	mfc0	$17, CP0_LLADDR
	mfc0	$18, CP0_WATCHLO
	mfc0	$19, CP0_WATCHHI
	mfc0	$20, CP0_DEBUG
	mfc0	$21, CP0_DEPC
	mfc0	$22, CP0_ECC
	mfc0	$23, CP0_TAGLO
	mfc0	$24, CP0_ERROREPC
	mfc0	$25, CP0_DESAVE

	sw	$1,  0(k0)
	sw	$2,  4(k0)
	sw	$3,  8(k0)
	sw	$4,  12(k0)
	sw	$5,  16(k0)
	sw	$6,  20(k0)
	sw	$7,  24(k0)
	sw	$8,  28(k0)
	sw	$9,  32(k0)
	sw	$10, 36(k0)
	sw	$11, 40(k0)
	sw	$12, 44(k0)
	sw	$13, 48(k0)
	sw	$14, 52(k0)
	sw	$15, 56(k0)
	sw	$16, 60(k0)
	sw	$17, 64(k0)
	sw	$18, 68(k0)
	sw	$19, 72(k0)
	sw	$20, 76(k0)
	sw	$21, 80(k0)
	sw	$22, 84(k0)
	sw	$23, 88(k0)
	sw	$24, 92(k0)
	sw	$25, 96(k0)
	sw	$29, 100(k0)	/* saved sp */
	move	sp, k0

	/* preserve virtual address of stack */
	la	k0, sleep_save_sp
	sw	sp, 0(k0)

	/* flush caches and write buffers */
	jal	jz_flush_cache_all
	nop
#if 0
	/* set new sdram refresh constant */
	li	t0, 1
	la	t1, EMC_RTCOR
	sh	t0, 0(t1)



	/* disable PLL */
	la	t0, CPM_PLCR1
	sw	$0, 0(t0)
#endif
	/* put CPU to sleep mode */
	la	t0, CPM_LCR
	lw	t1, 0(t0)
	li	t2, ~CPM_LCR_LPM_MASK
	and	t1, t2
	ori	t1, CPM_LCR_LPM_SLEEP

	.align	5
	/* align execution to a cache line */
	j	1f

	.align	5
1:
	/* all needed values are now in registers.
	 * These last instructions should be in cache
	 */
	nop
	nop

	/* set sleep mode */
	sw	t1, 0(t0)
	nop

	/* enter sleep mode */
	.set	mips3
	wait
	nop
	.set	mips0

2:	j	2b		/* loop waiting for suspended */
	nop

/*
 * jz_cpu_resume()
 *
 * entry point from bootloader into kernel during resume
 */

	.align 5
	.globl	jz_cpu_resume
jz_cpu_resume:
#if 0   /*60 no have */

	/* clear SCR.HGP */
	la	t0, CPM_SCR
	lw	t1, 0(t0)
	li	t2, ~CPM_SCR_HGP
	and	t1, t2
	sw	t1, 0(t0)
#endif
	/* restore LCR.LPM to IDLE mode */
	la	t0, CPM_LCR
	lw	t1, 0(t0)
	li	t2, ~CPM_LCR_LPM_MASK
	and	t1, t2
	ori	t1, CPM_LCR_LPM_IDLE
	sw	t1, 0(t0)

	/* restore saved sp */
	la	t0, sleep_save_sp
	lw	sp, 0(t0)

	/* restore CP0 registers */
	move	k0, sp
	lw	$1,  0(k0)
	lw	$2,  4(k0)
	lw	$3,  8(k0)
	lw	$4,  12(k0)
	lw	$5,  16(k0)
	lw	$6,  20(k0)
	lw	$7,  24(k0)
	lw	$8,  28(k0)
	lw	$9,  32(k0)
	lw	$10, 36(k0)
	lw	$11, 40(k0)
	lw	$12, 44(k0)
	lw	$13, 48(k0)
	lw	$14, 52(k0)
	lw	$15, 56(k0)
	lw	$16, 60(k0)
	lw	$17, 64(k0)
	lw	$18, 68(k0)
	lw	$19, 72(k0)
	lw	$20, 76(k0)
	lw	$21, 80(k0)
	lw	$22, 84(k0)
	lw	$23, 88(k0)
	lw	$24, 92(k0)
	lw	$25, 96(k0)
	lw	$29, 100(k0)	/* saved sp */

	mtc0	$1, CP0_INDEX
	mtc0	$2, CP0_RANDOM
	mtc0	$3, CP0_ENTRYLO0
	mtc0	$4, CP0_ENTRYLO1
	mtc0	$5, CP0_CONTEXT
	mtc0	$6, CP0_PAGEMASK
	mtc0	$7, CP0_WIRED
	mtc0	$8, CP0_BADVADDR
	mtc0	$9, CP0_ENTRYHI
	mtc0	$10, CP0_STATUS
/*	mtc0	$11, $12, 1*/		/* IntCtl */
	mtc0	$12, CP0_CAUSE
	mtc0	$13, CP0_EPC
/*	mtc0	$14, $15, 1*/		/* EBase */
	mtc0	$15, CP0_CONFIG
/*	mtc0	$16, CP0_CONFIG, 7*/	/* Config 7 */
	mtc0	$17, CP0_LLADDR
	mtc0	$18, CP0_WATCHLO
	mtc0	$19, CP0_WATCHHI
	mtc0	$20, CP0_DEBUG
	mtc0	$21, CP0_DEPC
	mtc0	$22, CP0_ECC
	mtc0	$23, CP0_TAGLO
	mtc0	$24, CP0_ERROREPC
	mtc0	$25, CP0_DESAVE

	/* restore general registers */
	move	k0, sp
	lw	k1,  120(k0)		/* hi */
	lw	$0,  0(k0)
	lw	$1,  4(k0)
	mthi	k1
	lw	k1,  124(k0)		/* lo */
	lw	$2,  8(k0)
	lw	$3,  12(k0)
	mtlo	k1
	lw	$4,  16(k0)
	lw	$5,  20(k0)
	lw	$6,  24(k0)
	lw	$7,  28(k0)
	lw	$8,  32(k0)
	lw	$9,  36(k0)
	lw	$10, 40(k0)
	lw	$11, 44(k0)
	lw	$12, 48(k0)
	lw	$13, 52(k0)
	lw	$14, 56(k0)
	lw	$15, 60(k0)
	lw	$16, 64(k0)
	lw	$17, 68(k0)
	lw	$18, 72(k0)
	lw	$19, 76(k0)
	lw	$20, 80(k0)
	lw	$21, 84(k0)
	lw	$22, 88(k0)
	lw	$23, 92(k0)
	lw	$24, 96(k0)
	lw	$25, 100(k0)
	lw	$28, 104(k0)
	lw	$29, 108(k0)		/* saved sp */
	lw	$30, 112(k0)
	lw	$31, 116(k0)		/* saved ra */

	/* return to caller */
	jr	ra
	nop

sleep_save_sp:
	.word	0			/* preserve sp here */

	.set	reorder
