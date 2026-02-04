shader_type canvas_item;
render_mode unshaded, blend_add;

#include "./_shared.gdshaderinc"

// volumetrics shader !!
// known issues:
// - results can look a bit fuzzy at low step counts
// - transforms are applied in uv space, which makes it scale with the sprite. this is is bad.

uniform sampler3D noiseTexture : hint_default_white;
uniform float perspectiveAmount : hint_range(0.0, 1.0) = 0.2;
uniform float perspectiveOffset : hint_range(0.0, 1.0) = 0.0;
uniform float scaleMax : hint_range(0.5, 1.5) = 0.9;
uniform float noiseScrollSpeed : hint_range(-1.0, 1.0) = -0.02;
uniform float brightnessMultiplier : hint_range(0.0, 10.0) = 4.0;
uniform float lodMultiplier : hint_range(0.0, 8.0) = 2.0;

// i like these syntacticly more than #defines. shouldn't have any overhead. :3
const int STEPS = 8;
const float BORDER_FADE = 0.1;
const float JITTER = 1.0 / (float(STEPS) + 1.0);

// scales the provided UVs from their center by <amount>
vec2 scaleVec(in vec2 uv, in float amount) {
	return (uv - 0.5) / amount + 0.5;
}

bool inDangerZone(in vec2 uv) {
	return uv.x < 0.05 || uv.x > 0.95 || uv.y < 0.05 || uv.y > 0.95;
}

float getBorderFade(in vec2 uv) {
	vec2 uv2 = abs(uv - 0.5);
	return clamp(
		1.0 - (max(uv2.x, uv2.y) * 2.0 - 1.0 + BORDER_FADE) / BORDER_FADE,
		0.0, 1.0
	);
}

void fragment() {
	// This makes a vaguely correct-looking projection angle by forcing
	// the screen UV to a 1:1 aspect ratio, using the height as 0..1
	vec2 screenUv = (SCREEN_UV - 0.5) * vec2(SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x, 1.0) + 0.5;
	
	float scaleMin = (1.0 - perspectiveAmount * 0.2) * scaleMax;
	vec2 stepDir = (screenUv - 0.5) * perspectiveAmount;
	vec3 color = vec3(0.0);
	
	for (int i=0; i<STEPS; i++) {
		float f = float(i) / float(STEPS);
		
		// Z-Jitter. This makes the rays not hit the exact
		// same "layers" for each pixel, which hides our banding issue.
		f += (rand(SCREEN_UV + vec2(TIME * 0.0001)) - 0.5) * 1.0 * JITTER;
		
		float f2 = f + perspectiveOffset;
		float scale = scaleMax * f2 + scaleMin * (1.0 - f2);
		
		
		vec2 uvOffset = stepDir * (1.0 - f2);
		vec2 uv = scaleVec(UV + uvOffset, scale);
		
		// XY-Jitter. This is a worse solution to fix banding than the above.
		//uv += (rand(UV + vec2(0., TIME * 0.001)) - 0.5) * (f + 0.5) * perspectiveAmount * 0.09;
		
		vec3 noiseUv = vec3(uv + uvOffset, f2 * perspectiveAmount * 1.0);
		noiseUv.y = mod(noiseUv.y + TIME * noiseScrollSpeed, 1.0);
		
		if (uv.x < 0. || uv.x > 1. || uv.y < 0. || uv.y > 1.) {
			continue;
		}
		
		float noise = texture(noiseTexture, noiseUv).r;
		
		float distFac = (1. - f);
		distFac *= distFac; // the vague notion of inverse square law
		distFac += .05; // fudge the numbers a bit lmao
		
		// Bias LODs towards end of range
		vec4 sample = textureLod(TEXTURE, uv, f * lodMultiplier);
		color += sample.rgb * sample.a * noise * distFac;
	}
	
	// another magic number!!! whabam
	COLOR.rgb = color / float(STEPS) * brightnessMultiplier;
	COLOR.a = 1.0;
	
	// DEBUG: Show where we start to fade out
	//if (getBorderFade(UV) < 1.0 && length(COLOR.rgb) > 0.01) {
		//COLOR.rgb = vec3(1.0, 0.0, 0.0);
	//}
	
	// if we reach the mesh's edge, that could lead to a sharp cutoff.
	// instead we just fade it out right at the boundary of the uvs.
	COLOR.rgb *= vec3(getBorderFade(UV));
}
