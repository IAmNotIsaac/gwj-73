shader_type canvas_item;

uniform float thickness : hint_range(0.0, 1.0) = 0.1;

void fragment() {
	float d2l = UV.x;
	float d2r = 1.0 - UV.x;
	float d2t = UV.y;
	float d2b = 1.0 - UV.y;
	float grad_x = smoothstep(0.0, thickness, min(d2l, d2r));
	float grad_y = smoothstep(0.0, thickness, min(d2t, d2b));
	COLOR.a = grad_x * grad_y;
}