# Golden parity run: PASS (2026-10-06, RTX 5070, Windows 11)

| Item | Value |
|---|---|
| Worker | `cmfd-v4-replay.exe` sha256 `1f635cf62bdaf711071bc11f327dcc1dba6a17b8c36158f139ccb682d782cb05` (CI run 37504117625, commit `88ceafb`, windows-2022, nvcc 12.8.61, MSVC 14.44.35207) |
| Harness | `cmfd-v4-capture.exe` sha256 `f0596e6f3f7ff5c9a6d43b5e2fccbc7417c6320a8472141102a514d3b31ab3bd` (alt-worker @ cmfd-001, static CRT) |
| Host | Windows 11 Pro 26300 (clean install, QEMU/KVM q35 guest), NVIDIA 617.42 WHQL, GeForce RTX 5070 (compute 12.0, 12 GB), GPU passed through from Proxmox |
| Golden set | `GOLDEN-INPUTS.json` `801a030c…`, official capture manifest `3ee464b2…` (official Linux worker `f872912b…`, RTX 5070, 2026-10-02), `MODEL-V2.bank` `5f9b213c…` |
| Self-test | `small_differential=EXACT`, `dp4a_differential=EXACT`, `replay_self_test=EXACT` ([01-selftest.txt](01-selftest.txt)) |
| Compare | **`COMPARE 10272 items, 0 mismatches`**, exit 0, 675 s: 10,240 search nonces (320 RUNBATCH batches of 32) + 8 full-trace nonces + kept output files ([02-compare.txt](02-compare.txt)) |

Files: [00-run.log](00-run.log) (script log incl. input hashes), [bundle-hashes.txt](bundle-hashes.txt) (SHA-256 of every result file as read on the host), [gpu-check.txt](gpu-check.txt) (driver/GPU/process state before the run), [SUMMARY.md](SUMMARY.md) (script-generated).

Verdict: this build is **qualified** for use as the Common Foundry Windows companion worker in Kraskus Universal Miner. Any other build (different hash) is unqualified until it passes the same run.
