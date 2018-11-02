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
git checkout master
git pull
cd ..

REM Copy over needed stuff
xcopy /s copy\* leveldb-mcpe\

REM Patch fixes
cd leveldb-mcpe
git apply ../fixes.patch > compile.log 2>&1
cd ..

echo Compiling linux version (ubuntu 18.04)

REM Build linux version first
wsl ./compile.sh > compile.log 2>&1

echo Finished linux build
echo Compiling windows version (windows 7)

REM Build windows version now
compile_windows.bat