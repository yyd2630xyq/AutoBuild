@REM use winlibs-i686-mcf-dwarf-gcc-13.1.0-mingw-w64msvcrt-11.0.0-r5
@REM C:\msys64\mingw32\bin\gcc.exe

gcc -Wall -O2 -s -o yenvprobe.exe yenvprobe.c

move /Y *.exe ..\bin\
