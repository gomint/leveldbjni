set VCTargetsPath=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\IDE\VC\VCTargets
set MSBuildPath=C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin
set dir=%~dp0

REM Download zlib
@del /Q /S zlib.zip
powershell -Command "(New-Object Net.WebClient).DownloadFile('https://zlib.net/zlib1211.zip', 'zlib.zip')"

REM Extract zlib
mkdir zlib
powershell.exe -nologo -noprofile -command "& { $shell = New-Object -COM Shell.Application; $target = $shell.NameSpace('%dir%zlib'); $zip = $shell.NameSpace('%dir%zlib.zip'); $target.CopyHere($zip.Items(), 16); }"

REM Add path to MSBuild Binaries
@if exist "%ProgramFiles%\MSBuild\14.0\bin" set PATH=%ProgramFiles%\MSBuild\14.0\bin;%PATH%
@if exist "%ProgramFiles(x86)%\MSBuild\14.0\bin" set PATH=%ProgramFiles(x86)%\MSBuild\14.0\bin;%PATH%

REM Compile zlib
copy copy\zlib\zlibstat.vcxproj zlib\zlib-1.2.11\contrib\vstudio\vc14\zlibstat.vcxproj
"%MSBuildPath%\msbuild.exe" zlib\zlib-1.2.11\contrib\vstudio\vc14\zlibstat.vcxproj /p:Configuration=ReleaseWithoutAsm /p:Platform=x64
mkdir zlib\zlib
copy zlib\zlib-1.2.11\zconf.h zlib\zlib\zconf.h
copy zlib\zlib-1.2.11\zlib.h zlib\zlib\zlib.h
copy zlib\zlib-1.2.11\zconf.h zlib\zconf.h
copy zlib\zlib-1.2.11\zlib.h zlib\zlib.h

REM Compile leveldb
"%MSBuildPath%\msbuild.exe" leveldb-mcpe\leveldb.vcxproj /p:Configuration=Release /p:Platform=x64 /p:ZlibLibPath=%dir%zlib\zlib-1.2.11\contrib\vstudio\vc14\x64\ZlibStatReleaseWithoutAsm\zlibstat.lib /p:ZlibIncludePath=%dir%zlib\

REM Copy over to resources
copy leveldb-mcpe\x64\Release\leveldb.dll ..\resources\leveldb-mcpe.dll