extends Interactive
class_name Pickable

@export var item := "flashlight"
@export var pickable := true

func use():
	return super()

func pickup():
	rpc("_pickup")
	
@rpc("any_peer","call_local","unreliable_ordered")
func _pickup():
	queue_free()
	return Relations.get_item(item)

func in_hand():
	rpc("_in_hand")

@rpc("any_peer","call_local","unreliable_ordered")
func _in_hand():
	pickable = false
	InstanceMesh.layers = 32

func looked_at():
	if pickable:
		super()
