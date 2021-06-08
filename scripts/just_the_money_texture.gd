extends Control

onready var tex := $TextureRect as TextureRect

func _ready():
	tex.texture = SharedMaterialManager.view_tex
