# Upstream provenance

| Item | Value |
|---|---|
| Project | Common Foundry — https://github.com/Common-Foundry-1/CommonFoundry (MIT) |
| Release | v1.0.8, published 2026-10-05; tag object → commit `3aa5369512f47d0b3c49a49a54a0395e71e0c000` |
| Source file | `tools/production-v4-prover/cuda/koala_four_limb_replay.cu` (58,393 bytes), sha256 `d4c30e99883506b2e00ba9cecb41177b70e066c2be79da1400a1fea7feafc999` — `src/koala_four_limb_replay.cu` is a byte-for-byte copy with no modification |
| Upstream build plan | `tools/production-v4-prover/build-replay.sh` (sha256 `657366f7b8d4a4015128bd42c974eaf85869ca067ff2379a68d52d5ef2813e2e`, copied to `upstream-scripts/` for reference): `nvcc -O3 -std=c++17 --generate-code=arch=compute_{70,75,80,86,89,90,120},code=sm_* --generate-code=arch=compute_70,code=compute_70 -I<CUTLASS 3.9.2>/include koala_four_limb_replay.cu` |
| Upstream Windows status | the official `commonfoundry-mainnet-miner-windows-x86_64-v1.0.8.zip` (sha256 `7c971b8c972147a5548472d569276b3c30f98bd3b2d57d12d30378ca52c25899`) contains native `cmfd-miner.exe` / `cmfd-launch.exe` but a **Linux** `cmfd-v4-replay` run through WSL2 (`scripts/package_mainnet.py`, `packaging/mainnet/windows/START-MINER.ps1`). No official native Windows worker exists. |
| Official reference worker | Linux `cmfd-v4-replay`, sha256 `f872912bdc3431642e509a634caa2844f347e220ed7b58a02cf2ec874387c5f1` (identical in v1.0.0 … v1.0.8; v1.0.9–v1.0.11 release notes state the worker and CUDA runtime are unchanged) |
| Release signing | upstream signs `SHA256SUMS.txt` with an SSH ed25519 key (`commonfoundry-mainnet-owner`, namespace `commonfoundry-release`, fingerprint `SHA256:cA1Tsf8hL/pxDV5WpOE3iPW3b4uDQosu1dOh//4a/fk`) |
| CUTLASS | https://github.com/NVIDIA/cutlass tag v3.9.2 = `ad7b2f5e84fcfa124cb02b91d5bd26d238c0459e` (BSD-3); `build-replay.sh` refuses any other commit |
| Upgrade path | v1.0.11 after Windows parity is established on v1.0.8 (owner decision 2026-10-06). The worker source did not change between those tags per upstream; re-verify the file hash when bumping. |

`PINS-SHA256.txt` lists the hashes of every pinned file in this repository.

## What Kraskus adds

Only the Windows build recipe (`build/build-windows.cmd`, CI workflow), the host-compiler flags MSVC needs (`/EHsc /bigobj /MT /Zc:__cplusplus`; the last one is required because CUTLASS 3.9.2's `platform.h` keys `is_unsigned_v` on `__cplusplus`), the parity procedure and documentation. No source patch.
