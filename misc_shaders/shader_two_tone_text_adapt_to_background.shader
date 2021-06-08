shader_type canvas_item;

uniform vec4 standard_color : hint_color;
uniform vec4 contrast_color : hint_color;

void fragment(){
	COLOR.a = texture(TEXTURE, UV).a;
	COLOR.rgb = texture(SCREEN_TEXTURE, SCREEN_UV).rgb == vec3(0.0) ? standard_color.rgb : contrast_color.rgb;
}