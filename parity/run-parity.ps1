<#
Kraskus native Windows cmfd-v4-replay.exe: golden-vector parity run.

Run on a Windows x64 host with an NVIDIA GPU (>= 8 GB VRAM, compute capability >= 7.0,
driver >= 570 for the CUDA 12.8 runtime). No admin rights needed. Nothing is installed.

What it proves: the Kraskus-built worker (unmodified upstream source @ 3aa5369, CUTLASS 3.9.2,
nvcc 12.8.93 + MSVC 14.44) produces byte-identical outputs to the OFFICIAL CUDA worker
(f872912b..., captured on the RTX 5070 under Linux, 2026-10-02) for all 10,240 search nonces
and all 8 full-trace nonces of the Phase 4 golden set, driven through the official TAB protocol.

  .\run-parity.ps1 -Bank D:\cmfd\MODEL-V2.bank [-Worker ..\build\windows-x64\cmfd-v4-replay.exe]
                   [-Scratch D:\cmfd\scratch] [-DownloadBank]

-DownloadBank fetches the 4 official bank parts (1.61 GB each, pinned SHA-256, official CDN then
GitHub fallback), verifies each part, assembles MODEL-V2.bank and verifies the whole (needs ~13 GB).
#>
param(
  [Parameter(Mandatory = $true)][string]$Bank,
  [string]$Worker = (Join-Path $PSScriptRoot "..\build\windows-x64\cmfd-v4-replay.exe"),
  [string]$Scratch = (Join-Path $PSScriptRoot "scratch"),
  [switch]$DownloadBank,
  # Verify inputs and the bank (downloading it if asked) and stop: for staging a host before its GPU is attached.
  [switch]$StageOnly
)
$ErrorActionPreference = "Stop"
$golden = Join-Path $PSScriptRoot "golden"
$tools = Join-Path $PSScriptRoot "tools"
$out = Join-Path $PSScriptRoot ("results\" + (Get-Date -Format "yyyy-MM-dd-HHmm") + "-" + $env:COMPUTERNAME.ToLower())
New-Item -ItemType Directory -Force $out, $Scratch | Out-Null
$log = Join-Path $out "00-run.log"
function Log($m) { $line = "[{0}] {1}" -f (Get-Date -Format "HH:mm:ss"), $m; $line; Add-Content $log $line }
function Sha($p) { (Get-FileHash -Algorithm SHA256 -LiteralPath $p).Hash.ToLower() }
function Expect($p, $sha) { $got = Sha $p; if ($got -ne $sha) { throw "hash mismatch for $p`n  expected $sha`n  got      $got" }; Log "ok  $([IO.Path]::GetFileName($p)) $got" }

# ---- pinned inputs (GOLDEN-INPUTS.json 801a030c..., capture manifest 3ee464b2...) ----
$pins = @{
  "GOLDEN-INPUTS.json"      = "801a030cc6d266de5b4e60a863e0fa80551696db49fdd92f53d96a5e7bd9cf80"
  "capture-manifest.json"   = "3ee464b236eb818d38955dd9a4e3f60ec5d823422fea855bab945bcdb71328ef"
  "search-coefficients.bin" = "5accd4f138282995ee30b2fe800d0fb8df5dfb9918f1ccfe378aa0855faafec1"
  "full-coefficients.bin"   = "a0d2a46bf61ebae30de81eb86600d793c434927792eccef20b3a864a34323261"
  "search-digests.txt"      = "c01e1ae1bc1b7c0f434554c579a10ff281e4b5ce446121f4c74f12c4f5ea9494"
  "full-digests.txt"        = "57cd287b9a308a6a2bed7aa636e0921ca1bcbcb8328da41df311661b96dc2f44"
}
$bankSha = "5f9b213c3bda51b74e4ebabb26607b67385d613aa8d99af915a48ab063e17d4e"
$bankBytes = 6442975416
$parts = @(
  @{ name = "V4-MODEL-V2.bank.part01"; sha = "3af0fd15bf0377bab42f2c59d8337f4f82e87e32c5f8c4f27ebfc21681450254" },
  @{ name = "V4-MODEL-V2.bank.part02"; sha = "9d4f2547dc632c1c5f74ace84d26ca2ce38be50bea01ed93542fc5ab56aed6cf" },
  @{ name = "V4-MODEL-V2.bank.part03"; sha = "a1bf1ac3230a54006039b3ce2add912e4c6f94065afad322bbaebee15b089602" },
  @{ name = "V4-MODEL-V2.bank.part04"; sha = "5af1c6de16f5d48032aa9b37a5d48abd5d6c6e22b24935476faddb9af2cf7069" }
)
$bases = @("https://downloads.commonfoundry.ai/v0.1.0-rc.1", "https://github.com/JustAResearcher/CommonFoundry-Binaries/releases/download/v0.1.0-rc.1")

Log "worker  $Worker sha256 $(Sha $Worker)"
foreach ($k in $pins.Keys) { Expect (Join-Path $golden $k) $pins[$k] }
if (-not $StageOnly) { Log "nvidia-smi: $((& nvidia-smi --query-gpu=name,uuid,driver_version,memory.total --format=csv,noheader) -join ' | ')" }

# ---- model bank ----
if (-not (Test-Path -LiteralPath $Bank)) {
  if (-not $DownloadBank) { throw "bank not found at $Bank (pass -DownloadBank to fetch the official parts)" }
  $dir = Split-Path -Parent $Bank; New-Item -ItemType Directory -Force $dir | Out-Null
  foreach ($p in $parts) {
    $dst = Join-Path $dir $p.name
    if (-not (Test-Path -LiteralPath $dst) -or (Sha $dst) -ne $p.sha) {
      $ok = $false
      foreach ($b in $bases) {
        try { Log "download $($p.name) from $b"; curl.exe -fL --retry 3 -C - -o $dst "$b/$($p.name)" | Out-Null; if ((Sha $dst) -eq $p.sha) { $ok = $true; break } } catch { Log "  failed: $_" }
      }
      if (-not $ok) { throw "could not fetch a valid $($p.name)" }
    }
    Log "ok  $($p.name)"
  }
  $tmp = "$Bank.assemble"
  $fs = [IO.File]::Create($tmp)
  try { foreach ($p in $parts) { $in = [IO.File]::OpenRead((Join-Path $dir $p.name)); try { $in.CopyTo($fs) } finally { $in.Dispose() } } } finally { $fs.Dispose() }
  if ((Get-Item $tmp).Length -ne $bankBytes) { throw "assembled bank has the wrong length" }
  Expect $tmp $bankSha
  Move-Item -Force $tmp $Bank
}
if ((Get-Item -LiteralPath $Bank).Length -ne $bankBytes) { throw "bank has the wrong length" }
Expect $Bank $bankSha
if ($StageOnly) { Log "stage-only: inputs, tools and bank verified; GPU steps skipped"; exit 0 }

# ---- 1. official self-test on this GPU ----
Log "self-test ..."
& $Worker --self-test *> (Join-Path $out "01-selftest.txt"); $selfRc = $LASTEXITCODE
Get-Content (Join-Path $out "01-selftest.txt") | ForEach-Object { Log "  $_" }
if ($selfRc -ne 0 -or -not (Select-String -Path (Join-Path $out "01-selftest.txt") -Pattern "replay_self_test=EXACT" -Quiet)) { throw "self-test failed (exit $selfRc)" }

# ---- 2. golden compare: every per-nonce hash and every kept file must be identical ----
$capture = Join-Path $tools "cmfd-v4-capture.exe"
Log "compare (10240 search nonces as RUNBATCH 32 + 8 RUN full) ..."
$sw = [Diagnostics.Stopwatch]::StartNew()
& $capture compare --worker $Worker --bank $Bank --manifest (Join-Path $golden "capture-manifest.json") --scratch $Scratch `
  --search-coefficients (Join-Path $golden "search-coefficients.bin") --search-digests (Join-Path $golden "search-digests.txt") `
  --full-coefficients (Join-Path $golden "full-coefficients.bin") --full-digests (Join-Path $golden "full-digests.txt") `
  --batch-size 32 --timeout-secs 3600 *> (Join-Path $out "02-compare.txt")
$cmpRc = $LASTEXITCODE; $sw.Stop()
Get-Content (Join-Path $out "02-compare.txt") -Tail 25 | ForEach-Object { Log "  $_" }
Log ("compare exit {0} after {1:n0} s" -f $cmpRc, $sw.Elapsed.TotalSeconds)
$verdict = if ($cmpRc -eq 0) { "PASS" } else { "FAIL" }
@"
# Native Windows cmfd-v4-replay parity - $env:COMPUTERNAME - $(Get-Date -Format "yyyy-MM-dd HH:mm")

| Item | Value |
|---|---|
| Worker | $Worker |
| Worker sha256 | $(Sha $Worker) |
| GPU | $((& nvidia-smi --query-gpu=name,uuid,driver_version --format=csv,noheader) -join ' ') |
| Self-test | exit $selfRc (01-selftest.txt) |
| Golden compare | **$verdict** (exit $cmpRc, $([int]$sw.Elapsed.TotalSeconds) s, 02-compare.txt) |
| Golden set | GOLDEN-INPUTS 801a030c..., official capture manifest 3ee464b2... (official worker f872912b..., RTX 5070, 2026-10-02) |
"@ | Set-Content (Join-Path $out "SUMMARY.md")
Get-Content (Join-Path $out "SUMMARY.md")
if ($cmpRc -ne 0) { exit 1 }
