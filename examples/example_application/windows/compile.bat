mkdir build

:: If below doesn't work for you
:: NOTE: `rc.exe` may be found at "C:\Program Files (x86)\Windows Kits\10\bin\10.0.22000.0\x64\rc.exe" if not in PATH
:: rc /r /fo build\resources.res resources.rc
:: nim c -d:useRC --cc:vcc main.nim

windres -o build/resources.res -i resources.rc
nim c main.nim