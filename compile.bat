@echo off

set ARCH=x64
set VS_VER=
set VS_YEAR=
set CMAKE_TARGET=
set LEVELDB_MCPE_VER=84348b9b826cc280cde659185695d2170b54824c
set DEPS_DIR=%~dp0\deps

where git >nul 2>nul || (call :pm-echo-error "git is required")
where cmake >nul 2>nul || (call :pm-echo-error "cmake is required")
where 7z >nul 2>nul || (call :pm-echo-error "7z is required")
where wget >nul 2>nul || (call :pm-echo-error "wget is required")

call :check-vs-exists 2017 15 || call :check-vs-exists 2019 16 || call :pm-fatal-error "Please install Visual Studio 2017 or 2019"

rm %DEPS_DIR% -rf || :
mkdir %DEPS_DIR%
cd /D %DEPS_DIR%

call :pm-echo "Downloading deps..."

call :get-zip https://zlib.net/zlib1211.zip || call :pm-fatal-error "Could not download zlib"
call :get-zip https://github.com/pmmp/leveldb/archive/%LEVELDB_MCPE_VER%.zip || call :pm-fatal-error "Could not download leveldb"

move leveldb-%LEVELDB_MCPE_VER% leveldb
move zlib-1.2.11 zlib

call :pm-echo "Building zlib"

cd /D zlib
cmake -G "%CMAKE_TARGET%" -A "%ARCH%" || exit 1
call :pm-echo "Compiling"
msbuild ALL_BUILD.vcxproj /p:Configuration=Release /m 2>&1 || exit 1
cd ..

cd /D leveldb
call :pm-echo "Building leveldb"
cmake -G "%CMAKE_TARGET%" -A "%ARCH%"^
 -DCMAKE_PREFIX_PATH="%DEPS_DIR%"^
 -DCMAKE_INSTALL_PREFIX="%DEPS_DIR%"^
 -DBUILD_SHARED_LIBS=OFF^
 -DLEVELDB_BUILD_BENCHMARKS=OFF^
 -DLEVELDB_BUILD_TESTS=OFF^
 -DZLIB_LIBRARY="%DEPS_DIR%\zlib\Release\zlib.lib"^
 . 2>&1 || exit 1
call :pm-echo "Compiling"
msbuild ALL_BUILD.vcxproj /p:Configuration=Release /m 2>&1 || exit 1
cd ..

cd /D ../src/main/c
cmake -G "%CMAKE_TARGET%" -A "%ARCH%" || exit 1
call :pm-echo "Compiling"
msbuild ALL_BUILD.vcxproj /p:Configuration=Release /m 2>&1 || exit 1
call :pm-echo "Installing files... (this is ok to fail)"
msbuild INSTALL.vcxproj /p:Configuration=Release 2>&1 || exit 1

:check-vs-exists
if exist "C:\Program Files (x86)\Microsoft Visual Studio\%~1" (
    set VS_VER=%~2
    set VS_YEAR=%~1
    set CMAKE_TARGET=Visual Studio %~2 %~1
    call :pm-echo "Found Visual Studio %~1"
    exit /B 0
) else (
    call :pm-echo "DID NOT FIND VS %~1"
    set VS_VER=
    set VS_YEAR=
    exit /B 1
)

:get-extension-zip-from-github:
call :pm-echo " - %~1: downloading %~2..."
call :get-zip https://github.com/%~3/%~4/archive/%~2.zip || exit /B 1
move %~4-%~2 %~1 >>"%log_file%" 2>&1 || exit /B 1
exit /B 0

:get-zip
wget %~1 --no-check-certificate -q -O temp.zip || exit /B 1
7z x -y temp.zip >nul || exit /B 1
del /s /q temp.zip >nul || exit /B 1
exit /B 0

:pm-fatal-error
call :pm-echo-error "%~1 - check compile.log for details"

:pm-echo-error
call :pm-echo "[ERROR] %~1"
exit /B 0

:pm-echo
echo [PocketMine] %~1
echo [PocketMine] %~1 >>"%log_file%" 2>&1
exit /B 0