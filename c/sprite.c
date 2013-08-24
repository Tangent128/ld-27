
#define GL_GLEXT_PROTOTYPES 1

#if defined(__APPLE__)
	#include <OpenGL/gl.h>
#else
	#include <GL/gl.h>
#endif

#include <stdio.h>
#include <stdlib.h>

#include "game.h"

// max size of shader source handled
#define MAX_SHADER_SIZE (1024*100)

// hold OpenGL object names for sprite program
static GLuint spriteVertices;
static GLuint spriteElements;
static GLuint spriteProgram;
static GLuint spriteCoords;
static GLuint spriteCamera;
static GLuint spriteLocation;
static GLuint spriteTexture;

//static GLint projection;
//static GLint color;

// geometry

static GLfloat projectionMatrix[] = {
	1.0, 0.0, 0.0, 0.0,
	0.0, 1.0, 0.0, 0.0,
	0.0, 0.0, 1.0, 0.0,
	0.0, 0.0, 0.0, 1.0,
};

// === utility funcs for shader loading ===
// ========================================

// read a file (caller needs to free buffer)
static char* slurpFile(FILE* file, int* size) {
	char* buffer = malloc(MAX_SHADER_SIZE);
	*size = fread(buffer, 1, MAX_SHADER_SIZE - 1, file);
	
	// null terminate
	buffer[*size] = 0;
	return buffer;
}

// compile a file to a shader
static GLuint makeShader(char* filename, GLenum shaderType) {

	GLuint shader = glCreateShader(shaderType);
	
	// load source into shader
	GLint codeSize;
	FILE* file = fopen(filename, "r");
	if(file != NULL) {
		GLchar* source = slurpFile(file, &codeSize);
	
		glShaderSource(shader, 1, (const GLchar**) &source, NULL);
		
		free(source);
		fclose(file);
	} else {
		printf("Could not open shader file %s\n", filename);
	}
	
	// compile shader
	glCompileShader(shader);
	
	// get log
	if(debugEnabled) {
		GLint logSize;
		glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &logSize);

		char* buffer = malloc(logSize);
		glGetShaderInfoLog(shader, logSize, NULL, buffer);

		write(1, buffer, logSize - 1);
		free(buffer);
	}
	
	return shader;
}

// compile a vertex & fragment shader into a program
static GLuint makeProgram(char* vertexFile, char* fragmentFile) {
	// compile component shaders
	GLuint vertexS = makeShader(vertexFile, GL_VERTEX_SHADER);
	GLuint fragmentS = makeShader(fragmentFile, GL_FRAGMENT_SHADER);

	// link into program
	GLuint program = glCreateProgram();
	glAttachShader(program, vertexS);
	glAttachShader(program, fragmentS);
	glLinkProgram(program);

	// get log
	if(debugEnabled) {
		GLint logSize;
		glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logSize);

		char* buffer = malloc(logSize);
		glGetProgramInfoLog(program, logSize, NULL, buffer);

		write(1, buffer, logSize - 1);
		free(buffer);
	}
	
	return program;
}

// load a PNG image as a texture
GLuint makeTexture(char* fileName) {
	GLuint texture;

	// prep texture
	glGenTextures(1, &texture);
	glBindTexture(GL_TEXTURE_2D, texture);
	
	// init dummy texture
	GLsizei width = 32, height = 32;
	size_t size = width * height * sizeof(GLubyte) * 4;
	GLubyte *pixels = malloc(size);
	
	int i;
	for(i = 0; i < size; i++) {
		pixels[i] = 100;
	}
	
	// load pixel data into texture
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
	
	free(pixels);
	
	return texture;
}

// === sprites ===
// ===============

// setup OpenGL buffers for sprite geometry
static void spriteInit() {
	// 2D buffer of sprite bounds
	GLfloat points[] = {
		0.0, 0.0,
		0.0, 1.0,
		1.0, 0.0,
		1.0, 1.0
	};
	
	// two triangles make a square
	static GLshort tris[] = {
		0, 1, 2,
		2, 1, 3,
	};
	
	// create buffers
	glGenBuffers(1, &spriteVertices);
	glGenBuffers(1, &spriteElements);
	
	// user buffers
	glBindBuffer(GL_ARRAY_BUFFER, spriteVertices);
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, spriteElements);
	
	// copy in data
	glBufferData(GL_ARRAY_BUFFER, sizeof(points), &points, GL_STATIC_DRAW);
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(tris), &tris, GL_STATIC_DRAW);

	// load shaders
	spriteProgram = makeProgram("gl/sprite.v.glsl", "gl/sprite.f.glsl");
	
	spriteCamera = glGetUniformLocation(spriteProgram, "camera");
	spriteLocation = glGetUniformLocation(spriteProgram, "location");
	
	spriteCoords = glGetAttribLocation(spriteProgram, "coords");
	spriteTexture = glGetUniformLocation(spriteProgram, "texture0");
	
}

// public call to prepare drawing sprites
void beginSprites(float cameraX, float cameraY) {
	glUseProgram(spriteProgram);

	// setup sprite geometry
	glBindBuffer(GL_ARRAY_BUFFER, spriteVertices);
	glEnableVertexAttribArray(spriteCoords);
	glVertexAttribPointer(spriteCoords, 2, GL_FLOAT, GL_FALSE, 0, 0);
	
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, spriteElements);
	
	// setup texture sampler
	glActiveTexture(GL_TEXTURE0);
	glUniform1i(spriteTexture, GL_TEXTURE0);
	
	// locate camera
	glUniform2f(spriteCamera, cameraX, cameraY);
}

// public call to draw a sprite
void drawSprite(float x, float y, GLuint texture) {

	glUniform2f(spriteLocation, x, y);
	
	glBindTexture(GL_TEXTURE_2D, texture);
	glUniform1i(spriteTexture, 0);
	
	glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_SHORT, 0);
}

// public call cleaning up after drawing sprites
void endSprites() {
	glDisableVertexAttribArray(spriteCoords);
}

// === backgrounds ===
// ===================

// public call to draw a background
void drawBackground( /*...*/ ) {
	glClear( GL_COLOR_BUFFER_BIT );
}

// === setup ===
// =============

// public call to setup GL constants
void glInit() {
	
	// misc. settings
	glClearColor( 0, 0, 100, 255 );
	
	// sprites
	spriteInit();
	
	// setup attributes
	//printf("%d %d\n", position, color);

	// ready
	
	
	
}


