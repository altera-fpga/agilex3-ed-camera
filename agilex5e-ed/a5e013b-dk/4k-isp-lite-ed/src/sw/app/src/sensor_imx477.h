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

#include <stdint.h>

int sensor_imx477_init(const char i2c_dev_name[], unsigned char address);

int write_sensor_imx477(uint16_t reg, uint8_t val);
unsigned char read_sensor_imx477(unsigned int reg);

int set_sensor_imx477();

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __SENSOR_IMX477_H__ */


