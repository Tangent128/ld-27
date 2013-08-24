unspecified:
	@echo "need to 'make linux.exe', 'make osx.exe', 'make windows.exe', etc"

linux.exe: game.c
	gcc -o linux.exe `sdl-config --libs` -lGL -lm game.c

osx.exe: game.c
	gcc -o osx.exe `sdl-config --libs` -framework Foundation -framework OpenGL -lm game.c

