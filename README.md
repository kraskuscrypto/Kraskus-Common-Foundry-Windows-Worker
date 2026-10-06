# Kraskus Common Foundry Windows Worker

Native **Windows x64** build of the Common Foundry ProductionV4 search worker, `cmfd-v4-replay.exe`, from the **unmodified upstream MIT source**. This repository is build-focused only: it pins the sources and toolchain, builds the binary reproducibly in CI, publishes it with SHA-256 hashes, and documents how it is qualified against the official worker. It is not a miner, not a product and has no user interface.

Why it exists: the official Common Foundry Windows package ships the GPU worker as a Linux binary that runs through WSL2. The official `cmfd-miner.exe` can drive a native worker directly (`--production-v4-replay-worker <path>`), so a native build removes the WSL2 requirement. [Kraskus Universal Miner](https://github.com/kraskuscrypto/Kraskus-Universal-Miner) consumes the release artifact as a **pinned, hash-verified companion executable** (never as a source dependency), and only after it has passed the golden-vector parity run described below.

## Pins

| What | Pin |
|---|---|
| Upstream repository | `Common-Foundry-1/CommonFoundry`, MIT |
| Upstream source | tag **v1.0.8** = commit `3aa5369512f47d0b3c49a49a54a0395e71e0c000`; `tools/production-v4-prover/cuda/koala_four_limb_replay.cu`, sha256 `d4c30e99883506b2e00ba9cecb41177b70e066c2be79da1400a1fea7feafc999` (copied verbatim to `src/`) |
| CUTLASS | tag **v3.9.2** = commit `ad7b2f5e84fcfa124cb02b91d5bd26d238c0459e`, BSD-3 (the exact commit upstream's `build-replay.sh` requires; fetched by CI, never vendored) |
| CUDA | **12.8** (nvcc 12.8.x, `cudart_static`); CI uses CUDA 12.8.0 |
| Host compiler | MSVC 14.4x (Visual Studio 2022 17.14 Build Tools or newer), `-allow-unsupported-compiler`; flags `/EHsc /bigobj /MT /Zc:__cplusplus` |
| GPU targets | native `sm_70 75 80 86 89 90 120` + `compute_70` PTX (identical to upstream's Linux build plan) |

See [UPSTREAM.md](UPSTREAM.md) for the provenance record and [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for licences.

## Build

CI (`.github/workflows/build.yml`) is the reference build: `windows-2022`, CUDA 12.8.0, CUTLASS checked out at the pinned commit, `build/build-windows.cmd`, image check with `cuobjdump`, SHA-256, artifact upload, and a GitHub release with `SHA256SUMS` on `v*` tags.

Locally, with a CUDA 12.8 toolkit (`CUDA_PATH`) and CUTLASS at the pinned commit (`CUTLASS_ROOT`):

```bat
build\build-windows.cmd
```

Output: `build\windows-x64\cmfd-v4-replay.exe`, `images-elf.txt`, `images-ptx.txt`, `SHA256SUMS`.

## Qualification (required before any release is used)

The worker must be **bit-identical** to the official CUDA worker (`cmfd-v4-replay`, sha256 `f872912bdc3431642e509a634caa2844f347e220ed7b58a02cf2ec874387c5f1`, from the signed v1.0.8 Linux package) over the Kraskus golden set: **10,240 search nonces (RUNBATCH 32) and 8 full-trace nonces**, every per-nonce output hash and every kept file equal to the official capture (RTX 5070, 2026-10-02). `parity/run-parity.ps1` runs the worker's own `--self-test` and then the comparison on a Windows host with an NVIDIA GPU (≥ 8 GB, compute capability ≥ 7.0). See [parity/README.md](parity/README.md).

Status: see [CHANGELOG.md](CHANGELOG.md).

## Interface (unchanged from upstream)

`cmfd-v4-replay.exe --server <MODEL-V2.bank>`: TAB-framed commands on stdin (`RUNBATCH`, `RUN search|full`, `EVICT`, `QUIT`), markers on stdout (`CMFD_V4_REPLAY_READY`, `…_DONE`, `…_EVICTED`), fatal errors on stderr with exit 1; `--self-test` prints `replay_self_test=EXACT`. Device selection through `CUDA_VISIBLE_DEVICES` (the official miner passes the GPU UUID). Windows writes `\r\n` line endings on stdout, which the official client accepts.

## Not in scope

No mining fee, no telemetry, no network code, no changes to the upstream algorithm or protocol. Branding: "Common Foundry" is the upstream project's name; this is a Kraskus build of their MIT-licensed worker and implies no endorsement.
