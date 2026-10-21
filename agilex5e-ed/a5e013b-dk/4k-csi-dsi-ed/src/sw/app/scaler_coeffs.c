#include "scaler_coeffs.h"

int get_required_lobes(int in_size, int out_size, int taps) {
    float float_lobes = (out_size < in_size)
                            ? ((float)(taps * out_size)) / ((float)(2 * in_size))
                            : (float)(taps / 2);
    int lobes = (int)float_lobes;
    lobes = (lobes < 1) ? 1 : (lobes > 2) ? 2 : lobes;
    return lobes;
}

int get_active_taps(int in_size, int out_size, int lobes, int taps) {
    float ideal_taps = (in_size < out_size)
                           ? (float)(2 * lobes)
                           : ((float)(2 * lobes * in_size)) / ((float)out_size);
    int int_taps = (int)ideal_taps;
    if (((float)int_taps) < ideal_taps) {
        int_taps++;
    }
    if (int_taps > taps) {
        return taps;
    } else {
        return int_taps;
    }
}

float lanczos(float x, float lobes) {
    // sinc(0) is explicity defined to be 1
    if (x == 0.0) {
        return 1.0;
    }
    // Outside the lobes is defined to be 0
    else if (!(x <= lobes && x >= -lobes)) {
        return 0.0;
    } else {
        float pi_x = PI * x;
        return (sin(pi_x) / pi_x) * (sin(pi_x / lobes) / (pi_x / lobes));
    }
}

void generate_lanczos_coefficients(int **coeffs, int taps, int phases, int lobes,
                                   int frac_bits) {

    float *raw_coeffs = (float *)malloc(taps * sizeof(float));
    float lanczos_offset_per_tap = 0.0;
    float float_lobes = (float)lobes;
    float float_phases = (float)phases;
    float quant_scaling = (float)(1 << frac_bits);

    // if there is an odd number of taps we center the kernel at floor(taps/2)
    // in phase 0 all taps have no zero coefficients - divide lanczos kernel into taps + 1
    // samples ignore the first and last sample as they will be zero (taken at +/- lobes
    // exactly) if there are even taps we again center at floor(taps/2) in phase 0 the
    // final tap will have coefficient of 0 - divide lanczos kernel into taps samples only
    // ignore the first sample (at -lobes) and use the last sample (at +lobes) to generate
    // the 0 for phase 0
    if ((taps & 0x1) > 0) {
        lanczos_offset_per_tap = ((float)(2 * lobes)) / ((float)(taps + 1));
    } else {
        lanczos_offset_per_tap = ((float)(2 * lobes)) / ((float)taps);
    }

    for (int i = 0; i < phases; i++) {

        // We are going to add this value to move the function left.
        // Generally f(x+1) is to the right of f(x) so phaseOffset counts down
        float phase_offset = (float)i * (lanczos_offset_per_tap / float_phases);
        float total = 0.0;
        for (int j = 0; j < taps; j++) {
            // Move by one tap each time, scaling these taps appropriately
            // to the natural size of the lanczos function (-lobes to lobes)
            float tap_offset = ((float)(j + 1)) * lanczos_offset_per_tap;
            raw_coeffs[j] =
                lanczos(-float_lobes + tap_offset - phase_offset, float_lobes);

            // keeps a running total for normalisation
            total += raw_coeffs[j];
        }

        // normailise the coefficients so they sum to 1, and quantize to frac bits
        float quantization_error = 0.0;
        for (int j = 0; j < taps; j++) {
            raw_coeffs[j] /= total;

            float scaled = raw_coeffs[j] * quant_scaling;
            int rval = (int)scaled;
            quantization_error += scaled - ((float)rval);
            if (quantization_error < -0.5) {
                rval--;
                quantization_error += 1.0;
            } else if (quantization_error > 0.5) {
                rval++;
                quantization_error -= 1.0;
            }
            coeffs[i][j] = rval;
        }
    }

    free(raw_coeffs);
}

void load_coefficients(int scaler_base_address, int **coeffs, int taps, int phases,
                       int bank, int active_taps, int is_horizontal) {
    int taps_offset = ((taps - 1) / 2) - ((active_taps - 1) / 2);
    int scaler_coeff_base = scaler_base_address + 512;

    // set the bank in address 0
    IOWR(scaler_coeff_base, 0, bank);
    // non_active taps set to 0 for all phases
    if (taps_offset > 0) {
        for (int j = 0; j < taps_offset; j++) {
            IOWR(scaler_coeff_base, j + 3, 0);
        }
    }
    if ((taps_offset + active_taps) < taps) {
        for (int j = (taps_offset + active_taps); j < taps; j++) {
            IOWR(scaler_coeff_base, j + 3, 0);
        }
    }
    for (int i = 0; i < phases; i++) {
        // set the phase in address 0
        IOWR(scaler_coeff_base, 1, i);
        // write the coefficient for each active tap
        for (int j = 0; j < active_taps; j++) {
            IOWR(scaler_coeff_base, j + taps_offset + 3, coeffs[i][j]);
        }
        // commit the phase via address 2
        IOWR(scaler_coeff_base, 2, is_horizontal);
    }
}

void scaler_create_and_load_horizontal_coefficents(int scaler_base_address, int taps,
                                                   int phases, int frac_bits,
                                                   int in_width, int out_width,
                                                   int bank) {
    int lobes = get_required_lobes(in_width, out_width, taps);
    int active_taps = get_active_taps(in_width, out_width, lobes, taps);

    int **coeffs = (int **)malloc(phases * sizeof(int *));
    for (int i = 0; i < phases; i++) {
        coeffs[i] = (int *)malloc(active_taps * sizeof(int));
    }

    generate_lanczos_coefficients(coeffs, active_taps, phases, lobes, frac_bits);
    load_coefficients(scaler_base_address, coeffs, taps, phases, bank, active_taps, 1);

    for (int i = 0; i < phases; i++) {
        free(coeffs[i]);
    }
    free(coeffs);
}

void scaler_create_and_load_vertical_coefficents(int scaler_base_address, int taps,
                                                 int phases, int frac_bits, int in_height,
                                                 int out_height, int bank) {
    int lobes = get_required_lobes(in_height, out_height, taps);
    int active_taps = get_active_taps(in_height, out_height, lobes, taps);

    int **coeffs = (int **)malloc(phases * sizeof(int *));
    for (int i = 0; i < phases; i++) {
        coeffs[i] = (int *)malloc(active_taps * sizeof(int));
    }

    generate_lanczos_coefficients(coeffs, active_taps, phases, lobes, frac_bits);
    load_coefficients(scaler_base_address, coeffs, taps, phases, bank, active_taps, 0);

    for (int i = 0; i < phases; i++) {
        free(coeffs[i]);
    }
    free(coeffs);
}
