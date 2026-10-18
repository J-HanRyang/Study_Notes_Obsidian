#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
export UVM_HOME="${UVM_HOME:-$HOME/tools/uvm-2020.3.1}"
mkdir -p logs

case "${1:-run}" in
  build)
    verilator --binary --timing --timescale 1ns/1ps -j 2 -Wno-fatal \
      -CFLAGS -O0 +define+UVM_NO_DPI -I"$UVM_HOME/src" -Itb \
      "$UVM_HOME/src/uvm_pkg.sv" rtl/sync_fifo.sv \
      tb/fifo_if.sv tb/fifo_pkg.sv tb/top.sv \
      --top-module top 2>&1 | tee logs/basic_build.log
    ;;
  run)
    ./obj_dir/Vtop 2>&1 | tee logs/basic_run.log
    # A simulator's exit code alone does not guarantee UVM success.
    if grep -Eq 'UVM_(ERROR|FATAL)[[:space:]]*:[[:space:]]*[1-9]' logs/basic_run.log ||
       ! grep -q '\[SCB\].*comparisons=[1-9]' logs/basic_run.log; then
      echo 'Basic test FAILED; see logs/basic_run.log'
      exit 1
    fi
    echo 'Basic A5 write/read comparison PASS'
    ;;
  *) echo 'Usage: bash run.sh build | bash run.sh run'; exit 2 ;;
esac
