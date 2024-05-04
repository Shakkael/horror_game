// Huge thanks to godotshader.com users
shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_default_transparent, filter_linear;
uniform int amount = 40;

void fragment()
{
	vec2 grid_uv = round(SCREEN_UV * float(amount)) / float(amount);

	vec4 text = texture(SCREEN_TEXTURE, grid_uv);
	
	COLOR = text;
}