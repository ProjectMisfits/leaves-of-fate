shader_type canvas_item;
render_mode unshaded, blend_add;

#include "./_shared.gdshaderinc"

void fragment() {
	float sample = rand(fract(SCREEN_UV + vec2(TIME * 0.04)));
	sample *= clamp(sample, 0.5, 1.0) * 2. - 1.;
	COLOR.a = sample;
	
}
