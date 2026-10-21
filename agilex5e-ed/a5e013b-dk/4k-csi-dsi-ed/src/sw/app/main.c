/*******************************************************************************
Copyright (C) Altera Corporation

This code and the related documents are Altera copyrighted materials and your
use of them is governed by the express license under which they were provided to
you ("License"). This code and the related documents are provided as is, with no
express or implied warranties other than those that are expressly stated in the
License.
*******************************************************************************/

/* Copyright (C) 2026 Altera Corporation
 *
 * SPDX-License-Identifier: GPL-2.0-only */

#include <fcntl.h>
#include <inttypes.h>
#include <io.h>
#include <stdbool.h>
#include <stdio.h>
#include <string.h>
#include <system.h>
#include <unistd.h>

#include "board.h"
#include "btc_dptx_syslib.h"
#include "config.h"
#include "debug.h"
#include "dptx_app_defs.h"
#include "dptx_formats.h"
#include "dsi_csr.h"
#include "intel_axi2cv.h"
#include "intel_vvp_1d_lut.h"
#include "intel_vvp_blc.h"
#include "intel_vvp_csc.h"
#include "intel_vvp_demosaic.h"
#include "intel_vvp_mixer.h"
#include "intel_vvp_pip_conv.h"
#include "intel_vvp_protocol_conv.h"
#include "intel_vvp_scaler.h"
#include "intel_vvp_switch.h"
#include "intel_vvp_tpg.h"
#include "intel_vvp_vfb.h"
#include "intel_vvp_wbc.h"
#include "panel_ctrl.h"
#include "scaler_coeffs.h"
#include "sensor_imx477.h"
#include "tx_utils.h"

#define DEBUG 0

// #define CHECK_VVP_RETCODES

#if DEBUG == 1
#define DPTX_PRINT(...) printf(__VA_ARGS__)
#else
#define DPTX_PRINT(...)
#undef BITEC_STATUS_DEBUG
#endif /* DEBUG */

#if defined(DEBUG) && defined(CHECK_VVP_RETCODES)
#define VVP_INIT_CHECK(RETCODE, IP_NAME)                                                 \
    do {                                                                                 \
        if (RETCODE != kIntelVvpCoreOk) {                                                \
            printf("Failed to initialise driver for %s\n", IP_NAME);                     \
            printf("Exiting...\n");                                                      \
            return 1;                                                                    \
        }                                                                                \
    } while (0)
#else
#define VVP_INIT_CHECK(COND, IP_NAME)                                                    \
    do {                                                                                 \
    } while (0)
#endif

// Get the core capabilities (defined in QSYS and ported to system.h)
#define TX_MAX_LINK_RATE DP_TX_SUBSYSTEM_DP_SOURCE_BITEC_CFG_TX_MAX_LINK_RATE
#define TX_MAX_LANE_COUNT DP_TX_SUBSYSTEM_DP_SOURCE_BITEC_CFG_TX_MAX_LANE_COUNT

#define AXI_OFFSET 0x300

// Gamma OETF (BT.709) -> Arryas size = 1536
// The following Gamma transfer function was derived after performing a sensor
// tuning, so that the output image looks like a Gamma OETF (BT.709) has been
// applied on it.
const uint32_t gamma_oetf_bt709_1dlut[1536] = {
    4096,    9220,    13321,   18445,   22546,   27670,   31771,   36895,   40996,
    46120,   50221,   55345,   59446,   64570,   68671,   73795,   77896,   83020,
    87121,   92245,   96346,   100446,  104546,  108646,  112746,  116846,  119922,
    124021,  128121,  131197,  134272,  138371,  141447,  144522,  148621,  151697,
    154772,  157847,  160922,  163997,  167072,  170147,  172198,  175272,  178347,
    181422,  183473,  186547,  189622,  191673,  194747,  197822,  199873,  202947,
    204998,  208072,  210123,  212173,  215247,  217298,  219348,  222422,  224473,
    226523,  229597,  231648,  233698,  235748,  237798,  240872,  242923,  244973,
    247023,  249073,  251123,  253173,  255223,  257273,  259323,  261373,  263423,
    265473,  267523,  269573,  271623,  273673,  275723,  277773,  279823,  281873,
    283923,  285973,  288023,  289049,  291098,  293148,  295198,  297248,  298274,
    300323,  302373,  304423,  305449,  307498,  309548,  311598,  312624,  314673,
    316723,  318773,  319799,  321848,  323898,  324924,  326973,  327999,  330048,
    332098,  333124,  335173,  337223,  338249,  340298,  341324,  343373,  344399,
    346448,  348498,  349524,  351573,  352599,  354648,  355674,  357723,  358749,
    360798,  361824,  363873,  364899,  366948,  367974,  370023,  371049,  373098,
    374124,  375149,  377198,  378224,  380273,  381299,  383348,  384374,  385399,
    387448,  388474,  390523,  391549,  392574,  394623,  395649,  397698,  398724,
    399749,  401798,  402824,  403849,  405898,  406924,  407949,  409998,  411024,
    412049,  414098,  415124,  416149,  418198,  419224,  420249,  421274,  423323,
    424349,  425374,  427423,  428449,  429474,  430499,  432548,  433574,  434599,
    435624,  437673,  438699,  439724,  440749,  442798,  443824,  444849,  445874,
    446899,  448948,  449974,  450999,  452024,  454073,  455099,  456124,  457149,
    458174,  459199,  461248,  462274,  463299,  464324,  465349,  467398,  468424,
    469449,  470474,  471499,  472524,  473549,  475598,  476624,  477649,  478674,
    479699,  480724,  481749,  483798,  484824,  485849,  486874,  487899,  488924,
    489949,  490974,  493023,  494049,  495074,  496099,  497124,  498149,  499174,
    500199,  501224,  502249,  503274,  505323,  506349,  507374,  508399,  509424,
    510449,  511474,  512499,  513524,  0,       0,       0,       0,       0,
    0,       0,       0,       0,       0,       0,       0,       0,       0,
    0,       0,       0,       0,       0,       0,       0,       0,       0,
    0,       0,       0,       0,       0,       0,       0,       0,       0,
    0,       0,       0,       0,       0,       0,       0,       0,       0,
    0,       0,       0,       0,       0,       0,       0,       0,       0,
    0,       0,       0,       0,       0,       0,       0,       0,       0,
    0,       0,       0,       0,       0,       517621,  521721,  526845,  530946,
    535046,  539146,  543246,  547346,  551446,  555546,  559646,  563746,  566822,
    570921,  575021,  579121,  582197,  586296,  590396,  594496,  597572,  601671,
    604747,  608846,  611922,  616021,  619097,  623196,  626272,  630371,  633447,
    637546,  640622,  643697,  647796,  650872,  653947,  658046,  661122,  664197,
    667272,  671371,  674447,  677522,  680597,  683672,  687771,  690847,  693922,
    696997,  700072,  703147,  706222,  709297,  712372,  715447,  718522,  721597,
    724672,  727747,  730822,  733897,  736972,  740047,  743122,  745173,  748247,
    751322,  754397,  757472,  760547,  762598,  765672,  768747,  771822,  774897,
    776948,  780022,  783097,  785148,  788222,  791297,  794372,  796423,  799497,
    802572,  804623,  807697,  809748,  812822,  815897,  817948,  821022,  823073,
    826147,  829222,  831273,  834347,  836398,  839472,  841523,  844597,  846648,
    849722,  851773,  854847,  856898,  859972,  862023,  865097,  867148,  870222,
    872273,  874323,  877397,  879448,  882522,  884573,  886623,  889697,  891748,
    893798,  896872,  898923,  900973,  904047,  906098,  908148,  911222,  913273,
    915323,  918397,  920448,  922498,  924548,  927622,  929673,  931723,  934797,
    936848,  938898,  940948,  942998,  946072,  948123,  950173,  952223,  954273,
    957347,  959398,  961448,  963498,  965548,  968622,  970673,  972723,  974773,
    976823,  978873,  980923,  983997,  986048,  988098,  990148,  992198,  994248,
    996298,  998348,  1000398, 1002448, 1005522, 1007573, 1009623, 1011673, 1013723,
    1015773, 1017823, 1019873, 1021923, 1023973, 1026023, 1028073, 1030123, 1032173,
    1034223, 1036273, 1038323, 1040373, 1042423, 1044473, 1046523, 1048573, 4096,
    9220,    13321,   18445,   22546,   27670,   31771,   36895,   40996,   46120,
    50221,   55345,   59446,   64570,   68671,   73795,   77896,   83020,   87121,
    92245,   96346,   100446,  104546,  108646,  112746,  116846,  119922,  124021,
    128121,  131197,  134272,  138371,  141447,  144522,  148621,  151697,  154772,
    157847,  160922,  163997,  167072,  170147,  172198,  175272,  178347,  181422,
    183473,  186547,  189622,  191673,  194747,  197822,  199873,  202947,  204998,
    208072,  210123,  212173,  215247,  217298,  219348,  222422,  224473,  226523,
    229597,  231648,  233698,  235748,  237798,  240872,  242923,  244973,  247023,
    249073,  251123,  253173,  255223,  257273,  259323,  261373,  263423,  265473,
    267523,  269573,  271623,  273673,  275723,  277773,  279823,  281873,  283923,
    285973,  288023,  289049,  291098,  293148,  295198,  297248,  298274,  300323,
    302373,  304423,  305449,  307498,  309548,  311598,  312624,  314673,  316723,
    318773,  319799,  321848,  323898,  324924,  326973,  327999,  330048,  332098,
    333124,  335173,  337223,  338249,  340298,  341324,  343373,  344399,  346448,
    348498,  349524,  351573,  352599,  354648,  355674,  357723,  358749,  360798,
    361824,  363873,  364899,  366948,  367974,  370023,  371049,  373098,  374124,
    375149,  377198,  378224,  380273,  381299,  383348,  384374,  385399,  387448,
    388474,  390523,  391549,  392574,  394623,  395649,  397698,  398724,  399749,
    401798,  402824,  403849,  405898,  406924,  407949,  409998,  411024,  412049,
    414098,  415124,  416149,  418198,  419224,  420249,  421274,  423323,  424349,
    425374,  427423,  428449,  429474,  430499,  432548,  433574,  434599,  435624,
    437673,  438699,  439724,  440749,  442798,  443824,  444849,  445874,  446899,
    448948,  449974,  450999,  452024,  454073,  455099,  456124,  457149,  458174,
    459199,  461248,  462274,  463299,  464324,  465349,  467398,  468424,  469449,
    470474,  471499,  472524,  473549,  475598,  476624,  477649,  478674,  479699,
    480724,  481749,  483798,  484824,  485849,  486874,  487899,  488924,  489949,
    490974,  493023,  494049,  495074,  496099,  497124,  498149,  499174,  500199,
    501224,  502249,  503274,  505323,  506349,  507374,  508399,  509424,  510449,
    511474,  512499,  513524,  0,       0,       0,       0,       0,       0,
    0,       0,       0,       0,       0,       0,       0,       0,       0,
    0,       0,       0,       0,       0,       0,       0,       0,       0,
    0,       0,       0,       0,       0,       0,       0,       0,       0,
    0,       0,       0,       0,       0,       0,       0,       0,       0,
    0,       0,       0,       0,       0,       0,       0,       0,       0,
    0,       0,       0,       0,       0,       0,       0,       0,       0,
    0,       0,       0,       0,       517621,  521721,  526845,  530946,  535046,
    539146,  543246,  547346,  551446,  555546,  559646,  563746,  566822,  570921,
    575021,  579121,  582197,  586296,  590396,  594496,  597572,  601671,  604747,
    608846,  611922,  616021,  619097,  623196,  626272,  630371,  633447,  637546,
    640622,  643697,  647796,  650872,  653947,  658046,  661122,  664197,  667272,
    671371,  674447,  677522,  680597,  683672,  687771,  690847,  693922,  696997,
    700072,  703147,  706222,  709297,  712372,  715447,  718522,  721597,  724672,
    727747,  730822,  733897,  736972,  740047,  743122,  745173,  748247,  751322,
    754397,  757472,  760547,  762598,  765672,  768747,  771822,  774897,  776948,
    780022,  783097,  785148,  788222,  791297,  794372,  796423,  799497,  802572,
    804623,  807697,  809748,  812822,  815897,  817948,  821022,  823073,  826147,
    829222,  831273,  834347,  836398,  839472,  841523,  844597,  846648,  849722,
    851773,  854847,  856898,  859972,  862023,  865097,  867148,  870222,  872273,
    874323,  877397,  879448,  882522,  884573,  886623,  889697,  891748,  893798,
    896872,  898923,  900973,  904047,  906098,  908148,  911222,  913273,  915323,
    918397,  920448,  922498,  924548,  927622,  929673,  931723,  934797,  936848,
    938898,  940948,  942998,  946072,  948123,  950173,  952223,  954273,  957347,
    959398,  961448,  963498,  965548,  968622,  970673,  972723,  974773,  976823,
    978873,  980923,  983997,  986048,  988098,  990148,  992198,  994248,  996298,
    998348,  1000398, 1002448, 1005522, 1007573, 1009623, 1011673, 1013723, 1015773,
    1017823, 1019873, 1021923, 1023973, 1026023, 1028073, 1030123, 1032173, 1034223,
    1036273, 1038323, 1040373, 1042423, 1044473, 1046523, 1048573, 4096,    9220,
    13321,   18445,   22546,   27670,   31771,   36895,   40996,   46120,   50221,
    55345,   59446,   64570,   68671,   73795,   77896,   83020,   87121,   92245,
    96346,   100446,  104546,  108646,  112746,  116846,  119922,  124021,  128121,
    131197,  134272,  138371,  141447,  144522,  148621,  151697,  154772,  157847,
    160922,  163997,  167072,  170147,  172198,  175272,  178347,  181422,  183473,
    186547,  189622,  191673,  194747,  197822,  199873,  202947,  204998,  208072,
    210123,  212173,  215247,  217298,  219348,  222422,  224473,  226523,  229597,
    231648,  233698,  235748,  237798,  240872,  242923,  244973,  247023,  249073,
    251123,  253173,  255223,  257273,  259323,  261373,  263423,  265473,  267523,
    269573,  271623,  273673,  275723,  277773,  279823,  281873,  283923,  285973,
    288023,  289049,  291098,  293148,  295198,  297248,  298274,  300323,  302373,
    304423,  305449,  307498,  309548,  311598,  312624,  314673,  316723,  318773,
    319799,  321848,  323898,  324924,  326973,  327999,  330048,  332098,  333124,
    335173,  337223,  338249,  340298,  341324,  343373,  344399,  346448,  348498,
    349524,  351573,  352599,  354648,  355674,  357723,  358749,  360798,  361824,
    363873,  364899,  366948,  367974,  370023,  371049,  373098,  374124,  375149,
    377198,  378224,  380273,  381299,  383348,  384374,  385399,  387448,  388474,
    390523,  391549,  392574,  394623,  395649,  397698,  398724,  399749,  401798,
    402824,  403849,  405898,  406924,  407949,  409998,  411024,  412049,  414098,
    415124,  416149,  418198,  419224,  420249,  421274,  423323,  424349,  425374,
    427423,  428449,  429474,  430499,  432548,  433574,  434599,  435624,  437673,
    438699,  439724,  440749,  442798,  443824,  444849,  445874,  446899,  448948,
    449974,  450999,  452024,  454073,  455099,  456124,  457149,  458174,  459199,
    461248,  462274,  463299,  464324,  465349,  467398,  468424,  469449,  470474,
    471499,  472524,  473549,  475598,  476624,  477649,  478674,  479699,  480724,
    481749,  483798,  484824,  485849,  486874,  487899,  488924,  489949,  490974,
    493023,  494049,  495074,  496099,  497124,  498149,  499174,  500199,  501224,
    502249,  503274,  505323,  506349,  507374,  508399,  509424,  510449,  511474,
    512499,  513524,  0,       0,       0,       0,       0,       0,       0,
    0,       0,       0,       0,       0,       0,       0,       0,       0,
    0,       0,       0,       0,       0,       0,       0,       0,       0,
    0,       0,       0,       0,       0,       0,       0,       0,       0,
    0,       0,       0,       0,       0,       0,       0,       0,       0,
    0,       0,       0,       0,       0,       0,       0,       0,       0,
    0,       0,       0,       0,       0,       0,       0,       0,       0,
    0,       0,       0,       517621,  521721,  526845,  530946,  535046,  539146,
    543246,  547346,  551446,  555546,  559646,  563746,  566822,  570921,  575021,
    579121,  582197,  586296,  590396,  594496,  597572,  601671,  604747,  608846,
    611922,  616021,  619097,  623196,  626272,  630371,  633447,  637546,  640622,
    643697,  647796,  650872,  653947,  658046,  661122,  664197,  667272,  671371,
    674447,  677522,  680597,  683672,  687771,  690847,  693922,  696997,  700072,
    703147,  706222,  709297,  712372,  715447,  718522,  721597,  724672,  727747,
    730822,  733897,  736972,  740047,  743122,  745173,  748247,  751322,  754397,
    757472,  760547,  762598,  765672,  768747,  771822,  774897,  776948,  780022,
    783097,  785148,  788222,  791297,  794372,  796423,  799497,  802572,  804623,
    807697,  809748,  812822,  815897,  817948,  821022,  823073,  826147,  829222,
    831273,  834347,  836398,  839472,  841523,  844597,  846648,  849722,  851773,
    854847,  856898,  859972,  862023,  865097,  867148,  870222,  872273,  874323,
    877397,  879448,  882522,  884573,  886623,  889697,  891748,  893798,  896872,
    898923,  900973,  904047,  906098,  908148,  911222,  913273,  915323,  918397,
    920448,  922498,  924548,  927622,  929673,  931723,  934797,  936848,  938898,
    940948,  942998,  946072,  948123,  950173,  952223,  954273,  957347,  959398,
    961448,  963498,  965548,  968622,  970673,  972723,  974773,  976823,  978873,
    980923,  983997,  986048,  988098,  990148,  992198,  994248,  996298,  998348,
    1000398, 1002448, 1005522, 1007573, 1009623, 1011673, 1013723, 1015773, 1017823,
    1019873, 1021923, 1023973, 1026023, 1028073, 1030123, 1032173, 1034223, 1036273,
    1038323, 1040373, 1042423, 1044473, 1046523, 1048573};

// Main pipeline
#define INIT_HSIZE 3840
#define INIT_VSIZE 2160

// DSI panel size
#define DSI_HSIZE 1280
#define DSI_VSIZE 800

#define ICON_HSIZE 144
#define ICON_VSIZE 144
#define IMG_INFO_COLORSPACE_RGB 0
#define IMG_INFO_SUBSAMPLING_444 3
#define BAYER_PHASE 3
#define TPG_BAYER_SWITCH_IN 0
#define MIPI_BAYER_SWITCH_IN 1
#define BAYER_SWITCH_OUT 0
#define BLC_BLACK_PEDESTAL 256

#define CSC_PASSTHROUGH_COEFFS_10BITS                                                    \
    {{{1.0f, 0.0f, 0.0f}, {0.0f, 1.0f, 0.0f}, {0.0f, 0.0f, 1.0f}}, {0.0f, 0.0f, 0.0f}}

intel_vvp_tpg_instance input_tpg;
intel_vvp_switch_instance input_switch;
intel_vvp_blc_instance blc;
intel_vvp_wbc_instance wbc;
intel_vvp_demosaic_instance demosaic;
intel_vvp_csc_instance csc;
intel_vvp_vfb_instance vfb;
intel_vvp_tpg_instance tpg_base_layer;
intel_vvp_mixer_instance mixer;
intel_vvp_1d_lut_instance vvp_1d_lut;
intel_vvp_pip_conv_instance pip_conv_1to2;
intel_vvp_protocol_conv_instance proto_lite_to_full;

intel_vvp_switch_instance output_switch;
intel_vvp_scaler_instance dsi_downscaler;
intel_vvp_vfb_instance dsi_vfb;
intel_vvp_protocol_conv_instance dsi_lite_to_full;

/////////////////////////////////////////////////////
#define CCM_DATA_ROWS 3
#define CCM_DATA_COLS 4

struct ccm_data_t {
    uint32_t _temperature; // in Kelvin
    float _data[CCM_DATA_ROWS][CCM_DATA_COLS];
};

// These are pre-calculated coefficients  used by the color correction matrix
// IP. The actual coefficients are selected based on the different temperature
// values.
struct ccm_data_t ccm_data[] = {
    {2700,
     {{1.97212233966, -0.31148457161, 0.0629290786905, 0.0},
      {-0.605994182169, 1.60888428497, -0.989673475203, 0.0},
      {-0.366128157495, -0.297399713363, 1.92674439651, 0.0}}},
    {3200,
     {{2.09545240572, -0.271942119736, 0.0437406747877, 0.0},
      {-0.804253946252, 1.58130893506, -0.82617639942, 0.0},
      {-0.291198459473, -0.309366815326, 1.78243572463, 0.0}}},
    {4000,
     {{2.19308523953, -0.231189909127, 0.0256799820648, 0.0},
      {-0.95221818352, 1.56099976121, -0.693310582809, 0.0},
      {-0.240867056013, -0.329809852082, 1.66763060074, 0.0}}},
    {5000,
     {{2.30731116488, -0.200557686432, 0.00948551882926, 0.0},
      {-1.1007633158, 1.54942609732, -0.608735454974, 0.0},
      {-0.206547849081, -0.348868410891, 1.59924993615, 0.0}}},
    {6000,
     {{2.38474473977, -0.192237034314, 0.00333308341238, 0.0},
      {-1.20850786855, 1.56213412896, -0.552686310272, 0.0},
      {-0.176236871227, -0.369897094645, 1.54935322686, 0.0}}},
    {6500,
     {{2.40880697803, -0.190736905595, 0.00155607184761, 0.0},
      {-1.23496753647, 1.5715786598, -0.546106655638, 0.0},
      {-0.173839441559, -0.380841754202, 1.54455058379, 0.0}}},
    {8000,
     {{2.46311530809, -0.184704972889, -0.00509696200995, 0.0},
      {-1.31971272713, 1.61604460292, -0.521126671284, 0.0},
      {-0.143402580958, -0.43133963003, 1.52622363329, 0.0}}},
    {9900,
     {{2.49073102955, -0.181164783264, -0.00682715535404, 0.0},
      {-1.3761653417, 1.67965095666, -0.500044172644, 0.0},
      {-0.114565687852, -0.498486173392, 1.506871328, 0.0}}}};

const size_t CCM_DATA_SIZE = sizeof(ccm_data) / sizeof(struct ccm_data_t);

struct ccm_data_t get_ccm_data(const uint32_t temperature) {
    size_t idx0 = 0;
    size_t idx1 = 0;

    while (idx0 < CCM_DATA_SIZE) {
        if (ccm_data[idx0]._temperature > temperature)
            break;
        ++idx0;
    }

    if (idx0 > 0) {
        if (idx0 >= CCM_DATA_SIZE) {
            idx0 = CCM_DATA_SIZE - 1;
            idx1 = idx0;
        } else {
            idx1 = idx0 - 1;
        }
    }

    if (idx0 == idx1)
        return ccm_data[idx0];
    else {
        const float n = (float)(temperature - ccm_data[idx1]._temperature);
        const float d =
            (float)(ccm_data[idx0]._temperature - ccm_data[idx1]._temperature);
        const float r = n / d;

        struct ccm_data_t result = {};

        for (size_t i = 0; i < CCM_DATA_ROWS; ++i) {
            for (size_t j = 0; j < CCM_DATA_COLS; ++j) {
                result._data[i][j] =
                    ccm_data[idx1]._data[i][j] +
                    r * (ccm_data[idx0]._data[i][j] - ccm_data[idx1]._data[i][j]);
            }
        }

        return result;
    }
}

intel_vvp_coefficients get_ccm_coeffs(struct ccm_data_t ccm_data_intp) {
    intel_vvp_coefficients coeffs;

    coeffs.coeffs[0].c1 = ccm_data_intp._data[2][2];
    coeffs.coeffs[0].c2 = ccm_data_intp._data[1][2];
    coeffs.coeffs[0].c3 = ccm_data_intp._data[0][2];
    coeffs.s[0] = 0;

    coeffs.coeffs[1].c1 = ccm_data_intp._data[2][1];
    coeffs.coeffs[1].c2 = ccm_data_intp._data[1][1];
    coeffs.coeffs[1].c3 = ccm_data_intp._data[0][1];
    coeffs.s[1] = 0;

    coeffs.coeffs[2].c1 = ccm_data_intp._data[2][0];
    coeffs.coeffs[2].c2 = ccm_data_intp._data[1][0];
    coeffs.coeffs[2].c3 = ccm_data_intp._data[0][0];
    coeffs.s[2] = 0;

    return coeffs;
}

void printf_csc_coeffs(intel_vvp_coefficients intp_ccm_coeffs) {
    for (int r = 0; r < 3; ++r) {
        // Set the coefficients for each channel
        printf("Colour plane (%d): %f, %f, %f\n", r, intp_ccm_coeffs.coeffs[r].c1,
               intp_ccm_coeffs.coeffs[r].c2, intp_ccm_coeffs.coeffs[r].c3);
    }
}

// Externally defined data and variables

// Defined in tx_utils.c
extern int new_rx;
extern BYTE tx_edid_data[512]; // Sink EDID

// Global data and state variables

intel_axi2cv_instance axi2cv;
int res_switch = 1;
uint32_t dp_tx_status = 0;
uint32_t output_format = 0x0;
uint32_t output_format_override = 0x0;
bool bpc10_support = false;

// Parse EDID DTD and update the list of supported formats
void update_supported_formats_from_dtd(const uint8_t *dtd) {
    // Ignore descriptor if not DTD
    if ((dtd[0] == 0x0) && (dtd[1] == 0x00))
        return;

    uint32_t pixel_clock = (dtd[0] | (dtd[1] << 8)) * 10000;

    uint32_t width = dtd[2];
    uint32_t h_blanking = dtd[3];
    width = width | ((dtd[4] & 0xf0) << 4);
    h_blanking = h_blanking | ((dtd[4] & 0x0f) << 8);

    uint32_t height = dtd[5];
    uint32_t v_blanking = dtd[6];
    height = height | ((dtd[7] & 0xf0) << 4);
    v_blanking = v_blanking | ((dtd[7] & 0x0f) << 8);

    uint32_t total_pixels = (width + h_blanking) * (height + v_blanking);
    uint32_t frame_rate_frac = ((pixel_clock % total_pixels) * 100) / total_pixels;
    // Frame rate x100 Hz
    uint32_t frame_rate = ((pixel_clock / total_pixels) * 100) + frame_rate_frac;

    // Check and update the app supported formats
    dptx_formats_set_supported(width, height, frame_rate);
}

// Process sink EDID and upate list of supported video formats
void process_sink_edid() {
    // Check basic display parameters for 10bpc support
    if (tx_edid_data[EDID_INDEX_BDP_START] & EDID_INDEX_BDP_DIGITAL_INPUT)
        bpc10_support = ((tx_edid_data[EDID_INDEX_BDP_START] &
                          EDID_INDEX_BDP_BIT_DEPTH_MASK) == EDID_INDEX_BDP_BIT_DEPTH_10);

    // Process DTDs in the main block
    for (uint8_t startOfDescriptor = EDID_INDEX_DESCRIPTOR1_START;
         startOfDescriptor <= EDID_INDEX_DESCRIPTOR4_START;
         startOfDescriptor += EDID_INDEX_DESCRIPTOR_SIZE) {
        update_supported_formats_from_dtd(&tx_edid_data[startOfDescriptor]);
    }

    //-- Does the EDID have an extension block?
    bool extBlockPresent = (tx_edid_data[EDID_INDEX_EXT_BLOCK_COUNT] > 0);

    //-- If present, check the checksum on the extension block.
    if (extBlockPresent) {
        const unsigned char *extBlockData = tx_edid_data + EDID_BLOCK_SIZE;
        uint32_t start_of_DTD = extBlockData[EDID_INDEX_EXT_DTD_START];

        //-- DTD must start within the EDID block
        if (start_of_DTD < EDID_BLOCK_SIZE) {
            //-- Loop through the Data Blocks but check that start of DTD
            // indicates
            // having space for them
            if (start_of_DTD > EDID_INDEX_EXT_DB_START) {
                //-
                //- Detailed timing descriptors
                //-
                uint32_t num_of_DTD = extBlockData[EDID_INDEX_EXT_CEA_SUPPORT] & 0x1f;
                const uint8_t *dtd = extBlockData + start_of_DTD;

                for (uint32_t i = 0; i < num_of_DTD; ++i) {
                    update_supported_formats_from_dtd(dtd);
                    dtd += EDID_DTD_SIZE;
                }

                uint32_t dataBlockStart = EDID_INDEX_EXT_DB_START;

                //-- Must stay within the region below the DTD and not go
                // outside the
                // EDID block
                while ((dataBlockStart < start_of_DTD) &&
                       (dataBlockStart < EDID_BLOCK_SIZE)) {
                    //-- First byte in a Data Block encodes type and length
                    //--      bit 7..5: Block Type Tag (1 is audio, 2 is video,
                    // 3 is
                    // vendor specific, 4 is speaker
                    //--                allocation, all other values Reserved)
                    //--      bit 4..0: Total number of bytes in this block
                    // following this
                    // byte
                    uint8_t dataBlockType = (extBlockData[dataBlockStart] & 0xE0) >> 5;
                    uint8_t dataBlockLength =
                        (extBlockData[dataBlockStart] & 0x1F); //-- Max length of 31bytes

                    //-- Sanity check on the indicated block length
                    if ((dataBlockStart + dataBlockLength) < EDID_BLOCK_SIZE) {
                        if (dataBlockType == EDID_VIDEO_DATA_BLOCK) {
                            //-- Loop through looking for the VIC codes of
                            // interest.
                            //-- Note that we only loop over the indicated block
                            // length and
                            // this
                            //-- has been verified above.
                            for (int byteLoop = 1; byteLoop <= dataBlockLength;
                                 byteLoop++) {
                                uint8_t vic =
                                    extBlockData[dataBlockStart + byteLoop] & 0x7F;
                                dptx_formats_set_supported_by_vic(vic);
                            }
                        }

                        if ((dataBlockType == EDID_VENDOR_SPECIFIC_DATA_BLOCK) &&
                            (dataBlockLength >= EDID_INDEX_EXT_VSDB_MIN_LENGTH)) {
                            //-- Look for VSDB data block that defines color
                            // depth
                            if ((extBlockData[dataBlockStart + 1] == 0x03) &&
                                (extBlockData[dataBlockStart + 2] == 0x0C) &&
                                (extBlockData[dataBlockStart + 3] == 0x00)) {
                                //-- Is 10 bpc supported?
                                if ((extBlockData[dataBlockStart + 6] & 0x70) > 0) {
                                    bpc10_support |= true;
                                }
                            }
                        }
                        //----------------------------------------------------------------------------------------------------
                        //-- Already checked that adding the block length (+1)
                        // doesn't take
                        // us outside the EDID block
                        //-- Add one to pointer as the block length value does
                        // not include
                        // the first byte (header)
                        dataBlockStart += dataBlockLength;
                        dataBlockStart += 1;
                    } else {
                        DPTX_PRINT("EDID: Invalid extended block length\n");
                    }
                }
            }
        } else {
            DPTX_PRINT("EDID: Invalid extended block start\n");
        }
    }
}

// Configure DP CVO (NOT DSI)
void program_cvo_timing(intel_axi2cv_instance *cvo, const cvo_timing_info_t *t) {
    if (cvo && t) {
        intel_axi2cv_set_output_mode(
            cvo, 0, t->interlaced, t->sample_count, t->f0_line_count, t->f1_line_count,
            t->h_front_porch, t->h_sync_length, t->h_blanking, t->v_front_porch,
            t->v_sync_length, t->v_blanking, t->f0_v_front_porch, t->f0_v_sync_length,
            t->f0_v_blanking, t->active_picture_line, t->f0_v_rising, t->field_rising,
            t->field_falling, t->h_sync_polarity, t->v_sync_polarity);
    }
}

uint32_t get_tx_link_rate() {
    return (((IORD(btc_dptx_baseaddr(0), DPTX_REG_TX_CONTROL) >> 21) & 0xff) * 270);
}

#if BITEC_TX_AUX_DEBUG
char auxTxDebugEnable;
static AuxDecoderInstance _gTxAuxInstance;
#endif

unsigned int lt_tx_link_rate;
unsigned int lt_tx_lane_count;

//==================================================================
// Main Program
//==================================================================

// Common img info setup for VVP IPs
static void vvp_set_rgb_img_info(void *core, uint32_t width, uint32_t height) {
    intel_vvp_core_set_img_info_width(core, width);
    intel_vvp_core_set_img_info_height(core, height);
    intel_vvp_core_set_img_info_interlace(core, 3);
    intel_vvp_core_set_img_info_colorspace(core, IMG_INFO_COLORSPACE_RGB);
    intel_vvp_core_set_img_info_subsampling(core, IMG_INFO_SUBSAMPLING_444);
    intel_vvp_core_set_img_info_cositing(core, 0);
}

static void vvp_configure_input_tpg(uint32_t blue, uint32_t green, uint32_t red) {
    intel_vvp_tpg_stop(&input_tpg);
    intel_vvp_core_set_img_info_width(&input_tpg.core_instance, INIT_HSIZE);
    intel_vvp_core_set_img_info_height(&input_tpg.core_instance, INIT_VSIZE);
    intel_vvp_core_set_img_info_interlace(&input_tpg.core_instance, 3);
    intel_vvp_tpg_set_pattern(&input_tpg,
                              0); // Colour bars = 0, Solid colors = 1
    intel_vvp_tpg_set_colors(&input_tpg, blue, green, red);
    intel_vvp_tpg_commit_writes(&input_tpg);
    intel_vvp_tpg_start(&input_tpg);
}

static void vvp_one_time_init() {

    // DSI pipeline protocol converter - Lite to full
    vvp_set_rgb_img_info(&dsi_lite_to_full, DSI_HSIZE, DSI_VSIZE);
    intel_vvp_protocol_conv_enable(&dsi_lite_to_full, true);

    // DSI pipeline Framebuffer
    vvp_set_rgb_img_info(&dsi_vfb, DSI_HSIZE, DSI_VSIZE);
    intel_vvp_vfb_output_enable(&dsi_vfb, true);

    // DSI pipeline (down)scaler
    if (intel_vvp_scaler_get_scaling_algorithm(&dsi_downscaler) ==
        kIntelVvpScalerPolyphaseScaling) {
        scaler_create_and_load_horizontal_coefficents(
            PRE_DSI_SUBSYSTEM_PRE_DSI_SUBSYSTEM_DOWNSCALER_BASE, 4, 16, 6, INIT_HSIZE,
            DSI_HSIZE, 0);
        scaler_create_and_load_vertical_coefficents(
            PRE_DSI_SUBSYSTEM_PRE_DSI_SUBSYSTEM_DOWNSCALER_BASE, 4, 16, 6, INIT_VSIZE,
            DSI_VSIZE, 0);
        intel_vvp_scaler_set_h_bank(&dsi_downscaler, 0);
        intel_vvp_scaler_set_v_bank(&dsi_downscaler, 0);
    }
    intel_vvp_scaler_set_output_width(&dsi_downscaler, DSI_HSIZE);
    intel_vvp_scaler_set_output_height(&dsi_downscaler, DSI_VSIZE);
    vvp_set_rgb_img_info(&dsi_downscaler, INIT_HSIZE, INIT_VSIZE);
    intel_vvp_scaler_commit_writes(&dsi_downscaler);

    // DPTX pipeline protocol converter - Lite to full
    vvp_set_rgb_img_info(&proto_lite_to_full.core_instance, INIT_HSIZE, INIT_VSIZE);
    intel_vvp_protocol_conv_enable(&proto_lite_to_full, true);

    // DPTX pipeline PIP converter - 1 to 2
    vvp_set_rgb_img_info(&pip_conv_1to2.core_instance, INIT_HSIZE, INIT_VSIZE);

    // ISP 1D LUT
    intel_vvp_core_set_img_info_width(&vvp_1d_lut.core_instance, INIT_HSIZE);
    intel_vvp_core_set_img_info_height(&vvp_1d_lut.core_instance, INIT_VSIZE);
    printf("1D LUT write array status... %d\n",
           intel_vvp_1d_lut_write_data_array(&vvp_1d_lut, gamma_oetf_bt709_1dlut, 1536));

    // ISP Mixer (combines icon, base tpg, and camera stream)
    intel_vvp_core_set_img_info_width(&mixer.core_instance, INIT_HSIZE);
    intel_vvp_core_set_img_info_height(&mixer.core_instance, INIT_VSIZE);
    intel_vvp_core_set_img_info_subsampling(&mixer.core_instance,
                                            IMG_INFO_SUBSAMPLING_444);

    intel_vvp_mixer_set_blend_mode(&mixer, 1, kIntelVvpMixerBlendOpaque);
    intel_vvp_mixer_set_blend_mode(&mixer, 2, kIntelVvpMixerBlendOpaque);

    // Mixer Input Layer # 1 : input video from VfB
    intel_vvp_mixer_set_horiz_offset(&mixer, 1, 0);
    intel_vvp_mixer_set_vert_offset(&mixer, 1, 0);
    intel_vvp_mixer_set_width(&mixer, 1, INIT_HSIZE);
    intel_vvp_mixer_set_height(&mixer, 1, INIT_VSIZE);

    // Mixer Input Layer # 3 : input video from Icon
    intel_vvp_mixer_set_horiz_offset(&mixer, 2, 0);
    intel_vvp_mixer_set_vert_offset(&mixer, 2, 0);
    intel_vvp_mixer_set_width(&mixer, 2, ICON_HSIZE);
    intel_vvp_mixer_set_height(&mixer, 2, ICON_VSIZE);
    intel_vvp_mixer_commit_writes(&mixer);

    // ISP base layer TPG - solid color + color bars
    intel_vvp_tpg_stop(&tpg_base_layer);
    intel_vvp_core_set_img_info_width(&tpg_base_layer.core_instance, INIT_HSIZE);
    intel_vvp_core_set_img_info_height(&tpg_base_layer.core_instance, INIT_VSIZE);
    intel_vvp_core_set_img_info_interlace(&tpg_base_layer.core_instance, 3);
    intel_vvp_tpg_set_pattern(&tpg_base_layer, 0);
    intel_vvp_tpg_commit_writes(&tpg_base_layer);
    intel_vvp_tpg_start(&tpg_base_layer);

    // ISP framebuffer
    vvp_set_rgb_img_info(&vfb.core_instance, INIT_HSIZE, INIT_VSIZE);
    intel_vvp_vfb_output_enable(&vfb, true);

    // ISP color space converter - for managing color temperature
    // Committed once in vvp_configure_defaults(): WBC/BLC reject writes while a commit is
    // pending
    vvp_set_rgb_img_info(&csc.core_instance, INIT_HSIZE, INIT_VSIZE);

    // ISP demosaic
    intel_vvp_core_set_img_info_width(&demosaic.core_instance, INIT_HSIZE);
    intel_vvp_core_set_img_info_height(&demosaic.core_instance, INIT_VSIZE);

    // ISP white balance correction
    intel_vvp_core_set_img_info_width(&wbc.core_instance, INIT_HSIZE);
    intel_vvp_core_set_img_info_height(&wbc.core_instance, INIT_VSIZE);

    // ISP black level correction
    intel_vvp_core_set_img_info_width(&blc.core_instance, INIT_HSIZE);
    intel_vvp_core_set_img_info_height(&blc.core_instance, INIT_VSIZE);
}

// Default settings for VVP IPs (all of ISP + DP preprocessing + DSI preprocessing)
static void vvp_configure_defaults(bool rx_present, intel_vvp_coefficients *default_ccm) {

    // 1D LUT
    intel_vvp_1d_lut_set_bypass(&vvp_1d_lut, false);

    // ISP end mixer
    intel_vvp_mixer_set_input_mode(&mixer, 1, true, false,
                                   true); // enable, consume, soft start
    intel_vvp_mixer_set_input_mode(&mixer, 2, true, false,
                                   true); // enable, consume, soft start
    intel_vvp_mixer_commit_writes(&mixer);

    // ISP base layer TPG - solid color + color bars
    intel_vvp_tpg_stop(&tpg_base_layer);
    intel_vvp_tpg_set_pattern(&tpg_base_layer,
                              0); // Colour bars = 1, Solid colors = 0
    intel_vvp_tpg_set_colors(&tpg_base_layer, 1023, 0, 0); // BGR
    intel_vvp_tpg_commit_writes(&tpg_base_layer);
    intel_vvp_tpg_start(&tpg_base_layer);

    // ISP color space converter - for managing color temperature
    intel_vvp_csc_set_coeff_data(&csc, default_ccm, 10);
    intel_vvp_csc_set_output_color_space(&csc, kIntelVvpCsRgb);
    intel_vvp_csc_commit_writes(&csc);

    // ISP demosaic
    intel_vvp_core_set_img_info_width(&demosaic.core_instance, INIT_HSIZE);
    intel_vvp_core_set_img_info_height(&demosaic.core_instance, INIT_VSIZE);
    intel_vvp_demosaic_set_cfa_phase(&demosaic,
                                     BAYER_PHASE); // RGGB = 0 (Framos IMX678), BGGR = 3
                                                   // (Raspberry pi hq camera)
    intel_vvp_demosaic_set_bypass(&demosaic, false);

    // ISP white balance correction
    intel_vvp_wbc_set_cfa_00_color_scaler(&wbc, 0x1d89);
    intel_vvp_wbc_set_cfa_01_color_scaler(&wbc, 0x0800);
    intel_vvp_wbc_set_cfa_10_color_scaler(&wbc, 0x0800);
    intel_vvp_wbc_set_cfa_11_color_scaler(&wbc, 0x0de9);
    intel_vvp_wbc_set_cfa_phase(&wbc, BAYER_PHASE); // RGGB = 0, BGGR = 3
    intel_vvp_wbc_set_bypass(&wbc, false);
    intel_vvp_wbc_commit(&wbc);

    // ISP black level correction
    intel_vvp_core_set_img_info_width(&blc.core_instance, INIT_HSIZE);
    intel_vvp_core_set_img_info_height(&blc.core_instance, INIT_VSIZE);
    intel_vvp_blc_set_cfa_00_black_pedestal(&blc, BLC_BLACK_PEDESTAL);
    intel_vvp_blc_set_cfa_00_color_scaler(&blc, 17496);
    intel_vvp_blc_set_cfa_01_black_pedestal(&blc, BLC_BLACK_PEDESTAL);
    intel_vvp_blc_set_cfa_01_color_scaler(&blc, 17496);
    intel_vvp_blc_set_cfa_10_black_pedestal(&blc, BLC_BLACK_PEDESTAL);
    intel_vvp_blc_set_cfa_10_color_scaler(&blc, 17496);
    intel_vvp_blc_set_cfa_11_black_pedestal(&blc, BLC_BLACK_PEDESTAL);
    intel_vvp_blc_set_cfa_11_color_scaler(&blc, 17496);
    intel_vvp_blc_set_cfa_phase(&blc, BAYER_PHASE); // RGGB = 0, BGGR = 3
    intel_vvp_blc_set_bypass(&blc, false);
    intel_vvp_blc_commit(&blc);

    // ISP RX ingest mux
    if (rx_present) {
        intel_vvp_switch_set_input_config(&input_switch, TPG_BAYER_SWITCH_IN,
                                          kIntelVvpSwitchInputConsumed); // TPG
        intel_vvp_switch_set_input_config(&input_switch, MIPI_BAYER_SWITCH_IN,
                                          kIntelVvpSwitchInputEnabled); // IMX Sensor
        intel_vvp_switch_set_output_config(&input_switch, BAYER_SWITCH_OUT, true,
                                           MIPI_BAYER_SWITCH_IN);
    } else {
        intel_vvp_switch_set_input_config(&input_switch, TPG_BAYER_SWITCH_IN,
                                          kIntelVvpSwitchInputEnabled); // TPG
        intel_vvp_switch_set_input_config(&input_switch, MIPI_BAYER_SWITCH_IN,
                                          kIntelVvpSwitchInputConsumed); // IMX Sensor
        intel_vvp_switch_set_output_config(&input_switch, BAYER_SWITCH_OUT, true,
                                           TPG_BAYER_SWITCH_IN);
    }
    intel_vvp_switch_commit_writes(&input_switch);

    // ISP remosaic
    // printf("Remosaic Phase BGGR \n");
    // RGGB = 0x94 -> 1001_0100 (Framos IMX678)
    // BGGR = 0x16 -> 0001_0110 (IMX477 Raspberry pi hq camera)
    IOWR(ISP_LITE_IN_SUBSYSTEM_ISP_IN_RMS_BASE, 1, 0x16);
}

void print_banner() {
    printf("\n============================================================="
           "\nDemo        : MIPI CSI-2 Camera to DSI-2 Display Example Design"
           "\nDevkit      : Agilex 5 FPGA E-Series 013B Development Kit "
           "\nMIPI CSI Rx : MIPI Bank 3A (J21)"
           "\nMIPI DSI Tx : MIPI Bank 2A (J20)"
           "\nDP Tx       : DisplayPort Transmit (J12)"
           "\n=============================================================\n");
}

// BLC and WBC do not allow a second commit until first is accepted
void block_until_wbc_free() {
    while (intel_vvp_wbc_commit_is_pending(&wbc)) {
        usleep(5000);
    }
}

void block_until_blc_free() {
    while (intel_vvp_blc_commit_is_pending(&blc)) {
        usleep(5000);
    }
}

int main() {

    print_banner();

    /**************************************************************/
    // IMPORTANT: If picolibc is used for libc in place of newlib (see
    // bsp_commands.tcl), non-blocking input causes issues with getchar() and
    // other libc stdin methods.
    //
    // This is because the HAL's picolibc syscall stub (in alt_io_redirect.c)
    // doesn't account for read(STDIN_FILENO, ...) possibly failing (and in this
    // case will return garbage, not necessarily EOF); down the call chain
    // altera_avalon_jtag_uart_read returns an error code if non-blocking and the
    // RX FIFO is empty. Blocking guarantees read() suceeds and writes a
    // character to the buffer.
    /**************************************************************/

    // Non-blocking output
    int out_flags = fcntl(STDOUT_FILENO, F_GETFL);
    out_flags |= O_NONBLOCK;
    int res_out = fcntl(STDOUT_FILENO, F_SETFL, out_flags);

    /************************************************************************/
    // Blocking input means the main loop stalls until a key is pressed.
    // This means DPTX HPD events will not get processed until a key is pressed
    /************************************************************************/

    // Non-blocking input (assuming newlib)
    int in_flags = fcntl(STDIN_FILENO, F_GETFL);
    // in_flags &= ~O_NONBLOCK; // deliberately clear
    in_flags |= O_NONBLOCK;
    int res_in = fcntl(STDIN_FILENO, F_SETFL, in_flags);

    if ((res_in == -1) || (res_out == -1)) {
        printf("FCNTL Failed\n");
    }

    //-------------------------------------------------------------------------
    // Devkit setup
    //-------------------------------------------------------------------------

    printf("Starting Configuration Sequence...\n");
    printf("DP Tx was configured for on-board connectors\n");

    // Perform Devkit Specific initialisations
    board_configure();
    printf("The Devkit was configured OK\n");

    //-------------------------------------------------------------------------
    // DDR4 calibration
    //-------------------------------------------------------------------------

    printf("Waiting for DDR4 calibration to complete...\n");
    uint32_t emif_pio_val = (IORD(EMIF_SUBSYSTEM_PIO_EMIF_CAL_BASE, 0) & (0x3));

    unsigned int cal_timer = 0;
    const uint32_t cal_poll_rate = 10000;
    const uint32_t cal_one_sec_num_ticks = 1000000 / cal_poll_rate;

    while (emif_pio_val != 0x3) {
        usleep(cal_poll_rate);
        emif_pio_val = (IORD(EMIF_SUBSYSTEM_PIO_EMIF_CAL_BASE, 0) & (0x3));
        if (DEBUG && cal_timer % cal_one_sec_num_ticks == 0) { // every 1s
            printf("EMIF pio iopll_0_locked: %0d, cal_done_rst_n: %0d \n",
                   !!(emif_pio_val & 0x2), !!(emif_pio_val & 0x1));
        }
        cal_timer += 1;
    }
    printf("DDR4 calibration is completed\n");

    unsigned int cal_time = cal_timer * cal_poll_rate;
    printf("Calibration time (since waiting message): %0u.%0us\n", cal_time / 1000000,
           (cal_time % 1000000) / 10000);

    //-------------------------------------------------------------------------
    // IMX477 sensor setup
    //-------------------------------------------------------------------------

    printf("//================================================= \n");
    printf("  IMX477 Sensor setup  \n\n");

    // SLASEL  | I2C Address
    //  0/NC   | 0x1A (Pi HQ Sensor)
    //  1      | 0x10

    bool sensor_init_success =
        sensor_imx477_init(MIPI_RX_SUBSYSTEM_CAM_I2C_NAME, 0x1A) == 0;

    if (sensor_init_success) {
        if (set_sensor_imx477()) {
            printf("Initial IMX477 sensor setup has failed.\n");
        } else {
            printf("Initial IMX477 sensor setup configuration has passed.\n");
        }
    } else {
        printf("Failed to detect IMX477 sensor. Only TPG inputs will be "
               "available.\n");
    }

    //-------------------------------------------------------------------------
    // DPTX setup
    //-------------------------------------------------------------------------

    printf("//================================================= \n");
    printf("  DP TX setup  \n\n");

    // Init Bitec DP system library
    btc_dptx_syslib_add_tx(0, DP_TX_SUBSYSTEM_DP_SOURCE_BASE,
                           DP_TX_SUBSYSTEM_DP_SOURCE_IRQ_INTERRUPT_CONTROLLER_ID,
                           DP_TX_SUBSYSTEM_DP_SOURCE_IRQ);
    if (btc_dptx_syslib_init()) {
        DPTX_PRINT("DP driver init success\n");
    }

    intel_vab_core_base axi2cv_addr_base =
        (intel_vab_core_base)(DP_TX_SUBSYSTEM_DP_SOURCE_BASE + (AXI_OFFSET << 2));

    if (intel_axi2cv_init(&axi2cv, axi2cv_addr_base)) {
        DPTX_PRINT("Error initialising AXI2CV\nExiting...\n");
        return 1;
    }

    printf("Initialised AXI2CV...\n");

    // Init the source
    bitec_dptx_init();

#if BITEC_TX_AUX_DEBUG
    dp_dump_aux_debug_init(&_gTxAuxInstance,
                           DP_TX_SUBSYSTEM_AUX_TX_DEBUG_FIFO_IN_CSR_BASE,
                           DP_TX_SUBSYSTEM_AUX_TX_DEBUG_FIFO_OUT_BASE, false);
    auxTxDebugEnable = 0;
#endif

    lt_tx_link_rate = TX_MAX_LINK_RATE;
    lt_tx_lane_count = TX_MAX_LANE_COUNT;

    // Check if a Sink is readily connected

    unsigned int sr =
        IORD(btc_dptx_baseaddr(0), DPTX_REG_TX_STATUS); // Reading SR clears IRQ
    bool hpd = sr & 0x04;
    bool prev_hpd = hpd;

    if (hpd) {
#if BITEC_TX_CAPAB_MST
        btc_dptxll_hpd_change(0, 1);
        pc_fsm = PC_FSM_START;
#else
        btc_dptx_hpd_change(0, 1);
        bitec_dptx_linktrain();
#endif
        new_rx = 1;
    } else {
        DPTX_PRINT("DPTX HPD = 0, skipping link training...\n");
    }

    BTC_DPTX_ENABLE_HPD_IRQ(0); // Enable IRQ on HPD changes from the sink

    //-------------------------------------------------------------------------
    // Panel setup
    //-------------------------------------------------------------------------

    printf("//================================================= \n");
    printf("  DSI LCD panel setup\n\n");

    const int backlight_level = 255;
    if (panel_i2c_init(MIPI_DSI2_TX_SUBSYSTEM_MIPI_OUT_I2C_NAME) == 0) {
        panel_init();

        // Enable immediately, as DSI CVO starts immediately out of reset
        panel_enable(backlight_level);
        printf("Panel configuration success\n");
    } else {
        printf("Panel configuration failed\n");
    }
    //-------------------------------------------------------------------------
    // Pipeline setup
    //-------------------------------------------------------------------------

    printf("//================================================= \n");
    printf("  Initialising ISP + video pipeline\n\n");

    int vvp_retcode = 0;

    //-- Color space converter coefficients
    const intel_vvp_coefficients ccm_passthrough = CSC_PASSTHROUGH_COEFFS_10BITS;

    intel_vvp_coefficients ccm_3000k = get_ccm_coeffs(get_ccm_data(3000));
    intel_vvp_coefficients ccm_4000k = get_ccm_coeffs(get_ccm_data(4000));
    intel_vvp_coefficients ccm_5000k = get_ccm_coeffs(get_ccm_data(5000));
    intel_vvp_coefficients ccm_6000k = get_ccm_coeffs(get_ccm_data(6000));
    intel_vvp_coefficients ccm_7000k = get_ccm_coeffs(get_ccm_data(7000));
    intel_vvp_coefficients ccm_8000k = get_ccm_coeffs(get_ccm_data(8000));
    intel_vvp_coefficients ccm_9000k = get_ccm_coeffs(get_ccm_data(9000));

    // Initialise all VVP drivers (ISP, DPTX pipeline, DSI pipeline)
    vvp_retcode |= intel_vvp_protocol_conv_init(
        &dsi_lite_to_full,
        (intel_vvp_core_base)PRE_DSI_SUBSYSTEM_PRE_DSI_SUBSYSTEM_LITE_TO_FULL_BASE);
    VVP_INIT_CHECK(vvp_retcode, "dsi_lite_to_full");

    vvp_retcode |= intel_vvp_vfb_init(
        &dsi_vfb, (intel_vvp_core_base)PRE_DSI_SUBSYSTEM_PRE_DSI_SUBSYSTEM_VFB_BASE);
    VVP_INIT_CHECK(vvp_retcode, "dsi_vfb");

    vvp_retcode |= intel_vvp_scaler_init(
        &dsi_downscaler,
        (intel_vvp_core_base)PRE_DSI_SUBSYSTEM_PRE_DSI_SUBSYSTEM_DOWNSCALER_BASE);
    VVP_INIT_CHECK(vvp_retcode, "dsi_downscaler");

    vvp_retcode |= intel_vvp_protocol_conv_init(
        &proto_lite_to_full,
        (intel_vvp_core_base)ISP_LITE_OUT_SUBSYSTEM_ISP_OUT_PROTO_CONV_BASE);
    VVP_INIT_CHECK(vvp_retcode, "proto_lite_to_full");

    vvp_retcode |= intel_vvp_pip_conv_init(
        &pip_conv_1to2,
        (intel_vvp_core_base)ISP_LITE_OUT_SUBSYSTEM_VID_OUT_PIP_CONV_BASE);
    VVP_INIT_CHECK(vvp_retcode, "pip_conv_1to2");

    vvp_retcode |= intel_vvp_switch_init(
        &output_switch, (intel_vvp_core_base)ISP_LITE_OUT_SUBSYSTEM_ISP_OUT_SWITCH_BASE);
    VVP_INIT_CHECK(vvp_retcode, "output_switch");

    vvp_retcode |= intel_vvp_1d_lut_init(
        &vvp_1d_lut, (intel_vvp_core_base)ISP_LITE_OUT_SUBSYSTEM_ISP_1D_LUT_BASE);
    VVP_INIT_CHECK(vvp_retcode, "vvp_1d_lut");

    vvp_retcode |= intel_vvp_mixer_init(
        &mixer, (intel_vvp_core_base)ISP_LITE_OUT_SUBSYSTEM_ISP_MIXER_BASE);
    VVP_INIT_CHECK(vvp_retcode, "mixer");

    vvp_retcode |= intel_vvp_tpg_init(
        &tpg_base_layer, (intel_vvp_core_base)ISP_LITE_OUT_SUBSYSTEM_ISP_TPG_BASE);
    VVP_INIT_CHECK(vvp_retcode, "tpg_base_layer");

    vvp_retcode |= intel_vvp_vfb_init(
        &vfb, (intel_vvp_core_base)ISP_LITE_OUT_SUBSYSTEM_ISP_VFB_BASE);
    VVP_INIT_CHECK(vvp_retcode, "vfb");

    vvp_retcode |=
        intel_vvp_csc_init(&csc, (intel_vvp_core_base)ISP_LITE_SUBSYSTEM_ISP_CCM_BASE);
    VVP_INIT_CHECK(vvp_retcode, "csc");

    vvp_retcode |= intel_vvp_demosaic_init(
        &demosaic, (intel_vvp_core_base)ISP_LITE_SUBSYSTEM_ISP_DMS_BASE);
    VVP_INIT_CHECK(vvp_retcode, "demosaic");

    vvp_retcode |=
        intel_vvp_wbc_init(&wbc, (intel_vvp_core_base)ISP_LITE_SUBSYSTEM_ISP_WBC_BASE);
    VVP_INIT_CHECK(vvp_retcode, "wbc");

    vvp_retcode |=
        intel_vvp_blc_init(&blc, (intel_vvp_core_base)ISP_LITE_SUBSYSTEM_ISP_BLC_BASE);
    VVP_INIT_CHECK(vvp_retcode, "blc");

    vvp_retcode |= intel_vvp_switch_init(
        &input_switch, (intel_vvp_core_base)ISP_LITE_IN_SUBSYSTEM_ISP_IN_SWITCH_BASE);
    VVP_INIT_CHECK(vvp_retcode, "input_switch");

    vvp_retcode |= intel_vvp_tpg_init(
        &input_tpg, (intel_vvp_core_base)ISP_LITE_IN_SUBSYSTEM_ISP_IN_TPG_BASE);
    VVP_INIT_CHECK(vvp_retcode, "input_tpg");

    // Output Switch (VVP-Full): follows the DP Tx HPD state
    printf("DPTX HPD: %0d\n", hpd);
    intel_vvp_switch_set_input_config(&output_switch, 0, kIntelVvpSwitchInputEnabled);
    intel_vvp_switch_set_output_config(&output_switch, 0, hpd, 0);
    intel_vvp_switch_set_output_config(&output_switch, 1, true, 0);
    vvp_set_rgb_img_info(&output_switch, INIT_HSIZE, INIT_VSIZE);
    intel_vvp_switch_commit_writes(&output_switch);

    int icon_tgl = 1;
    unsigned int int_ccm_cnt = 2;
    unsigned int int_wbc_cnt = 1;
    unsigned int int_tpg_cnt = 0;

    intel_vvp_tpg_set_bars_type(&input_tpg, kIntelVvpTpgColorBars);
    vvp_one_time_init();
    usleep(10000);
    vvp_configure_defaults(sensor_init_success, &ccm_5000k);
    vvp_configure_input_tpg(4095, BLC_BLACK_PEDESTAL,
                            BLC_BLACK_PEDESTAL); // BGR -> Blue

    /*
     * Panel configuration is derived from official Raspberry Pi linux driver,
     * however exact initialization sequencing is difficult to replicate fully.
     *
     * The following sequence, where we set VSYNC high for 2 seconds, seems to
     * avoid visual glitches on startup. This is should NOT be considered an
     * official reference on how to initialize the panel.
     */

    dsi_csr_vtiming_std_t default_vtiming_std = {
        .hreset = 0,
        .vreset = 0,
        .htotal = 2230,
        .vtotal = 928,
        .f1_start = 0,
        .f2_start = 8191,
        .hb_end = 950,
        .v1b_start = 0,
        .v1b_end = 128,
        .v2b_start = 8191,
        .v2b_end = 8191,
        .hs_start = 860,
        .hs_end = 890,
        .v1s_hstart = 860,
        .v1s_vstart = 40,
        .v1s_hend = 860,
        .v1s_vend = 88,
        .v2s_hstart = 8191,
        .v2s_vstart = 8191,
        .v2s_hend = 8191,
        .v2s_vend = 8191,
    };

    // Force the timing generator to keep VSYNC high
    dsi_csr_vtiming_std_t default_vtiming_std_init = default_vtiming_std;
    default_vtiming_std_init.v1s_vstart = 0;
    default_vtiming_std_init.v1s_vend = 0;

    dsi_csr_set_vtiming_std(default_vtiming_std);
    usleep(2000000);

    // Force VSYNC high all the time for a bit
    dsi_csr_set_vtiming_std(default_vtiming_std_init);
    usleep(2000000);

    dsi_csr_set_vtiming_std(default_vtiming_std);


    printf("//================================================= \n");
    printf("Please press 'h' to see the menu\n");

    // Main loop
    while (1) {
        // Serve Syslib periodic tasks
        btc_dptx_syslib_monitor();

#if BITEC_TX_CAPAB_MST
        btc_dptxll_syslib_monitor();
        // Simulate the user MST TX application
        bitec_dptx_pc();
#endif

#if BITEC_TX_AUX_DEBUG
        if (auxTxDebugEnable & 1)
            dp_dump_aux_debug(&_gTxAuxInstance);
#endif

        hpd = bitec_dptx_get_hpd();
        if (hpd != prev_hpd) {
            printf("Change in DPTX HPD (now %0d), adjusting output switch...\n", hpd);
            // Only allow data to pass through if DPTX is connected. The DPTX sink
            // deasserts TREADY on the video input if disconnected, which stalls
            // the switch unless switch set to consume mode.
            intel_vvp_switch_set_output_config(&output_switch, 0, hpd, 0);
            intel_vvp_switch_commit_writes(&output_switch);
            prev_hpd = hpd;
        }

        // Check current Tx status and update status register
        uint32_t dp_tx_vid_ena_1b = IORD(DP_TX_SUBSYSTEM_DP_SOURCE_BASE, 0x350) & 0x1;
        uint32_t dp_tx_vid_match_1b = IORD(DP_TX_SUBSYSTEM_DP_SOURCE_BASE, 0x351) & 0x1;
        uint32_t dp_tx_vid_valid_1b = IORD(DP_TX_SUBSYSTEM_DP_SOURCE_BASE, 0x36D) & 0x1;

        uint32_t dp_tx_status_current =
            dp_tx_vid_ena_1b << 2 | dp_tx_vid_match_1b << 1 | dp_tx_vid_valid_1b;

        if (dp_tx_status != dp_tx_status_current) {
            dp_tx_status = dp_tx_status_current;
            IOWR(DP_TX_SUBSYSTEM_PIO_STATUS_BASE, 0, dp_tx_status);
        }

        // Handle new sink here
        if (new_rx) {
            new_rx = 0;

            dptx_formats_clear_supported();
            bpc10_support = false;

            process_sink_edid();

            // Disable QHD for now. Need correct timing data
            dptx_formats_clear_supported_n(2);
            dptx_formats_clear_supported_n(3);

            if (DEBUG) {
                dptx_formats_print();
            }
            DPTX_PRINT("10bpc: %s\n", bpc10_support ? "Yes" : "No");

            // Update supported formats register
            uint32_t reg_val = 0x0;

            const uint32_t num_supported_formats =
                dptx_min(dptx_formats_len(), MAX_SUPPORTED_FORMATS);

            for (uint32_t i = 0; i < num_supported_formats; ++i) {
                uint32_t v = (dptx_formats_is_supported(i) ? 1 : 0);
                reg_val |= (v << i);
            }

            if (bpc10_support)
                reg_val |= FORMATS_REG_10BPC;

            IOWR(DP_TX_SUBSYSTEM_PIO_SUPPORTD_FMATS_BASE, 0, reg_val);

            res_switch = 1;
        }

        // Check for output format override request
        // uint32_t output_format_override_new =
        // IORD(DP_TX_SUBSYSTEM_PIO_FORMAT_OVRRIDE_BASE, 0); Currently this demo
        // only supports 4K30p output video resolution on the DP Tx The video
        // resolution is selectd directly in the SW App, by selecting the
        // correct index for the table located in dptx_formats.c video_format_t
        // sink_formats[] = { idx == 0 => {0, EDID_2160P60_VIC, "3840x2160p60",
        // {CVO_2160P_MODE},   TX_CLK_297,      6000}, idx == 1 => {0,
        // EDID_2160P30_VIC, "3840x2160p30",  {CVO_2160P_MODE},   TX_CLK_148_5,
        // 3000}, idx == 2 => {0, EDID_NA_VIC,      "2560x1440p60",
        // {CVO_2160P_MODE},   TX_CLK_241_5,    6000},   /* Needs correct timing
        // data */ idx == 3 => {0, EDID_NA_VIC,      "2560x1440p30",
        // {CVO_2160P_MODE},   TX_CLK_120_75,   3000},   /* Needs correct timing
        // data */ idx == 4 => {0, EDID_1080P60_VIC, "1920x1080p60",
        // {CVO_1080P_MODE},   TX_CLK_74_25,    6000}, idx == 5 => {0,
        // EDID_1080P30_VIC, "1920x1080p30",  {CVO_1080P_MODE},   TX_CLK_37_125,
        // 3000}, idx == 6 => {0, EDID_720P60_VIC,  "1280x720p60",
        // {CVO_720P_MODE}, TX_CLK_37_125,   6000}, idx == 7 => {0,
        // EDID_720P30_VIC,  "1280x720p30", {CVO_720P_MODE},    TX_CLK_18_5625,
        // 3000}
        // };
        // 3840x2160p30
        uint32_t output_format_override_new = 0x1;

        // ToDo: validate output_format_override_new!
        if (output_format_override != output_format_override_new) {
            DPTX_PRINT("Format override: %" PRIx32 "\n", output_format_override_new);
            output_format_override = output_format_override_new;
            res_switch = 1;
        }

        if (res_switch == 1) {
            const video_format_t *format = NULL;
            uint32_t output_format_new = 0x0;

            // Use requested output format if provided
            // otherwise pick the first supported from the list
            uint32_t override_val = output_format_override & FORMATS_REG_MASK;

            if (override_val) {
                uint32_t v = override_val;
                uint32_t idx = 0;

                while ((v & 0x1) == 0) {
                    ++idx;
                    v = v >> 1;
                }

                const video_format_t *f = dptx_formats_get(idx);

                if (f && f->supported) {
                    format = f;
                    output_format_new = (0x1 << idx);

                    if (bpc10_support && (output_format_override & FORMATS_REG_10BPC))
                        output_format_new |= FORMATS_REG_10BPC;
                }
            } else {
                for (uint32_t idx = 0; idx < dptx_formats_len(); ++idx) {
                    const video_format_t *f = dptx_formats_get(idx);

                    if (f && f->supported) {
                        format = f;
                        output_format_new = (0x1 << idx);

                        if (bpc10_support)
                            output_format_new |= FORMATS_REG_10BPC;

                        break;
                    }
                }
            }

            if (!format) {
                uint32_t idx = dptx_formats_get_fallback_idx();
                format = dptx_formats_get(idx);
                output_format_new = (0x1 << idx);
            }

            if (format) {
                DPTX_PRINT("New format: %s\n", format->str);
                program_cvo_timing(&axi2cv, &format->timing);
                board_tx_freq(format->tx_clk);

                /*
                    If the sink reports 10bpc support we also need to check
                    if the current link rate is highe enough to produce stable
                    10 bpc output
                */

                /* Default to 8 bpc */
                uint8_t bpc = 1;

                if (output_format_new & FORMATS_REG_10BPC) {
                    const cvo_timing_info_t *timing = &format->timing;

                    if (timing) {
                        if ((timing->sample_count >= 3840) &&
                            (timing->f0_line_count >= 2160) && (format->fps >= 6000)) {
                            const uint32_t link_rate = get_tx_link_rate();

                            if (link_rate >= 8100)
                                bpc = 2; /* 10 bpc output is possible */
                            else
                                output_format_new &=
                                    ~(FORMATS_REG_10BPC); // Fall back to 8bpc
                        }
                    }
                }

                btc_dptx_set_color_space(0, 0, bpc, 0, 0, 0);
            }

            if (output_format != output_format_new) {
                output_format = output_format_new;
                IOWR(DP_TX_SUBSYSTEM_PIO_CURR_FORMAT_BASE, 0, output_format);

                DPTX_PRINT("New format: 0x%08" PRIx32 "\n", output_format);
            }

            res_switch = 0;
        }

        int cmd;

        cmd = getchar();

        if (cmd != EOF) {
            switch (cmd) {
            case 'h': {
                print_banner();
                printf("\n=============================================================\n"
                       "[s] -> Toggle between MIPI Rx and Input TPG\n"
                       "[r] -> ISP Lite Camera: Default Configuration\n"
                       "[t] -> Toggle Icon (On and Off)\n"
                       "[1] -> BLC: BGGR Mode\n"
                       "[2] -> BLC: Bypass Mode\n"
                       "[3] -> WBC: BGGR Mode (From 3000K to 9000K)\n"
                       "[4] -> WBC: Bypass Mode\n"
                       "[5] -> Demosaic: BGGR Mode\n"
                       "[6] -> Demosaic: Bypass Mode (Bayer Mode)\n"
                       "[7] -> CCM: RGB Mode (From 3000K to 9000K)\n"
                       "[8] -> CCM: Bypass Mode\n"
                       "[9] -> 1D LUT: BT-709 Mode\n"
                       "[0] -> 1D LUT: Bypass Mode\n"
                       "[m] -> Exposure Gain: Increment\n"
                       "[n] -> Exposure Gain: Decrement\n"
#if DEBUG == 1
                       "[!] -> Pipeline diagnostics\n"
#endif
                       "=============================================================\n");
                break;
            }
            case 's': {
                // printf("Toggle Input Switch \n");
                if (int_tpg_cnt < 4) {
                    int_tpg_cnt = int_tpg_cnt + 1;
                } else {
                    int_tpg_cnt = 0;
                }

                // Do not attempt to switch to sensor if not available
                if (!sensor_init_success && int_tpg_cnt == 0) {
                    printf("Sensor not available... not switching to rx\n");
                    int_tpg_cnt = 1;
                }

                if (int_tpg_cnt == 1) {
                    intel_vvp_switch_set_input_config(&input_switch, TPG_BAYER_SWITCH_IN,
                                                      kIntelVvpSwitchInputEnabled); // TPG
                    intel_vvp_switch_set_input_config(
                        &input_switch, MIPI_BAYER_SWITCH_IN,
                        kIntelVvpSwitchInputConsumed); // IMX Sensor
                    intel_vvp_switch_set_output_config(&input_switch, BAYER_SWITCH_OUT,
                                                       true, TPG_BAYER_SWITCH_IN);
                    intel_vvp_tpg_set_pattern(&input_tpg,
                                              0); // Colour bars = 0, Solid colors = 1
                    intel_vvp_tpg_set_bars_type(&input_tpg, kIntelVvpTpgColorBars);
                    intel_vvp_tpg_set_colors(&input_tpg, 4095, BLC_BLACK_PEDESTAL,
                                             BLC_BLACK_PEDESTAL); // BGR
                    intel_vvp_tpg_commit_writes(&input_tpg);
                    intel_vvp_switch_commit_writes(&input_switch);
                    printf("Input Switch set for -> Input TPG Color Bars \n");
                } else if (int_tpg_cnt == 2) {
                    intel_vvp_switch_set_input_config(&input_switch, TPG_BAYER_SWITCH_IN,
                                                      kIntelVvpSwitchInputEnabled); // TPG
                    intel_vvp_switch_set_input_config(
                        &input_switch, MIPI_BAYER_SWITCH_IN,
                        kIntelVvpSwitchInputConsumed); // IMX Sensor
                    intel_vvp_switch_set_output_config(&input_switch, BAYER_SWITCH_OUT,
                                                       true, TPG_BAYER_SWITCH_IN);
                    intel_vvp_tpg_set_pattern(&input_tpg,
                                              1); // Colour bars = 0, Solid colors = 1
                    intel_vvp_tpg_set_bars_type(&input_tpg, kIntelVvpTpgColorBars);
                    intel_vvp_tpg_set_colors(&input_tpg, 4095, BLC_BLACK_PEDESTAL,
                                             BLC_BLACK_PEDESTAL); // BGR
                    intel_vvp_tpg_commit_writes(&input_tpg);
                    intel_vvp_switch_commit_writes(&input_switch);
                    printf("Input Switch set for -> Input TPG Solid-Blue \n");
                } else if (int_tpg_cnt == 3) {
                    intel_vvp_switch_set_input_config(&input_switch, TPG_BAYER_SWITCH_IN,
                                                      kIntelVvpSwitchInputEnabled); // TPG
                    intel_vvp_switch_set_input_config(
                        &input_switch, MIPI_BAYER_SWITCH_IN,
                        kIntelVvpSwitchInputConsumed); // IMX Sensor
                    intel_vvp_switch_set_output_config(&input_switch, BAYER_SWITCH_OUT,
                                                       true, TPG_BAYER_SWITCH_IN);
                    intel_vvp_tpg_set_pattern(&input_tpg,
                                              1); // Colour bars = 0, Solid colors = 1
                    intel_vvp_tpg_set_bars_type(&input_tpg, kIntelVvpTpgColorBars);
                    intel_vvp_tpg_set_colors(&input_tpg, BLC_BLACK_PEDESTAL, 4095,
                                             BLC_BLACK_PEDESTAL); // BGR
                    intel_vvp_tpg_commit_writes(&input_tpg);
                    intel_vvp_switch_commit_writes(&input_switch);
                    printf("Input Switch set for -> Input TPG Solid-Green \n");
                } else if (int_tpg_cnt == 4) {
                    intel_vvp_switch_set_input_config(&input_switch, TPG_BAYER_SWITCH_IN,
                                                      kIntelVvpSwitchInputEnabled); // TPG
                    intel_vvp_switch_set_input_config(
                        &input_switch, MIPI_BAYER_SWITCH_IN,
                        kIntelVvpSwitchInputConsumed); // IMX Sensor
                    intel_vvp_switch_set_output_config(&input_switch, BAYER_SWITCH_OUT,
                                                       true, TPG_BAYER_SWITCH_IN);
                    intel_vvp_tpg_set_pattern(&input_tpg,
                                              1); // Colour bars = 0, Solid colors = 1
                    intel_vvp_tpg_set_bars_type(&input_tpg, kIntelVvpTpgColorBars);
                    intel_vvp_tpg_set_colors(&input_tpg, BLC_BLACK_PEDESTAL,
                                             BLC_BLACK_PEDESTAL,
                                             4095); // BGR
                    intel_vvp_tpg_commit_writes(&input_tpg);
                    intel_vvp_switch_commit_writes(&input_switch);
                    printf("Input Switch set for -> Input TPG Solid-Red \n");
                } else {
                    intel_vvp_switch_set_input_config(
                        &input_switch, TPG_BAYER_SWITCH_IN,
                        kIntelVvpSwitchInputConsumed); // TPG
                    intel_vvp_switch_set_input_config(
                        &input_switch, MIPI_BAYER_SWITCH_IN,
                        kIntelVvpSwitchInputEnabled); // IMX Sensor
                    intel_vvp_switch_set_output_config(&input_switch, BAYER_SWITCH_OUT,
                                                       true, MIPI_BAYER_SWITCH_IN);
                    intel_vvp_switch_commit_writes(&input_switch);
                    printf("Input Switch set for -> MIPI Rx \n");
                }
                break;
            }
            case '1': {
                block_until_blc_free();
                printf("BLC: BGGR Mode \n");
                intel_vvp_blc_set_cfa_00_black_pedestal(&blc, BLC_BLACK_PEDESTAL);
                intel_vvp_blc_set_cfa_00_color_scaler(&blc, 17496);
                intel_vvp_blc_set_cfa_01_black_pedestal(&blc, BLC_BLACK_PEDESTAL);
                intel_vvp_blc_set_cfa_01_color_scaler(&blc, 17496);
                intel_vvp_blc_set_cfa_10_black_pedestal(&blc, BLC_BLACK_PEDESTAL);
                intel_vvp_blc_set_cfa_10_color_scaler(&blc, 17496);
                intel_vvp_blc_set_cfa_11_black_pedestal(&blc, BLC_BLACK_PEDESTAL);
                intel_vvp_blc_set_cfa_11_color_scaler(&blc, 17496);
                intel_vvp_blc_set_cfa_phase(&blc,
                                            BAYER_PHASE); // RGGB = 0, BGGR = 3
                intel_vvp_blc_set_bypass(&blc, false);
                intel_vvp_blc_commit(&blc);
                break;
            }
            case '2': {
                block_until_blc_free();
                while (intel_vvp_blc_commit_is_pending(&blc)) {
                    usleep(10000);
                }
                printf("BLC: Bypass Mode \n");
                intel_vvp_blc_set_bypass(&blc, true);
                intel_vvp_blc_commit(&blc);
                break;
            }
            case '3': {
                block_until_wbc_free();
                printf("WBC: BGGR Mode \n");
                if (int_wbc_cnt <= 6) {
                    int_wbc_cnt = int_wbc_cnt + 1;
                } else {
                    int_wbc_cnt = 1;
                }

                // Default to 4000K: 3000K to 9000K
                if (int_wbc_cnt == 1) { // # 3000K
                    intel_vvp_wbc_set_cfa_00_color_scaler(&wbc, 0x1e66);
                    intel_vvp_wbc_set_cfa_11_color_scaler(&wbc, 0x0d3a);
                    printf("WBC: Set for 3000K \n");
                } else if (int_wbc_cnt == 2) { // # 4000K
                    intel_vvp_wbc_set_cfa_00_color_scaler(&wbc, 0x1d89);
                    intel_vvp_wbc_set_cfa_11_color_scaler(&wbc, 0x0de9);
                    printf("WBC: Set for 4000K \n");
                } else if (int_wbc_cnt == 3) { // # 5000K
                    intel_vvp_wbc_set_cfa_00_color_scaler(&wbc, 0x1d23);
                    intel_vvp_wbc_set_cfa_11_color_scaler(&wbc, 0x0e1f);
                    printf("WBC: Set for 5000K \n");
                } else if (int_wbc_cnt == 4) { // # 6000K
                    intel_vvp_wbc_set_cfa_00_color_scaler(&wbc, 0x1bf2);
                    intel_vvp_wbc_set_cfa_11_color_scaler(&wbc, 0x0ecf);
                    printf("WBC: Set for 6000K \n");
                } else if (int_wbc_cnt == 5) { // # 7000K
                    intel_vvp_wbc_set_cfa_00_color_scaler(&wbc, 0x1a5b);
                    intel_vvp_wbc_set_cfa_11_color_scaler(&wbc, 0x0fb9);
                    printf("WBC: Set for 7000K \n");
                } else if (int_wbc_cnt == 6) { // # 8000K
                    intel_vvp_wbc_set_cfa_00_color_scaler(&wbc, 0x19f5);
                    intel_vvp_wbc_set_cfa_11_color_scaler(&wbc, 0x0ff4);
                    printf("WBC: Set for 8000K \n");
                } else if (int_wbc_cnt == 7) { // # 9000K
                    intel_vvp_wbc_set_cfa_00_color_scaler(&wbc, 0x198f);
                    intel_vvp_wbc_set_cfa_11_color_scaler(&wbc, 0x102f);
                    printf("WBC: Set for 9000K \n");
                }

                intel_vvp_wbc_set_cfa_01_color_scaler(&wbc, 0x0800);
                intel_vvp_wbc_set_cfa_10_color_scaler(&wbc, 0x0800);
                intel_vvp_wbc_set_cfa_phase(&wbc,
                                            BAYER_PHASE); // RGGB = 0, BGGR = 3
                intel_vvp_wbc_set_bypass(&wbc, false);
                intel_vvp_wbc_commit(&wbc);
                break;
            }
            case '4': {
                block_until_wbc_free();
                printf("WBC: Bypass Mode \n");
                intel_vvp_wbc_set_bypass(&wbc, true);
                intel_vvp_wbc_commit(&wbc);
                break;
            }
            case '5': {
                printf("Demosaic: BGGR Mode \n");
                intel_vvp_demosaic_set_cfa_phase(&demosaic,
                                                 BAYER_PHASE); // RGGB = 0, BGGR = 3
                intel_vvp_demosaic_set_bypass(&demosaic, false);
                break;
            }
            case '6': {
                printf("Demosaic: Bypass Mode \n");
                intel_vvp_demosaic_set_cfa_phase(&demosaic,
                                                 BAYER_PHASE); // RGGB = 0, BGGR = 3
                intel_vvp_demosaic_set_bypass(&demosaic, true);
                break;
            }
            case '7': {
                printf("CCM: RGB Mode \n");
                if (int_ccm_cnt <= 6) {
                    int_ccm_cnt = int_ccm_cnt + 1;
                } else {
                    int_ccm_cnt = 1;
                }

                if (int_ccm_cnt == 1) { // # 3000K
                    intel_vvp_csc_set_coeff_data(&csc, &ccm_3000k, 10);
                    printf("CCM: Set for 3000K \n");
                    printf_csc_coeffs(ccm_3000k);
                } else if (int_ccm_cnt == 2) { // # 4000K
                    intel_vvp_csc_set_coeff_data(&csc, &ccm_4000k, 10);
                    printf("CCM: Set for 4000K \n");
                    printf_csc_coeffs(ccm_4000k);
                } else if (int_ccm_cnt == 3) { // # 5000K
                    intel_vvp_csc_set_coeff_data(&csc, &ccm_5000k, 10);
                    printf("CCM: Set for 5000K \n");
                    printf_csc_coeffs(ccm_5000k);
                } else if (int_ccm_cnt == 4) { // # 6000K
                    intel_vvp_csc_set_coeff_data(&csc, &ccm_6000k, 10);
                    printf("CCM: Set for 6000K \n");
                    printf_csc_coeffs(ccm_6000k);
                } else if (int_ccm_cnt == 5) { // # 7000K
                    intel_vvp_csc_set_coeff_data(&csc, &ccm_7000k, 10);
                    printf("CCM: Set for 7000K \n");
                    printf_csc_coeffs(ccm_7000k);
                } else if (int_ccm_cnt == 6) { // # 8000K
                    intel_vvp_csc_set_coeff_data(&csc, &ccm_8000k, 10);
                    printf("CCM: Set for 8000K \n");
                    printf_csc_coeffs(ccm_8000k);
                } else if (int_ccm_cnt == 7) { // # 9000K
                    intel_vvp_csc_set_coeff_data(&csc, &ccm_9000k, 10);
                    printf("CCM: Set for 9000K \n");
                    printf_csc_coeffs(ccm_9000k);
                }

                intel_vvp_csc_commit_writes(&csc);
                break;
            }
            case '8': {
                printf("CCM: Bypass Mode \n");
                intel_vvp_csc_set_coeff_data(&csc, &ccm_passthrough, 0);
                intel_vvp_csc_commit_writes(&csc);
                break;
            }
            case '9': {
                printf("1D LUT: BT-709 Mode \n");
                intel_vvp_1d_lut_set_bypass(&vvp_1d_lut, false);
                break;
            }
            case '0': {
                printf("1D LUT: Bypass Mode \n");
                intel_vvp_1d_lut_set_bypass(&vvp_1d_lut, true);
                break;
            }
            case 't': {
                printf("Toggle Icon \n");
                if (icon_tgl == 0) {
                    icon_tgl = 1;
                    intel_vvp_mixer_set_input_mode(
                        &mixer, 1, true, false,
                        true); // enable, consume, soft start: VfB
                    intel_vvp_mixer_set_input_mode(
                        &mixer, 2, true, false,
                        true); // enable, consume, soft start: Icon
                    intel_vvp_mixer_commit_writes(&mixer);
                    printf("Icon     : On \n");
                } else {
                    icon_tgl = 0;
                    intel_vvp_mixer_set_input_mode(
                        &mixer, 1, true, false,
                        true); // enable, consume, soft start: VfB
                    intel_vvp_mixer_set_input_mode(
                        &mixer, 2, true, true,
                        true); // enable, consume, soft start: Icon
                    intel_vvp_mixer_commit_writes(&mixer);
                    printf("Icon     : Off \n");
                }
                break;
            }
            case 'r': {
                printf("Restoring Default Settings \n");

                // Set sensor to default settings
                if (sensor_init_success) {
                    if (set_sensor_imx477()) {
                        printf("Error: Setting sensor defaults did not "
                               "complete successfully!\n");
                    }
                }

                int_ccm_cnt = 2;
                int_wbc_cnt = 1;
                int_tpg_cnt = 0;

                vvp_configure_defaults(sensor_init_success, &ccm_5000k);
                vvp_configure_input_tpg(4095, BLC_BLACK_PEDESTAL,
                                        BLC_BLACK_PEDESTAL); // BGR

                break;
            }

            case 'm': {
                printf("//================================================= \n");
                printf("Exposure Gain: Increment \n");
                printf("//================================================= \n");

                unsigned char d_gain_p2 = read_sensor_imx477(0x020E) & (0x0f);
                unsigned char d_gain_p1 = read_sensor_imx477(0x020F) & (0xff);
                unsigned int d_gain_total = (d_gain_p2 << 8) | (d_gain_p1);

                unsigned char a_gain_p2 = read_sensor_imx477(0x0204) & (0x03);
                unsigned char a_gain_p1 = read_sensor_imx477(0x0205) & (0xff);
                unsigned int a_gain_total = (a_gain_p2 << 8) | (a_gain_p1);

                // Digital gain range : 0 to 4090
                printf("Old Digital Gain... %u\n", d_gain_total);
                // Analogue gain range : 0 to 970
                printf("Old Analogue Gain... %u\n", a_gain_total);

                if (d_gain_total >= 0 && d_gain_total < 4090) {
                    d_gain_total = d_gain_total + 10;
                    d_gain_p2 = (d_gain_total & 0xf00) >> (8);
                    d_gain_p1 = (d_gain_total & 0x0ff);

                    write_sensor_imx477(0x020E, d_gain_p2);
                    write_sensor_imx477(0x020F, d_gain_p1);
                    printf("New Digital Gain... %u\n", d_gain_total);
                    printf("New Analogue Gain... %u\n", a_gain_total);
                } else if ((d_gain_total >= 4090) && (a_gain_total >= 0) &&
                           (a_gain_total < 970)) {
                    a_gain_total = a_gain_total + 10;
                    a_gain_p2 = (a_gain_total & 0x300) >> (8);
                    a_gain_p1 = (a_gain_total & 0x0ff);

                    write_sensor_imx477(0x0204, a_gain_p2);
                    write_sensor_imx477(0x0205, a_gain_p1);
                    printf("New Digital Gain... %u\n", d_gain_total);
                    printf("New Analogue Gain... %u\n", a_gain_total);
                } else {
                    printf("You have reached the maximum value for the Digital "
                           "Gain... %u\n",
                           d_gain_total);
                    printf("You have reached the maximum value for the "
                           "Analogue Gain... "
                           "%u\n",
                           a_gain_total);
                }
                printf("//================================================= \n");
                break;
            }
            case 'n': {
                printf("//================================================= \n");
                printf("Exposure Gain: Decrement \n");
                printf("//================================================= \n");

                unsigned char d_gain_p2 = read_sensor_imx477(0x020E) & (0x0f);
                unsigned char d_gain_p1 = read_sensor_imx477(0x020F) & (0xff);
                unsigned int d_gain_total = (d_gain_p2 << 8) | (d_gain_p1);

                unsigned char a_gain_p2 = read_sensor_imx477(0x0204) & (0x03);
                unsigned char a_gain_p1 = read_sensor_imx477(0x0205) & (0xff);
                unsigned int a_gain_total = (a_gain_p2 << 8) | (a_gain_p1);

                // Digital gain range : 0 to 4090
                printf("Old Digital Gain... %u\n", d_gain_total);
                // Analogue gain range : 0 to 970
                printf("Old Analogue Gain... %u\n", a_gain_total);

                if ((d_gain_total >= 0) && (a_gain_total > 0) && (a_gain_total <= 970)) {
                    a_gain_total = a_gain_total - 10;
                    a_gain_p2 = (a_gain_total & 0x300) >> (8);
                    a_gain_p1 = (a_gain_total & 0x0ff);

                    write_sensor_imx477(0x0204, a_gain_p2);
                    write_sensor_imx477(0x0205, a_gain_p1);
                    printf("New Digital Gain... %u\n", d_gain_total);
                    printf("New Analogue Gain... %u\n", a_gain_total);
                } else if (d_gain_total > 0 && d_gain_total <= 4090) {
                    d_gain_total = d_gain_total - 10;
                    d_gain_p2 = (d_gain_total & 0xf00) >> (8);
                    d_gain_p1 = (d_gain_total & 0x0ff);

                    write_sensor_imx477(0x020E, d_gain_p2);
                    write_sensor_imx477(0x020F, d_gain_p1);
                    printf("New Digital Gain... %u\n", d_gain_total);
                    printf("New Analogue Gain... %u\n", a_gain_total);
                } else {
                    printf("You have reached the minimum value for the Digital "
                           "Gain... %u\n",
                           d_gain_total);
                    printf("You have reached the minimum value for the "
                           "Analogue Gain... "
                           "%u\n",
                           a_gain_total);
                }
                printf("//================================================= \n");
                break;
            }

#ifdef DEBUG
            case '!': {
                // Useful for checking pipeline status
                //
                // We achieve 30->60 fps by naively rely on the frame buffer
                // to repeat frames; expect DSI VFB to roughly have half
                // its frames repeated.
                //
                // The second VFB feeds from first; if first VFB fails,
                // expect no good output on second.
                //
                // CSI RX -> ISP -> Input VFB --> DP TX
                //                            |-> DSI VFB -> DSI TX
                printf("//================================================= \n");
                printf("Input VFB input:    %" PRIu32 "\n"
                       "          output:   %" PRIu32 "\n"
                       "          dropped:  %" PRIu32 "\n"
                       "          repeated: %" PRIu32 "\n"
                       "DSI VFB   input:    %" PRIu32 "\n"
                       "          output:   %" PRIu32 "\n"
                       "          dropped:  %" PRIu32 "\n"
                       "          repeated: %" PRIu32 "\n",
                       intel_vvp_vfb_get_num_input_fields(&vfb),
                       intel_vvp_vfb_get_num_output_fields(&vfb),
                       intel_vvp_vfb_get_num_dropped_fields(&vfb),
                       intel_vvp_vfb_get_num_repeated_fields(&vfb),
                       intel_vvp_vfb_get_num_input_fields(&dsi_vfb),
                       intel_vvp_vfb_get_num_output_fields(&dsi_vfb),
                       intel_vvp_vfb_get_num_dropped_fields(&dsi_vfb),
                       intel_vvp_vfb_get_num_repeated_fields(&dsi_vfb));
                break;
            }
#endif
            default: {
                printf("You have reached an invalid menu option (%02x)\n", cmd);
                printf("Please press 'h' to see the valid options for this "
                       "design\n");
            }
            } // switch cmd[0]
        } // cmd != NULL
    }

    return 1; // hal.enable_exit is enabled; will spin forever on "exit"
}
