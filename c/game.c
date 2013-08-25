
#include <SDL/SDL.h>
#include <stdio.h>
#include <math.h>
#include <lua.h>
#include <lauxlib.h>

#include "game.h"
#include "sprite.h"

// global state
int debugEnabled = 1;

// "world" data ===================

// mouse location
static float mx;
static float my;

// keys
static Uint8 kU = 0;
static Uint8 kD = 0;
static Uint8 kL = 0;
static Uint8 kR = 0;
static Uint8 kSpace = 0;
static Uint8 kEscape = 0;

// misc. state
static int time = 0;

// major functions ==============

static void initSDL() {
	// INIT SDL
	if( SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER) < 0) {
		printf("Could not initialize SDL: %s.\n", SDL_GetError());
		exit(-1);
	}
	atexit(SDL_Quit);
	
	// titlebar
	SDL_WM_SetCaption("Snooze Button", NULL);
	
	// hide mouse
	SDL_ShowCursor(SDL_DISABLE);
	
	// get OpenGL Context
	SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );
	SDL_Surface *win = SDL_SetVideoMode(640, 480, 32, SDL_OPENGL);
}

static void initLua(lua_State *L, int argc, char** argv) {
	
	// init Lua
	luaL_openlibs(L);

	// expose sprite libs
	luaopen_sprite(L);
	lua_setglobal(L, "g");

	// load main Lua code
	int status = luaL_loadfile(L, "lua/game.lua");
	if(status == LUA_OK) {
		// push command-line args
		lua_checkstack(L, argc);
		int i;
		for(i = 1; i < argc; i++) { // i = 1: skip program name
			lua_pushstring(L, argv[i]);
		}
		
		status = lua_pcall(L, argc - 1, 0, 0); // argc - 1: skip program name
	}
	if(status != LUA_OK) {
		const char* errorMessage = lua_tostring(L, -1);
		printf("Error loading main.lua: %s %d\n", errorMessage, argc);
		exit(1);
	}

}

static void input() {
	
	SDL_Event evt;
	while(SDL_PollEvent(&evt) > 0) {
		
		switch(evt.type) {
			case SDL_QUIT:
				exit(0);
				break;
			case SDL_KEYDOWN:
			case SDL_KEYUP:
				switch(evt.key.keysym.sym) {
					case SDLK_ESCAPE:
						//SDL_WM_GrabInput(SDL_GRAB_OFF);
						kEscape = evt.key.state;
						break;
					case SDLK_SPACE:
						kSpace = evt.key.state;
						break;
					case SDLK_UP:
					case SDLK_w:
						kU = evt.key.state;
						break;
					case SDLK_DOWN:
					case SDLK_s:
						kD = evt.key.state;
						break;
					case SDLK_LEFT:
					case SDLK_a:
						kL = evt.key.state;
						break;
					case SDLK_RIGHT:
					case SDLK_d:
						kR = evt.key.state;
						break;
				}
				break;
			case SDL_MOUSEBUTTONDOWN:
				//SDL_WM_GrabInput(SDL_GRAB_ON);
				break;
			case SDL_MOUSEMOTION:
				// record the mouse location
				// and translate to game coordinates
				mx = evt.motion.x / 32.0;
				my = (480 - evt.motion.y) / 32.0;
				break;
			//default: printf("Event type %d\n", evt.type);
		}
		
	}
}


int main(int argc, char** argv) {

	lua_State *L = luaL_newstate();

	// Step 0: Init
	initSDL();
	initGL(); // in sprite.c
	initLua(L, argc, argv);
		
	// push Lua game loop function onto stack
	lua_getglobal(L, "gameCycle");
	

	// The Loop
	while(1) {
		// Step 1: Input
		input();
		
		// Step 2 & 3: "Physics" & Rendering (Lua-driven)
	beginSprites(0,0);
		
		lua_pushvalue(L, -1); // gameLoop function
		lua_pushinteger(L, time);
		lua_pushnumber(L, mx);
		lua_pushnumber(L, my);
		lua_pushboolean(L, kU == SDL_PRESSED);
		lua_pushboolean(L, kD == SDL_PRESSED);
		lua_pushboolean(L, kL == SDL_PRESSED);
		lua_pushboolean(L, kR == SDL_PRESSED);
		lua_pushboolean(L, kSpace == SDL_PRESSED);
		lua_pushboolean(L, kEscape == SDL_PRESSED);
		
		int status = lua_pcall(L, 9, 0, 0);
		if(status != LUA_OK) {
			const char* errorMessage = lua_tostring(L, -1);
			printf("Error: %s\n", errorMessage);
			exit(1);
		}
		
	endSprites();
		
		// Step 3.9: Flip rendered image to screen
		SDL_GL_SwapBuffers();
		
		// Step 4: Wait (for next frame)
		SDL_Delay(30);
		time = time + 30;
	}
	
}

