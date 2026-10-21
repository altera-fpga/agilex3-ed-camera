# 4Kp30 Camera Lite System Example Design for Agilex™ Devices

The 4Kp30 Camera Lite Example Design for Agilex® Devices demonstrates a practical, area-efficient, and cost-efficient glass-to-glass camera system solution. Support for the industry-standard Mobile Industry Processor Interface (MIPI) D-PHY and MIPI CSI-2 interfaces on Agilex® FPGAs provides a powerful platform for camera product development.

## Description

The design is a hardware and software co-design: The hardware path includes a sensor feeding an Image Signal Processing (ISP) subsystem. The ISP subsystem is a video processing pipeline that incorporates VVP IP cores to convert raw sensor image data into RGB video data. The design drives the resulting 4Kp30 streaming video output through an Altera® DisplayPort IP. The software stack is a bare-metal application that runs on an embedded Nios® V soft processor. The backend of the software application interrogates the hardware, discovers the IP components dynamically, and configures them. Multiple feedback loops monitor the hardware and keep components in lockstep—for example, DisplayPort Hot Plug Detect (HPD). The frontend of the software creates a terminal-based user interface and runs it over a JTAG UART.

## Project Details

- **Title**: 4Kp30 Camera Lite System Example Design for Agilex™ Devices
- **Source**: Github
- **Family**: Agilex 3
- **Quartus Version**: 26.1.1
- **Development Kit**: Agilex® 3 FPGA and SoC C-Series Development Kit DK-A3W135BM16AEA
- **Device Part**: A3CW135BM16AE6S
- **Design Package**: agilex3c_a3w135b-dk_4k-isp-lite-ed.zip
- **Category**: Video/Vision
- **URL**: https://github.com/altera-fpga/agilex3-ed-camera/tree/rel/26.1.1/agilex3c-ed/a3w135b-dk/4k-isp-lite-ed
- **download URL**: https://github.com/altera-fpga/agilex3-ed-camera/releases/download/rel-26.1.1/agilex3c_a3w135b-dk_4k-isp-lite-ed.zip

---

## Documentation

- **Title**: User Guide
- **URL**: https://github.com/altera-fpga/agilex3-ed-camera/blob/rel/26.1.1/agilex3c-ed/a3w135b-dk/4k-isp-lite-ed/docs/doc-camera-lite.md

---

## Repository Overview

The repository contains the necessary files and collateral to create and build
the 4Kp30 Camera Lite System Example Design for Agilex™ Devices.

The product of this repository is generated using a software and
hardware flow, and it is listed in the following table:

| Product | Type | Description |
|----|----|----|
| `.sof` | SRAM Object File | FPGA bitstream to be loaded over JTAG |

---

## Quick Start

1. Download the example design from the repository listed in the following table.

| Component | Location | Branch / Tag |
|-----------|----------|--------------|
| Agilex® 3 Assets release tag | [rel-26.1.1](https://github.com/altera-fpga/agilex3-ed-camera/releases/tag/rel-26.1.1) | `rel-26.1.1` |

2. Extract the package.

3. Confirm that the FPGA design files are in `src/vds/`, `src/rtl/`, and `src/ip/`.

4. Confirm that the software files are in `src/sw/`.

   The example design directory structure is as follows:

```text
<Example Design>/
├── top.qpf                  # Quartus project file
├── top.qsf                  # Quartus settings file
├── README.md                # Repository readme
├── docs/                    # User guide for this example design
├── output_files/            # Precompiled SOF
├── scripts/                 # Scripts used to generate the example design
└── src/
    ├── custom_ip/           # Non-QPDS IP
    ├── ip/                  # .ip files
    ├── rtl/                 # RTL files
    ├── sdc/                 # SDC files
    ├── sw/                  # Bare-metal software application
    └── vds/                 # Tcl to generate the Visual Designer Studio (VDS) project
```

5. Launch the Quartus® Prime Pro Edition software.

6. Open `<Example Design>/top.qpf`.

7. On the **Processing** menu, click **Start Compilation**.

8. Wait until compilation completes.

After a successful compilation, the Quartus® Prime software generates the programming file in the `<Example Design>/output_files/` directory:

* `top.sof`

---

## Recompiling the Nios® V Software Application

To rebuild the Nios® V software application and merge it into the .sof, type the following commands:

```bash
cd <Example Design>/scripts/
quartus_sh -t post_swapp_gen.tcl
```

The script compiles the Nios® V application, merges the generated hexadecimal (HEX) ROM into the project, and generates an updated `top.sof` that contains the latest software.

---




