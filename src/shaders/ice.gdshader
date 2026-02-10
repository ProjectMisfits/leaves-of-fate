shader_type canvas_item;
render_mode skip_vertex_transform;

#include "./_shared.gdshaderinc"

const int REFLECT_X = 0;
const int REFLECT_XY = 1;
const int REFLECT_CIRCLE = 2;

uniform int reflectMode : hint_enum("Horizontal", "Square", "Radial");

uniform sampler2D screenTexture : hint_screen_texture, filter_linear_mipmap;
uniform float normalScale : hint_range(0.0, 2.0) = 1.0;
uniform float reflectScale : hint_range(0.2, 8.0) = 0.6;
uniform float textureAmount : hint_range(0.0, 1.0) = 0.8;
uniform float reflectionAmount : hint_range(0.0, 1.0) = 0.8;
uniform vec2 positionCenter;

uniform float warpWidth : hint_range(0.1, 48.0) = 16.0;
uniform float warpWidthDistance : hint_range(0.0, 384.0) = 100.0;

varying vec2 uvReflectScale;

varying vec2 screenPosCenter;
varying vec2 screenLocalUp;
varying vec2 screenUnit;

// Adapted from https://github.com/toji/gl-matrix/blob/master/src/mat4.js#L1152
#if 0
vec3 get_mat4_scaling(in mat4 m) {
	return vec3(
		length(m[0]),
		length(m[1]),
		length(m[2])
	);
}
#endif

// Simplified version of above.
vec2 get_mat4_scaling_xy(in mat4 m) {
	return vec2(
		length(m[0]),
		length(m[1])
	);
}

#if 0
mat4 get_mat4_rotation_skew(in mat4 m) {
	m[0].z = 0.;
	m[1].z = 0.;
	m[2].z = 0.;
	m[0] = normalize(m[0]);
	m[1] = normalize(m[1]);
	m[2] = normalize(m[2]);
	m[3] = vec4(0., 0., 0., 1);
	return m;
}
#endif

vec2 get_mat4_xy_up(in mat4 m) {
	return normalize(m[1]).xy;
}

#if 0
vec3 get_tint(in vec3 color, in float amount) {
	color /= dot(color, vec3(0.3333));
	return mix(vec3(1.0), color, amount);
}
#endif

void vertex() {
	VERTEX = (MODEL_MATRIX * vec4(VERTEX, 0., 1.)).xy;
	
	// Calculate a combined projection matrix to go from world space to screen space
	mat4 projMatrix = (SCREEN_MATRIX * CANVAS_MATRIX);
	screenUnit = get_mat4_scaling_xy(projMatrix);
	
	uvReflectScale = vec2(-reflectScale, 1.0);
	if (reflectMode != REFLECT_X) {
		uvReflectScale[1] *= -reflectScale;
	}
	
	// Get the sprite's up vector from its rotation matrix
	// This lets us rotate the axis of reflection with it
	screenLocalUp = get_mat4_xy_up(MODEL_MATRIX);
	
	// Takes (local) positionCenter and converts it into (screen) screenPosCenter
	screenPosCenter = (projMatrix * MODEL_MATRIX * vec4(positionCenter, 1., 1.)).xy * 0.5 + 0.5;
}

// code reuse ftw
const float BORDER_FADE = 0.3;
float get_border_fade(in vec2 uv) {
	vec2 uv2 = abs(uv - 0.5);
	return clamp(
		1.0 - (max(uv2.x, uv2.y) * 2.0 - 1.0 + BORDER_FADE) / BORDER_FADE,
		0.0, 1.0
	);
}

// worst function ever. fuck you
// like sign(x) except with smoothing between (-1, 1)
float sinful_sin_sign(in float x) {
	if (x < -0.5) return -1.;
	if (x > 0.5) return 1.;
	return sin(x * PI);
}

const float DISPERSE_AMOUNT = 0.03;
vec3 sample_texture_lod_dispersed(in sampler2D tex, in float lod, in vec2 uv, in vec2 offset) {
	return vec3(
		textureLod(tex, uv + offset * (1.0 - DISPERSE_AMOUNT), lod).r,
		textureLod(tex, uv + offset, lod).g,
		textureLod(tex, uv + offset * (1.0 + DISPERSE_AMOUNT), lod).b
	);
}

void fragment() {
	vec2 invScreenUnit = 1.0 / screenUnit;
	vec3 surfNormal = NORMAL * 0.5 * normalScale;
	//COLOR.rgb = saturation(COLOR.rgb, 0.8);
	
	
	vec2 uvRelative = SCREEN_UV - screenPosCenter;
	mat2 rotateFromLocal = mat2(screenLocalUp.yx * vec2(1., -1.), screenLocalUp);
	
	// Reflect based on mode
	
	uvRelative *= invScreenUnit;
	uvRelative *= rotateFromLocal;
	uvRelative *= screenUnit;
	
	vec2 fakeUv = uvRelative / screenUnit * 0.01;
	
	uvRelative *= uvReflectScale;
	
	// Warp UVs around center based on reflection mode
	
	if (reflectMode == REFLECT_CIRCLE) {
		vec2 r = fakeUv;
		float d = length(r);
		r.y *= screenUnit.y / screenUnit.x;
		vec2 direction = r / d;
		float newD = sinful_sin_sign(d * warpWidth) * warpWidthDistance * reflectScale * screenUnit.x;
		uvRelative += direction * newD;
	}
	else {
		uvRelative.x += sinful_sin_sign(fakeUv.x * warpWidth) * warpWidthDistance * reflectScale * screenUnit.x;
	}

	if (reflectMode == REFLECT_XY) {
		uvRelative.y += sinful_sin_sign(fakeUv.y * warpWidth) * warpWidthDistance * reflectScale * screenUnit.y;
	}
	
	// Restore position

	uvRelative *= invScreenUnit;
	uvRelative *= inverse(rotateFromLocal);
	uvRelative *= screenUnit;

	uvRelative += screenPosCenter;
	float fadeFactor = get_border_fade(uvRelative);
	
	#ifdef HIGH_QUALITY
	vec3 reflectedSample = sample_texture_lod_dispersed(screenTexture, 1.0, vec2(0.5), vec2(-0.5) + uvRelative + surfNormal.xy * 0.3);
	#else
	vec3 reflectedSample = textureLod(screenTexture, uvRelative + surfNormal.xy * 0.3, 1.0).rgb;
	#endif
	
	vec3 blurredSample = textureLod(screenTexture, SCREEN_UV + surfNormal.xy * 0.3, 2.0).rgb;
	
	vec3 reflectedColor = mix(reflectedSample, blurredSample, 1. - fadeFactor);
	
	COLOR.rgb = COLOR.rgb * textureAmount + reflectedColor * reflectionAmount; // * get_tint(blurredSample, 1.0);
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
	
	float nDot = dot(NORMAL, LIGHT_DIRECTION);
	
	float factor = nDot * -1.0; // + 0.5;
	
	// COLOR.rgb
	
	LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY * factor, LIGHT_COLOR.a);
}
