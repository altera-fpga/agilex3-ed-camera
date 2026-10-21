/*******************************************************************************
Copyright (C) Altera Corporation

This code and the related documents are Altera copyrighted materials and your
use of them is governed by the express license under which they were provided to
you ("License"). This code and the related documents are provided as is, with no
express or implied warranties other than those that are expressly stated in the
License.
*******************************************************************************/
/* Copyright (C) Altera Corporation
 *
 * SPDX-License-Identifier: GPL-2.0-only */

#ifndef IMX477_REG_DEF_H
#define IMX477_REG_DEF_H


#define BITS_TO_MASK(x) ((1 << x) - 1)

#define PIX_ORDER_RO 0x0006
#define PIX_ORDER_RO_MASK BITS_TO_MASK(2)

// The model ID of the sensor
#define SENSOR_MODEL_ID_H_RO 0x0016
#define SENSOR_MODEL_ID_H_RO_MASK BITS_TO_MASK(8)
#define SENSOR_MODEL_ID_L_RO 0x0017
#define SENSOR_MODEL_ID_L_RO_MASK BITS_TO_MASK(8)

#define SENSOR_ID 0x477

#define SENSOR_X_SIZE 4056
#define SENSOR_Y_SIZE 3044


/////////////////////////// REG DEFINITIONS
// Enable Dolby HDR mode
#define DOL_EN_RW 0x00E3
#define DOL_EN_RW_MASK BITS_TO_MASK(1)
// Dolby HDR mode select
// 0 - Disabled
// 1 - 2Frames in DOL-HDR frame
// 2 - 3Frames in DOL-HDR frame
// 3 - not allowed
#define DOL_NUM_RW 0x00E4
#define DOL_NUM_RW_MASK BITS_TO_MASK(2)
#define DOL_CSI_DT_FMT_H_2ND_RW 0x00FC
#define DOL_CSI_DT_FMT_H_2ND_RW_MASK BITS_TO_MASK(8)
#define DOL_CSI_DT_FMT_L_2ND_RW 0x00FD
#define DOL_CSI_DT_FMT_L_2ND_RW_MASK BITS_TO_MASK(8)
#define DOL_CSI_DT_FMT_H_3RD_RW 0x00FE
#define DOL_CSI_DT_FMT_H_3RD_RW_MASK BITS_TO_MASK(8)
#define DOL_CSI_DT_FMT_L_3RD_RW 0x00FF
#define DOL_CSI_DT_FMT_L_3RD_RW_MASK BITS_TO_MASK(8)

// Essentially an on-off switch.
// 0 = Software on standby
// 1 = Streaming.
// You need to switch off the software in order to update the values
#define MODE_SEL_RW 0x0100
#define MODE_SEL_RW_MASK BITS_TO_MASK(1)

// Flip the image
// 0b01 - flip horizontally
// 0b10 - flip vertically
#define V_H_FLIP_RW 0x0101
#define V_H_FLIP_RW_MASK BITS_TO_MASK(2)

#define SW_RESET_RW 0x0103
#define SW_RESET_RW_MASK BITS_TO_MASK(1)

#define CSI_FMT_RAW8 0x08
#define CSI_FMT_RAW10 0x0A
#define CSI_FMT_RAW12 0x0C

// Output data format for CSI
// H = uncompressed data bit width
// L = compressed data bit width
// 0x0808 - RAW8
// 0x0A08 - 10-bit to 8 bit compression
// 0x0A0A - RAW10
// 0x0C0C - RAW12
// Anything else is forbidden
#define CSI_DT_FMT_H_RW 0x0112
#define CSI_DT_FMT_H_RW_MASK BITS_TO_MASK(8)
#define CSI_DT_FMT_L_RW 0x0113
#define CSI_DT_FMT_L_RW_MASK BITS_TO_MASK(8)

#define CSI_MIPI_LANES_2 0x1
#define CSI_MIPI_LANES_4 0x3
// How many lanes for the camera to run on?
// 0 = 1 lane (not supported)
// 1 = 2 lanes
// 2 = 3 lanes (not supported)
// 3 = 4 lanes
#define CSI_LANE_MODE_RW 0x0114
#define CSI_LANE_MODE_RW_MASK BITS_TO_MASK(2)

// External clock frequency in MHz. Should match INCK frequency
// MUST be within the range of 6->27MHz
#define EXCK_FREQ_DECIMAL_RW 0x0136
#define EXCK_FREQ_DECIMAL_RW_MASK BITS_TO_MASK(8)
#define EXCK_FREQ_FRACTION_RW 0x0137
#define EXCK_FREQ_FRACTION_RW_MASK BITS_TO_MASK(8)

// Enable temp control. 0 = off, 1 = on
#define TEMP_SEN_CTRL_RW 0x0138
#define TEMP_SEN_CTRL_RW_MASK BITS_TO_MASK(1)

// Read the temp out from the sensor. Range:
// 0xEC: -20
// 0x00: 0
// 0x50: 80
// Temps in celsius
#define TEMP_SEN_OUT_RO 0x013A
#define TEMP_SEN_OUT_RO_MASK BITS_TO_MASK(1)

// Fine integration time in number of pixel clocks
#define FINE_INTEG_TIME_UPPER_RW 0x200
#define FINE_INTEG_TIME_UPPER_RW_MASK BITS_TO_MASK(8)
#define FINE_INTEG_TIME_LOWER_RW 0x0201
#define FINE_INTEG_TIME_LOWER_RW_MASK BITS_TO_MASK(8)
// Coarse integration time in number of lines
#define COARSE_INTEG_TIME_UPPER_RW 0x202
#define COARSE_INTEG_TIME_UPPER_RW_MASK BITS_TO_MASK(8)
#define COARSE_INTEG_TIME_LOWER_RW 0x0203
#define COARSE_INTEG_TIME_LOWER_RW_MASK BITS_TO_MASK(8)

// Analogue gain
// The formula is:
// Multiplier = 1024 / (1024 - ANA_GAIN_GLOBAL)
// It can range from 0->978d
#define ANA_GAIN_GLOBAL_UPPER_RW 0x0204
#define ANA_GAIN_GLOBAL_UPPER_RW_MASK BITS_TO_MASK(2)
#define ANA_GAIN_GLOBAL_LOWER_RW 0x0205
#define ANA_GAIN_GLOBAL_LOWER_RW_MASK BITS_TO_MASK(8)

// Digital gain
// The formula is:
// Multiplier = DIG_GAIN_GR / 256
// It can range from 256->4095
#define DIG_GAIN_GR_UPPER_RW 0x020E
#define DIG_GAIN_GR_UPPER_RW_MASK BITS_TO_MASK(8)
#define DIG_GAIN_GR_LOWER_RW 0x020F
#define DIG_GAIN_GR_LOWER_RW_MASK BITS_TO_MASK(8)

// SME-HDR - UNDOCUMENTED, possibly named by accident?
#define SME_HDR_MODE_RW 0x0220
#define SME_HDR_MODE_RW_MASK BITS_TO_MASK(8)
#define SME_HDR_RESO_RW 0x0221
#define SME_HDR_RESO_RW_MASK BITS_TO_MASK(8)

/////// Nasty PLL settings

// Pixel clock divider for internal video timing system
// Allowed values: (in decimal)
// 4, 5, 6, 7, 8, 9, 10
#define IVT_PXCK_DIV_RW 0x0301
#define IVT_PXCK_DIV_RW_MASK BITS_TO_MASK(5)

// System clock divider for internal video timing system
// Allowed values: 2, 4
#define IVT_SYCK_DIV_RW 0x0303
#define IVT_SYCK_DIV_RW_MASK BITS_TO_MASK(3)

// Two modes:
// If PLL_MULT_DRIV = 1
//    The pre-PLL clock divider for Internal Video Timing (IVT) System Clock
// If PLL_MULT_DRIV = 0
//    The pre-pll clock divider for BOTH IVT system and Internal output pixel system
// Allowed range:
// 0x1 -> 0x4
#define IVT_PREPLLCK_DIV_RW 0x0305
#define IVT_PREPLLCK_DIV_RW_MASK BITS_TO_MASK(4)

// Two modes:
// If PLL_MULT_DRIV = 1
//    The PLL freq multiplier for Internal Video Timing (IVT) System Clock
//    Allowed range:
//       150d -> 350d
// If PLL_MULT_DRIV = 0
//    The PLL freq multiplier for BOTH IVT system and Internal output pixel system
//    Allowed range:
//       100d -> 350d
#define IVT_PLL_MPY_UPPER_RW 0x0306
#define IVT_PLL_MPY_UPPER_RW_MASK BITS_TO_MASK(3)
#define IVT_PLL_MPY_LOWER_RW 0x0307
#define IVT_PLL_MPY_LOWER_RW_MASK BITS_TO_MASK(8)

// Pixel clock divider for Internal Output Pixel System
//  MUST match output bits per symbol
// Allowed values: 0x8, 0xA, 0xC
#define IOP_PXCK_DIV_RW 0x0309
#define IOP_PXCK_DIV_RW_MASK BITS_TO_MASK(5)

// System clock divider for Internal Output Pixel System
// Range: 0x1, 0x2, 0x4
#define IOP_SYCK_DIV_RW 0x030B
#define IOP_SYCK_DIV_RW_MASK BITS_TO_MASK(5)

// Does nothing if PLL_MULT_DRIV=0
// pre-PLL clock divider for internal output pixel system when PLL_MULT_DRIV=1
// Range: 0x1->0x4
#define IOP_PREPLLCK_DIV_RW 0x030D
#define IOP_PREPLLCK_DIV_RW_MASK BITS_TO_MASK(4)

// Does nothing if PLL_MULT_DRIV=0
// PLL multiplier for internal output pixel system when PLL_MULT_DRIV=1
// Range: 100d->350d
#define IOP_PLL_MPY_UPPER_RW 0x030E
#define IOP_PLL_MPY_UPPER_RW_MASK BITS_TO_MASK(3)
#define IOP_PLL_MPY_LOWER_RW 0x030F
#define IOP_PLL_MPY_LOWER_RW_MASK BITS_TO_MASK(8)

// Sets the PLL mode
// 0 - Single PLL mode
// 1 - Dual PLL mode
#define PLL_MULT_DRIV_RW 0x0310
#define PLL_MULT_DRIV_RW_MASK BITS_TO_MASK(1)

// Frame vertical line count
#define FRM_LENGTH_LINES_UPPER_RW 0x0340
#define FRM_LENGTH_LINES_UPPER_RW_MASK BITS_TO_MASK(8)
#define FRM_LENGTH_LINES_LOWER_RW 0x0341
#define FRM_LENGTH_LINES_LOWER_RW_MASK BITS_TO_MASK(8)

// Frame horizontal clock count
#define LINE_LENGTH_PCK_UPPER_RW 0x0342
#define LINE_LENGTH_PCK_UPPER_RW_MASK BITS_TO_MASK(8)
#define LINE_LENGTH_PCK_LOWER_RW 0x0343
#define LINE_LENGTH_PCK_LOWER_RW_MASK BITS_TO_MASK(8)

// Horizontal analog cropping start position
// Note, when H flip is 1, start becomes end and end becomes start
#define X_ADD_START_UPPER_RW 0x0344
#define X_ADD_START_UPPER_RW_MASK BITS_TO_MASK(8)
#define X_ADD_START_LOWER_RW 0x0345
#define X_ADD_START_LOWER_RW_MASK BITS_TO_MASK(8)
#define Y_ADD_START_UPPER_RW 0x0346
#define Y_ADD_START_UPPER_RW_MASK BITS_TO_MASK(8)
#define Y_ADD_START_LOWER_RW 0x0347
#define Y_ADD_START_LOWER_RW_MASK BITS_TO_MASK(8)
#define X_ADD_END_UPPER_RW 0x0348
#define X_ADD_END_UPPER_RW_MASK BITS_TO_MASK(8)
#define X_ADD_END_LOWER_RW 0x0349
#define X_ADD_END_LOWER_RW_MASK BITS_TO_MASK(8)
#define Y_ADD_END_UPPER_RW 0x034A
#define Y_ADD_END_UPPER_RW_MASK BITS_TO_MASK(8)
#define Y_ADD_END_LOWER_RW 0x034B
#define Y_ADD_END_LOWER_RW_MASK BITS_TO_MASK(8)

// Output crop

// The horizontal image size output from the sensor
// MUST be a multiple of 4
#define X_OUT_SIZE_UPPER_RW 0x034C
#define X_OUT_SIZE_UPPER_RW_MASK BITS_TO_MASK(5)
#define X_OUT_SIZE_LOWER_RW 0x034D
#define X_OUT_SIZE_LOWER_RW_MASK BITS_TO_MASK(8)

// The vertical image size output from the sensor
// MUST be a multiple of 2
#define Y_OUT_SIZE_UPPER_RW 0x034E
#define Y_OUT_SIZE_UPPER_RW_MASK BITS_TO_MASK(5)
#define Y_OUT_SIZE_LOWER_RW 0x034F
#define Y_OUT_SIZE_LOWER_RW_MASK BITS_TO_MASK(8)

// Frame length automatic tracking
// 0 - off
// 1 - frame length is set to match coarse integration time + alpha
#define FRM_LENGTH_CTL_RW 0x0350
#define FRM_LENGTH_CTL_RW_MASK BITS_TO_MASK(1)

// Subsampling pixel skip from even number pixels to odd pixels
#define X_EVN_INC_RW 0x0381
#define X_EVN_INC_RW_MASK BITS_TO_MASK(3)
// Subsampling pixel skip from odd number pixels to even pixels
#define X_ODD_INC_RW 0x0383
#define X_ODD_INC_RW_MASK BITS_TO_MASK(3)
// Subsampling pixel skip from even number lines to odd lines
#define Y_EVN_INC_RW 0x0385
#define Y_EVN_INC_RW_MASK BITS_TO_MASK(3)
// Subsampling pixel skip from odd number lines to even lines
#define Y_ODD_INC_RW 0x0387
#define Y_ODD_INC_RW_MASK BITS_TO_MASK(3)

//// Scaling

// Scaling mode selection
// 0 - No scaling
// 1 - Horizontal scaling
// 2 - Horizontal and vertical scaling
// 3 - Not allowed
#define SCALE_MODE_RW 0x0401
#define SCALE_MODE_RW_MASK BITS_TO_MASK(2)

#define SCALE_MODE_NONE 0x0
#define SCALE_MODE_HORIZ_ONLY 0x1
#define SCALE_MODE_HORIZ_VERTI 0x2

// Downscaling factor M
// Range 16d->511d
// Outside that range is forbidden.
#define SCALE_M_UPPER_RW 0x0404
#define SCALE_M_UPPER_RW_MASK BITS_TO_MASK(1)
#define SCALE_M_LOWER_RW 0x0405
#define SCALE_M_LOWER_RW_MASK BITS_TO_MASK(8)


//// Digital crop

// X offset from the left side of visible pixel data after analog cropping, binning and subsampling
#define DIG_CROP_X_OFFSET_UPPER_RW 0x408
#define DIG_CROP_X_OFFSET_UPPER_RW_MASK BITS_TO_MASK(5)
#define DIG_CROP_X_OFFSET_LOWER_RW 0x409
#define DIG_CROP_X_OFFSET_LOWER_RW_MASK BITS_TO_MASK(8)

// Y offset from the top side of visible pixel data after analog cropping, binning and subsampling
#define DIG_CROP_Y_OFFSET_UPPER_RW 0x40A
#define DIG_CROP_Y_OFFSET_UPPER_RW_MASK BITS_TO_MASK(5)
#define DIG_CROP_Y_OFFSET_LOWER_RW 0x40B
#define DIG_CROP_Y_OFFSET_LOWER_RW_MASK BITS_TO_MASK(8)

// Image width after digital cropping (inc. analog crop, binning, subsample, etc.)
#define DIG_CROP_IMAGE_WIDTH_UPPER_RW 0x040C
#define DIG_CROP_IMAGE_WIDTH_UPPER_RW_MASK BITS_TO_MASK(5)
#define DIG_CROP_IMAGE_WIDTH_LOWER_RW 0x40D
#define DIG_CROP_IMAGE_WIDTH_LOWER_RW_MASK BITS_TO_MASK(8)

// Image height after digital cropping (inc. analog crop, binning, subsample, etc.)
#define DIG_CROP_IMAGE_HEIGHT_UPPER_RW 0x040E
#define DIG_CROP_IMAGE_HEIGHT_UPPER_RW_MASK BITS_TO_MASK(5)
#define DIG_CROP_IMAGE_HEIGHT_LOWER_RW 0x40F
#define DIG_CROP_IMAGE_HEIGHT_LOWER_RW_MASK BITS_TO_MASK(8)

//// TPG

#define TPG_MODE_CAMERA 0x0
#define TPG_MODE_SOLID_COL 0x1
#define TPG_MODE_COL_BAR_TPG 0x2
#define TPG_MODE_COL_BAR_FADE_TPG 0x3

// TPG mode:
// 0 - No pattern, display camera
// 1 - Solid colour
// 2 - Colour bars
// 3 - Fade to grey colour bars
// 4 - PN9 (?)
#define TP_MODE_UPPER_RW 0x0600
#define TP_MODE_UPPER_RW_MASK BITS_TO_MASK(1)
#define TP_MODE_LOWER_RW 0x0601
#define TP_MODE_LOWER_RW_MASK BITS_TO_MASK(8)

#define TD_R_UPPER_RW 0x0602
#define TD_R_UPPER_RW_MASK BITS_TO_MASK(4)
#define TD_R_LOWER_RW 0x0603
#define TD_R_LOWER_RW_MASK BITS_TO_MASK(8)

#define TD_GR_UPPER_RW 0x0604
#define TD_GR_UPPER_RW_MASK BITS_TO_MASK(4)
#define TD_GR_LOWER_RW 0x0605
#define TD_GR_LOWER_RW_MASK BITS_TO_MASK(8)

#define TD_B_UPPER_RW 0x0606
#define TD_B_UPPER_RW_MASK BITS_TO_MASK(4)
#define TD_B_LOWER_RW 0x0607
#define TD_B_LOWER_RW_MASK BITS_TO_MASK(8)

#define TD_GB_UPPER_RW 0x0608
#define TD_GB_UPPER_RW_MASK BITS_TO_MASK(4)
#define TD_GB_LOWER_RW 0x0609
#define TD_GB_LOWER_RW_MASK BITS_TO_MASK(8)

/// MIPI

// Set MIPI global timing mode. See SRM 3.1.4 - Mipi Global Timing setting
// 0 = Automatic mode, based on PLL output frequency
// 1 = Set using values of REQ_LINK_BIT_RATE_MBPS and CSI_LANE_MODE
// 2 = Set using the registers 0x080A->0x0819 (This is for the brave)
#define DPHY_CTRL_RW 0x0808
#define DPHY_CTRL_RW_MASK BITS_TO_MASK(2)


// Mipi global timing Tclk
#define TCLK_POST_EX_UPPER_RW 0x080A
#define TCLK_POST_EX_UPPER_RW_MASK BITS_TO_MASK(2)
#define TCLK_POST_EX_LOWER_RW 0x080B
#define TCLK_POST_EX_LOWER_RW_MASK BITS_TO_MASK(8)

// Mipi global timing Ths_prepare
#define THS_PREPARE_EX_UPPER_RW 0x080C
#define THS_PREPARE_EX_UPPER_RW_MASK BITS_TO_MASK(2)
#define THS_PREPARE_EX_LOWER_RW 0x080D
#define THS_PREPARE_EX_LOWER_RW_MASK BITS_TO_MASK(8)

// Mipi global timing Ths_zero_min
#define THS_ZERO_MIN_EX_UPPER_RW 0x080E
#define THS_ZERO_MIN_EX_UPPER_RW_MASK BITS_TO_MASK(2)
#define THS_ZERO_MIN_EX_LOWER_RW 0x080F
#define THS_ZERO_MIN_EX_LOWER_RW_MASK BITS_TO_MASK(8)

// Mipi global timing Ths_trail
#define THS_TRAIL_EX_UPPER_RW 0x0810
#define THS_TRAIL_EX_UPPER_RW_MASK BITS_TO_MASK(2)
#define THS_TRAIL_EX_LOWER_RW 0x0811
#define THS_TRAIL_EX_LOWER_RW_MASK BITS_TO_MASK(8)

// Mipi global timing Tclk_trail_min
#define TCLK_TRAIL_MIN_EX_UPPER_RW 0x0812
#define TCLK_TRAIL_MIN_EX_UPPER_RW_MASK BITS_TO_MASK(2)
#define TCLK_TRAIL_MIN_EX_LOWER_RW 0x0813
#define TCLK_TRAIL_MIN_EX_LOWER_RW_MASK BITS_TO_MASK(8)

// Mipi global timing Tclk_prepare
#define TCLK_PREPARE_EX_UPPER_RW 0x0814
#define TCLK_PREPARE_EX_UPPER_RW_MASK BITS_TO_MASK(2)
#define TCLK_PREPARE_EX_LOWER_RW 0x0815
#define TCLK_PREPARE_EX_LOWER_RW_MASK BITS_TO_MASK(8)

// Mipi global timing Tclk_zero
#define TCLK_ZERO_EX_UPPER_RW 0x0816
#define TCLK_ZERO_EX_UPPER_RW_MASK BITS_TO_MASK(2)
#define TCLK_ZERO_EX_LOWER_RW 0x0817
#define TCLK_ZERO_EX_LOWER_RW_MASK BITS_TO_MASK(8)

// Mipi global timing Tlpx
#define TLPX_EX_UPPER_RW 0x0818
#define TLPX_EX_UPPER_RW_MASK BITS_TO_MASK(2)
#define TLPX_EX_LOWER_RW 0x0819
#define TLPX_EX_LOWER_RW_MASK BITS_TO_MASK(8)

// Specify the output data rate in Mbps
// Upper 16 bits are integer
// Lower 16 bits are fractional
#define REQ_LINK_BIT_RATE_MBPS_INT_UPPER_RW 0x0820
#define REQ_LINK_BIT_RATE_MBPS_INT_UPPER_RW_MASK BITS_TO_MASK(8)
#define REQ_LINK_BIT_RATE_MBPS_INT_LOWER_RW 0x0821
#define REQ_LINK_BIT_RATE_MBPS_INT_LOWER_RW_MASK BITS_TO_MASK(8)
#define REQ_LINK_BIT_RATE_MBPS_FRAC_UPPER_RW 0x0822
#define REQ_LINK_BIT_RATE_MBPS_FRAC_UPPER_RW_MASK BITS_TO_MASK(8)
#define REQ_LINK_BIT_RATE_MBPS_FRAC_LOWER_RW 0x0823
#define REQ_LINK_BIT_RATE_MBPS_FRAC_LOWER_RW_MASK BITS_TO_MASK(8)

// Enables periodic skew calibration
#define SCAL_PERIOD_EN_RW 0x0830
#define SCAL_PERIOD_EN_RW_MASK BITS_TO_MASK(1)

// Enables initial skew calibration
#define SCAL_INIT_EN_RW 0x0832
#define SCAL_INIT_EN_RW_MASK BITS_TO_MASK(1)

// Binning settings

// Enable binning
// 0 - off
// 1 - on
#define BINNING_MODE_RW 0x0900
#define BINNING_MODE_RW_MASK BITS_TO_MASK(1)

// Binning type in horizontal and vertical directions
// Upper nybble is horizontal direction
// Lower nybble is vertical direction
// 0x1 = no binning
// 0x2 = 2 binning
#define BINNING_TYPE_H_V_RW 0x0901
#define BINNING_TYPE_H_V_RW_MASK BITS_TO_MASK(8)

// Defs for bin type
#define BINNING_HORIZ_NO_BIN 0x10
#define BINNING_HORIZ_2_BIN 0x20
#define BINNING_VERTI_NO_BIN 0x01
#define BINNING_VERTI_2_BIN 0x02

// Bin weighting mode
// 0 - Averaged
// 1 - Summed
// 2 - Weighting averaged
#define BINNING_WEIGHTING_RW 0x0902
#define BINNING_WEIGHTING_RW_MASK BITS_TO_MASK(2)

#define BIN_WEIGHT_MODE_AVERAGED 0x0
#define BIN_WEIGHT_MODE_SUMMED 0x1
#define BIN_WEIGHT_MODE_WEIGHT_AVERAGED 0x2

// Skew calibration

// Skew Calibration unit of time
// 0 - measured in us
// 1 - measured in bitrate per lane / 8
#define SCAL_TSKEWCAL_UNIT_RW 0x3400
#define SCAL_TSKEWCAL_UNIT_RW_MASK BITS_TO_MASK(1)

#define SCAL_TSKEWCAL_INIT_UPPER_RW 0x3408
#define SCAL_TSKEWCAL_INIT_LOWER_RW 0x3409

#define SCAL_TSKEWCAL_PERIOD_UPPER_RW 0x340A
#define SCAL_TSKEWCAL_PERIOD_LOWER_RW 0x340B


// Autofocus Detection Area type
// 0x0 = Fixed Window Mode (16x12)
// 0x1 = Fixed Window Mode (8x6)
// 0x2 = Flexible mode
#define AREA_MODE_RW 0x38A3
#define AREA_MODE_RW_MASK BITS_TO_MASK(2)

// Autofocus phase detection area setting.
// Controls top left X coordinates.
// Only valid when AREA_MODE is 0 or 1
#define PD_AREA_X_OFFSET_UPPER_RW 0x38A4
#define PD_AREA_X_OFFSET_UPPER_RW_MASK BITS_TO_MASK(5)
#define PD_AREA_X_OFFSET_LOWER_RW 0x38A5
#define PD_AREA_X_OFFSET_LOWER_RW_MASK BITS_TO_MASK(8)

// Autofocus phase detection area setting.
// Controls top left Y coordinates.
// Only valid when AREA_MODE is 0 or 1
#define PD_AREA_Y_OFFSET_UPPER_RW 0x38A6
#define PD_AREA_Y_OFFSET_UPPER_RW_MASK BITS_TO_MASK(5)
#define PD_AREA_Y_OFFSET_LOWER_RW 0x38A7
#define PD_AREA_Y_OFFSET_LOWER_RW_MASK BITS_TO_MASK(8)

// Autofocus phase detection area setting
// Controls width of the phase detection area.
// When AREA_MODE = 2, set to 1FFF
// When AREA_MODE = 1, set to H direction pixels of one division
#define PD_AREA_WIDTH_UPPER_RW 0x38A8
#define PD_AREA_WIDTH_UPPER_RW_MASK BITS_TO_MASK(5)
#define PD_AREA_WIDTH_LOWER_RW 0x38A9
#define PD_AREA_WIDTH_LOWER_RW_MASK BITS_TO_MASK(8)

// Autofocus phase detection area setting
// Controls height of the phase detection area.
// When AREA_MODE = 2, set to 1FFF
// When AREA_MODE = 1, set to V direction pixels of one division
#define PD_AREA_HEIGHT_UPPER_RW 0x38AA
#define PD_AREA_HEIGHT_UPPER_RW_MASK BITS_TO_MASK(5)
#define PD_AREA_HEIGHT_LOWER_RW 0x38AB
#define PD_AREA_HEIGHT_LOWER_RW_MASK BITS_TO_MASK(8)

// Set to 1 if bps = 12
// 0 otherwise
#define ADBIT_MODE_RW 0x3F0D
#define ADBIT_MODE_RW_MAST BITS_TO_MASK(1)

// Use per-channel gain
// 0 - off
// 1 - on, all channels will be scaled by the same gain
#define DPGA_USE_GLOBAL_GAIN_RW 0x3FF9
#define DPGA_USE_GLOBAL_GAIN_RW_MASK BITS_TO_MASK(1)


// Embedded data line control
// 0 - No embedded data line
// 2 - Embedded data occurs 2 lines - TODO - what does this mean?
#define EBD_SIZE_V_RW 0xBCF1
#define EBD_SIZE_V_RW_MASK BITS_TO_MASK(8)

// Stop the internal clock when frame blanking.
// 0 = off
// 1 = on
// Only use if you specifically want to use low-power mode
#define FRAME_BLANKSTOP_CL_RW 0xE000
#define FRAME_BLANKSTOP_CL_RW_MASK 0x1

#endif
