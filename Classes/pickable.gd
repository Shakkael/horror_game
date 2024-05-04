extends Interactive
class_name Pickable

@export var item := "flashlight"

func pickup():
	queue_free()
	return Relations.get_item(item)

func use():
	pass

func in_hand():
	InstanceMesh.layers = 32
