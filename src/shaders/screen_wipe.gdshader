shader_type canvas_item;
render_mode unshaded;

uniform float threshold : hint_range(0., 1.) = 0.0;

void fragment() {
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 uvScale = aspect > 1. ? vec2(aspect, 1.0) : vec2(1.0, 1.0 / aspect);
	vec2 screenUv = (SCREEN_UV - 0.5) * uvScale + 0.5;
	
	COLOR.a = length(screenUv - 0.5) > threshold ? 1. : 0.;
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
