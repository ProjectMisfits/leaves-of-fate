shader_type canvas_item;
render_mode blend_add;

#include "./_shared.gdshaderinc"

uniform sampler2D screenTexture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec3 sample = textureLod(screenTexture, SCREEN_UV, 3.0).rgb;
	COLOR.rgb *= sample / get_luma(sample);
}

void light() {
	LIGHT.rgba = vec4(LIGHT_COLOR.rgb * COLOR.rgb * LIGHT_ENERGY, LIGHT_COLOR.a);
}
