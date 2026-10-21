#include "dsi_csr.h"
#include "io.h"
#include <stdbool.h>
#include <stdint.h>

const static uint32_t REG_CVO_STATUS = 0x540;

const static uint32_t REG_COMMIT = 0x644;
const static uint32_t REG_RESET_POS = 0x64c;
const static uint32_t REG_TOTALS = 0x650;
const static uint32_t REG_HB_END = 0x654;
const static uint32_t REG_V1B_POS = 0x658;
const static uint32_t REG_V2B_POS = 0x65C;
const static uint32_t REG_FIELD_STARTS = 0x660;
const static uint32_t REG_HS_POS = 0x664;
const static uint32_t REG_V1S_START = 0x668;
const static uint32_t REG_V1S_END = 0x66C;
const static uint32_t REG_V2S_START = 0x670;
const static uint32_t REG_V2S_END = 0x674;

dsi_csr_vtiming_std_t dsi_csr_get_vtiming_std() {
    dsi_csr_vtiming_std_t std;

    uint32_t regval;

    regval = IORD_32DIRECT(base_addr, REG_RESET_POS);
    std.hreset = regval & 0xFFFF;
    std.vreset = (regval >> 16) & 0xFFFF;

    regval = IORD_32DIRECT(base_addr, REG_TOTALS);
    std.htotal = regval & 0xFFFF;
    std.vtotal = (regval >> 16) & 0xFFFF;

    regval = IORD_32DIRECT(base_addr, REG_HB_END);
    std.hb_end = regval & 0xFFFF;

    regval = IORD_32DIRECT(base_addr, REG_V1B_POS);
    std.v1b_start = regval & 0xFFFF;
    std.v1b_end = (regval >> 16) & 0xFFFF;

    regval = IORD_32DIRECT(base_addr, REG_V2B_POS);
    std.v2b_start = regval & 0xFFFF;
    std.v2b_end = (regval >> 16) & 0xFFFF;

    regval = IORD_32DIRECT(base_addr, REG_FIELD_STARTS);
    std.f1_start = regval & 0xFFFF;
    std.f2_start = (regval >> 16) & 0xFFFF;

    regval = IORD_32DIRECT(base_addr, REG_HS_POS);
    std.hs_start = regval & 0xFFFF;
    std.hs_end = (regval >> 16) & 0xFFFF;

    regval = IORD_32DIRECT(base_addr, REG_V1S_START);
    std.v1s_hstart = regval & 0xFFFF;
    std.v1s_vstart = (regval >> 16) & 0xFFFF;

    regval = IORD_32DIRECT(base_addr, REG_V1S_END);
    std.v1s_hend = regval & 0xFFFF;
    std.v1s_vend = (regval >> 16) & 0xFFFF;

    regval = IORD_32DIRECT(base_addr, REG_V2S_START);
    std.v2s_hstart = regval & 0xFFFF;
    std.v2s_vstart = (regval >> 16) & 0xFFFF;

    regval = IORD_32DIRECT(base_addr, REG_V2S_END);
    std.v2s_hend = regval & 0xFFFF;
    std.v2s_vend = (regval >> 16) & 0xFFFF;
    return std;
}

int dsi_csr_set_vtiming_std(dsi_csr_vtiming_std_t std) {
    uint32_t regval;

    regval = std.hreset;
    regval |= (std.vreset << 16);
    IOWR_32DIRECT(base_addr, REG_RESET_POS, regval);

    regval = std.htotal;
    regval |= std.vtotal << 16;
    IOWR_32DIRECT(base_addr, REG_TOTALS, regval);

    regval = std.hb_end;
    IOWR_32DIRECT(base_addr, REG_HB_END, regval);

    regval = std.v1b_start;
    regval |= std.v1b_end << 16;
    IOWR_32DIRECT(base_addr, REG_V1B_POS, regval);

    regval = std.v2b_start;
    regval |= std.v2b_end << 16;
    IOWR_32DIRECT(base_addr, REG_V2B_POS, regval);

    regval = std.f1_start;
    regval |= std.f2_start << 16;
    IOWR_32DIRECT(base_addr, REG_FIELD_STARTS, regval);

    regval = std.hs_start;
    regval |= std.hs_end << 16;
    IOWR_32DIRECT(base_addr, REG_HS_POS, regval);

    regval = std.v1s_hstart;
    regval |= std.v1s_vstart << 16;
    IOWR_32DIRECT(base_addr, REG_V1S_START, regval);

    regval = std.v1s_hend;
    regval |= std.v1s_vend << 16;
    IOWR_32DIRECT(base_addr, REG_V1S_END, regval);

    regval = std.v2s_hstart;
    regval |= std.v2s_vstart << 16;
    IOWR_32DIRECT(base_addr, REG_V2S_START, regval);

    regval = std.v2s_hend;
    regval |= std.v2s_vend << 16;
    IOWR_32DIRECT(base_addr, REG_V2S_END, regval);

    IOWR_32DIRECT(base_addr, REG_COMMIT, 1);

    return 0;
}

bool dsi_csr_cvo_is_locked() {
    uint32_t regval = IORD_32DIRECT(base_addr, REG_CVO_STATUS);
    return regval & 0x1;
}
