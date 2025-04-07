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

	float steps = step(0.0005, noise(st + vec2(0, TIME)) * fract(st.y - 0.45));
	float steps2 = step(0.001, noise(st + vec2(0, TIME)) * fract(st.y - 0.45));
	float steps3 = step(0.003, noise(st + vec2(0, TIME)) * fract(st.y - 0.45));
    float steps4 = step(0.005, noise(st + vec2(0, TIME)) * fract(st.y - 0.45));

    vec3 color;
    //if (steps == 0.0) {
        ////COLOR = vec4(0.266,0.367,0.305, 1.0);
		//COLOR = vec4(0.508,0.418,0.141, 1.0);//light brown
    //} else 
	if (steps2 == 0.0){
        //COLOR = vec4(0.121,0.168,0.141, 0.9);//deep sage
        //COLOR = vec4(0.391,0.305,0.109, 0.9);//brown
		//COLOR = vec4(0.266,0.367,0.305, 1.0);//sage
		COLOR = vec4(0.121,0.168,0.141, 1.0);//deep sage
    } else 
	if (steps3 == 0.0){
        //COLOR = vec4(0.043,0.078,0.070, 0.8);
        //COLOR = vec4(0.270,0.188,0.074, 0.8);//dark brown
		//COLOR = vec4(0.660, 0.668, 0.227, 0.9);//mustard
		//COLOR = vec4(0.266,0.367,0.305, 1.0);//sage
		COLOR = vec4(0.043,0.078,0.070, 0.9);//midnight green
	} else if (steps4 == 0.0){
        //COLOR = vec4(0.043,0.078,0.070, 0.8);//midnight green
        //COLOR = vec4(0.168,0.066,0.027, 0.7);//rich earth
		//COLOR = vec4(0.520, 0.699, 0.586, 0.8);//light sage
		//COLOR = vec4(0.121,0.168,0.141, 0.9);//deep sage
		COLOR = vec4(0.266,0.367,0.305, 0.7);//sage
    } else {
        COLOR = vec4(0.0,0.0,0.0, 0.0);
    }
    
    //COLOR = vec4(color.xyz,length(color));
}