extends Node

export var path_to_mesh : NodePath

func _ready():
	var n = get_node_or_null(path_to_mesh) as GeometryInstance
	
	if n != null:
		n.material_override = SharedMaterialManager.get_money_material()
