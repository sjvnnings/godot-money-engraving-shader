extends Spatial

onready var cam := $Camera as Camera
onready var particles := $Particles as Particles

func _process(delta):
	var origin := cam.project_ray_origin(get_viewport().get_mouse_position())
	var normal := cam.project_ray_normal(get_viewport().get_mouse_position())
	
	var mat := particles.process_material as ShaderMaterial
	mat.set_shader_param("ray_start", origin)
	mat.set_shader_param("ray_normal", normal)
