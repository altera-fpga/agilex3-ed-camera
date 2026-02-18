/*******************************************************************************
Copyright (C) Altera Corporation

This code and the related documents are Altera copyrighted materials and your
use of them is governed by the express license under which they were provided to
you ("License"). This code and the related documents are provided as is, with no
express or implied warranties other than those that are expressly stated in the
License.
*******************************************************************************/
/* Copyright (C) 2025 Altera Corporation
*
* SPDX-License-Identifier: GPL-2.0-only */

#ifndef __SENSOR_IMX477_H__
#define __SENSOR_IMX477_H__

#ifdef __cplusplus
extern "C"
{
#endif /* __cplusplus */

int set_sensor_imx477(long port, unsigned char address);
unsigned char read_sensor_imx477(long port, unsigned char address, unsigned int reg);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __SENSOR_IMX477_H__ */
