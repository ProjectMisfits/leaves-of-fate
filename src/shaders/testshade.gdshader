shader_type canvas_item;

uniform float shadowDistance : hint_range(0.0, 30.0) = 15.0;
//uniform sampler2D depthTexture : hint_depth_texture;

// TODO:
// - Shadows should scale with the screen, not the sprite!
// - Light should be sampled from varying dirs to approximate roughness
// - Use hemispheric sampling to fake bevel


// Rough luminance approximation
float luma(in vec3 rgb) {
	return rgb.r * .3 + rgb.g * .5 + rgb.b * .2;
}

vec2 sobel_normal(in sampler2D tex, in vec2 uv, in vec2 unit) {
	float alpha = luma(texture(tex, uv).rgb);
	float alphay = luma(texture(tex, uv + unit * vec2(0., 1.)).rgb);
	float alphax = luma(texture(tex, uv + unit * vec2(1., 0.)).rgb);
	return vec2(
		alphax - alpha,
		alphay - alpha
	);
}

#define STEPS 4
#define DIST shadowDistance

float sampleAlpha(in sampler2D tex, in vec2 uv) {
	if (uv.x < .0 || uv.x > 1. || uv.y < .0 || uv.y > 1.) return 1.0;
	vec4 sample = texture(tex, uv);

	// Experiment: Shadows on all lineart?
	// if (length(sample.rgb) < 0.5) return 0.0;
	return sample.a;
}

const int ANG_STEPS = 16;
const float STEP_ANGLE = PI * 2. / float(ANG_STEPS);

vec2 vec2_from_angle(in float ang) {
	return vec2(cos(ang), sin(ang));
}

vec3 avg_normal(in sampler2D tex, in vec2 uv, in vec2 distMult) {
	// These default values are used to bias the vector to UP by default.
	float factorAccum = 0.1;
	vec3 posAccum = vec3(0., 0., factorAccum);

	float ang = 0.;
	for (int i=0; i<ANG_STEPS; i++) {
		vec3 pos = vec3(vec2_from_angle(ang), 0.);
		vec4 sample = texture(tex, uv + pos.xy * distMult);
		float fac = 1. - sample.a;
		posAccum += pos * fac;
		factorAccum += fac;
		ang += STEP_ANGLE;
	}

	// I am too lazy to figure out how to get epsilon. fuck it
	// this should never happen with the current default params
	if (factorAccum < 0.00001)
		return vec3(0.);

	// We know the result of this will be normalized
	// because it is the sum of normalized vecs multiplied by factors.
	// by dividing by the sum of factors, we get a normalized vec.
	return posAccum / factorAccum;
}

// raycast v1
//void light() {
	////float cNdotL = max(0.0, dot(NORMAL, LIGHT_DIRECTION));
	//vec2 lightDir = normalize(LIGHT_DIRECTION.xy);
	//
	//vec2 inv_tex_size = TEXTURE_PIXEL_SIZE * DIST;
	//float accum = 0.0;
	//
	//for (int i=0; i<STEPS; i++) {
		//float f = float(i) / float(STEPS);
		//float sample = sampleAlpha(TEXTURE, UV + lightDir * inv_tex_size * f);
		//accum += sample / float(STEPS);
	//}
	//
	//accum = 1. - accum;
	//
	//float lightZ = LIGHT_DIRECTION.z;
	//float light_factor = lightZ + accum * (1. - lightZ);
	//
	//LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY * light_factor, LIGHT_COLOR.a);
//}

// n-dot
//void light() {
	//vec3 normal = avg_normal(TEXTURE, UV, TEXTURE_PIXEL_SIZE * DIST);
	//float cNdotL = max(0., dot(normal, LIGHT_DIRECTION));
	//
	//// vec4(normal.xyz * 0.5 + 0.5, 1.);
	//LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY * cNdotL, LIGHT_COLOR.a);
//}

void fragment() {
	//COLOR.rgb = vec3(0w.);
	//COLOR.a = textureLod(TEXTURE, UV, 2.0).a;
}


// n-dot LOD
//void light() {
	//float lodLevel = 2.5;
	//
	//float sampleDist = 8.0;
	//vec3 size = vec3(TEXTURE_PIXEL_SIZE * sampleDist, 0.);
	//
	//float alphaMid = textureLod(TEXTURE, UV, lodLevel).a;
	//
	//vec2 alpha00 = vec2(
		//textureLod(TEXTURE, UV - size.xz, lodLevel).a,
		//textureLod(TEXTURE, UV - size.zy, lodLevel).a
	//);
	//vec2 alpha11 = vec2(
		//textureLod(TEXTURE, UV + size.xz, lodLevel).a,
		//textureLod(TEXTURE, UV + size.zy, lodLevel).a
	//);
	//
	//vec2 alphaDelta = (alpha00.xy - alpha11.xy);
	//vec3 normal = normalize(vec3(alphaDelta, 0.4));
	////LIGHT.rgb = normal * 0.5 + 0.5;
	////LIGHT.a = 1.;
	//
	//float cNdotL = max(0., dot(normal, LIGHT_DIRECTION));
	//LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY * cNdotL, LIGHT_COLOR.a);
//}


// n-dot direction-biased LOD
void light() {
	float lodLevel = 2.2;
	float sampleDist = 0.9; //DIST;

	vec3 size = vec3(vec2(1.) * sampleDist, 0.);
	vec2 normLightDir = normalize(LIGHT_DIRECTION.xy);

	mat2 transform = mat2(
		vec2(normLightDir.xy),
		vec2(normLightDir.y, -normLightDir.x)
	);

	//mat2 transform = mat2(
		//vec2(1., 0.),
		//vec2(0., 1.)
	//);

	//float alphaMid = textureLod(TEXTURE, UV, lodLevel).a;

	vec2 deltaX = size.xz * transform * TEXTURE_PIXEL_SIZE;
	vec2 deltaY = size.zy * transform * TEXTURE_PIXEL_SIZE;

	vec2 alpha00 = vec2(
		textureLod(TEXTURE, UV - deltaX, lodLevel).a,
		textureLod(TEXTURE, UV - deltaY, lodLevel).a
	);
	vec2 alpha11 = vec2(
		textureLod(TEXTURE, UV + deltaX, lodLevel).a,
		textureLod(TEXTURE, UV + deltaY, lodLevel).a
	);

	vec2 alphaDelta = (alpha00.xy - alpha11.xy) * inverse(transform);
	//vec3 normal = normalize(vec3(alphaDelta, 1.));
	vec3 normal = normalize(vec3(sobel_normal(TEXTURE, UV, TEXTURE_PIXEL_SIZE), 0.1));
	float alphaAvg = (alpha00.x + alpha00.y + alpha11.x + alpha11.y) * 0.25;

	// Debug: Show calculated normals
	//LIGHT.rgb = normal * 0.5 + 0.5;
	//LIGHT.a = 1.;

	float cNdotL = max(0., dot(normal, LIGHT_DIRECTION));
	//cNdotL *= 1. - alphaAvg;
	cNdotL = 1. - pow(1. - cNdotL, 4.0);
	LIGHT = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY * cNdotL, LIGHT_COLOR.a);
}