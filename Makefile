LUA_DIR= c/lua-5.2.2
LUA_CFLAGS= -I$(LUA_DIR)/src
LUA_LFLAGS= -L$(LUA_DIR)/src -llua
LUA_LIB= $(LUA_DIR)/src/liblua.a

CFLAGS= $(LUA_CFLAGS)
LFLAGS= `sdl-config --libs` $(LUA_LFLAGS) -lpng -lm

HEADERS= c/game.h
O_FILES= c/game.o c/sprite.o
PREDEPS= $(LUA_LIB) $(HEADERS)

unspecified:
	@echo "need to 'make linux.exe', 'make osx.exe', 'make windows.exe', etc"

linux.exe: $(O_FILES)
	gcc -o linux.exe -lGL $(LFLAGS) $(O_FILES)

osx.exe: $(O_FILES)
	gcc -o osx.exe -framework Foundation -framework OpenGL $(LFLAGS) $(O_FILES)


# compile
.SUFFIXES: .c .o
.c.o:
	gcc -c -o $@ $(LUA_CFLAGS) $<
	

# libs
$(LUA_LIB):
	cd $(LUA_DIR) && make generic

# files
c/game.o: c/game.c $(PREDEPS)
c/sprite.o: c/sprite.c $(PREDEPS)

clean:
	cd $(LUA_DIR) && make clean
	rm -f c/*.o
	rm *.exe

	
.PHONY: unspecified clean

