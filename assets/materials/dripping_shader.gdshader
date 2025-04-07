//Original Shadertoy Base Source: https://www.shadertoy.com/view/XlKfDz

shader_type canvas_item;

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

	float steps = step(0.001, noise(st + TIME) * fract(st.y - 0.45));
	float steps2 = step(0.003, noise(st + TIME) * fract(st.y - 0.45));
    float steps3 = step(0.01, noise(st + TIME) * fract(st.y - 0.45));

    vec3 color;
    if (steps == 0.0) {
        COLOR = vec4(0.266,0.367,0.305, 1.0);

    } else if (steps2 == 0.0){
        COLOR = vec4(0.121,0.168,0.141, 0.9);

    } else if (steps3 == 0.0){
        COLOR = vec4(0.043,0.078,0.070, 0.8);

    } else {
        COLOR = vec4(0.0,0.0,0.0, 0.0);
    }
    
    //COLOR = vec4(color.xyz,length(color));
}