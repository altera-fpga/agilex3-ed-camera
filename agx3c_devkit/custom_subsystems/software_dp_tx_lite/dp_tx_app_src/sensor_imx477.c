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


#include "system.h"
#include "io.h"
#include "alt_types.h"
#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include "intel_fpga_i2c.h"
#include "imx477_regs.h"
#include "sensor_imx477.h"

#define CURRENT_BPS CSI_FMT_RAW12
#define LOCAL_REG_DEFINE_1 REG_DEF_12
#define IMX477_BITS_PER_PIXEL       (12)

unsigned char read_sensor_imx477(long port, unsigned char address, unsigned int reg)
{
    unsigned char ret_rd = 0xff;
    // SLASEL  | I2C Address
    //  0/NC   | 0x1A (Pi HQ Sensor)
    //  1      | 0x10

    intel_fpga_i2c_init(port, 100000000);
    ret_rd = intel_fpga_i2c_read_imx(port, address, reg);
    return ret_rd;
}

int set_sensor_imx477(long port, unsigned char address)
{
    int ret = 0;
    // SLASEL  | I2C Address
    //  0/NC   | 0x1A (Pi HQ Sensor)
    //  1      | 0x10


    intel_fpga_i2c_init(port, 100000000);

    intel_fpga_i2c_write_imx(port, address, MODE_SEL_RW, 0x0);
    intel_fpga_i2c_write_imx(port, address, EXCK_FREQ_DECIMAL_RW, 0x18);
    intel_fpga_i2c_write_imx(port, address, EXCK_FREQ_FRACTION_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, TEMP_SEN_CTRL_RW, 0x01);
    intel_fpga_i2c_write_imx(port, address, FRAME_BLANKSTOP_CL_RW, 0x01); // Changed from 0 -> 1
    intel_fpga_i2c_write_imx(port, address, 0xe07a, 0x01);
    intel_fpga_i2c_write_imx(port, address, DPHY_CTRL_RW, 0x01); // Changed from 2 -> 1
    intel_fpga_i2c_write_imx(port, address, 0x4ae9, 0x18);
    intel_fpga_i2c_write_imx(port, address, 0x4aea, 0x08);
    intel_fpga_i2c_write_imx(port, address, 0xf61c, 0x04);
    intel_fpga_i2c_write_imx(port, address, 0xf61e, 0x04);
    intel_fpga_i2c_write_imx(port, address, 0x4ae9, 0x21);
    intel_fpga_i2c_write_imx(port, address, 0x4aea, 0x80);
    intel_fpga_i2c_write_imx(port, address, 0x38a8, 0x1f);
    intel_fpga_i2c_write_imx(port, address, 0x38a9, 0xff);
    intel_fpga_i2c_write_imx(port, address, 0x38aa, 0x1f);
    intel_fpga_i2c_write_imx(port, address, 0x38ab, 0xff);
    intel_fpga_i2c_write_imx(port, address, 0x55d4, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x55d5, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x55d6, 0x07);
    intel_fpga_i2c_write_imx(port, address, 0x55d7, 0xff);
    intel_fpga_i2c_write_imx(port, address, 0x55e8, 0x07);
    intel_fpga_i2c_write_imx(port, address, 0x55e9, 0xff);
    intel_fpga_i2c_write_imx(port, address, 0x55ea, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x55eb, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x574c, 0x07);
    intel_fpga_i2c_write_imx(port, address, 0x574d, 0xff);
    intel_fpga_i2c_write_imx(port, address, 0x574e, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x574f, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x5754, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x5755, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x5756, 0x07);
    intel_fpga_i2c_write_imx(port, address, 0x5757, 0xff);
    intel_fpga_i2c_write_imx(port, address, 0x5973, 0x04);
    intel_fpga_i2c_write_imx(port, address, 0x5974, 0x01);
    intel_fpga_i2c_write_imx(port, address, 0x5d13, 0xc3);
    intel_fpga_i2c_write_imx(port, address, 0x5d14, 0x58);
    intel_fpga_i2c_write_imx(port, address, 0x5d15, 0xa3);
    intel_fpga_i2c_write_imx(port, address, 0x5d16, 0x1d);
    intel_fpga_i2c_write_imx(port, address, 0x5d17, 0x65);
    intel_fpga_i2c_write_imx(port, address, 0x5d18, 0x8c);
    intel_fpga_i2c_write_imx(port, address, 0x5d1a, 0x06);
    intel_fpga_i2c_write_imx(port, address, 0x5d1b, 0xa9);
    intel_fpga_i2c_write_imx(port, address, 0x5d1c, 0x45);
    intel_fpga_i2c_write_imx(port, address, 0x5d1d, 0x3a);
    intel_fpga_i2c_write_imx(port, address, 0x5d1e, 0xab);
    intel_fpga_i2c_write_imx(port, address, 0x5d1f, 0x15);
    intel_fpga_i2c_write_imx(port, address, 0x5d21, 0x0e);
    intel_fpga_i2c_write_imx(port, address, 0x5d22, 0x52);
    intel_fpga_i2c_write_imx(port, address, 0x5d23, 0xaa);
    intel_fpga_i2c_write_imx(port, address, 0x5d24, 0x7d);
    intel_fpga_i2c_write_imx(port, address, 0x5d25, 0x57);
    intel_fpga_i2c_write_imx(port, address, 0x5d26, 0xa8);
    intel_fpga_i2c_write_imx(port, address, 0x5d37, 0x5a);
    intel_fpga_i2c_write_imx(port, address, 0x5d38, 0x5a);
    intel_fpga_i2c_write_imx(port, address, 0x5d77, 0x7f);
    intel_fpga_i2c_write_imx(port, address, 0x7b75, 0x0e);
    intel_fpga_i2c_write_imx(port, address, 0x7b76, 0x0b);
    intel_fpga_i2c_write_imx(port, address, 0x7b77, 0x08);
    intel_fpga_i2c_write_imx(port, address, 0x7b78, 0x0a);
    intel_fpga_i2c_write_imx(port, address, 0x7b79, 0x47);
    intel_fpga_i2c_write_imx(port, address, 0x7b7c, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x7b7d, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x8d1f, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x8d27, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9004, 0x03);
    intel_fpga_i2c_write_imx(port, address, 0x9200, 0x50);
    intel_fpga_i2c_write_imx(port, address, 0x9201, 0x6c);
    intel_fpga_i2c_write_imx(port, address, 0x9202, 0x71);
    intel_fpga_i2c_write_imx(port, address, 0x9203, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9204, 0x71);
    intel_fpga_i2c_write_imx(port, address, 0x9205, 0x01);
    intel_fpga_i2c_write_imx(port, address, 0x9371, 0x6a);
    intel_fpga_i2c_write_imx(port, address, 0x9373, 0x6a);
    intel_fpga_i2c_write_imx(port, address, 0x9375, 0x64);
    intel_fpga_i2c_write_imx(port, address, 0x991a, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x996b, 0x8c);
    intel_fpga_i2c_write_imx(port, address, 0x996c, 0x64);
    intel_fpga_i2c_write_imx(port, address, 0x996d, 0x50);
    intel_fpga_i2c_write_imx(port, address, 0x9a4c, 0x0d);
    intel_fpga_i2c_write_imx(port, address, 0x9a4d, 0x0d);
    intel_fpga_i2c_write_imx(port, address, 0xa001, 0x0a);
    intel_fpga_i2c_write_imx(port, address, 0xa003, 0x0a);
    intel_fpga_i2c_write_imx(port, address, 0xa005, 0x0a);
    intel_fpga_i2c_write_imx(port, address, 0xa006, 0x01);
    intel_fpga_i2c_write_imx(port, address, 0xa007, 0xc0);
    intel_fpga_i2c_write_imx(port, address, 0xa009, 0xc0);
    intel_fpga_i2c_write_imx(port, address, 0x3d8a, 0x01);
    intel_fpga_i2c_write_imx(port, address, 0x4421, 0x04);
    intel_fpga_i2c_write_imx(port, address, 0x7b3b, 0x01);
    intel_fpga_i2c_write_imx(port, address, 0x7b4c, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9905, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9907, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9909, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x990b, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9944, 0x3c);
    intel_fpga_i2c_write_imx(port, address, 0x9947, 0x3c);
    intel_fpga_i2c_write_imx(port, address, 0x994a, 0x8c);
    intel_fpga_i2c_write_imx(port, address, 0x994b, 0x50);
    intel_fpga_i2c_write_imx(port, address, 0x994c, 0x1b);
    intel_fpga_i2c_write_imx(port, address, 0x994d, 0x8c);
    intel_fpga_i2c_write_imx(port, address, 0x994e, 0x50);
    intel_fpga_i2c_write_imx(port, address, 0x994f, 0x1b);
    intel_fpga_i2c_write_imx(port, address, 0x9950, 0x8c);
    intel_fpga_i2c_write_imx(port, address, 0x9951, 0x1b);
    intel_fpga_i2c_write_imx(port, address, 0x9952, 0x0a);
    intel_fpga_i2c_write_imx(port, address, 0x9953, 0x8c);
    intel_fpga_i2c_write_imx(port, address, 0x9954, 0x1b);
    intel_fpga_i2c_write_imx(port, address, 0x9955, 0x0a);
    intel_fpga_i2c_write_imx(port, address, 0x9a13, 0x04);
    intel_fpga_i2c_write_imx(port, address, 0x9a14, 0x04);
    intel_fpga_i2c_write_imx(port, address, 0x9a19, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9a1c, 0x04);
    intel_fpga_i2c_write_imx(port, address, 0x9a1d, 0x04);
    intel_fpga_i2c_write_imx(port, address, 0x9a26, 0x05);
    intel_fpga_i2c_write_imx(port, address, 0x9a27, 0x05);
    intel_fpga_i2c_write_imx(port, address, 0x9a2c, 0x01);
    intel_fpga_i2c_write_imx(port, address, 0x9a2d, 0x03);
    intel_fpga_i2c_write_imx(port, address, 0x9a2f, 0x05);
    intel_fpga_i2c_write_imx(port, address, 0x9a30, 0x05);
    intel_fpga_i2c_write_imx(port, address, 0x9a41, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9a46, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9a47, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9c17, 0x35);
    intel_fpga_i2c_write_imx(port, address, 0x9c1d, 0x31);
    intel_fpga_i2c_write_imx(port, address, 0x9c29, 0x50);
    intel_fpga_i2c_write_imx(port, address, 0x9c3b, 0x2f);
    intel_fpga_i2c_write_imx(port, address, 0x9c41, 0x6b);
    intel_fpga_i2c_write_imx(port, address, 0x9c47, 0x2d);
    intel_fpga_i2c_write_imx(port, address, 0x9c4d, 0x40);
    intel_fpga_i2c_write_imx(port, address, 0x9c6b, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9c71, 0xc8);
    intel_fpga_i2c_write_imx(port, address, 0x9c73, 0x32);
    intel_fpga_i2c_write_imx(port, address, 0x9c75, 0x04);
    intel_fpga_i2c_write_imx(port, address, 0x9c7d, 0x2d);
    intel_fpga_i2c_write_imx(port, address, 0x9c83, 0x40);
    intel_fpga_i2c_write_imx(port, address, 0x9c94, 0x3f);
    intel_fpga_i2c_write_imx(port, address, 0x9c95, 0x3f);
    intel_fpga_i2c_write_imx(port, address, 0x9c96, 0x3f);
    intel_fpga_i2c_write_imx(port, address, 0x9c97, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9c98, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9c99, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9c9a, 0x3f);
    intel_fpga_i2c_write_imx(port, address, 0x9c9b, 0x3f);
    intel_fpga_i2c_write_imx(port, address, 0x9c9c, 0x3f);
    intel_fpga_i2c_write_imx(port, address, 0x9ca0, 0x0f);
    intel_fpga_i2c_write_imx(port, address, 0x9ca1, 0x0f);
    intel_fpga_i2c_write_imx(port, address, 0x9ca2, 0x0f);
    intel_fpga_i2c_write_imx(port, address, 0x9ca3, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9ca4, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9ca5, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9ca6, 0x1e);
    intel_fpga_i2c_write_imx(port, address, 0x9ca7, 0x1e);
    intel_fpga_i2c_write_imx(port, address, 0x9ca8, 0x1e);
    intel_fpga_i2c_write_imx(port, address, 0x9ca9, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9caa, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9cab, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9cac, 0x09);
    intel_fpga_i2c_write_imx(port, address, 0x9cad, 0x09);
    intel_fpga_i2c_write_imx(port, address, 0x9cae, 0x09);
    intel_fpga_i2c_write_imx(port, address, 0x9cbd, 0x50);
    intel_fpga_i2c_write_imx(port, address, 0x9cbf, 0x50);
    intel_fpga_i2c_write_imx(port, address, 0x9cc1, 0x50);
    intel_fpga_i2c_write_imx(port, address, 0x9cc3, 0x40);
    intel_fpga_i2c_write_imx(port, address, 0x9cc5, 0x40);
    intel_fpga_i2c_write_imx(port, address, 0x9cc7, 0x40);
    intel_fpga_i2c_write_imx(port, address, 0x9cc9, 0x0a);
    intel_fpga_i2c_write_imx(port, address, 0x9ccb, 0x0a);
    intel_fpga_i2c_write_imx(port, address, 0x9ccd, 0x0a);
    intel_fpga_i2c_write_imx(port, address, 0x9d17, 0x35);
    intel_fpga_i2c_write_imx(port, address, 0x9d1d, 0x31);
    intel_fpga_i2c_write_imx(port, address, 0x9d29, 0x50);
    intel_fpga_i2c_write_imx(port, address, 0x9d3b, 0x2f);
    intel_fpga_i2c_write_imx(port, address, 0x9d41, 0x6b);
    intel_fpga_i2c_write_imx(port, address, 0x9d47, 0x42);
    intel_fpga_i2c_write_imx(port, address, 0x9d4d, 0x5a);
    intel_fpga_i2c_write_imx(port, address, 0x9d6b, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9d71, 0xc8);
    intel_fpga_i2c_write_imx(port, address, 0x9d73, 0x32);
    intel_fpga_i2c_write_imx(port, address, 0x9d75, 0x04);
    intel_fpga_i2c_write_imx(port, address, 0x9d7d, 0x42);
    intel_fpga_i2c_write_imx(port, address, 0x9d83, 0x5a);
    intel_fpga_i2c_write_imx(port, address, 0x9d94, 0x3f);
    intel_fpga_i2c_write_imx(port, address, 0x9d95, 0x3f);
    intel_fpga_i2c_write_imx(port, address, 0x9d96, 0x3f);
    intel_fpga_i2c_write_imx(port, address, 0x9d97, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9d98, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9d99, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9d9a, 0x3f);
    intel_fpga_i2c_write_imx(port, address, 0x9d9b, 0x3f);
    intel_fpga_i2c_write_imx(port, address, 0x9d9c, 0x3f);
    intel_fpga_i2c_write_imx(port, address, 0x9d9d, 0x1f);
    intel_fpga_i2c_write_imx(port, address, 0x9d9e, 0x1f);
    intel_fpga_i2c_write_imx(port, address, 0x9d9f, 0x1f);
    intel_fpga_i2c_write_imx(port, address, 0x9da0, 0x0f);
    intel_fpga_i2c_write_imx(port, address, 0x9da1, 0x0f);
    intel_fpga_i2c_write_imx(port, address, 0x9da2, 0x0f);
    intel_fpga_i2c_write_imx(port, address, 0x9da3, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9da4, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9da5, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9da6, 0x1e);
    intel_fpga_i2c_write_imx(port, address, 0x9da7, 0x1e);
    intel_fpga_i2c_write_imx(port, address, 0x9da8, 0x1e);
    intel_fpga_i2c_write_imx(port, address, 0x9da9, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9daa, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9dab, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9dac, 0x09);
    intel_fpga_i2c_write_imx(port, address, 0x9dad, 0x09);
    intel_fpga_i2c_write_imx(port, address, 0x9dae, 0x09);
    intel_fpga_i2c_write_imx(port, address, 0x9dc9, 0x0a);
    intel_fpga_i2c_write_imx(port, address, 0x9dcb, 0x0a);
    intel_fpga_i2c_write_imx(port, address, 0x9dcd, 0x0a);
    intel_fpga_i2c_write_imx(port, address, 0x9e17, 0x35);
    intel_fpga_i2c_write_imx(port, address, 0x9e1d, 0x31);
    intel_fpga_i2c_write_imx(port, address, 0x9e29, 0x50);
    intel_fpga_i2c_write_imx(port, address, 0x9e3b, 0x2f);
    intel_fpga_i2c_write_imx(port, address, 0x9e41, 0x6b);
    intel_fpga_i2c_write_imx(port, address, 0x9e47, 0x2d);
    intel_fpga_i2c_write_imx(port, address, 0x9e4d, 0x40);
    intel_fpga_i2c_write_imx(port, address, 0x9e6b, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9e71, 0xc8);
    intel_fpga_i2c_write_imx(port, address, 0x9e73, 0x32);
    intel_fpga_i2c_write_imx(port, address, 0x9e75, 0x04);
    intel_fpga_i2c_write_imx(port, address, 0x9e94, 0x0f);
    intel_fpga_i2c_write_imx(port, address, 0x9e95, 0x0f);
    intel_fpga_i2c_write_imx(port, address, 0x9e96, 0x0f);
    intel_fpga_i2c_write_imx(port, address, 0x9e97, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9e98, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9e99, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9ea0, 0x0f);
    intel_fpga_i2c_write_imx(port, address, 0x9ea1, 0x0f);
    intel_fpga_i2c_write_imx(port, address, 0x9ea2, 0x0f);
    intel_fpga_i2c_write_imx(port, address, 0x9ea3, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9ea4, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9ea5, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9ea6, 0x3f);
    intel_fpga_i2c_write_imx(port, address, 0x9ea7, 0x3f);
    intel_fpga_i2c_write_imx(port, address, 0x9ea8, 0x3f);
    intel_fpga_i2c_write_imx(port, address, 0x9ea9, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9eaa, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9eab, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9eac, 0x09);
    intel_fpga_i2c_write_imx(port, address, 0x9ead, 0x09);
    intel_fpga_i2c_write_imx(port, address, 0x9eae, 0x09);
    intel_fpga_i2c_write_imx(port, address, 0x9ec9, 0x0a);
    intel_fpga_i2c_write_imx(port, address, 0x9ecb, 0x0a);
    intel_fpga_i2c_write_imx(port, address, 0x9ecd, 0x0a);
    intel_fpga_i2c_write_imx(port, address, 0x9f17, 0x35);
    intel_fpga_i2c_write_imx(port, address, 0x9f1d, 0x31);
    intel_fpga_i2c_write_imx(port, address, 0x9f29, 0x50);
    intel_fpga_i2c_write_imx(port, address, 0x9f3b, 0x2f);
    intel_fpga_i2c_write_imx(port, address, 0x9f41, 0x6b);
    intel_fpga_i2c_write_imx(port, address, 0x9f47, 0x42);
    intel_fpga_i2c_write_imx(port, address, 0x9f4d, 0x5a);
    intel_fpga_i2c_write_imx(port, address, 0x9f6b, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9f71, 0xc8);
    intel_fpga_i2c_write_imx(port, address, 0x9f73, 0x32);
    intel_fpga_i2c_write_imx(port, address, 0x9f75, 0x04);
    intel_fpga_i2c_write_imx(port, address, 0x9f94, 0x0f);
    intel_fpga_i2c_write_imx(port, address, 0x9f95, 0x0f);
    intel_fpga_i2c_write_imx(port, address, 0x9f96, 0x0f);
    intel_fpga_i2c_write_imx(port, address, 0x9f97, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9f98, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9f99, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9f9a, 0x2f);
    intel_fpga_i2c_write_imx(port, address, 0x9f9b, 0x2f);
    intel_fpga_i2c_write_imx(port, address, 0x9f9c, 0x2f);
    intel_fpga_i2c_write_imx(port, address, 0x9f9d, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9f9e, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9f9f, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9fa0, 0x0f);
    intel_fpga_i2c_write_imx(port, address, 0x9fa1, 0x0f);
    intel_fpga_i2c_write_imx(port, address, 0x9fa2, 0x0f);
    intel_fpga_i2c_write_imx(port, address, 0x9fa3, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9fa4, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9fa5, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9fa6, 0x1e);
    intel_fpga_i2c_write_imx(port, address, 0x9fa7, 0x1e);
    intel_fpga_i2c_write_imx(port, address, 0x9fa8, 0x1e);
    intel_fpga_i2c_write_imx(port, address, 0x9fa9, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9faa, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9fab, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9fac, 0x09);
    intel_fpga_i2c_write_imx(port, address, 0x9fad, 0x09);
    intel_fpga_i2c_write_imx(port, address, 0x9fae, 0x09);
    intel_fpga_i2c_write_imx(port, address, 0x9fc9, 0x0a);
    intel_fpga_i2c_write_imx(port, address, 0x9fcb, 0x0a);
    intel_fpga_i2c_write_imx(port, address, 0x9fcd, 0x0a);
    intel_fpga_i2c_write_imx(port, address, 0xa14b, 0xff);
    intel_fpga_i2c_write_imx(port, address, 0xa151, 0x0c);
    intel_fpga_i2c_write_imx(port, address, 0xa153, 0x50);
    intel_fpga_i2c_write_imx(port, address, 0xa155, 0x02);
    intel_fpga_i2c_write_imx(port, address, 0xa157, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0xa1ad, 0xff);
    intel_fpga_i2c_write_imx(port, address, 0xa1b3, 0x0c);
    intel_fpga_i2c_write_imx(port, address, 0xa1b5, 0x50);
    intel_fpga_i2c_write_imx(port, address, 0xa1b9, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0xa24b, 0xff);
    intel_fpga_i2c_write_imx(port, address, 0xa257, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0xa2ad, 0xff);
    intel_fpga_i2c_write_imx(port, address, 0xa2b9, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0xb21f, 0x04);
    intel_fpga_i2c_write_imx(port, address, 0xb35c, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0xb35e, 0x08);
    intel_fpga_i2c_write_imx(port, address, CSI_DT_FMT_H_RW, CURRENT_BPS);
    intel_fpga_i2c_write_imx(port, address, CSI_DT_FMT_L_RW, CURRENT_BPS);
    intel_fpga_i2c_write_imx(port, address, CSI_LANE_MODE_RW, CSI_MIPI_LANES_2);
    intel_fpga_i2c_write_imx(port, address, FRM_LENGTH_CTL_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, EBD_SIZE_V_RW, 0x0); // 2 -> 0
    intel_fpga_i2c_write_imx(port, address, DPGA_USE_GLOBAL_GAIN_RW, 0x01);
    // intel_fpga_i2c_write_imx(port, address, LINE_LENGTH_PCK_UPPER_RW, 0x5d);
    // intel_fpga_i2c_write_imx(port, address, LINE_LENGTH_PCK_LOWER_RW, 0xc0);
    // intel_fpga_i2c_write_imx(port, address, FRM_LENGTH_LINES_UPPER_RW, 0x0c);
    // intel_fpga_i2c_write_imx(port, address, FRM_LENGTH_LINES_LOWER_RW, 0x14);
    intel_fpga_i2c_write_imx(port, address, X_ADD_START_UPPER_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, X_ADD_START_LOWER_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, Y_ADD_START_UPPER_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, Y_ADD_START_LOWER_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, X_ADD_END_UPPER_RW, 0x0e);
    intel_fpga_i2c_write_imx(port, address, X_ADD_END_LOWER_RW, 0xff);
    intel_fpga_i2c_write_imx(port, address, Y_ADD_END_UPPER_RW, 0x08);
    intel_fpga_i2c_write_imx(port, address, Y_ADD_END_LOWER_RW, 0x6f);
    intel_fpga_i2c_write_imx(port, address, DOL_EN_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, DOL_NUM_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, DOL_CSI_DT_FMT_H_2ND_RW, 0x0a);
    intel_fpga_i2c_write_imx(port, address, DOL_CSI_DT_FMT_L_2ND_RW, 0x0a);
    intel_fpga_i2c_write_imx(port, address, DOL_CSI_DT_FMT_H_3RD_RW, 0x0a);
    intel_fpga_i2c_write_imx(port, address, DOL_CSI_DT_FMT_L_3RD_RW, 0x0a);
    intel_fpga_i2c_write_imx(port, address, SME_HDR_MODE_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, SME_HDR_RESO_RW, 0x11);
    intel_fpga_i2c_write_imx(port, address, X_EVN_INC_RW, 0x01);
    intel_fpga_i2c_write_imx(port, address, X_ODD_INC_RW, 0x01);
    intel_fpga_i2c_write_imx(port, address, Y_EVN_INC_RW, 0x01);
    intel_fpga_i2c_write_imx(port, address, Y_ODD_INC_RW, 0x01);
    intel_fpga_i2c_write_imx(port, address, BINNING_MODE_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, BINNING_TYPE_H_V_RW, BINNING_HORIZ_NO_BIN | BINNING_VERTI_NO_BIN);
    intel_fpga_i2c_write_imx(port, address, BINNING_WEIGHTING_RW, BIN_WEIGHT_MODE_WEIGHT_AVERAGED);
    intel_fpga_i2c_write_imx(port, address, 0x3140, 0x02);
    intel_fpga_i2c_write_imx(port, address, 0x3c00, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x3c01, 0x03);
    intel_fpga_i2c_write_imx(port, address, 0x3c02, 0xa2);
    intel_fpga_i2c_write_imx(port, address, ADBIT_MODE_RW, 0x01);
    intel_fpga_i2c_write_imx(port, address, 0x5748, 0x07);
    intel_fpga_i2c_write_imx(port, address, 0x5749, 0xff);
    intel_fpga_i2c_write_imx(port, address, 0x574a, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x574b, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x7b75, 0x0a);
    intel_fpga_i2c_write_imx(port, address, 0x7b76, 0x0c);
    intel_fpga_i2c_write_imx(port, address, 0x7b77, 0x07);
    intel_fpga_i2c_write_imx(port, address, 0x7b78, 0x06);
    intel_fpga_i2c_write_imx(port, address, 0x7b79, 0x3c);
    intel_fpga_i2c_write_imx(port, address, 0x7b53, 0x01);
    intel_fpga_i2c_write_imx(port, address, 0x9369, 0x5a);
    intel_fpga_i2c_write_imx(port, address, 0x936b, 0x55);
    intel_fpga_i2c_write_imx(port, address, 0x936d, 0x28);
    intel_fpga_i2c_write_imx(port, address, 0x9304, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9305, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9e9a, 0x2f);
    intel_fpga_i2c_write_imx(port, address, 0x9e9b, 0x2f);
    intel_fpga_i2c_write_imx(port, address, 0x9e9c, 0x2f);
    intel_fpga_i2c_write_imx(port, address, 0x9e9d, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9e9e, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x9e9f, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0xa2a9, 0x60);
    intel_fpga_i2c_write_imx(port, address, 0xa2b7, 0x00);
    intel_fpga_i2c_write_imx(port, address, SCALE_MODE_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, SCALE_M_UPPER_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, SCALE_M_LOWER_RW, 0x10);
    intel_fpga_i2c_write_imx(port, address, DIG_CROP_X_OFFSET_UPPER_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, DIG_CROP_X_OFFSET_LOWER_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, DIG_CROP_Y_OFFSET_UPPER_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, DIG_CROP_Y_OFFSET_LOWER_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, DIG_CROP_IMAGE_WIDTH_UPPER_RW, 0x0f);
    intel_fpga_i2c_write_imx(port, address, DIG_CROP_IMAGE_WIDTH_LOWER_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, DIG_CROP_IMAGE_HEIGHT_UPPER_RW, 0x08);
    intel_fpga_i2c_write_imx(port, address, DIG_CROP_IMAGE_HEIGHT_LOWER_RW, 0x70);
    intel_fpga_i2c_write_imx(port, address, X_OUT_SIZE_UPPER_RW, 0x0f);
    intel_fpga_i2c_write_imx(port, address, X_OUT_SIZE_LOWER_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, Y_OUT_SIZE_UPPER_RW, 0x08);
    intel_fpga_i2c_write_imx(port, address, Y_OUT_SIZE_LOWER_RW, 0x70);
    intel_fpga_i2c_write_imx(port, address, IVT_PXCK_DIV_RW, 0x05);
    intel_fpga_i2c_write_imx(port, address, IVT_SYCK_DIV_RW, 0x02);
    intel_fpga_i2c_write_imx(port, address, IVT_PREPLLCK_DIV_RW, 0x04);
    intel_fpga_i2c_write_imx(port, address, IVT_PLL_MPY_UPPER_RW, 0x01);
    intel_fpga_i2c_write_imx(port, address, IVT_PLL_MPY_LOWER_RW, 0x5e);
    intel_fpga_i2c_write_imx(port, address, IOP_PXCK_DIV_RW, CURRENT_BPS);
    intel_fpga_i2c_write_imx(port, address, IOP_SYCK_DIV_RW, 0x01);
    intel_fpga_i2c_write_imx(port, address, IOP_PREPLLCK_DIV_RW, 0x02);
    intel_fpga_i2c_write_imx(port, address, IOP_PLL_MPY_UPPER_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, IOP_PLL_MPY_LOWER_RW, 0x7d); // 64
    intel_fpga_i2c_write_imx(port, address, PLL_MULT_DRIV_RW, 0x01);
    intel_fpga_i2c_write_imx(port, address, REQ_LINK_BIT_RATE_MBPS_INT_UPPER_RW, 0x0B); // 9
    intel_fpga_i2c_write_imx(port, address, REQ_LINK_BIT_RATE_MBPS_INT_LOWER_RW, 0xB8); // 60
    intel_fpga_i2c_write_imx(port, address, REQ_LINK_BIT_RATE_MBPS_FRAC_UPPER_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, REQ_LINK_BIT_RATE_MBPS_FRAC_LOWER_RW, 0x00);
    intel_fpga_i2c_write_imx(port, address, TCLK_POST_EX_UPPER_RW,           0x00);
    intel_fpga_i2c_write_imx(port, address, TCLK_POST_EX_LOWER_RW,           0x97);
    intel_fpga_i2c_write_imx(port, address, THS_PREPARE_EX_UPPER_RW,         0x00);
    intel_fpga_i2c_write_imx(port, address, THS_PREPARE_EX_LOWER_RW,         0x5f);
    intel_fpga_i2c_write_imx(port, address, THS_ZERO_MIN_EX_UPPER_RW,        0x00);
    intel_fpga_i2c_write_imx(port, address, THS_ZERO_MIN_EX_LOWER_RW,        0x9f);
    intel_fpga_i2c_write_imx(port, address, THS_TRAIL_EX_UPPER_RW,           0x00);
    intel_fpga_i2c_write_imx(port, address, THS_TRAIL_EX_LOWER_RW,           0x6f);
    intel_fpga_i2c_write_imx(port, address, TCLK_TRAIL_MIN_EX_UPPER_RW,      0x00);
    intel_fpga_i2c_write_imx(port, address, TCLK_TRAIL_MIN_EX_LOWER_RW,      0x6f);
    intel_fpga_i2c_write_imx(port, address, TCLK_PREPARE_EX_UPPER_RW,        0x00);
    intel_fpga_i2c_write_imx(port, address, TCLK_PREPARE_EX_LOWER_RW,        0x57);
    intel_fpga_i2c_write_imx(port, address, TCLK_ZERO_EX_UPPER_RW,           0x01);
    intel_fpga_i2c_write_imx(port, address, TCLK_ZERO_EX_LOWER_RW,           0x87);
    intel_fpga_i2c_write_imx(port, address, TLPX_EX_UPPER_RW,                0x00);
    intel_fpga_i2c_write_imx(port, address, TLPX_EX_LOWER_RW,                0x4f);
    intel_fpga_i2c_write_imx(port, address, 0xe04c, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0xe04d, 0x7f);
    intel_fpga_i2c_write_imx(port, address, 0xe04e, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0xe04f, 0x1f);
    intel_fpga_i2c_write_imx(port, address, 0x3e20, 0x01);
    intel_fpga_i2c_write_imx(port, address, 0x3e37, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x3f50, 0x00);
    intel_fpga_i2c_write_imx(port, address, 0x3f56, 0x02);
    intel_fpga_i2c_write_imx(port, address, 0x3f57, 0xae);
    intel_fpga_i2c_write_imx(port, address, SCAL_PERIOD_EN_RW,               0x0);
    intel_fpga_i2c_write_imx(port, address, SCAL_INIT_EN_RW,                 0x1);
    intel_fpga_i2c_write_imx(port, address, SCAL_TSKEWCAL_UNIT_RW,           0x0);
    intel_fpga_i2c_write_imx(port, address, SCAL_TSKEWCAL_INIT_UPPER_RW,     0x00);
    intel_fpga_i2c_write_imx(port, address, SCAL_TSKEWCAL_INIT_LOWER_RW,     0x32);
    intel_fpga_i2c_write_imx(port, address, SCAL_TSKEWCAL_PERIOD_UPPER_RW,   0x00);
    intel_fpga_i2c_write_imx(port, address, SCAL_TSKEWCAL_PERIOD_LOWER_RW,   0x05);
    intel_fpga_i2c_write_imx(port, address, LINE_LENGTH_PCK_UPPER_RW,        0x36);
    intel_fpga_i2c_write_imx(port, address, LINE_LENGTH_PCK_LOWER_RW,        0x50);
    intel_fpga_i2c_write_imx(port, address, FRM_LENGTH_LINES_UPPER_RW,       0x09);
    intel_fpga_i2c_write_imx(port, address, FRM_LENGTH_LINES_LOWER_RW,       0x1C);
    intel_fpga_i2c_write_imx(port, address, V_H_FLIP_RW, 0x3); // Flip the sensor
    intel_fpga_i2c_write_imx(port, address, DIG_GAIN_GR_UPPER_RW, 0x00); // Digital exposure gain
    intel_fpga_i2c_write_imx(port, address, DIG_GAIN_GR_LOWER_RW, 0xfa); // Digital exposure gain
    intel_fpga_i2c_write_imx(port, address, MODE_SEL_RW, 0x1);

    ret = 1;
    return ret;
}
