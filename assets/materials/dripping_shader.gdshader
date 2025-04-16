//Original Shadertoy Base Source: https://www.shadertoy.com/view/XlKfDz
shader_type canvas_item;

uniform float factor = 200.0;
uniform float fps_limit = 240.0;
uniform sampler2D gradient_texture: filter_nearest;

float rand(vec2 n) {
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p){
	vec2 ip = floor(p);
	vec2 u = fract(p);
	u = u*u*(3.0-2.0*u);

	float res = mix(
		mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
		mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
	return res*res;
}

void fragment()
{
	vec2 res = (1.0/SCREEN_PIXEL_SIZE);
	vec2 st = FRAGCOORD.xy/res.xy;
	st.y *= -res.y/res.x;
	st *= 21.3;

	float x = factor * noise(st + vec2(0, round(TIME*fps_limit)/fps_limit)) * fract(st.y - 0.45);

	COLOR = texture(gradient_texture, vec2(x, 0.5));
}