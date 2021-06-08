extends MeshInstance

func _ready():
	material_override = SharedMaterialManager.get_money_material()
