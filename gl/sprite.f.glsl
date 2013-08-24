#version 120

//uniform vec3 color;
varying vec2 texCoords;

void main() {
	gl_FragColor = vec3(texCoords*10,0);
}

