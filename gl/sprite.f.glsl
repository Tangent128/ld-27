#version 120

uniform sampler2D texture0;
varying vec2 texCoords;

void main() {
	gl_FragColor = texture2D(texture0, vec2(texCoords.x, 1 - texCoords.y));
}

