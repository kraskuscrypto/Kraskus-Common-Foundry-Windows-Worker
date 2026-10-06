# Agent instructions — Kraskus Common Foundry Windows Worker

This repository builds one binary, `cmfd-v4-replay.exe`, from pinned, unmodified upstream MIT source. It is **build-focused only**.

Rules:

1. **Never modify `src/koala_four_limb_replay.cu`.** It is a byte-for-byte copy of the upstream file; CI fails if its hash changes. Upgrading means replacing it with the upstream file of a newer tag and updating `UPSTREAM.md`, `PINS-SHA256.txt`, `CHANGELOG.md` and the CI hash.
2. **Pins are explicit and checked:** upstream commit, CUTLASS commit, CUDA version, MSVC expectations. Change them only with a documented reason.
3. **No fee, no telemetry, no network code, no protocol or arithmetic changes.** Exactness against the official worker is the only acceptance criterion (`parity/`).
4. **A build is not usable until it passes parity** (all 10,240 search nonces and all 8 full-trace nonces identical to the official capture). Record results under `parity/results/` and the qualified hash in `CHANGELOG.md`. Kraskus Universal Miner consumes releases as pinned, hash-verified artifacts — never as a source dependency.
5. Keep the licences and notices (`LICENSE`, `LICENSE-UPSTREAM-MIT`, `LICENSE-CUTLASS-BSD-3`, `THIRD_PARTY_NOTICES.md`) in every release archive.
6. No product code, no UI, no miner here. Product work belongs in Kraskus Universal Miner.
