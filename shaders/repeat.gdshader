shader_type canvas_item;

uniform vec2 scale = vec2(1.0, 1.0);

void fragment() {
	COLOR = texture(TEXTURE, UV * scale);
}
