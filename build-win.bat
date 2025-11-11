@echo on
setlocal enabledelayedexpansion

set GENERATOR=Ninja

set CONFIGS=Release Debug

if exist "update.bat" (
    call update.bat
)

for /f %%p in ('wmic cpu get NumberOfLogicalProcessors ^| findstr /r /v "^$"') do set CORES=%%p

set triplet=%1

echo ================================
echo Building for %triplet%
echo ================================

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
