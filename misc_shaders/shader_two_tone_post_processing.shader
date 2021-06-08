//A simple post processing shader that draws the scene using unshaded colors.
shader_type canvas_item;

uniform vec4 background_color : hint_color;
uniform vec4 obj_color : hint_color;

void fragment(){
	vec4 c = texture(TEXTURE, UV);
	COLOR.rgb = c.a == 0.0 || c.rgb == vec3(0.0) ? background_color.rgb : obj_color.rgb;
}