#!/usr/bin/env bash
set -euo pipefail
ulimit -c 0
PROJECT_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"
export UVM_HOME="${UVM_HOME:-$HOME/tools/uvm-2020.3.1}"
mkdir -p tb_extend/logs
mode="${1:-run}"
case "$mode" in
  build)
    test -f "$UVM_HOME/src/uvm_pkg.sv" || { echo "Missing UVM: $UVM_HOME"; exit 2; }
    verilator --version
    verilator --binary --timing --assert --trace --timescale 1ns/1ps \
      -j 2 -Wno-fatal +define+UVM_NO_DPI \
      -I"$UVM_HOME/src" -Itb_extend \
      "$UVM_HOME/src/uvm_pkg.sv" rtl/sync_fifo.sv \
      tb_extend/fifo_if.sv tb_extend/fifo_pkg.sv tb_extend/fifo_assertions.sv tb_extend/top.sv \
      --Mdir obj_dir_extend --top-module top 2>&1 | tee tb_extend/logs/build.log
    ;;
  run)
    seed="${2:-1}"
    [[ "$seed" =~ ^[0-9]+$ ]] || { echo "Seed must be a non-negative integer"; exit 2; }
    if (( $# >= 2 )); then shift 2; elif (( $# == 1 )); then shift; fi
    test -x obj_dir_extend/Vtop || { echo 'Build first: bash tb_extend/run.sh build'; exit 2; }
    log="tb_extend/logs/run_seed_${seed}.log"
    if [[ " $* " == *' +INJECT_MISMATCH '* ]]; then log="tb_extend/logs/injected_seed_${seed}.log"; fi
    if [[ " $* " == *' +SMOKE_ONLY '* ]]; then log="tb_extend/logs/smoke_seed_${seed}.log"; fi
    {
      echo "UTC=$(date -u +%FT%TZ)"
      verilator --version
      echo "UVM_HOME=$UVM_HOME UVM_COMMIT=$(git -C "$UVM_HOME" rev-parse --short HEAD)"
      printf 'COMMAND: ./obj_dir_extend/Vtop +verilator+seed+%s %s\n' "$seed" "$*"
      ./obj_dir_extend/Vtop "+verilator+seed+$seed" "$@"
    } 2>&1 | tee "$log"
    # Some simulators return zero even after UVM_ERROR; require explicit PASS.
    if ! grep -q '\[RESULT\] FIFO verification PASS' "$log" ||
       grep -Eq 'UVM_(ERROR|FATAL)[[:space:]]*:[[:space:]]*[1-9]' "$log"; then
      echo "FAILED: inspect $log"
      exit 1
    fi
    ;;
  regression)
    for seed in 1 7 42; do bash "$0" run "$seed"; done
    if bash "$0" run 1 +INJECT_MISMATCH; then
      echo 'ERROR: intentional corruption was NOT detected'
      exit 1
    fi
    grep -q '\[DATA\].*expected=.*actual=' tb_extend/logs/injected_seed_1.log || {
      echo 'Injection failed for an unrelated reason'; exit 1;
    }
    echo 'REGRESSION PASS: seeds 1/7/42 passed; intentional mismatch was detected.'
    ;;
  *) echo 'Usage: bash tb_extend/run.sh {build|run [seed] [plusargs...]|regression}'; exit 2 ;;
esac
