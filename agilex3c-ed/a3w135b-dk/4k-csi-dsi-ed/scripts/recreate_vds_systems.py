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
recreate_vds_systems.py

Creates VDS source files (.vds, .ip) files directly from version controlled
quartus_sh tcl scripts.

This serves as an example on how to manage VDS systems on a large scale.

It is recommended to perform experimental changes/active development from
within the VDS GUI, and once satisfied copy/export the changes over to Tcl
to serve as the ultimate source of reproducibility and human readability.
"""

import argparse
import shutil
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
CREATE_SYSTEM_TCL = REPO_ROOT / "scripts" / "vds" / "create_system.tcl"


def main() -> int:

    parser = argparse.ArgumentParser(
        prog=f"quartus_py {Path(__file__).name}",
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    _ = parser.parse_args()

    if not shutil.which("quartus_sh"):
        print(
            "[ERROR]: quartus_sh not available in the current environment! "
            + "Ensure your Quartus installation ($QUARTUS_ROOTDIR/bin or "
            + "%QUARTUS_ROOTDIR%\\bin) is on PATH."
        )
        return 1

    if not CREATE_SYSTEM_TCL.is_file():
        print(f"ERROR: {CREATE_SYSTEM_TCL} not found")
        return 1

    cmd = ["quartus_sh", "-t", str(CREATE_SYSTEM_TCL)]

    print(f"running: {' '.join(cmd)}")

    try:
        _ = subprocess.run(cmd, check=True)
        print("All subsystems built successfully.")

    except:
        print("Failed!")
        print(
            'If the error was "Failed to create initial save of system",'
            + " ensure you are running this from an X11 capable host,"
            + " or wrap call with xvfb-run if available"
        )

        return 1

    print("Now fixing top-level .qsf")

    qsf_file = REPO_ROOT / "top.qsf"

    if not qsf_file.exists():
        print("[Error]: Cannot find top.qsf under repo root!")
        return 1

    lines = qsf_file.read_text(encoding="utf-8").splitlines()

    lines.remove("source \"src/qsf/sdc_after_files.qsf\"")
    lines.append("source \"src/qsf/sdc_after_files.qsf\"")

    qsf_file.write_text("\n".join(lines) + "\n")

    print("Done fixing top-level .qsf")

    return 0


if __name__ == "__main__":
    # quartus_py is a standard Python intepreter, bundled with Quartus to avoid
    # making assumptions about the environment

    python_interpreter = sys.executable
    if (not (python_interpreter.endswith("quartus_py.exe"))) & (
        not (python_interpreter.endswith("quartus_py"))
    ):
        print(
                f'[ERROR]: Invalid python interpreter, please use "quartus_py".' +
                f' Current interpreter path: {python_interpreter}'
        )
        sys.exit(1)

    sys.exit(main())
