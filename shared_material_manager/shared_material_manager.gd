extends Node

export var _money_material : SpatialMaterial

var view_tex : ViewportTexture

onready var money_viewport := $money_viewport as Viewport

func _ready():
	view_tex = money_viewport.get_texture()
	
	_money_material.albedo_texture = view_tex

func get_money_material() -> SpatialMaterial:
	return _money_material
