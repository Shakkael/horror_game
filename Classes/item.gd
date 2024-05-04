extends Resource
class_name Item

@export var id := 0
@export var name := "Placeholder"
@export var desc := "Placeholder Description"
@export var texture := preload("res://Graphics/Sprites/HUD/Placeholder.png")

@export_group("Properties")
@export_subgroup("Object")
@export var object_to_spawn := 'flashlight'
@export_subgroup("Healing")
@export_flags("Heals") var heals := 0
@export var hp_heal := 0

func use(target):
	if heals and target.has_method('heal'):
		target.heal(hp_heal)
	
func take(target, cur_item):
	if cur_item == null or cur_item.name != name:
		# Item is taken
		target.set_cur_item(self)
	else:
		# Item is hidden
		target.set_cur_item(null)
