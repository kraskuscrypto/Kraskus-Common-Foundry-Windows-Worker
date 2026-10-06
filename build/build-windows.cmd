@echo off
rem Kraskus native Windows build of the Common Foundry ProductionV4 replay worker.
rem Mirrors upstream tools/production-v4-prover/build-replay.sh @ 3aa5369 (v1.0.8):
rem   nvcc -O3 -std=c++17 --generate-code=arch=compute_{70,75,80,86,89,90,120},code=sm_*
rem        --generate-code=arch=compute_70,code=compute_70 -I<CUTLASS 3.9.2>/include koala_four_limb_replay.cu
rem Inputs (environment):
rem   CUDA_PATH     CUDA 12.8 toolkit root (default: the CUDA_PATH the toolkit installer sets)
rem   CUTLASS_ROOT  CUTLASS checkout at ad7b2f5e84fcfa124cb02b91d5bd26d238c0459e (default: third_party\cutlass)
rem   VCVARS        vcvars64.bat to call when cl.exe is not already on PATH (default: VS 2022 Build Tools)
rem Output: build\windows-x64\cmfd-v4-replay.exe + images-elf.txt + images-ptx.txt + SHA256SUMS
setlocal EnableDelayedExpansion
set "ROOT=%~dp0.."
for %%I in ("%ROOT%") do set "ROOT=%%~fI"
if not defined CUTLASS_ROOT set "CUTLASS_ROOT=%ROOT%\third_party\cutlass"
if not defined CUDA_PATH (echo CUDA_PATH is not set & exit /b 2)
set "NVCC=%CUDA_PATH%\bin\nvcc.exe"
set "CUOBJDUMP=%CUDA_PATH%\bin\cuobjdump.exe"
set "SRC=%ROOT%\src\koala_four_limb_replay.cu"
set "OUT=%ROOT%\build\windows-x64"
if not exist "%NVCC%" (echo nvcc not found at "%NVCC%" & exit /b 2)
if not exist "%CUTLASS_ROOT%\include\cutlass\cutlass.h" (echo CUTLASS not found at "%CUTLASS_ROOT%" & exit /b 2)
if not exist "%OUT%" mkdir "%OUT%"
where cl.exe >nul 2>nul
if errorlevel 1 (
  if not defined VCVARS set "VCVARS=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
  if not exist "%VCVARS%" set "VCVARS=C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
  if not exist "%VCVARS%" (echo vcvars64.bat not found; put cl.exe on PATH or set VCVARS & exit /b 2)
  call "%VCVARS%" >nul || exit /b 2
)
set "PATH=%CUDA_PATH%\bin;%PATH%"
"%NVCC%" --version | findstr /C:"release"
"%NVCC%" --list-gpu-code > "%OUT%\nvcc-gpu-code.txt"
for %%A in (sm_70 sm_75 sm_80 sm_86 sm_89 sm_90 sm_120) do (
  findstr /X /C:"%%A" "%OUT%\nvcc-gpu-code.txt" >nul || (echo The toolkit cannot emit %%A; CUDA 12.8 or 12.9 is required & exit /b 3)
)
"%NVCC%" -O3 -std=c++17 -cudart static -allow-unsupported-compiler ^
  -Xcompiler "/EHsc /bigobj /MT /W1 /nologo /Zc:__cplusplus" ^
  --generate-code=arch=compute_70,code=sm_70 ^
  --generate-code=arch=compute_75,code=sm_75 ^
  --generate-code=arch=compute_80,code=sm_80 ^
  --generate-code=arch=compute_86,code=sm_86 ^
  --generate-code=arch=compute_89,code=sm_89 ^
  --generate-code=arch=compute_90,code=sm_90 ^
  --generate-code=arch=compute_120,code=sm_120 ^
  --generate-code=arch=compute_70,code=compute_70 ^
  -I"%CUTLASS_ROOT%\include" -I"%CUDA_PATH%\include" ^
  "%SRC%" -o "%OUT%\cmfd-v4-replay.exe" %*
if errorlevel 1 exit /b 1
del /q "%OUT%\cmfd-v4-replay.lib" "%OUT%\cmfd-v4-replay.exp" 2>nul
"%CUOBJDUMP%" --list-elf "%OUT%\cmfd-v4-replay.exe" > "%OUT%\images-elf.txt" || exit /b 4
"%CUOBJDUMP%" --list-ptx "%OUT%\cmfd-v4-replay.exe" > "%OUT%\images-ptx.txt" || exit /b 4
for %%A in (sm_70 sm_75 sm_80 sm_86 sm_89 sm_90 sm_120) do (
  findstr /C:"%%A.cubin" "%OUT%\images-elf.txt" >nul || (echo Missing native image %%A & exit /b 4)
)
findstr /C:"sm_70.ptx" "%OUT%\images-ptx.txt" >nul || (echo Missing compute_70 PTX fallback & exit /b 4)
type "%OUT%\images-elf.txt" "%OUT%\images-ptx.txt"
powershell -NoProfile -Command "(Get-FileHash '%OUT%\cmfd-v4-replay.exe' -Algorithm SHA256).Hash.ToLower() + '  cmfd-v4-replay.exe' | Set-Content -Encoding ascii '%OUT%\SHA256SUMS'; Get-Content '%OUT%\SHA256SUMS'"
echo Replay targets verified: Volta and RTX 20/30/40/50; physical-card qualification is separate (parity/).
endlocal
