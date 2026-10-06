# Changelog

## Unreleased

- Repository created 2026-10-06 (owner decision): build-focused, public, MIT (Kraskus parts) + MIT (upstream worker) + BSD-3 (CUTLASS) + CUDA EULA (cudart).
- Pins: upstream v1.0.8 @ `3aa5369512f47d0b3c49a49a54a0395e71e0c000` (worker source sha256 `d4c30e99…c999`, unmodified), CUTLASS 3.9.2 @ `ad7b2f5e84fcfa124cb02b91d5bd26d238c0459e`, CUDA 12.8, MSVC 2022 14.4x.
- First workstation build (nvcc 12.8.93 from conda-forge, MSVC 14.44.35207): `cmfd-v4-replay.exe` 2,543,616 B, sha256 `3b31b67ee0f310f02308ee0621e364aee8634c3267b1e79a492b50df496a7b6e`, native sm_70…sm_120 + compute_70 PTX, imports KERNEL32 only.
- First CI build (run 37504117625, commit `88ceafb`, `windows-2022`, nvcc 12.8.61, MSVC 14.44.35207): `cmfd-v4-replay.exe` 2,543,616 B, sha256 `1f635cf62bdaf711071bc11f327dcc1dba6a17b8c36158f139ccb682d782cb05`, same GPU images as the workstation build (the hash differs only by compiler patch level). This is the artifact the parity run tests.
- `parity/run-parity.ps1`: resolve the script directory at run time (Windows PowerShell 5.1 leaves `$PSScriptRoot` empty while binding parameter defaults, so `-File` invocations without `-Worker`/`-Scratch` failed with an empty `Join-Path`); found while staging the QA VM.
- 2026-10-06 RTX 5070 window 1 (VM160, driver 617.42, cc 12.0): worker `1f635cf6…` self-test EXACT (small_differential, dp4a_differential, replay_self_test); golden compare NOT executed because the dynamic-CRT harness tools failed to launch (`0xC0000135`, missing `vcruntime140.dll`). Not a parity result. Harness tools rebuilt with a static CRT for window 2.
- **Qualification: PASS (2026-10-06, window 2).** `cmfd-v4-replay.exe` `1f635cf6…` on RTX 5070 / Windows 11 / driver 617.42: self-test EXACT, `COMPARE 10272 items, 0 mismatches` (10,240 search + 8 full-trace nonces), 675 s. Record: `parity/results/2026-10-06-rtx5070-win11/`. Only this hash is qualified; `parity/QUALIFIED-SHA256` pins it and the release job refuses to publish a rebuild with a different hash.

## v1.0.8.1 (2026-10-06)

- First release: the qualified build above, packaged as `kraskus-cmfd-v4-replay-1.0.8.1-windows-x64.zip` + `SHA256SUMS`. Version = upstream 1.0.8 + Kraskus build 1.
