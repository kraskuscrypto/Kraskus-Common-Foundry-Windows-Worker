# Changelog

## Unreleased

- Repository created 2026-10-06 (owner decision): build-focused, public, MIT (Kraskus parts) + MIT (upstream worker) + BSD-3 (CUTLASS) + CUDA EULA (cudart).
- Pins: upstream v1.0.8 @ `3aa5369512f47d0b3c49a49a54a0395e71e0c000` (worker source sha256 `d4c30e99…c999`, unmodified), CUTLASS 3.9.2 @ `ad7b2f5e84fcfa124cb02b91d5bd26d238c0459e`, CUDA 12.8, MSVC 2022 14.4x.
- First workstation build (nvcc 12.8.93 from conda-forge, MSVC 14.44.35207): `cmfd-v4-replay.exe` 2,543,616 B, sha256 `3b31b67ee0f310f02308ee0621e364aee8634c3267b1e79a492b50df496a7b6e`, native sm_70…sm_120 + compute_70 PTX, imports KERNEL32 only.
- First CI build (run 37504117625, commit `88ceafb`, `windows-2022`, nvcc 12.8.61, MSVC 14.44.35207): `cmfd-v4-replay.exe` 2,543,616 B, sha256 `1f635cf62bdaf711071bc11f327dcc1dba6a17b8c36158f139ccb682d782cb05`, same GPU images as the workstation build (the hash differs only by compiler patch level). This is the artifact the parity run tests.
- **Qualification: NOT YET RUN.** The golden parity run needs a Windows host with an NVIDIA GPU; no build from this repository may be used by Kraskus Universal Miner until `parity/results/` records PASS for its hash.
