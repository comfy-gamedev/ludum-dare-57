// https://godotshaders.com/shader/efficient-2d-pixel-outlines/
shader_type canvas_item;

uniform vec4 outline_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float inverse_scale = 1.0;

void fragment() {
	if (COLOR.a == 0.0) {
		vec2 uv = (UV - vec2(0.5, 0.5)) * inverse_scale + vec2(0.5, 0.5);
		vec4 c = texture(TEXTURE, uv);
		COLOR = mix(COLOR, outline_color, c.a);
	}
}
