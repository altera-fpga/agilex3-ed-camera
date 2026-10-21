// senpanelsor control code
#include <stdio.h>
#include <unistd.h>

#include "alt_types.h"
#include "altera_avalon_i2c.h"

#include "panel_ctrl.h"

// waveshare panel constants
#define WS23448_I2C_ADDR (0x45)
#define WS23448_I2C_REGADDR_LEN (1)
#define WS23448_I2C_REGDATA_LEN (1)

// waveshare panel register addresses
#define WS23448_I2C_REG_DEV_EN (0xAD)
#define WS23448_I2C_REG_BACKLIGHT (0xAB)
#define WS23448_I2C_REG_COMMIT (0xAA)

typedef struct {
    alt_u8 addr;
    alt_u8 data;
} reg_8bit;

// register initialisation
static const reg_8bit ws23448_regs_init[] = {{0xc0, 0x01}, {0xc2, 0x01}, {0xac, 0x01}};

// pointer to i2c device
static ALT_AVALON_I2C_DEV_t *i2c_dev;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// private functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
// panel I2C read
static int panel_i2c_read(alt_u8 reg_addr, alt_u8 *reg_data, int read_len) {
    if (!i2c_dev || !reg_data)
        return 1;

    uint8_t local_reg_addr[1] = {reg_addr};

    /*
     * Lightweight copy of alt_avalon_i2c_master_tx_rx, with far fewer retries
     */
    ALT_AVALON_I2C_STATUS_CODE status;

    uint32_t retries = 10;

    while (retries--) {

        if (retries <= 3) {
            usleep(1000);
        }

        status = alt_avalon_i2c_master_transmit(i2c_dev, local_reg_addr, 1,
                                                ALT_AVALON_I2C_NO_RESTART,
                                                ALT_AVALON_I2C_NO_STOP);

        if (status != ALT_AVALON_I2C_SUCCESS)
            continue;

        status = alt_avalon_i2c_master_receive(
            i2c_dev, reg_data, read_len, ALT_AVALON_I2C_RESTART, ALT_AVALON_I2C_STOP);

        if (status != ALT_AVALON_I2C_SUCCESS)
            continue;

        break;
    }

    if (status != ALT_AVALON_I2C_SUCCESS) {
        printf("Error: Panel I2C read: 0x%02x:%02x FAILED\n", WS23448_I2C_ADDR, reg_addr);
        return 1;
    }

    return 0;
}

////////////////////////////////////////////////////////////////
// panel I2C write
static int panel_alt_write(alt_u8 reg_addr, alt_u8 reg_data) {
    alt_u8 tx_buf[WS23448_I2C_REGADDR_LEN + WS23448_I2C_REGDATA_LEN];
    int status;

    if (!i2c_dev)
        return 1;

    tx_buf[0] = reg_addr;
    tx_buf[1] = reg_data;

    status = alt_avalon_i2c_master_tx(i2c_dev, tx_buf,
                                      WS23448_I2C_REGADDR_LEN + WS23448_I2C_REGDATA_LEN,
                                      ALT_AVALON_I2C_NO_INTERRUPTS);
    if (status != ALT_AVALON_I2C_SUCCESS) {
        printf("Error: Panel I2C write: 0x%02x:%02x:%02x FAILED\n", WS23448_I2C_ADDR,
               reg_addr, reg_data);
        return 1;
    }
    return 0;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// public functions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////
// open I2C device and check I2C comms to panel
int panel_i2c_init(const char i2c_dev_name[]) {
    alt_u8 data;

    // open I2C device
    i2c_dev = alt_avalon_i2c_open(i2c_dev_name);
    if (i2c_dev == NULL) {
        printf("Error: Cannot find I2C controller '%s' in BSP - check VDS/PD"
               "system connectivity.\n",
               i2c_dev_name);
        return 1;
    }

    // set I2C device address
    alt_avalon_i2c_master_target_set(i2c_dev, WS23448_I2C_ADDR);

    // read panel ID register to check comms are working
    if (panel_i2c_read(WS23448_I2C_REG_DEV_EN, &data, 1)) {
        printf("Error: Failed to communicate with panel - check connection.\n");
        return 1;
    }
    printf("Panel detected.\n");
    return 0;
}

// Call after i2c_init
int panel_init() {
    int errs = 0;
    int reg_count = sizeof(ws23448_regs_init) / sizeof(reg_8bit);

    printf("Configuring panel - Waveshare WS23448 1280x800...\n");

    // write register table to panel
    for (int i = 0; i < reg_count; i++) {
        errs += panel_alt_write(ws23448_regs_init[i].addr, ws23448_regs_init[i].data);
    }
    if (errs) {
        printf("Panel initialisation failed (%d of %d register writes failed).\n", errs,
               reg_count);
        return 1;
    }
    printf("Panel initialisation complete. Note: not enabled yet.\n");
    return 0;
}

// Call after MIPI DSI switches to HS - DSI-2 IP requests HS after
// video stream active
int panel_enable(int backlight_level) {
    alt_u8 bl_reg;

    if (backlight_level > 255 || backlight_level < 0)
        bl_reg = 0;
    else
        bl_reg = 255 - backlight_level;

    if (panel_alt_write(0xad, 0x01)) {
        printf("Error: Failed to enable panel!\n");
        return 1;
    }

    if (panel_alt_write(WS23448_I2C_REG_BACKLIGHT, bl_reg) ||
        panel_alt_write(WS23448_I2C_REG_COMMIT, 0x01)) {
        printf("Error: Failed to enable backlight!");
        return 1;
    }

    printf("Panel enabled. Backlight set to %d%%\n",
           (int)((backlight_level * 100.0f + 128) / 255));

    return 0;
}
