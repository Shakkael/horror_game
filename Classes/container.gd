extends Destructible
class_name ContainerInt

@export_group("Iventory")
@export var inventory : Inventory = preload("res://Items/empty_inventory.tres")
@export var inventory_name := "Placeholder name"

func get_inv():
	return [inventory, inventory_name]
