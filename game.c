
#define GL_GLEXT_PROTOTYPES 1

#include <SDL/SDL.h>

#if defined(__MACOSX__)
	#include <OpenGL/gl.h>
#else
	#include <GL/gl.h>
#endif

#include <stdio.h>
#include <math.h>

// max size of source handled
#define FILE_SIZE (1024*100)

// hold OpenGL object names
static GLuint vertices;
static GLuint elements;
static GLint position;
static GLint projection;
static GLint color;

// "world" data ===================

// mouse location
static GLuint mx;
static GLuint my;

// misc. state
static double time = 0;
static float rgb[3];

// geometry
static GLfloat points[] = {
	0.3, 0.0, 0.0, // <-- this point gets mutated
	0.0, 0.3, 0.0,
	0.0, 0.0, 0.3,
	-0.3, 0.0, 0.0,
	0.0, -0.6, 0.0,
	0.0, 0.0, -0.3,
};
static GLshort tris[] = {
	0, 1, 2,
	3, 4, 5,
	0, 3, 1,
};

static GLfloat projectionMatrix[] = {
	1.0, 0.0, 0.0, 0.0,
	0.0, 1.0, 0.0, 0.0,
	0.0, 0.0, 1.0, 0.0,
	0.0, 0.0, 0.0, 1.0,
};


// helper functions ================

// read a file (caller needs to free buffer)
static char* grabFile(FILE* file, int* size) {
	char* buffer = malloc(FILE_SIZE);
	*size = fread(buffer, 1, FILE_SIZE - 1, file);
	
	// null terminate
	buffer[*size] = 0;
	return buffer;
}

// compile a file to a shader
static GLuint grabShader(char* filename, GLenum shaderType) {

	GLuint shader = glCreateShader(shaderType);
	
	// load source into shader
	GLint codeSize;
	FILE* file = fopen(filename, "r");
	GLchar* source = grabFile(file, &codeSize);
	
	glShaderSource(shader, 1, (const GLchar**) &source, NULL);
	free(source);
	fclose(file);
	
	// compile shader
	glCompileShader(shader);
	
	return shader;
}

// major functions ==============

static void init() {
	// INIT SDL
	if( SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER) < 0) {
		printf("Could not initialize SDL: %s.\n", SDL_GetError());
		exit(-1);
	}
	atexit(SDL_Quit);

	SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );
	SDL_Surface *win = SDL_SetVideoMode(640, 480, 32, SDL_OPENGL);
	
	// setup OpenGL
	glClearColor( 0, 0, 100, 255 );
	
	glGenBuffers(1, &vertices);
	glGenBuffers(1, &elements);
	
	glBindBuffer(GL_ARRAY_BUFFER, vertices);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elements);
	
	glBufferData(GL_ARRAY_BUFFER, sizeof(points), &points, GL_STATIC_DRAW);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(tris), &tris, GL_STATIC_DRAW);
	
	//glVertexPointer(3, GL_FLOAT, 0, 0);
	//glEnableClientState(GL_VERTEX_ARRAY);

	// ...shaders...
	GLuint vertexS = grabShader("hello.v.glsl", GL_VERTEX_SHADER);
	GLuint fragmentS = grabShader("hello.f.glsl", GL_FRAGMENT_SHADER);
	
	GLuint program = glCreateProgram();
	glAttachShader(program, vertexS);
	glAttachShader(program, fragmentS);
	glLinkProgram(program);
	
	position = glGetAttribLocation(program, "position");
	projection = glGetUniformLocation(program, "projection");
	color = glGetUniformLocation(program, "color");
	
	// setup attributes
	glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, 0, 0);
	glEnableVertexAttribArray(position);
	//printf("%d %d\n", position, color);

	// ready
	glUseProgram(program);
	
	// DEBUG: dump linker log
	GLint logSize;
	glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logSize);

	char* buffer = malloc(logSize);
	glGetProgramInfoLog(program, logSize, NULL, buffer);

	write(1, buffer, logSize - 1);
	free(buffer);

}

static float translatex = 0;
static float translatey = 0;

static void input() {
	
	SDL_Event evt;
	while(SDL_PollEvent(&evt) > 0) {
		
		switch(evt.type) {
			case SDL_QUIT:
				exit(0);
				break;
			case SDL_KEYDOWN:
				switch(evt.key.keysym.sym) {
					case SDLK_ESCAPE:
						SDL_WM_GrabInput(SDL_GRAB_OFF);
						break;
				        case SDLK_w:
					        translatey = translatey + .05;
						break;
				        case SDLK_s:
					        translatey = translatey - .05;
						break;
				        case SDLK_a:
       					        translatex = translatex - .05;
						break;
				        case SDLK_d:
					        translatex = translatex + .05;
						break;
				}
				break;
			case SDL_MOUSEBUTTONDOWN:
				SDL_WM_GrabInput(SDL_GRAB_ON);
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

double oscillate (int interval, int key, float rate) {
  if ((key % (2 * interval)) > interval) {
    return rate;
  } else {
    return rate * -1;
  }
}

static void tick() {
  // advance clock
  time = time + 0.3;

  // base one of the thingy's points on the mouse location
  points[0] = mx/320.0 - 1.0;
  points[1] = my/-240.0 + 1.0;

  // base thingy color on time
  rgb[0] = sin(time);
  rgb[1] = cos(time);
  rgb[2] = 0;
  
  // spin camera
    
  /* double spin = oscillate (10, time, 0.02);*/
  projectionMatrix[3] = translatex;
    
  double spin = time * 0.2;
    projectionMatrix[0] = cos(spin);
    projectionMatrix[1] = -sin(spin);
    projectionMatrix[4] = sin(spin);
    projectionMatrix[5] = cos(spin);
    projectionMatrix[7] = translatey;
}

static void draw() {
	
	// clear screen
	glClear( GL_COLOR_BUFFER_BIT );
	
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

