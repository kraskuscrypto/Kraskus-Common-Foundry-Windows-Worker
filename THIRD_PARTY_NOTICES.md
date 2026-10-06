# Third-party notices

## Common Foundry (worker source) — MIT

`src/koala_four_limb_replay.cu` and `upstream-scripts/build-replay.sh` are from https://github.com/Common-Foundry-1/CommonFoundry at commit `3aa5369512f47d0b3c49a49a54a0395e71e0c000`, licensed under the MIT License. The full licence text is in [LICENSE-UPSTREAM-MIT](LICENSE-UPSTREAM-MIT) and must accompany every binary built from this repository. "Common Foundry" is the upstream project's name; no endorsement is implied.

## NVIDIA CUTLASS — BSD-3-Clause

The build compiles against CUTLASS 3.9.2 (https://github.com/NVIDIA/cutlass, commit `ad7b2f5e84fcfa124cb02b91d5bd26d238c0459e`), Copyright (c) 2017–2025 NVIDIA CORPORATION & AFFILIATES, BSD 3-Clause License. The licence text is in [LICENSE-CUTLASS-BSD-3](LICENSE-CUTLASS-BSD-3). CUTLASS is header-only; its code is compiled into `cmfd-v4-replay.exe`.

## NVIDIA CUDA Runtime (cudart) — NVIDIA Software License Agreement (CUDA Toolkit EULA)

`cmfd-v4-replay.exe` statically links the CUDA Runtime library (`cudart_static`) from the NVIDIA CUDA Toolkit 12.8. Redistribution of the CUDA Runtime as part of an application is permitted under the CUDA Toolkit End User License Agreement (Attachment A, redistributable components). The EULA is available at https://docs.nvidia.com/cuda/eula/index.html. The NVIDIA driver (`nvcuda.dll`) is not distributed; it must be installed on the end user's system.

## Kraskus additions — MIT

The build script, CI workflow, parity driver and documentation in this repository are Copyright (c) 2026 Kraskus Crypto and licensed under the MIT License ([LICENSE](LICENSE)).
