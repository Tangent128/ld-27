
#define GL_GLEXT_PROTOTYPES 1

#include <SDL/SDL.h>

#if defined(__MACOSX__)
	#include <OpenGL/gl.h>
#else
	#include <GL/gl.h>
#endif

#include <stdio.h>

// max size of source handled
#define FILE_SIZE (1024*100)

static char* grabInput(int* size) {
	char* buffer = malloc(FILE_SIZE);
	*size = fread(buffer, 1, FILE_SIZE - 1, stdin);
	
	// null terminate
	buffer[*size] = 0;
	return buffer;
}

static usageExit(char* name) {
	printf("Usage: %s [v|f|g] < input.glsl   # where v/t/g select vertex/fragment/geometry shader\n", name);
	exit(1);
}

int main(int argc, char** argv) {
	
	if(argc != 2) {
		usageExit(argv[0]);
	}
	
	GLuint shaderType = GL_VERTEX_SHADER;
	switch(argv[1][0]) {
		case 'v':
			shaderType = GL_VERTEX_SHADER;
			break;
		case 'f':
			shaderType = GL_FRAGMENT_SHADER;
			break;
		case 'g':
			shaderType = GL_GEOMETRY_SHADER;
			break;
		default:
			usageExit(argv[0]);
	}
	
	
	// INIT SDL
	if( SDL_Init(SDL_INIT_VIDEO | SDL_INIT_TIMER) < 0) {
		printf("Could not initialize SDL: %s.\n", SDL_GetError());
		exit(-1);
	}
	atexit(SDL_Quit);

	SDL_GL_SetAttribute( SDL_GL_DOUBLEBUFFER, 1 );
	SDL_Surface *win = SDL_SetVideoMode(16, 16, 32, SDL_OPENGL);

	// Make shader

	GLuint shader = glCreateShader(shaderType);
	
	// load source into shader
	GLint codeSize;
	char* source = grabInput(&codeSize);
	
	glShaderSource(shader, 1, &source, NULL);
	
	// try to compile shader
	glCompileShader(shader);

	// get log
	GLint logSize;
	glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logSize);

	char* buffer = malloc(logSize);
	glGetShaderInfoLog(shader, logSize, NULL, buffer);

	write(1, buffer, logSize - 1);
	
	// cleanup
	glDeleteShader(shader);
	
}

