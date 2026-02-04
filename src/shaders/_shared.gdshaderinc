
// my favorite copy-paste random float function!!!
// Sourced from: https://thebookofshaders.com/10/
float rand(in vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}
