# MIPI CSI-2 Camera to DSI-2 Display Example Design for Agilex® 5 Devices

This example design demonstrates a complete Mobile Industry Processor Interface (MIPI) Camera
Serial Interface 2 (CSI-2) Rx to Display Serial Interface 2 (DSI-2) system, with a lightweight
image sensor processing (ISP) pipeline, using Altera® MIPI IP.

## Description

This project extends the [*4Kp30 Camera Lite Example Design for Agilex® 5 Devices*](https://github.com/altera-fpga/agilex3-ed-camera/tree/rel/26.1.1/agilex5e-ed/a5e013b-dk/4k-isp-lite-ed/) with
an additional MIPI-2 + D-PHY output. The CSI-2 Rx camera stream is duplicated into this
secondary output.

The main ISP pipeline, from the CSI-2 input to the DisplayPort 1.4 output, runs at a fixed 3840x2160 @30Hz.
The DSI-2 output duplicates the stream, downscales, and increases the refresh rate to 1280x800 @60Hz.
The DSI subsystem is setup in "Non-burst with sync pulses" mode with non-continuous clock.

## Project Details

- **Title**: MIPI CSI-2 Camera to DSI-2 Display Example Design for Agilex® 5 Devices
- **Source**: GitHub
- **Family**: Agilex 5
- **Quartus Version**: 26.1.1
- **Development Kit**: Agilex® 5 FPGA E-Series 013B Development Kit DK-A5E013BM16AEA
- **Device Part**: A5ED013BM16AE4SCS 
- **URL**: https://github.com/altera-fpga/agilex3-ed-camera/tree/rel/26.1.1/agilex5e-ed/a5e013b-dk/4k-csi-dsi-ed
- **Download URL**: https://github.com/altera-fpga/agilex3-ed-camera/releases/download/rel-26.1.1/agilex5e_a5e013b-dk_4k-csi-dsi-ed.zip

## Documentation

* **Title**: User Guide
* **URL**: [docs/index.md][docs-link]

## Quick Start

1) Clone the repository or download the project as a zip archive [here](https://github.com/altera-fpga/agilex3-ed-camera/releases/download/rel-26.1.1/agilex5e_a5e013b-dk_4k-csi-dsi-ed.zip).
2) Open the project (`top.qpf`) in Quartus, and click "Start Compilation".
3) To program the board, use the generated bitstream .sof file at `output_files/top.sof`.

A precompiled .sof can be found [here](https://github.com/altera-fpga/agilex3-ed-camera/releases/download/rel-26.1.1/agilex5_golden_4k_csi_dsi_ed.sof).

Refer to the [docs][docs-link] for full details.

[docs-link]: https://github.com/altera-fpga/agilex3-ed-camera/blob/rel/26.1.1/agilex5e-ed/a5e013b-dk/4k-csi-dsi-ed/docs/index.md