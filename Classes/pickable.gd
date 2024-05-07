extends Interactive
class_name Pickable

@export var item := "flashlight"
@export var pickable := true

func use():
	return super()

func pickup():
	rpc("_pickup")
	return Relations.get_item(item)
	
@rpc("any_peer","call_local","unreliable_ordered")
func _pickup():
	call_deferred("queue_free")

@rpc("any_peer","call_local","unreliable_ordered")
func in_hand():
	pickable = false
	InstanceMesh.layers = 32

func looked_at():
	if pickable:
		super()
