// Simplest, laziest blur shader in the world.
// BUT it is functional.
// Adjust "blur" variable to change the blur intensity.
shader_type canvas_item;

#include "./_shared.gdshaderinc"

uniform float blur = 0.9;
uniform sampler2D screenTexture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 sample = texture(screenTexture, SCREEN_UV, blur);
	COLOR = sample;
}