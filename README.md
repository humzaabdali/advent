# Advent of FPGA 2025 Solutions

Solutions for the [Advent of FPGA 2025](https://adventofcode.com/) challenge series, implemented in SystemVerilog.

## About Advent of FPGA

Advent of FPGA is an annual series of programming challenges that combine algorithmic problem-solving with FPGA hardware design. Each day presents a new challenge to solve using hardware description languages like SystemVerilog.

## Repository Structure

```
.
├── README.md              # This file
├── template.sv            # Reusable testbench template
├── day01/                 # Day 1 solution
│   ├── solution.sv
│   └── testbench.sv
├── day02/                 # Day 2 solution
│   ├── solution.sv
│   └── testbench.sv
└── ...
```

## Getting Started

### Prerequisites
- SystemVerilog simulator (e.g., Icarus Verilog, ModelSim, VCS)
- HDL compiler/synthesizer (optional, for hardware verification)

### Running Simulations

Example using Icarus Verilog:
```bash
iverilog -o sim day01/testbench.sv day01/solution.sv
vvp sim
```

Or with ModelSim:
```bash
vsim -do "run -all" testbench.sv
```

## Challenge Progress

- [ ] Day 01
- [ ] Day 02
- [ ] Day 03
- [ ] Day 04
- [ ] Day 05
- [ ] Day 06
- [ ] Day 07
- [ ] Day 08
- [ ] Day 09
- [ ] Day 10
- [ ] Day 11
- [ ] Day 12
- [ ] Day 13
- [ ] Day 14
- [ ] Day 15
- [ ] Day 16
- [ ] Day 17
- [ ] Day 18
- [ ] Day 19
- [ ] Day 20
- [ ] Day 21
- [ ] Day 22
- [ ] Day 23
- [ ] Day 24
- [ ] Day 25

## Template

The `template.sv` file provides a reusable structure for creating new challenge solutions:
- Testbench module (`top_module`)
- Clock generation and control
- Signal probing for waveform analysis
- Test stimulus patterns

## Resources

- [SystemVerilog Quick Reference](https://www.asic-world.com/systemverilog/systemverilog_tutorial.html)
- [Advent of Code](https://adventofcode.com/) (related problem-solving challenges)
- [HDL Tips and Best Practices](https://www.asic-world.com/)

## Notes

Each solution includes:
- Functional implementation
- Comprehensive testbench
- Simulation waveform probes
- Detailed comments explaining the approach

Good luck with the challenges! 🚀