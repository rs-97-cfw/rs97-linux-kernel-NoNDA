/*
 * Ingenic JZ475X Display Controllers Driver.
 * 
 * Common Routines.
 *
 * Copyright (C) 2005-2010 Ingenic Semiconductor Inc.
 * Author: River Wang <zwang@ingenic.cn>
 *		
 *  This program is free software; you can distribute it and/or modify it
 *  under the terms of the GNU General Public License (Version 2) as
 *  published by the Free Software Foundation.
 *
 *  This program is distributed in the hope it will be useful, but WITHOUT
 *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 *  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 *  for more details.
 *
 *  You should have received a copy of the GNU General Public License along
 *  with this program; if not, write to the Free Software Foundation, Inc.,
 *  59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
 *
 */

static inline unsigned long dma_align_size(unsigned long size)
{
	unsigned long align = JZ_FB_DMA_ALIGN;

	size = (size + align - 1) / align * align;

	return size;
}


