#define HIGH_QUALITY
// my favorite copy-paste random float function!!!
// Sourced from: https://thebookofshaders.com/10/
float rand(in vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

// Returns an approximation of the provided color's luma.
float luma(in vec3 v) { return v.r * 0.3 + v.g * 0.5 + v.b * 0.2; }
float luma(in vec4 v) { return v.r * 0.3 + v.g * 0.5 + v.b * 0.2; }

// Clamps a value from 0 to 1
float clamp01(in float v) { return clamp(v, 0., 1.); }
vec3 clamp01(in vec3 v) { return clamp(v, 0., 1.); }
vec4 clamp01(in vec4 v) { return clamp(v, 0., 1.); }

// Multiplies a color's saturation by c
vec3 saturation(in vec3 v, in float c) {
	float avg = (v.r + v.g + v.b) * 0.33333;
	return vec3(
		avg + (v.r - avg) * c,
		avg + (v.g - avg) * c,
		avg + (v.b - avg) * c
	);
}