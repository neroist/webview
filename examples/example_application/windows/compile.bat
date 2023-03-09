mkdir build

windres -o build/resources.o resources.rc
nim c main.nim