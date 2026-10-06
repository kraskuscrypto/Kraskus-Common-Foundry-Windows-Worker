# Golden-vector parity

A build of `cmfd-v4-replay.exe` is qualified only when it is **byte-identical** to the official CUDA worker over the Kraskus golden set, driven through the official TAB protocol:

| Item | Value |
|---|---|
| Official worker | Linux `cmfd-v4-replay`, sha256 `f872912bdc3431642e509a634caa2844f347e220ed7b58a02cf2ec874387c5f1` (signed v1.0.0…v1.0.8 packages) |
| Capture host | RTX 5070 (`GPU-b61ed97f-7002-4d93-30e2-1f61b19ade25`), Debian 13, driver 615.71.09, 2026-10-02 |
| Golden inputs | `golden/GOLDEN-INPUTS.json` (sha256 `801a030cc6d266de5b4e60a863e0fa80551696db49fdd92f53d96a5e7bd9cf80`): 10,240 search nonces (0..10240) and 8 full-trace nonces (1000000..1000008) over a frozen template derived with BLAKE3 `derive_key("Kraskus/CMFD-alt-worker/golden-template/v1", …)`; coefficients computed with the official `cmfd_consensus` functions |
| Coefficient files (not in git) | `search-coefficients.bin` 78,848,000 B sha256 `5accd4f138282995ee30b2fe800d0fb8df5dfb9918f1ccfe378aa0855faafec1`; `full-coefficients.bin` 61,600 B sha256 `a0d2a46bf61ebae30de81eb86600d793c434927792eccef20b3a864a34323261`; `search-digests.txt` sha256 `c01e1ae1bc1b7c0f434554c579a10ff281e4b5ce446121f4c74f12c4f5ea9494`; `full-digests.txt` (in git) sha256 `57cd287b9a308a6a2bed7aa636e0921ca1bcbcb8328da41df311661b96dc2f44` |
| Official capture manifest | `golden/capture-manifest.json` (sha256 `3ee464b236eb818d38955dd9a4e3f60ec5d823422fea855bab945bcdb71328ef`): per-nonce SHA-256 of every final activation and of every kept file produced by the official worker |
| Model bank | `MODEL-V2.bank` 6,442,975,416 B sha256 `5f9b213c3bda51b74e4ebabb26607b67385d613aa8d99af915a48ab063e17d4e` (4 official parts; `run-parity.ps1 -DownloadBank` fetches and verifies them) |
| Comparison tool | `cmfd-v4-capture compare` (Kraskus internal, `apps/common-foundry/alt-worker` @ `dc767a4`, Rust): replays the inputs on the worker under test and requires every per-nonce hash and every kept file to equal the manifest |

## Running

On a Windows x64 host with an NVIDIA GPU (≥ 8 GB VRAM, compute capability ≥ 7.0, driver ≥ 570 for CUDA 12.8), with `golden/` completed by the coefficient files above and `tools/cmfd-v4-capture.exe` present:

> The harness tools under `tools/` (`cmfd-v4-capture.exe`, `cmfd-v4-conformance.exe`, `cmfd-v4-ref-worker.exe`, Windows builds of `apps/common-foundry/alt-worker`) must be built with a **static CRT** (`RUSTFLAGS=-C target-feature=+crt-static`): a clean Windows 11 install has no `vcruntime140.dll`, and a dynamic-CRT build exits with `0xC0000135` (STATUS_DLL_NOT_FOUND) before comparing anything. This was hit on 2026-10-06 in the first RTX 5070 window (results `2026-10-06-1923`, self-test EXACT, compare not executed). Static builds used since: capture `f0596e6f…`, conformance `38f91d6b…`, ref-worker `e542438a…`.

```powershell
.\run-parity.ps1 -Bank D:\cmfd\MODEL-V2.bank -Worker ..\build\windows-x64\cmfd-v4-replay.exe [-DownloadBank]
```

The script verifies every input hash, verifies (or downloads and assembles) the bank, runs `--self-test` (must print `replay_self_test=EXACT`), then `compare` over all 10,240 + 8 nonces, and writes `results/<stamp>-<host>/SUMMARY.md`. Exit code 0 means zero mismatches.

## Exit criterion

`COMPARE <n> items, 0 mismatches` with `replay_self_test=EXACT`, recorded in `results/` with the worker's SHA-256, the GPU, the driver version and the toolchain. Each qualified build hash is listed in `CHANGELOG.md`; Kraskus Universal Miner pins exactly that hash.
