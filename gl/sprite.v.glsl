#version 120

uniform vec2 camera;
uniform vec2 location;

attribute vec2 coords;

varying vec2 texCoords;

const screenSize = vec2(640, 480)/2;

void main() {
	vec2 screenCoords = coords + location - camera;
	gl_Position = vec4( (screenCoords - screenSize) / screenSize, 0, 1);
	texCoords = coords;
}

