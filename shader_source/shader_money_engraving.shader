//Adapted from Texturelabs' photoshop tutorial: https://www.youtube.com/watch?v=GLRDCn5UMOo&list=PLJ181445jiU94JmpnmCWCNihi2TdhC_8o&index=223&t=137s
shader_type canvas_item;

uniform sampler2D gradient_map:hint_albedo;

uniform float fill_size = 100.0;
uniform float wavelength = 20.0;
uniform float amplitude = 0.1;

uniform float ripple_wavelength = 10.0;
uniform float ripple_amplitude_angle = 5.0;

uniform float grey_level_min = 0.0;
uniform float grey_level_max = 1.0;

uniform float engrave_opacity = 0.88;

float get_sin_fill(vec2 uv){
	float s = ((sin(uv.x * wavelength) + 1.0) / 2.0) * amplitude;
	return fract((1.0 - uv.y + s) * fill_size);
}

vec2 rotate_vector(vec2 v, float angle){
	return vec2(v.x * cos(angle) - v.y * sin(angle), v.x * sin(angle) + v.y * cos(angle));
}

vec2 get_ripple_coord(vec2 uv){
	float dist = distance(uv, vec2(0.5));
	float s = sin(dist * ripple_wavelength);
	
	float angle = radians(ripple_amplitude_angle) * s;
	
	return rotate_vector(uv - vec2(0.5), angle) + vec2(0.5);
}

float rgb_to_grey(vec3 col){
	float third = 1.0 / 3.0;
	return clamp(col.r * third + col.g * third + col.b * third, 0.0, 1.0);
}

float hard_mix(float val1, float val2){
	return float((val1 + val2) >= 1.0);
}

//https://gist.github.com/aferriss/9be46b6350a08148da02559278daa244
float level_range(float color, float min_input, float max_input){
    return min(max(color - min_input, 0.0) / (max_input - min_input), 1.0);
}

void fragment(){
	vec2 rippled_uv = get_ripple_coord(UV);
	float xyratio = TEXTURE_PIXEL_SIZE.x / TEXTURE_PIXEL_SIZE.y;
	float fill_pattern = get_sin_fill(rippled_uv); //Get the regular fill pattern
	float rotated_sin_fill = get_sin_fill(vec2(rippled_uv.y * xyratio, rippled_uv.x / xyratio)); //Get the fill pattern rotated by 90 degrees, adjusting for the non-square aspect ratio of our UVs
	
	float test_mix = mix(fill_pattern, 0.5, rotated_sin_fill);
	
	vec3 tex_col = texture(TEXTURE, UV).rgb;
	
	float grey = level_range(rgb_to_grey(tex_col), grey_level_min, grey_level_max);
	
	float engrave_val = hard_mix(test_mix, grey);
	float final = mix(grey, engrave_val, engrave_opacity);
	
	COLOR.rgb = texture(gradient_map, vec2(final, 0.5)).rgb;
}