# ISP-based Camera Lite Solution System Example Designs for Agilex® Devices

## Overview

This repository contains projects demonstrating how to create and build
ISP-based Camera Lite Solution Example Designs, using Altera®'s [Video and Vision Processing (VVP) Suite IP cores](https://www.altera.com/products/ip/po-3150/video-and-vision-processing-suite),
and targetting [Altera® Agilex® devices](https://www.altera.com/fpga).

The projects are stored in individual folders, classified by device families and target devkits.

---

## 4Kp30 Camera Lite Solution System Example Design

| | |
|---|---|
| **Target device family** | [Agilex® 3](https://www.altera.com/products/fpga/agilex/3) and [Agilex® 5E](https://www.altera.com/products/fpga/agilex/5/e-series) |
| **Development kit** | [Agilex® 3 FPGA and SoC C-Series Development Kit](https://www.altera.com/products/devkit/po-3000/agilex-3-fpga-and-soc-c-series-development-kit) and [Agilex® 5 FPGA E-Series 013B Development Kit](https://www.altera.com/products/devkit/po-3196/agilex-5-fpga-e-series-013b-development-kit) |
| **Control plane** | [Nios® V Processor](https://www.altera.com/products/ip/po-3098/nios-v-processors) with a bare-metal software application |
| **Precompiled SOF** | [Agilex® 3_Version_26.1.1](https://github.com/altera-fpga/agilex3-ed-camera/releases/download/rel-26.1.1/agilex3_golden_4k_isp_lite_ed.sof), [Agilex® 5_Version_26.1.1](https://github.com/altera-fpga/agilex3-ed-camera/releases/download/rel-26.1.1/agilex5_golden_4k_isp_lite_ed.sof), [Agilex® 3 Version_25.3](https://github.com/altera-fpga/agilex3-ed-camera/releases/download/rel-25.3/golden_agx3c_soc_devkit_isp_lite_top.sof) |
| **Quartus Project** | [Agilex® 3_Version_26.1.1](https://github.com/altera-fpga/agilex3-ed-camera/releases/download/rel-26.1.1/agilex3c_a3w135b-dk_4k-isp-lite-ed.zip), [Agilex® 5_Version_26.1.1](https://github.com/altera-fpga/agilex3-ed-camera/releases/download/rel-26.1.1/agilex5e_a5e013b-dk_4k-isp-lite-ed.zip), [Agilex® 3 Version_25.3](https://github.com/altera-fpga/agilex3-ed-camera/releases/download/rel-25.3/agx3c_devkit_4k30_isp_lite_ed.zip) |
| **Source Code** | [Agilex® 3 Version_26.1.1](https://github.com/altera-fpga/agilex3-ed-camera/tree/rel/26.1.1/agilex3c-ed/a3w135b-dk/4k-isp-lite-ed) [Agilex® 5 Version_26.1.1](https://github.com/altera-fpga/agilex3-ed-camera/tree/rel/26.1.1/agilex5e-ed/a5e013b-dk/4k-isp-lite-ed), [Agilex® 3 Version_25.3](https://github.com/altera-fpga/agilex3-ed-camera/tree/rel/25.3/agx3c_devkit) |
| **User Guide** | [Version_26.1.1](https://github.com/altera-fpga/agilex3-ed-camera/blob/rel/26.1.1/agilex3c-ed/a3w135b-dk/4k-isp-lite-ed/docs/doc-camera-lite.md), [Version_25.3](https://altera-fpga.github.io/rel-25.3/embedded-designs/agilex-3/c-series/camera/camera_lite_4k30/camera_4k/) |

---

## CSI Camera to DSI Display Solution System Example Design

| | |
|---|---|
| **Target device family** | [Agilex® 3](https://www.altera.com/products/fpga/agilex/3) and [Agilex® 5E](https://www.altera.com/products/fpga/agilex/5/e-series) |
| **Development kit** | [Agilex® 3 FPGA and SoC C-Series Development Kit](https://www.altera.com/products/devkit/po-3000/agilex-3-fpga-and-soc-c-series-development-kit) and [Agilex® 5 FPGA E-Series 013B Development Kit](https://www.altera.com/products/devkit/po-3196/agilex-5-fpga-e-series-013b-development-kit) |
| **Control plane** | [Nios® V Processor](https://www.altera.com/products/ip/po-3098/nios-v-processors) with a bare-metal software application |
| **Precompiled SOF** | [Agilex® 3 Version_26.1.1](https://github.com/altera-fpga/agilex3-ed-camera/releases/download/rel-26.1.1/agilex3_golden_4k_csi_dsi_ed.sof) and [Agilex® 5 Version_26.1.1](https://github.com/altera-fpga/agilex3-ed-camera/releases/download/rel-26.1.1/agilex5_golden_4k_csi_dsi_ed.sof) |
| **Quartus Project** | [Agilex® 3 Version_26.1.1](https://github.com/altera-fpga/agilex3-ed-camera/releases/download/rel-26.1.1/agilex3c_a3w135b-dk_4k-csi-dsi-ed.zip) and [Agilex® 5 Version_26.1.1](https://github.com/altera-fpga/agilex3-ed-camera/releases/download/rel-26.1.1/agilex5e_a5e013b-dk_4k-csi-dsi-ed.zip) |
| **Source Code** | [Agilex® 3 Version_26.1.1](https://github.com/altera-fpga/agilex3-ed-camera/tree/rel/26.1.1/agilex3c-ed/a3w135b-dk/4k-csi-dsi-ed) and [Agilex® 5 Version_26.1.1](https://github.com/altera-fpga/agilex3-ed-camera/tree/rel/26.1.1/agilex5e-ed/a5e013b-dk/4k-csi-dsi-ed) |
| **User Guide** | [Agilex® 3 Version_26.1.1](https://github.com/altera-fpga/agilex3-ed-camera/blob/rel/26.1.1/agilex3c-ed/a3w135b-dk/4k-csi-dsi-ed/docs/index.md) and [Agilex® 5 Version_26.1.1](https://github.com/altera-fpga/agilex3-ed-camera/blob/rel/26.1.1/agilex5e-ed/a5e013b-dk/4k-csi-dsi-ed/docs/index.md) |

---






