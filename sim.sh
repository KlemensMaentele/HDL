#!/usr/bin/env bash
# Compile + simulate SystemVerilog with Vivado's xsim, no GUI needed.
# Lives in the head folder; works on any subfolder (week1, week2, ...).
#
# Usage:
#   ./sim.sh <folder> <top_testbench> [file1.sv file2.sv ...]
#
# Examples:
#   ./sim.sh week2 tb_alu                          # all *.sv in week2/
#   ./sim.sh week2 tb_alu Types.sv ALU.sv tb_alu.sv  # explicit files (relative to week2/)
#   NOWAVES=1 ./sim.sh week2 tb_alu                # skip waveform recording
#
# Output goes to <folder>/build/ (waves.vcd for Surfer/WaveTrace/GTKWave,
# waves.wdb for the Vivado viewer).

VIVADO_SETTINGS="/shares/nct-opt/software/xilinx/settingsZitiVivado.sh"
VIVADO_VERSION="2023.2"

if [ $# -lt 2 ]; then
    echo "Usage: $0 <folder> <top_testbench> [files.sv ...]"
    exit 1
fi

DIR="$1"; TOP="$2"; shift 2

if [ ! -d "$DIR" ]; then
    echo "Folder '$DIR' not found."
    exit 1
fi
DIR="$(realpath "$DIR")"

# Source files: given ones (relative to the folder), or every .sv in the folder
FILES=()
if [ $# -gt 0 ]; then
    for f in "$@"; do FILES+=("$DIR/$f"); done
else
    shopt -s nullglob
    FILES=("$DIR"/*.sv)
fi

if [ ${#FILES[@]} -eq 0 ]; then
    echo "No .sv files found in $DIR."
    exit 1
fi

# Packages must be compiled first: *types*/*pkg*/*package* go to the front
PKG=(); REST=()
for f in "${FILES[@]}"; do
    case "$(basename "$f" | tr 'A-Z' 'a-z')" in
        *types*|*pkg*|*package*) PKG+=("$f") ;;
        *) REST+=("$f") ;;
    esac
done

# Load Vivado (only if it's not already on the PATH)
if ! command -v xvlog >/dev/null 2>&1; then
    # shellcheck disable=SC1090
    source "$VIVADO_SETTINGS" "$VIVADO_VERSION"
fi

if ! command -v xvlog >/dev/null 2>&1; then
    echo "xvlog still not found, check VIVADO_SETTINGS in this script."
    exit 1
fi

# Keep generated clutter (xsim.dir, logs, ...) out of your sources
BUILD_DIR="$DIR/build"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR" || exit 1

echo "=== Compiling ($DIR) ==="
xvlog -sv "${PKG[@]}" "${REST[@]}" || { echo "Compile failed."; exit 1; }

echo "=== Elaborating ($TOP) ==="
xelab -debug typical --timescale 1ns/1ps "$TOP" -s sim_snapshot || { echo "Elaboration failed."; exit 1; }

echo "=== Simulating ==="
if [ -n "$NOWAVES" ]; then
    xsim sim_snapshot -runall
else
    cat > waves.tcl <<'TCL'
open_vcd waves.vcd
log_vcd [get_objects -r /*]
log_wave -recursive *
run all
close_vcd
quit
TCL
    xsim sim_snapshot -tclbatch waves.tcl -wdb waves.wdb
fi

echo
echo "Done. Output is in $BUILD_DIR (waves.vcd / waves.wdb)."