extends Spatial

export var speed = 20.0

func _process(delta):
	rotate_y(deg2rad(speed) * delta);
