LUA_DIR= c/lua-5.2.2
LUA_CFLAGS= -I$(LUA_DIR)/src
LUA_LFLAGS= -L$(LUA_DIR)/src -llua
LUA_LIB= $(LUA_DIR)/src/liblua.a

GLEW_CFLAGS= -Ic -DGLEW_STATIC

CFLAGS= $(LUA_CFLAGS) $(GLEW_CFLAGS)
LFLAGS= `sdl-config --libs` $(LUA_LFLAGS) -lm

WIN_CFLAGS=-Dmain=SDL_main $(GLEW_CFLAGS)

HEADERS= c/game.h c/sprite.h
O_FILES= c/game.o c/sprite.o c/glew.o
PREDEPS= $(LUA_LIB) $(HEADERS)

CC= $(CROSS)gcc

unspecified:
	@echo "need to 'make linux.exe', 'make osx.exe', 'make windows.exe', etc" $(LUA_CFLAGS)

linux.exe: $(O_FILES) $(LUA_LIB)
	$(CC) -o linux.exe $(O_FILES) -lGL $(LFLAGS)

osx.exe: $(O_FILES) $(LUA_LIB)
	$(CC) -o osx.exe $(O_FILES) -framework Foundation -framework OpenGL $(LFLAGS)

#	cross-windows:
#	SDL_DIR=~/code/mingw/SDL-1.2.15
#	LUA_DIR=~/code/mingw/lua-5.2.2/src
#	export CPATH=$SDL_DIR/include/:$LUA_DIR
#	
#	#export LIBRARY_PATH=$SDL_DIR/lib
#
#	make CROSS=i486-mingw32- CFLAGS="\$(WIN_CFLAGS)" LFLAGS=-L$SDL_DIR/lib DLLS="$LUA_DIR/lua52.dll $SDL_DIR/bin/SDL.dll" windows.exe
windows.exe: $(O_FILES)
	$(CC) -o windows.exe $(O_FILES) $(LFLAGS) -lmingw32 -lSDLmain -lSDL -lopengl32  $(DLLS) -mwindows

# compile
#.SUFFIXES: .c .o
#.c.o:
#	$(CC) -c -o $@ $(CFLAGS) $<
	

# libs
$(LUA_LIB):
	cd $(LUA_DIR) && make CC=$(CC) generic

# files
c/game.o: c/game.c $(HEADERS)
	$(CC) -c -o $@ $(CFLAGS) $<
c/sprite.o: c/sprite.c $(HEADERS)
	$(CC) -c -o $@ $(CFLAGS) $<
c/glew.o: c/glew.c $(HEADERS)
	$(CC) -c -o $@ $(CFLAGS) $<

cleanGame:
	rm -f c/*.o
	rm -f *.exe

clean: cleanGame
	cd $(LUA_DIR) && make clean

	
.PHONY: unspecified clean cross-windows

