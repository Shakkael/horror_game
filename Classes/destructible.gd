extends Interactive
class_name Destructible

@export var destructible := false
@export_group("Objects")
@export var to_become : PackedScene
@export var to_spawn : PackedScene
@export_group("Items")
@export var to_drop : Item
