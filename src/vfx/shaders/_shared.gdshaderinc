// Enable high-quality shader settings if targeting the desktop.
#if (CURRENT_RENDERER == RENDERER_FORWARD_PLUS)
#define HIGH_QUALITY
#endif

// TEXTURE_PIXEL_SIZE doesn't seem to get set when using compatibility renderer.
// Work around by giving it an arbitrary value that looks sorta right.
#if (CURRENT_RENDERER == RENDERER_COMPATIBILITY)
#define TEXTURE_PIXEL_SIZE vec2(1.0 / 2048.0, 1.0 / 2048.0)
#endif


// my favorite copy-paste random float function!!!
// Sourced from: https://thebookofshaders.com/10/
float rand(in vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

const vec3 LUMA_BIAS = vec3(0.2126, 0.7152, 0.0722);

// Returns an approximation of the provided color's luma.
float get_luma(in vec3 v) { return dot(v, LUMA_BIAS); }
float get_luma(in vec4 v) { return dot(v.rgb, LUMA_BIAS); }

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