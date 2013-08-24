unspecified:
	@echo "need to 'make linux.exe', 'make osx.exe', 'make windows.exe', etc"

linux.exe: game.c
	gcc -o hello-linux `sdl-config --libs` -lGL -lm hello.c

osx.exe: game.c
	gcc -o hello-mac `sdl-config --libs` -framework Foundation -framework OpenGL -lm hello.c

