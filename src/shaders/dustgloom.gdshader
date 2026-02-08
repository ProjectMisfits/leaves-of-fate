shader_type canvas_item;
render_mode blend_disabled, unshaded;

#include "./_shared.gdshaderinc"

uniform sampler2D screenTexture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D noiseDetail : hint_default_black, repeat_enable;
uniform vec2 uvNoiseScale = vec2(8., 4.);

void fragment() {
	// SCREEN READS
	
	vec3 stdSample = texture(screenTexture, SCREEN_UV).rgb;
	vec3 bloomySample = textureLod(screenTexture, SCREEN_UV, 2.0).rgb;
	vec3 bloomPow = pow(bloomySample, vec3(3.0));
	
	// DUST
	
	vec3 noiseSample = texture(noiseDetail, UV * uvNoiseScale + vec2(0., TIME * 0.02)).rgb;
	noiseSample *= bloomPow * 3.0;
	
	// GLOOM
	
	vec3 bloom = clamp(bloomPow * 0.4, 0., 1.);
	COLOR.rgb = bloomySample * 0.2 + stdSample * 0.8 + bloom + noiseSample;
}
