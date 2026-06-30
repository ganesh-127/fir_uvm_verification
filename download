# N-Tap Parameterized FIR Filter — RTL Design & UVM Verification

A fully parameterized N-tap FIR filter implemented in SystemVerilog, verified with a complete industry-standard UVM testbench achieving **100% functional coverage** and **zero scoreboard failures** across 1005 transactions.

---

## Overview

This project demonstrates the full design-to-verification flow for a digital signal processing block:

- **RTL Design** — synthesizable, parameterized FIR filter with clean coding style
- **Functional Verification** — complete UVM environment built from scratch
- **Coverage-Driven Methodology** — directed, corner-case, and constrained-random testing with documented coverage exclusions

---

## Architecture

![UVM Architecture Diagram](docs/screenshots/architecture_diagram.png)

*Editable source: [docs/architecture_diagram.pptx](docs/architecture_diagram.pptx)*

---

## RTL Design

The FIR filter (`rtl/fir_filter.sv`) implements an 8-tap symmetric low-pass filter with the following features:

| Parameter | Default | Description |
|---|---|---|
| `N_TAPS` | 8 | Number of filter taps |
| `DATA_W` | 16 | Input data width (signed) |
| `COEF_W` | 16 | Coefficient width (signed) |
| `ACC_W` | 32 | Accumulator/output width |

**Interface:**
- `data_in` / `data_valid` — input sample and handshake
- `data_out` / `out_valid` — filtered output and handshake

**Key design decision:** shift register updates use blocking assignments inside `always_ff` so the MAC computation sees the current sample in the same clock cycle it arrives, avoiding a one-cycle output lag.

---

## Verification Environment

The UVM testbench (`tb/fir_uvm_tb.sv`) includes all standard components:

| Component | Purpose |
|---|---|
| `fir_transaction` | Randomizable sequence item — signed 16-bit input, constrained to full range |
| `fir_directed_seq` | 16 known-value transactions for sanity checking |
| `fir_corner_seq` | 5 transactions explicitly targeting coverage bin boundaries |
| `fir_random_seq` | 1000 constrained-random transactions |
| `fir_driver` | Drives DUT pins with cycle-accurate valid handshake |
| `fir_monitor` | Passively captures output on `out_valid`, broadcasts via analysis port |
| `fir_scoreboard` | Inline reference model mirroring DUT MAC logic exactly |
| `fir_coverage` | Functional coverage — input amplitude, output magnitude, cross coverage |
| `fir_agent` / `fir_env` | Standard UVM hierarchy |
| `fir_coverage_test` | Top-level test — runs corner sequence then 1000 random transactions |

### Coverage Model

```systemverilog
cp_input:  5 bins — neg_large, neg_small, zero, pos_small, pos_large
cp_output: 2 bins — negative, positive (zero output bin excluded — see below)
cx_in_x_out: cross of the above, with documented ignore_bins
```

**Coverage exclusions:** the zero-output bin and its cross combinations were excluded using `ignore_bins` because a FIR filter's output depends on an 8-sample history, not just the current input — making exact zero output mathematically improbable with non-zero random history. This is documented in-code rather than left as an unexplained coverage hole.

---

## Results

| Metric | Result |
|---|---|
| Total transactions | 1005 (5 corner + 1000 random) |
| Scoreboard PASS | 1005 |
| Scoreboard FAIL | 0 |
| Functional Coverage | **100%** |
| UVM_INFO | 1012 |
| UVM_WARNING | 0 |
| UVM_ERROR | 0 |
| UVM_FATAL | 0 |

### Scoreboard Summary & Final Coverage
![Scoreboard Results](docs/screenshots/scoreboard_results.png)

### Sample Pass Log (Constrained-Random Transactions)
![Test Passes](docs/screenshots/test_passes.png)

### UVM Report Summary
![UVM Report Summary](docs/screenshots/uvm_report_summary.png)

### Waveform — EPWave
![Waveform](docs/screenshots/waveform.png)

---

## Debug Story — A Real Bug Found and Fixed

During development, the scoreboard initially reported **0/16 passing** despite the DUT appearing to run correctly. Using structured debug logging in the scoreboard, the root cause was traced to a **one-cycle output lag**: the DUT's shift register used non-blocking assignments, so the MAC computation read the *old* shift register value rather than the newly arrived sample.

**Fix:** changed shift register updates inside `always_ff` from non-blocking (`<=`) to blocking (`=`) assignments, so the MAC sees the current sample immediately within the same clock edge. This aligned the DUT behavior with the reference model and resolved all scoreboard mismatches.

This highlights a subtle but common RTL pitfall — blocking vs. non-blocking assignment semantics inside sequential always blocks — and the value of a scoreboard with diagnostic logging for catching it.

---

## How to Run

This project was developed and verified on [EDA Playground](https://www.edaplayground.com/) using:

- **Simulator:** Aldec Riviera-PRO
- **UVM Version:** 1.2
- **Compile options:** `-timescale 1ns/1ps`

**Steps:**
1. Paste `rtl/fir_filter.sv` into the Design panel
2. Paste `tb/fir_uvm_tb.sv` into the Testbench panel
3. Set simulator to Riviera-PRO, UVM to 1.2
4. Run — `fir_coverage_test` runs by default (see `tb_top` in the testbench)

To run the directed sanity test instead, change the last line in `tb_top`:
```systemverilog
run_test("fir_directed_test");
```

---

## Repository Structure

```
fir-uvm-verification/
├── rtl/
│   └── fir_filter.sv          # Parameterized FIR filter DUT
├── tb/
│   └── fir_uvm_tb.sv          # Complete UVM testbench
├── docs/
│   └── screenshots/           # Waveform, scoreboard, coverage reports
├── logs/
│   └── simulation_log.txt     # Full simulation log
└── README.md
```

---

## Skills Demonstrated

`SystemVerilog` `UVM` `Functional Verification` `Constrained-Random Verification` `Coverage-Driven Verification` `RTL Design` `Digital Signal Processing` `Aldec Riviera-PRO`
