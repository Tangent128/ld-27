LUA_DIR= c/lua-5.2.2
LUA_CFLAGS= -I$(LUA_DIR)/src
LUA_LFLAGS= -L$(LUA_DIR)/src -llua
LUA_LIB= $(LUA_DIR)/src/liblua.a

CFLAGS= $(LUA_CFLAGS) $(EXTRA_CFLAGS)
LFLAGS= `sdl-config --libs` $(LUA_LFLAGS) -lm

HEADERS= c/game.h
O_FILES= c/game.o c/sprite.o
PREDEPS= $(LUA_LIB) $(HEADERS)

CC= $(CROSS)gcc

unspecified:
	@echo "need to 'make linux.exe', 'make osx.exe', 'make windows.exe', etc"

linux.exe: $(O_FILES)
	$(CC) -o linux.exe $(O_FILES) -lGL $(LFLAGS)

osx.exe: $(O_FILES)
	$(CC) -o osx.exe $(O_FILES) -framework Foundation -framework OpenGL $(LFLAGS)

#cross-windows: (still working on it)
#	
#	export CPATH=~/code/mingw/SDL-1.2.15/include/
#	
#	make CROSS=i486-mingw32-  windows.exe
#windows.exe: $(O_FILES)
#	$(CC) -o windows.exe $(O_FILES) -lopengl 

# compile
#.SUFFIXES: .c .o
#.c.o:
#	gcc -c -o $@ $(LUA_CFLAGS) $<
	

# libs
$(LUA_LIB):
	cd $(LUA_DIR) && make CC=$(CC) generic

# files
c/game.o: c/game.c $(PREDEPS)
	$(CC) -c -o $@ $(CFLAGS) $<
c/sprite.o: c/sprite.c $(PREDEPS)
	$(CC) -c -o $@ $(CFLAGS) $<
	
clean:
	cd $(LUA_DIR) && make clean
	rm -f c/*.o
	rm -f *.exe

	
.PHONY: unspecified clean cross-windows

