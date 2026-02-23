shader_type canvas_item;
render_mode unshaded;

#include "./_shared.gdshaderinc"

uniform bool useCenterPosition = true;
uniform vec2 centerPosition = vec2(0., 0.);
uniform sampler2D cutoutTexture : hint_default_white;
uniform float progress : hint_range(0., 1.) = 0.0;

varying vec2 uvCenter;

void vertex() {
	if (useCenterPosition) {
		// nuh uh!!
		//uvCenter = (SCREEN_MATRIX * CANVAS_MATRIX * vec4(centerPosition, 0., 1.)).xy * 0.5 + 0.5;

		// Since we're working with a canvas_item, CANVAS_MATRIX won't work as expected here.
		// The 'centerPosition' var is provided in canvas pixel coordinates, which are calculated w/ gdscript..
		uvCenter = (SCREEN_MATRIX * vec4(centerPosition, 0., 1.)).xy * 0.5 + 0.5;
	}
	else {
		uvCenter = vec2(0.5);
	}
}

void fragment() {
	float aspect = SCREEN_PIXEL_SIZE.y / SCREEN_PIXEL_SIZE.x;
	vec2 uvScale = aspect < 1. ? vec2(aspect, 1.0) : vec2(1.0, 1.0 / aspect);
	vec2 diffUv = (SCREEN_UV - uvCenter) * uvScale;
	
	// A: Circle
	float d = length(diffUv);
	COLOR.a = clamp01((d - 1. + progress) * 500.0);
	
	// B: Cutout
	
	//vec2 cutoutUv = diffUv * (pow(10.0, progress * 3.0) * 0.25) + 0.5;
	//vec4 sample;
	//
	//if (cutoutUv.x < 0. || cutoutUv.y < 0. || cutoutUv.x > 1. || cutoutUv.y > 1. || progress == 1.0) {
		//sample = vec4(0.);
	//}
	//else {
		//sample = texture(cutoutTexture, cutoutUv);
	//}
	//
	//COLOR.a = 1.0 - clamp(sample.a * 2.0 - 0.5, 0.0, 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
