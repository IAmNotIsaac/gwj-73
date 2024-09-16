shader_type canvas_item;

uniform vec3 color : source_color;

void fragment() {
	float a = sin(TIME);
	a = a * a;
	a += 1.0;
	float dx = abs(UV.x - 0.5) * 2.0;
	float dy = abs(UV.y - 0.5) * 2.0;
	COLOR.rgb = color;
	COLOR.a = (max(dx, dy) - 0.5) * a;
}
