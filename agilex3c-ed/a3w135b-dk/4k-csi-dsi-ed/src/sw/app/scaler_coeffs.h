#ifndef __SCALER_COEFFS_H
#define __SCALER_COEFFS_H

#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

#include <io.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <system.h>

#define PI 3.14159265

int get_required_lobes(int in_size, int out_size, int taps);

int get_active_taps(int in_size, int out_size, int lobes, int taps);

float lanczos(float x, float lobes);

void generate_lanczos_coefficients(int **coeffs, int taps, int phases, int lobes,
                                   int frac_bits);

void load_coefficients(int scaler_base_address, int **coeffs, int taps, int phases,
                       int bank, int active_taps, int is_horizontal);

void scaler_create_and_load_horizontal_coefficents(int scaler_base_address, int taps,
                                                   int phases, int frac_bits,
                                                   int in_width, int out_width, int bank);

void scaler_create_and_load_vertical_coefficents(int scaler_base_address, int taps,
                                                 int phases, int frac_bits, int in_width,
                                                 int out_width, int bank);

#ifdef __cplusplus
}
#endif /* __cplusplus */

#endif /* __SCALER_COEFFS_H */
