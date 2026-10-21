#!/usr/bin/env quartus_py

# (C) 2001-2026 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions and other
# software and tools, and its AMPP partner logic functions, and any output
# files from any of the foregoing (including device programming or simulation
# files), and any associated documentation or information are expressly subject
# to the terms and conditions of the Altera Program License Subscription
# Agreement, Altera IP License Agreement, or other applicable
# license agreement, including, without limitation, that your use is for the
# sole purpose of programming logic devices manufactured by Altera and sold by
# Altera or its authorized distributors.  Please refer to the applicable
# agreement for further details.

"""
build_niosv_sw.py

Compiles the software that is loaded onto the Nios V.

IMPORTANT: This design ships with the software program precompiled. This
           script should only be used if you wish to modify the design.

IMPORTANT: It is recommended, but not necessary, to run this script from within
           a niosv-shell, to guarantee Nios V command-line tools and the GNU
           toolchain for RISC-V are available on PATH.

Outputs the compiled gen/sw/build/app.elf file and its corresponding .hex
file (at gen/sw/build/niosv_subsystem_cpu_ram.hex). The script will
automatically copy this into src/sw/mem_init/niosv_subsystem_cpu_ram.hex
which is used as the initialization file for main memory.

You may use `niosv-download -r -g gen/sw/build/app.elf` to quickly reload
the software at runtime (i.e. after the device is programmed). If you wish
to alter the .sof instead, use the --update_sof argument.

If no arguments are provided, and the software project already exists, then
this results in a single call to make, for fast incremental compilation.

Arguments:
    --clean        Performs a clean build of the software project, including
                   BSP and cmake configuration.

    --update_sof   Update the .sof file, after generating the .hex file.
                   Fails if project compilation has not reached the
                   assembler stage yet.
"""

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

# Check that we are using the built-in "quartus_py" interpreter
python_interpreter = sys.executable
if (not (python_interpreter.endswith("quartus_py.exe"))) & (
    not (python_interpreter.endswith("quartus_py"))
):
    print(
        f'[ERROR]: Invalid python interpreter, please use "quartus_py". {python_interpreter}'
    )
    sys.exit(1)

# *****************************************************************************
# Project config
# *****************************************************************************

ELF_NAME = "app.elf"
HEX_NAME = "niosv_subsystem_cpu_ram.hex"

# *****************************************************************************
# Constants
# *****************************************************************************

PROJECT_DIR = Path(__file__).resolve().parent.parent

SOFTWARE_PATH = PROJECT_DIR / "src" / "sw"
BUILD_DIR = PROJECT_DIR / "gen" / "sw" / "build"
BSP_DIR = PROJECT_DIR / "gen" / "sw" / "bsp"
CMAKELISTS_DIR = PROJECT_DIR / "gen" / "sw" / "app"

ELF_FILE = BUILD_DIR / ELF_NAME
HEX_FILE = BUILD_DIR / HEX_NAME
MEM_INIT_FILE = SOFTWARE_PATH / "mem_init" / HEX_NAME

APP_SRC_DIR = SOFTWARE_PATH / "app"
TX_LIB_SRC_DIR = APP_SRC_DIR / "btc_dptx_syslib"
TXLL_LIB_SRC_DIR = APP_SRC_DIR / "btc_dptxll_syslib"

# BSP Directory
BSP_SETTINGS_FILE = BSP_DIR / "settings.bsp"
BSP_SCRIPT = SOFTWARE_PATH / "bsp_commands.tcl"

PROJECT_FILE = PROJECT_DIR / "top.qpf"

VDS_SYSTEM_FILE = PROJECT_DIR / "src" / "vds" / "top_subsystem" / "top_subsystem.vds"


# Main function
def build_software(clean: bool):
    # Select the required libraries

    regen_bsp = not BSP_DIR.is_dir() or clean
    regen_cmake_project = not BUILD_DIR.is_dir() or regen_bsp or clean

    # Generate BSP config files
    if regen_bsp:
        print("[INFO ]: Create BSP + App")

        if BSP_DIR.is_dir():
            shutil.rmtree(BSP_DIR)

        bsp_create_cmd = [
            "niosv-bsp",
            "-c",
            f"-p={PROJECT_FILE}",
            f"-s={VDS_SYSTEM_FILE}",
            "-t=hal",
            f"-x={BSP_SCRIPT}",
            str(BSP_SETTINGS_FILE),
        ]

        subprocess.run(bsp_create_cmd, check=True)

        bsp_gen_cmd = [
            "niosv-bsp",
            "-g",
            f"--bsp_dir={BSP_DIR}",
            str(BSP_SETTINGS_FILE),
        ]

        subprocess.run(bsp_gen_cmd, check=True)

    else:
        print("[INFO ]: Re-using BSP")

    if regen_cmake_project:
        print("[INFO ]: Create Application")

        if BUILD_DIR.is_dir():
            shutil.rmtree(BUILD_DIR)

        srcs_dirs = [APP_SRC_DIR]

        incs_dirs = [
            APP_SRC_DIR / "btc_dptx_syslib",
            APP_SRC_DIR / "btc_dptxll_syslib",
            APP_SRC_DIR,
        ]

        libs_dirs = [
            APP_SRC_DIR / "btc_dptx_syslib/release/btc_dptx_syslib",
            APP_SRC_DIR / "btc_dptxll_syslib/release/btc_dptxll_syslib",
        ]

        app_cmd = [
            "niosv-app",
            f"-a={CMAKELISTS_DIR}",
            f"--bsp-dir={BSP_DIR}",
            f"--srcs={','.join([str(x) for x in srcs_dirs])}",
            f"--incs={','.join([str(x) for x in incs_dirs])}",
            f"-e={ELF_NAME}",
        ]

        app_cmd.extend([f"--link-lib={l}" for l in libs_dirs])

        subprocess.run(app_cmd, check=True)

        cmake_config_cmd = [
            "cmake",
            "-S",
            str(CMAKELISTS_DIR),
            "-B",
            str(BUILD_DIR),
            "-G",
            "Unix Makefiles",
            "-DCMAKE_BUILD_TYPE=RelWithDebInfo",
            "-DCMAKE_EXPORT_COMPILE_COMMANDS=on",
            "--fresh",
        ]

        subprocess.run(cmake_config_cmd, check=True)

    cmake_build_cmd = ["make"]

    subprocess.run(cmake_build_cmd, cwd=BUILD_DIR, check=True)

    shutil.copy(HEX_FILE, MEM_INIT_FILE)

    print("[INFO ]: Done software build")


def create_dotfiles():
    """Create .clangd and .clang-format files for developer convenience"""
    dot_clang_format_file = PROJECT_DIR / ".clang-format"
    if not dot_clang_format_file.exists():
        dot_clang_format_file.write_text(
            "BasedOnStyle: LLVM\nColumnLimit: 80\nIndentWidth: 4\nTabWidth: 4\n"
        )

    dot_clangd_file = PROJECT_DIR / ".clangd"
    if not dot_clangd_file.exists():
        dot_clangd_file.write_text(
            "CompileFlags:\n  CompilationDatabase: gen/sw/build\n"
        )


if __name__ == "__main__":

    class _NoOptionsHelpFormatter(argparse.RawDescriptionHelpFormatter):
        def add_arguments(self, actions):
            return

    parser = argparse.ArgumentParser(
        prog=f"quartus_py {Path(__file__).name}",
        description=__doc__,
        formatter_class=_NoOptionsHelpFormatter,
    )

    parser.add_argument("--clean", action="store_true")

    parser.add_argument("--update_sof", action="store_true")

    args = parser.parse_args()

    create_dotfiles()

    build_software(args.clean)

    if args.update_sof:
        print("[INFO ]: Updating .sof file")
        quartus_cdb_cmd = ["quartus_cdb", "--update_mif", str(PROJECT_FILE)]
        subprocess.run(quartus_cdb_cmd, check=True)

        quartus_asm_cmd = ["quartus_asm", str(PROJECT_FILE)]
        subprocess.run(quartus_asm_cmd, check=True)
