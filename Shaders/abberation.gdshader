// chromatic aberration
//---------------------------------

shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;

uniform vec2 r_displacement = vec2(3.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(-3.0, 0.0);
uniform lowp float scale : hint_range(0.0, 3.0);


void fragment()
{
	
    vec2 center = vec2(0.5, 0.5);  // Center of the screen
    vec2 uvs = SCREEN_UV;
    
    // Calculate the distance of the current pixel from the center of the screen
    float distance2 = distance(uvs, center);
	
	float r = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*r_displacement*distance2*scale), 0.0).r;
	float g = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*g_displacement*distance2*scale), 0.0).g;
	float b = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE*b_displacement*distance2*scale), 0.0).b;
	
	COLOR = vec4(r, g, b, 1.0);
}