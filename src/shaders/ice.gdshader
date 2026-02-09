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

//varying mat4 combinedMatrix;
//varying mat4 invCombinedMatrix;

varying vec2 screenPosCenter;
varying vec2 screenPosUp;
varying vec2 screenPosLeft;
varying vec2 screenUnit;

// Adapted from https://github.com/toji/gl-matrix/blob/master/src/mat4.js#L1152
vec3 get_mat4_scaling(in mat4 m) {
	return vec3(
		length(m[0]),
		length(m[1]),
		length(m[2])
	);
}

// Simplified version of above.
vec2 get_mat4_scaling_xy(in mat4 m) {
	return vec2(
		length(m[0]),
		length(m[1])
	);
}

void vertex() {
	VERTEX = (MODEL_MATRIX * vec4(VERTEX, 0., 1.)).xy;
	
	mat4 combinedMatrix = (SCREEN_MATRIX * CANVAS_MATRIX);
	//invCombinedMatrix = inverse(combinedMatrix);
	
	screenUnit = get_mat4_scaling_xy(combinedMatrix);
	
	
	// Takes (local) positionCenter and converts it into (screen) screenPosCenter
	screenPosCenter = (combinedMatrix * MODEL_MATRIX * vec4(positionCenter, 1., 1.)).xy * 0.5 + 0.5;
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
float sinful_sin_sign(in float x) {
	if (x < -0.5) return -1.;
	if (x > 0.5) return 1.;
	return sin(x * PI);
}

void fragment() {
	vec3 surfNormal = NORMAL * 0.5 * normalScale;
	//COLOR.rgb = saturation(COLOR.rgb, 0.9);
	
	vec2 uvRelative = SCREEN_UV - screenPosCenter;
	vec2 fakeUv = uvRelative / screenUnit * 0.01;
	
	// Reflect based on mode
	
	if (reflectMode == REFLECT_X) {
		uvRelative *= vec2(-reflectScale, 1.0);
	}
	else {
		uvRelative *= vec2(-reflectScale);
	}
	
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

	uvRelative += screenPosCenter;
	float fadeFactor = get_border_fade(uvRelative);
	
	vec3 reflectedSample = textureLod(screenTexture, uvRelative + surfNormal.xy * 0.3, 1.0).rgb;
	vec3 blurredSample = textureLod(screenTexture, SCREEN_UV + surfNormal.xy * 0.3, 2.0).rgb;
	
	vec3 reflectedColor = mix(reflectedSample, blurredSample, 1. - fadeFactor);
	
	COLOR.rgb = COLOR.rgb * textureAmount + reflectedColor * reflectionAmount;
}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
	
	float nDot = dot(NORMAL, LIGHT_DIRECTION);
	
	float factor = nDot * -1.0; // + 0.5;
	
	// COLOR.rgb
	
	LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY * factor, LIGHT_COLOR.a);
}
