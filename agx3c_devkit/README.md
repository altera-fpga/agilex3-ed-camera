# **4Kp30 Camera Lite Example Design for Agilex™ 3 Devices**

## Overview

This project contains the necessary files and collaterals to create and build
the 4Kp30 Camera Lite Example Design for Agilex™ 3 Devices.

The generated product of this project is listed as follows:

| Product | Type | Description |
|----|----|----|
| `.sof` | SRAM Object File | FPGA bitstream to be loadeded over JTAG |

<br>

## License Requirements

The System Example Design supports the OpenCore Plus (OCP) evaluation license.

The resulting `.sof` can be tested on Hardware using both the time limited and
JTAG tethered features of the license.

Alternatively, a full license for the VVP IP Suite is required to produce a `.sof`
for a Hardware turnkey solution.

Note that for all cases, free licenses for MIPI D-Phy IP, MIPI CSI-2 IP, and
Nios® V Processor must be downloaded and installed.

Additional licensing information can be found here:

* [VVP IP Suite](https://www.altera.com/products/ip/a1jui000004qxfpmak/video-and-vision-processing-suite)
* [MIPI IP](https://www.altera.com/products/ip/a1jui0000049uuamam/mipi-d-phy-ip#tab-blade-1-3)
* [Nios® V Processor](https://www.altera.com/products/ip/a1jui0000049uvama2/nios-v-processors)

<br>

## **Features and Specifications**

The 4Kp30 Camera Lite Example Design provides:

* Support for the following Input and Output video interfaces
  * Input: MIPI CSI-2
  * Output: DisplayPort 1.4

* Support for the following sensor:
  * Raspberry PI HQ IMX477

* Support for the following progressive video resolutions on the input and output interfaces:
  * Fixed: 3840x2160 30Hz (4K30p)

* A video pipeline subsystem with:
  * 12-bit support for raw data from the sensor up to the Demosaic IP.
  * 10-bit support for RGB for video processing.
  * VVP ISP IP cores included: Black Level Correction, White Balance Correction, Demosaic, Color Correction Matrix and 1D LUT.
  * Video Frame Buffer
  * Support for an input video switch:
    * 2 inputs and 1 output
    * Input ports receive the data from Sensor and a TPG
    * The selected input data is broadcast to the ISP-Lite video pipeline
  * Support for an output video mixer:
    * Icon Generator
    * Input video stream
    * TPG

<br>

## Hardware Requirements

* [Agilex™ 3 FPGA and SoC C-Series Development Kit](https://www.altera.com/products/devkit/a1jui000006ty5dmae/agilex-3-fpga-and-soc-c-series-development-kit) or [Agilex™ 3 FPGA C-Series Development Kit](https://www.altera.com/products/devkit/a1jui000006own7mai/agilex-3-fpga-c-series-development-kit)
* [Raspberry Pi High Quality Camera with C/CS mount](https://www.raspberrypi.com/products/raspberry-pi-high-quality-camera/)
* [Wide-angle lens](https://thepihut.com/products/ultra-wide-angle-c-mount-lens-for-raspberry-pi-hq-camera-3-2mm-focal-length)
* [Tripod](https://thepihut.com/products/small-tripod-for-raspberry-pi-hq-camera)
* [15-> 22 pin flat mipi cable 20cm](https://thepihut.com/products/camera-adapter-cable-for-raspberry-pi-5)
* DP cable or HDMI Cable with a [4KP60 converter dongle](https://www.amazon.co.uk/gp/product/B01M6WK3KU/ref=ppx_yo_dt_b_asin_title_o02_s00?ie=UTF8&th=1)
* USB-C JTAG Cable.
* 4K Monitor/TV.

<br>


## Software Requirements

* [Altera® Quartus® Prime Pro version (25.3)](https://www.altera.com/downloads/fpga-development-tools/quartus-prime-pro-edition-design-software-version-25-3-linux).
  * Including open-source tools to compile software targeting NiosV soft-processors
* Device Support for Agilex™ 3 C-Series.
* [FPGA NiosV/g Open-Source Tools 25.3](https://www.altera.com/design/guidance/nios-v-developer).

<br>

## Hardware Flow

The Hardware flow to create and build the Quartus® project for
the 4Kp30 Camera Lite Solution System Example Design, uses the Modular Design Toolkit (MDT) .

* [Modular Design Toolkit](https://github.com/altera-fpga/modular-design-toolkit)

<br>

## Creating the Design using the Modular Design Toolkit (MDT)

Follow the next steps to create the Quartus® and Platform Designer Project for
the 4Kp30 Camera Lite Solution System Example Design:

* Currently, there are available two design description files, provided in a XML format:
  * `AGX_3C_SoC_Devkit_ISP_Lite.xml` for [Agilex™ 3 FPGA and SoC C-Series Development Kit]
    * Device Part Number: A3CW135BM16AE6S
  * `AGX_3C_FPGA_Devkit_ISP_Lite.xml` for [Agilex™ 3 FPGA C-Series Development Kit]
    * Device Part Number: A3CY135BM16AE6S

* Create your workspace and clone the repository using `--recurse-submodules`:

```bash
cd <workspace>
git clone -b rel-25.3 --recurse-submodules https://github.com/altera-fpga/agilex3-ed-camera.git agilex3-ed-camera
```

* Define a `<project>` location of your choice, creating a directory structure where necessary.

* Navigate to the `agilex3-ed-camera/agx3c_devkit` directory containing the cloned repository and create your project, selecting the XML variant for the project.

```bash
cd agilex3-ed-camera/agx3c_devkit/designs
quartus_sh -t ../modular-design-toolkit/scripts/create/create_shell.tcl -xml_path ./AGX_3C_SoC_Devkit_ISP_Lite.xml -proj_path <project> -o
```

* The previous command will create your Quartus® Prime and Platform Designer Project in `<project>`,
with a folder structure that is consistent with the MDT methodology.

* The following table provides a brief explanation regarding the content of each of the top-level folders:

    | Directory     | Description  |
    | --------------| ---- |
    | non_qpds_ip   | Contains the source code (RTL) of the design’s custom IP that is not part of Quartus® Prime. |
    | quartus       | Contains the base files for the Quartus® Project including the top.qpf, top.qsf. |
    | rtl           | Contains the sources files to build the project. |
    | scripts       | Contains a collection of TCL scripts from "Modular Design Toolkit" to build and compile the design software and hardware. |
    | sdc           | Contains the .sdc files for the subsystems to compile the project. |
    | software      | Contains all the files for building the application for the Nios® V. |

    </center>

<br>

## Building the Design using the Modular Design Toolkit (MDT)

Follow the next steps to build and generate the SOF file for the 4Kp30 Camera Lite Solution System Example Design:

* Navigate to the `<project>/scripts` directory and build your project:

```bash
quartus_sh -t build_shell.tcl -full_compile
```

* The `-full_compile` MDT build option performs not just the full Quartus® compilation, but also
compiles any Nios® V software, and merges it into the `.hex` ROM file built into the project
during compilation.

* Wait for the compilation to finish.

* The generated FPGA programming file is located in the `<project>/quartus/output_files` directory:
  * `top.sof`

* In case you need to recompile the Nios® V SW App, please follow the additional steps:

  * The design includes an initial version of `settings.bsp` that contains parameters
    to run the design. If you modify the Platform Designer's hardware, ensure you keep
    the integrity of the `settings.bsp` file fully synchronized with the Plaform Designer project, i.e. `top_qsys.qsys`.

  * Compile the software application and merge the SOF file with the newly generated `HEX` file
    with the following command:

    ```bash
      cd <project>/scripts/
      quartus_sh -t build_shell.tcl -update_sof
    ```

  * The `-update_sof` MDT build option compiles the Nios® V software and merges it into the `.hex` ROM file built into the project,
    generating a new `top.sof` file with the latest SW App updates.

<br>

## Resources

Full documentation for this Camera Solution System Example Design can be found
on the [Altera® FPGA Developer Site](https://altera-fpga.github.io/rel-25.3/embedded-designs/agilex-3/c-series/camera/camera_lite_4k30/camera_4k/).



