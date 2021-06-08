shader_type particles;

//The radius around the origin in which particles can spawn
uniform float spawn_radius = 2.0;

//The radius around the line in which particles should begin to move
uniform float avoidance_radius = 2.0;
//The speed at which particles should move away from the line
uniform float avo_speed = 1.0;

uniform float rotation_over_time = 2.0;

//Scale of the particles
uniform float scale = 3.0;

//Defines the line in 3D space that the particles try to avoid
uniform vec3 ray_start;
uniform vec3 ray_normal;

//Generates a random float from a seed. Taken from the official Godot docs.
float rand_from_seed(in uint seed) {
  int k;
  int s = int(seed);
  if (s == 0)
    s = 305420679;
  k = s / 127773;
  s = 16807 * (s - k * 127773) - 2836 * k;
  if (s < 0)
    s += 2147483647;
  seed = uint(s);
  return float(seed % uint(65536)) / 65535.0;
}

uint hash(uint x) {
  x = ((x >> uint(16)) ^ x) * uint(73244475);
  x = ((x >> uint(16)) ^ x) * uint(73244475);
  x = (x >> uint(16)) ^ x;
  return x;
}

//Distance squared
float dist_squared(vec3 v1, vec3 v2){
	return (v1.x - v2.x) + (v1.y - v2.y) + (v1.z - v2.z);
}

//Returns the closest point on a line defined by a point on the line and a normal
vec3 closest_point_to_line(vec3 point, vec3 line_begin, vec3 line_normal){
	vec3 begin_to_point_normal = normalize(point - line_begin);
	float dist_along_normal = dot(line_normal, begin_to_point_normal) * distance(line_begin, point);
	return line_begin + line_normal * dist_along_normal;
}

//Generates a rotation matrix around an axis by angle
//http://www.neilmendoza.com/glsl-rotation-about-an-arbitrary-axis/
mat4 rotation_matrix(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;
    
    return mat4(vec4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0),
                vec4(oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0),
                vec4(oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0),
                vec4(0.0,                                0.0,                                0.0,                                1.0));
}

void vertex(){
	if(RESTART){
		//Random seeds for spawn initialization
		uint alt_seed1 = hash(NUMBER + uint(1) + RANDOM_SEED);
		uint alt_seed2 = hash(NUMBER + uint(27) + RANDOM_SEED);
		uint alt_seed3 = hash(NUMBER + uint(43) + RANDOM_SEED);
		uint alt_seed4 = hash(NUMBER + uint(111) + RANDOM_SEED);
		uint alt_seed5 = hash(NUMBER + uint(2) + RANDOM_SEED);
		uint alt_seed6 = hash(NUMBER + uint(54) + RANDOM_SEED);
		uint alt_seed7 = hash(NUMBER + uint(99) + RANDOM_SEED);
		uint alt_seed8 = hash(NUMBER + uint(101) + RANDOM_SEED);
		
		//Set the custom to TIME so we can check time difference between frames (the delta time)
		CUSTOM.y = TIME;
		
		//Spawn in a random position around the origin
		vec3 position = vec3(rand_from_seed(alt_seed2) * 2.0 - 1.0, rand_from_seed(alt_seed3) * 2.0 - 1.0, rand_from_seed(alt_seed4) * 2.0 - 1.0);
		TRANSFORM[3].xyz = position * spawn_radius;
		
		//Generates a random basis to define the particle's spawn rotation
		vec3 up = vec3(rand_from_seed(alt_seed1) * 2.0 - 1.0, rand_from_seed(alt_seed4) * 2.0 - 1.0, rand_from_seed(alt_seed8) * 2.0 - 1.0);
		vec3 rand_point = vec3(rand_from_seed(alt_seed5) * 3.0 - 1.0, rand_from_seed(alt_seed6) * 3.0 - 1.0, rand_from_seed(alt_seed7) * 3.0 - 1.0);
		vec3 right = normalize(rand_point - closest_point_to_line(rand_point, position, up));
		vec3 forward = cross(up, right);
		
		//Adjust basis by scale
		TRANSFORM[0].xyz = right * scale;
		TRANSFORM[1].xyz = up * scale;
		TRANSFORM[2].xyz = forward * scale;
	}else{
		float delta = TIME - CUSTOM.y;
		vec3 pos = TRANSFORM[3].xyz;
		vec3 closest = closest_point_to_line(pos, ray_start, ray_normal);
		
		VELOCITY.y = -9.81;
		
		//If we're close enough to the line, push away from it
		if(dist_squared(pos, closest) < avoidance_radius * avoidance_radius){
			vec3 norm = normalize(pos - closest);
			VELOCITY += norm * avo_speed * delta;
		}
		
		//Rotate around the right axis
		TRANSFORM = TRANSFORM * rotation_matrix(normalize(TRANSFORM[0].xyz), rotation_over_time * delta);
		
		//Update our custom so we can compare TIME values next frame again
		CUSTOM.y = TIME;
	}
}