shader_type spatial;

uniform bool blink = false;

void fragment() {
	ALPHA = 0.;
	ALBEDO = vec3(1.,1.,1.);
	if(blink){
		ALPHA = clamp(sin(TIME*4.)/8.+0.15, 0., .25);
	}
	}