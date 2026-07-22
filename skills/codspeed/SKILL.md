---
name: codspeed
description: "Use when running performance benchmarks, optimizing code for speed/memory, analyzing flamegraphs, or setting up CodSpeed CI. Covers codspeed CLI commands — auth, run, exec, profile management, and instrument modes (simulation, walltime, memory)."
---

# CodSpeed CLI

`codspeed` installed at `~/.cargo/bin/codspeed`. Performance benchmarking CLI for any executable.

## Auth

```bash
codspeed auth login
codspeed auth status
```

## Instruments

Three modes via `-m` flag or `codspeed use <mode>`:

| Mode | What it measures | Use case |
|------|-----------------|----------|
| `simulation` | CPU instructions (Valgrind) | Fast iteration, deterministic |
| `walltime` | Real-world execution time | Final validation |
| `memory` | Heap allocations (eBPF) | Memory optimization |

```bash
# Set default for shell session
codspeed use simulation
codspeed show
codspeed use walltime
codspeed use memory
```

## Run benchmarks

```bash
# From codspeed.yml config
codspeed run -m simulation
codspeed run -m walltime
codspeed run -m memory

# With explicit command (Rust/cargo-codspeed, pytest-codspeed, etc.)
codspeed run -m simulation -- cargo codspeed run --bench decode
codspeed run -m simulation -- pytest --codspeed
codspeed run -m simulation -- go test -bench .
codspeed run -m simulation -- npx vitest bench

# Compare against a baseline
codspeed run -m simulation --base <run_id> -- cargo codspeed run --bench decode

# Full output (no rolling buffer)
codspeed run --show-full-output -- cargo codspeed run --bench decode

# Scoped: run only specific benchmark suites
codspeed run -m simulation -- cargo codspeed run --bench decode cat.jpg
```

## Exec single command (exec harness)

No config file needed — wraps any executable:

```bash
codspeed exec -m walltime -- sleep 1
codspeed exec -m simulation -- ./my-binary --arg1 value
codspeed exec -m memory -- ./my-binary

# With tuning options
codspeed exec -m walltime --warmup-time 100ms --max-time 2s -- ./my-binary
codspeed exec -m walltime --min-time 1s --max-rounds 100 -- ./my-binary

# Named benchmark
codspeed exec -m walltime --name "parse JSON" -- ./parse-json test.json
```

## Exec options

| Flag | Default | Description |
|------|---------|-------------|
| `--warmup-time <dur>` | 1s | Warmup duration before measurement |
| `--max-time <dur>` | 3s | Max total time for measurement |
| `--min-time <dur>` | — | Min time for measurement |
| `--max-rounds <n>` | — | Max iterations |
| `--min-rounds <n>` | — | Min iterations |
| `--name <str>` | command | Label for the benchmark |

Duration format: `"1s"`, `"500ms"`, `"1.5s"`, `"2m"`, or bare number in seconds.

## Config file (`codspeed.yml`)

```yaml
$schema: https://raw.githubusercontent.com/CodSpeedHQ/codspeed/refs/heads/main/schemas/codspeed.schema.json
options:
  warmup-time: "0.2s"
  max-time: 1s

benchmarks:
  - name: "parse JSON"
    exec: ./my-binary --arg1 value
    options:
      max-rounds: 20
  - name: "sort array"
    exec: ./my-binary2
    options:
      max-time: 200ms
```

Priority: `codspeed.yml` > `codspeed.yaml` > `.codspeed.yml` > `.codspeed.yaml`. Override with `--config <path>`.

## Profile management

```bash
codspeed profile list
codspeed profile show <name>
codspeed profile set <name> --upload-url <url> --token <token>
codspeed profile use <name>
```

## CI workflow (GitHub Actions)

```yaml
name: CodSpeed Benchmarks
on:
  push:
    branches: ["main"]
  pull_request:
  workflow_dispatch:
jobs:
  benchmarks:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v5
      - name: Setup environment
        run: |
          # Install deps, build your binary
      - name: Run benchmarks
        uses: CodSpeedHQ/action@v4
        with:
          run: codspeed run -m simulation
          mode: simulation
```

## Status & setup

```bash
codspeed status
codspeed setup
codspeed update
```

## Profiling (Linux)

```bash
# Enable profiler for flamegraph data
codspeed run -m walltime --enable-profiler -- cargo bench

# Unwinding mode
codspeed run --enable-profiler --perf-unwinding-mode fp -- cargo bench
codspeed run --enable-profiler --perf-unwinding-mode dwarf -- cargo bench
```

## Environment variables

| Var | Purpose |
|-----|---------|
| `CODSPEED_RUNNER_MODE` | Default instrument mode |
| `CODSPEED_REPOSITORY` | `owner/repo` for upload |
| `CODSPEED_TOKEN` | Auth token for upload |
| `CODSPEED_PROFILE` | Active profile name |
| `CODSPEED_PROVIDER` | `github` or `gitlab` |
| `CODSPEED_UPLOAD_URL` | Custom upload endpoint |
| `CODSPEED_PROFILER_ENABLED` | `true` to enable profiling |
| `CODSPEED_PERF_UNWINDING_MODE` | `fp` or `dwarf` |
| `CODSPEED_GO_RUNNER_VERSION` | Go runner version pin |
| `CODSPEED_PERF_ENABLED` | `false` to disable perf (walltime) |

## Gotchas

- `sudo` required for walltime (linux perf) and memory (eBPF) on Linux
- Simulation mode requires CodSpeed's fork of Valgrind (`valgrind --version` should show `codspeed`)
- Statically linked executables are NOT supported in simulation mode
- Simulation does NOT follow child processes
- Profiling (flamegraphs) only works on Linux
- Interpreted languages (Python, JS) not supported for simulation profiling yet
- Use `simulation` for fast iteration, `walltime` for final validation — some patterns only show in simulation
- `codspeed exec` options (`--warmup-time`, `--max-time`, etc.) are NOT available in `codspeed run`