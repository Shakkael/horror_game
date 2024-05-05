extends Interactive
class_name Pickable

@export var item := "flashlight"
@export var pickable := true

func use():
	return super()

func pickup():
	queue_free()
	return Relations.get_item(item)

func in_hand():
	pickable = false
	InstanceMesh.layers = 32

func looked_at():
	if pickable:
		super()
