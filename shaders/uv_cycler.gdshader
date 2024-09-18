shader_type canvas_item;

uniform vec4 color : source_color;
uniform vec2 direction = vec2(1.0, 1.0);

void fragment() {
	COLOR = texture(TEXTURE, UV - direction * TIME) * color;
}