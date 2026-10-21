#include "system.h"
#include <stdbool.h>
#include <stdint.h>

/*
 * A small set of drivers for controlling the DSI. This is a rough copy
 * of the drivers for standalone intel_vvp_cvo
 *
 * In particular, these provide convienience functions for
 * polling and updating the video timing standard emitted
 * by the embedded CVO/VTiming
 */

// This example design only contains one instance of the DSI; feel free to make
// generic via a driver instance if it suits your needs.
const static uint32_t base_addr = MIPI_DSI2_TX_SUBSYSTEM_MIPI_OUT_MIPI_DSI2_0_BASE;

// Encapsulates the "timing coordinates" expected by the timing generator.
//
// Keep in mind that, for a MIPI connection, your horizontal timing parameters
// should reflect the link rate. Refer to the MIPI DSI-2 User Guide for details
// on how to derive these parameters.
typedef struct dsi_csr_vtiming_std_s {
    uint16_t hreset;     // x-coord of start of frame - typically 0
    uint16_t vreset;     // y-coord of start of frame - typically 0
    uint16_t htotal;     // total width (i.e. including blanking)
    uint16_t vtotal;     // total height (i.e. including blanking)
    uint16_t f1_start;   // starting line of field 0 - typically 0
    uint16_t f2_start;   // starting line of field 1 (interlaced)
    uint16_t hb_end;     // x-coord of first active pixel
    uint16_t v1b_start;  // y-coord of first blanking line
    uint16_t v1b_end;    // y-coord of first active pixel
    uint16_t v2b_start;  // same as v1b_start but for field 2 (interlaced)
    uint16_t v2b_end;    // same as v1b_end but for field 2 (interlaced)
    uint16_t hs_start;   // x-coord of first hsync pixel
    uint16_t hs_end;     // x-coord of pixel AFTER hsync ends
    uint16_t v1s_hstart; // x-coord of first vsync pixel
    uint16_t v1s_vstart; // y-coord of first vsync pixel
    uint16_t v1s_hend;   // x-coord of pixel AFTER last vsync pixel
    uint16_t v1s_vend;   // y-coord of pixel AFTER last vsync pixel
    uint16_t v2s_hstart; // v1s_hstart but for field 2 (interlaced)
    uint16_t v2s_vstart; // v1s_vstart but for field 2 (interlaced)
    uint16_t v2s_hend;   // v1s_hend but for field 2 (interlaced)
    uint16_t v2s_vend;   // v1s_vend but for field 2 (interlaced)
} dsi_csr_vtiming_std_t;

/** Returns a populated dsi_csr_vtiming_std_t */
dsi_csr_vtiming_std_t dsi_csr_get_vtiming_std();

/** Sets then commits the given timing parameters */
int dsi_csr_set_vtiming_std(dsi_csr_vtiming_std_t standard);

/** Returns if the DSI's video input has locked onto the video timing generator */
bool dsi_csr_cvo_is_locked();
