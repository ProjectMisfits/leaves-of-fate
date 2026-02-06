shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screenTexture : hint_screen_texture, filter_linear_mipmap;


void fragment() {
	COLOR.rgb = textureLod(screenTexture, SCREEN_UV, 0.4).rgb;
}
