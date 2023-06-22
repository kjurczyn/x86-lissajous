CC=gcc
ASMBIN=nasm
FUN_NAME=lissajous
PATH_TO_LIB=C:\msys64\mingw64\include

all : asm cc link clean
asm : 
	$(ASMBIN) -o $(FUN_NAME).o -f win64 $(FUN_NAME).asm
cc :
	$(CC) -static -I$(PATH_TO_LIB) -c -g -m64 main.c
link :
	$(CC) -o x64/$(FUN_NAME) main.o  -lallegro -lallegro_image -lallegro_font $(FUN_NAME).o
	xcopy data x64\data /y /q
	
clean :
	del /q *.o