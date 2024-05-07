extends Destructible
class_name ContainerInt

@export_group("Iventory")
@export var inventory_name := "Placeholder name"
@export var inventory : Inventory = preload("res://Items/empty_inventory.tres")

@export var slots : Array[Item]
#Small rework?
func _ready():
	slots = inventory.slots

func get_inv():
	return [inventory, inventory_name]
