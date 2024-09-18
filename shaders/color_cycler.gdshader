shader_type canvas_item;

uniform sampler2D tex;
uniform vec2 direction = vec2(1.0, 1.0);

void fragment() {
	vec2 uv = UV - direction * TIME;
	uv = fract(uv);
	COLOR = texture(tex, uv);
}