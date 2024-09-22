shader_type canvas_item;

uniform sampler2D tex_shine;

void fragment() {
	float stretch = 8.0;
	vec4 color_a = texture(TEXTURE, UV);
	vec2 uv2 = (UV / vec2(1.0, stretch)) + vec2(0.0, TIME * 0.75);
	vec4 color_b = texture(tex_shine, fract(uv2));
	COLOR.rgb = mix(color_a.rgb, color_b.rgb, color_b.a);
	//COLOR = color_b;
}
