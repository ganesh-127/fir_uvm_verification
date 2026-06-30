# N-Tap Parameterized FIR Filter — RTL Design & UVM Verification

A parameterized N-tap FIR filter in SystemVerilog, verified with a complete UVM testbench achieving 100% functional coverage and zero scoreboard failures across 1005 transactions.

## How It Works

The design has two parts — the filter itself, and the verification environment built around it.

**RTL Design**
The FIR filter is parameterized for tap count, data width, and accumulator width, with a simple valid/ready handshake on both input and output. Internally it maintains a shift register of past samples and computes a multiply-accumulate (MAC) sum against a fixed coefficient set every cycle a new sample arrives.

**UVM Testbench**
Sequences generate stimulus in three flavors — directed (known values for sanity checking), corner (one transaction per coverage bin boundary), and random (1000 constrained-random transactions). The sequencer hands these to the driver, which drives the DUT's input pins cycle-accurately. The monitor passively watches the DUT's output and forwards every transaction to two places: the scoreboard, which runs an independent reference model of the FIR math and compares it against the DUT's actual output, and the coverage collector, which tracks whether the full range of input and output values has been exercised.

**Result:** 1005 transactions, PASS: 1005 / FAIL: 0, 100% functional coverage.

## Debug Story

During development, the scoreboard initially reported 0/16 transactions passing despite the DUT appearing to run correctly. Structured debug logging traced the issue to a one-cycle output lag — the DUT's shift register used non-blocking assignments, so the MAC computation read the *old* shift register value instead of the newly arrived sample. Switching to blocking assignments inside the `always_ff` block fixed the alignment and resolved every mismatch.

## Tools

SystemVerilog · Aldec Riviera-PRO · UVM 1.2 · EDA Playground
