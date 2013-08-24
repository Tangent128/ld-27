
#include <SDL/SDL.h>
#include <stdio.h>
#include <math.h>

#include "game.h"
#include "sprite.h"

// global state
int debugEnabled = 1;

// "world" data ===================

// mouse location
static int mx;
static int my;

// keys
static Uint8 kU = 0;
static Uint8 kD = 0;
static Uint8 kL = 0;
static Uint8 kR = 0;
static Uint8 kSpace = 0;
static Uint8 kEscape = 0;

// misc. state
static double time = 0.0;
static int sprite;

// major functions ==============

static void init() {
	// INIT SDL
	if( SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER) < 0) {
		printf("Could not initialize SDL: %s.\n", SDL_GetError());
		exit(-1);
	}
	atexit(SDL_Quit);

	// get OpenGL Context
	SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );
	SDL_Surface *win = SDL_SetVideoMode(640, 480, 32, SDL_OPENGL);
	
	// init graphics
	glInit();
	
	// dummy sprite
	sprite = makeTexture("10seconds.png");
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
						kU = evt.key.state;
						break;
					case SDLK_DOWN:
						kD = evt.key.state;
						break;
					case SDLK_LEFT:
						kL = evt.key.state;
						break;
					case SDLK_RIGHT:
						kR = evt.key.state;
						break;
				}
				break;
			case SDL_MOUSEBUTTONDOWN:
				//SDL_WM_GrabInput(SDL_GRAB_ON);
				break;
			case SDL_MOUSEMOTION:
				// record the mouse location
				mx = evt.motion.x;
				my = evt.motion.y;
				break;
			//default: printf("Event type %d\n", evt.type);
		}
		
	}
}

static void tick() {
	// advance clock
	time = time + 0.3;
	
	//printf("Keys: U:%hhd D:%hhd L:%hhd R:%hhd Escape:%hhd Space:%hhd\n", kU, kD, kL, kR, kEscape, kSpace);
	
/*  // base one of the thingy's points on the mouse location
  points[0] = mx/320.0 - 1.0;
  points[1] = my/-240.0 + 1.0;

  // base thingy color on time
  rgb[0] = sin(time);
  rgb[1] = cos(time);
  rgb[2] = 0;
  
  // spin camera
    
  double spin = oscillate (10, time, 0.02);
  projectionMatrix[3] = translatex;
    
  double spin = time * 0.2;
    projectionMatrix[0] = cos(spin);
    projectionMatrix[1] = -sin(spin);
    projectionMatrix[4] = sin(spin);
    projectionMatrix[5] = cos(spin);
    projectionMatrix[7] = translatey;*/
}

static void draw() {
	
	// clear screen
	
	drawBackground();
	
	beginSprites(100,100);
		drawSprite(0,0,sprite);
	endSprites();
	
	/*
	
	// move camera
	glUniformMatrix4fv(projection, 1, GL_FALSE, &projectionMatrix[0]);
	
	// send color to shader
	glUniform3f(color, rgb[0], rgb[1], 1.0);
	
	// copy new point data into buffer
	glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(points), &points);
	
	// draw the thingy
	glDrawElements(GL_TRIANGLES, 9, GL_UNSIGNED_SHORT, 0);

	*/

	// present image to screen	
	SDL_GL_SwapBuffers();
}

int main(int argc, char** argv) {

	// Step 0: Init
	init();
	
	// The Loop
	while(1) {
		// Step 1: Input
		input();
		
		// Step 2: "Physics" (whatever that means for game world)
		tick();
		
		// Step 3: Render
		draw();
		
		// Step 4: Wait (for next frame)
		SDL_Delay(30);
	}
	
}

