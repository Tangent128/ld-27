#version 120

uniform sampler2D texture0;
varying vec2 texCoords;

void main() {
	//gl_FragColor = vec4(1,texCoords,0);
	gl_FragColor = texture2D(texture0,texCoords);
}

