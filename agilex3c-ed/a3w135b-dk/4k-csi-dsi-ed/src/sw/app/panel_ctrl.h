#ifndef PANEL_CTRL_H
#define PANEL_CTRL_H

int panel_i2c_init(const char i2c_dev_name[]);
int panel_init(void);
int panel_enable(int backlight_level);

#endif // PANEL_CTRL_H
