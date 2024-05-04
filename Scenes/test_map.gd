extends Node3D

func _ready():
	for child : MeshInstance3D in $Collidable.get_children():
		child.create_convex_collision()
		child.get_child(0).collision_layer = 255
		child.get_child(0).collision_mask = 255
