shader_type canvas_item;

uniform float vignetteRadius : hint_range(0.0, 10.0) = 3.0;
uniform float vignetteAlpha : hint_range(0.0, 1.0) = 1.0;

void fragment() {

	// Vignette
	// Effect based on distance from center of screen
	float x = abs(UV.x - 0.5) * 2.0;
	float y = abs(UV.y - 0.5) * 2.0;
	float v = sqrt( (x * x) + (y * y) ) / vignetteRadius;

	COLOR = vec4(0, 0, 0, v * vignetteAlpha);
}