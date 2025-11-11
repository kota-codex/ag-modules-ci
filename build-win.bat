@echo on
setlocal enabledelayedexpansion

set triplet=%1
set GENERATOR=Ninja
set CONFIGS=Release Debug

if exist "update.bat" (
    call update.bat
)

for /F %%p in ('powershell -Command "(Get-CimInstance Win32_Processor).NumberOfLogicalCores"') do set CORES=%%p

set BUILD_DIR=build\%triplet%
if not exist "!BUILD_DIR!" mkdir "!BUILD_DIR!"
set OUT_DIR=..\..\out
if not exist "!OUT_DIR!" mkdir "!OUT_DIR!"
for %%c in (%CONFIGS%) do (
    echo Building %triplet%, config %%c in !BUILD_DIR!

    cmake -S "." -B "!BUILD_DIR!" -G "%GENERATOR%" ^
        -DCMAKE_TOOLCHAIN_FILE="%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake" ^
        -DVCPKG_TARGET_TRIPLET=%triplet% ^
        -DCMAKE_BUILD_TYPE=%%c ^
        -DAG_OUT_DIR=!OUT_DIR! ^
        -DAG_TRIPLE=%triplet%

    cmake --build "!BUILD_DIR!" --parallel !CORES!
)
