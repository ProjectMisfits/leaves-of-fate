shader_type canvas_item;

#include "./_shared.gdshaderinc"

/** The maximum highlight distance. */
uniform float DIST : hint_range(0.0, 32.0) = 12.0;
/** The pseudo-angular spread. */
uniform float SPREAD : hint_range(0.0, 2.0) = 0.9;
/** The debanding factor. If >0, adds coordinate noise to prevent visible shader banding. */
uniform float DEBAND : hint_range(0.0, 1.0) = 1.0;
/** Multiplies the rim highlights. If 0, just use another shader lmao. */
uniform float OVERDRIVE : hint_range(0.5, 10.0) = 3.0;

//const float SPREAD = 0.9;
//const float DIST = 16.0;
//const float DEBAND = 1.0;
const int STEPS = 4;
const float STEP_SIZE = 1. / float(STEPS);
const int RAYCOUNT = 3;

// Gets the distance to an edge.
float cast_ray(in sampler2D tex, in vec2 uv, in vec2 ray) {
	vec2 pos = uv;

	for (int i=0; i<STEPS; i++) {
		float sample = texture(tex, pos).a;
		if (sample < 0.5) return float(i) / float(STEPS);
		// pos = uv + float(i) * ray * STEP_SIZE;
		pos += ray * STEP_SIZE;
	}

	return 1.;
}

// Shifts a direction vector left/right by spreadFac
vec2 get_unit(in vec2 up, in float spreadFac) {
	vec2 left = vec2(-up.y, up.x);
	return normalize(up + left * spreadFac);
}

void light() {
	vec2 toLight = normalize(LIGHT_DIRECTION.xy);
	float rimLight = 0.;

	for (int i=0; i<RAYCOUNT; i++) {
		// The direction of this ray, from -0.5 to 0.5
		// If there's only one ray, it should be at position 0.0
		float f = RAYCOUNT <= 1 ? 0.0 : (float(i) / float(RAYCOUNT - 1) - 0.5);

		// Vary each ray's angle to diffuse shadows.
		float fScale = 1. - (1. / float(RAYCOUNT));
		float fRange = (1. - fScale) * 0.5;
		float fRandFactor = (rand(SCREEN_UV + vec2(f)) - 0.5) * 2. * DEBAND;

		f *= fScale;
		f += fRange * fRandFactor;

		float raySize = DIST;
		float stepSize = raySize * STEP_SIZE;

		vec2 rayDir = get_unit(toLight, f * SPREAD);
		float dotFac = dot(toLight, rayDir);
		dotFac *= dotFac; // accentuate normal curve

		// Shift starting pos to avoid banding.
		float facRandom = rand(SCREEN_UV.yx - vec2(f));
		float facOffset = (facRandom * DEBAND + 0.5) * STEP_SIZE;

		vec2 initialPos = rayDir * raySize * facOffset * TEXTURE_PIXEL_SIZE;
		vec2 baseUv = UV + initialPos;

		float dist = cast_ray(TEXTURE, baseUv, rayDir * raySize * TEXTURE_PIXEL_SIZE) + facOffset;
		dist = clamp(dist, 0., 1.);
		rimLight += dotFac * pow(1. - dist, 1.8) / float(RAYCOUNT);
	}

	// Blend between rimlight/frontlight based on Z
	float frontFactor = LIGHT_DIRECTION.z;
	float lightFactor = (rimLight * OVERDRIVE) * (1. - frontFactor) + frontFactor;

	//LIGHT.rgb = vec3(lightFactor);
	//LIGHT.a = 0.25 * COLOR.a;
	LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY * lightFactor, LIGHT_COLOR.a);
}
