shader_type canvas_item;
render_mode blend_disabled, unshaded;

#include "./_shared.gdshaderinc"

uniform float bloomScale : hint_range(0.0, 4.0) = 2.0;

uniform sampler2D screenTexture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D noiseDetail : hint_default_black, repeat_enable;
uniform vec2 uvNoiseScale = vec2(1., 1.);

varying vec2 worldVtxPos;

vec4 sample_bloom(in sampler2D tex, in vec2 uv) {
	return (
		textureLod(tex, uv, 3.0) * 0.3 +
		textureLod(tex, uv, 4.0) * 0.4 +
		textureLod(tex, uv, 5.0) * 0.3
	);
}

vec3 pow_luma(in vec3 color, in float p) {
	float luma = get_luma(color);
	float luma2 = pow(luma, p);
	return color * (luma2 / luma);
}

void vertex() {
	worldVtxPos = (MODEL_MATRIX * vec4(VERTEX, 0., 1.)).xy * 0.0008 * uvNoiseScale.xy;
}

void fragment() {
	// SCREEN READS
	
	vec3 stdSample = texture(screenTexture, SCREEN_UV).rgb;
	vec3 bloomySample = sample_bloom(screenTexture, SCREEN_UV).rgb;
	
	// This method causes weird color blending, pow_luma should fix it i think
	//vec3 bloomPow = pow(bloomySample, vec3(3.0)) * 4.0;
	vec3 bloomPow = pow_luma(bloomySample, 4.0) * bloomScale;
	
	// DUST
	
	vec2 uv = worldVtxPos;
	vec3 noiseSample = texture(noiseDetail, uv * uvNoiseScale + vec2(0., TIME * -0.02)).rgb;
	noiseSample *= saturation(bloomPow, 5.0) * 3.0;
	
	// GLOOM
	
	//COLOR.rgb = bloomPow;
	//COLOR.rgb = bloomySample;
	
	vec3 bloom = clamp(bloomPow * 0.4, 0., 1.);
	COLOR.rgb = bloomySample * 0.2 + stdSample * 0.8 + bloom + noiseSample;
}
