#version 120

attribute vec2 coords;

uniform vec2 camera;
uniform vec2 location;

uniform vec2 scale;
uniform float frame;
uniform float frames;

varying vec2 texCoords;

const int tileSize = 32;
const vec2 screenSize = vec2(640, 480)/(2*tileSize);

void main() {
	vec2 screenCoords = coords*scale + location - camera;
	gl_Position = vec4( (screenCoords - screenSize) / screenSize, 0, 1);
	texCoords = vec2( (coords.x + frame) / frames , coords.y );
}

