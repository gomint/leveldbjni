@echo off

REM Get rid of old logs
if exist compile.log (
  del compile.log
)

echo Creating resources and clearing previous builds

REM Make resources dir
@mkdir ..\resources > compile.log 2>&1

REM Delete old builds
@del /Q /S ..\resources\* > compile.log 2>&1

echo Setting up leveldb-mcpe

REM Remove leveldb-mcpe
@rmdir leveldb-mcpe /s /q > compile.log 2>&1

REM Get all submodules
git submodule update --init > compile.log 2>&1

REM We apply the mingw fixes first
cd leveldb-mcpe 
git apply ../mingw.patch > ../compile.log 2>&1
cd ..

echo Compiling linux version (ubuntu 18.04)

REM Build linux version first
wsl ./compile.sh > compile.log 2>&1

echo Finished linux build
echo Compiling windows version (windows 7)

REM Build windows version now
C:\msys64\mingw64.exe ./compile_windows.sh

REM since mingw64 is run async (not in this process) we need to check if the compiled dll is there
:still_more_files
    if not exist ..\resources\leveldb-mcpe.dll (
        echo Still waiting for windows compile to finish
		ping 127.0.0.1 -n 2 > nul
        goto :still_more_files
    )

echo Finished windows build

REM upx (pack the build)
echo Packing binaries

upx.exe --best ../resources/leveldb-mcpe.dll
upx.exe --best ../resources/leveldb-mcpe.so

echo Done