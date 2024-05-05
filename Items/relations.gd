extends Node

var items = {
	"flashlight" : preload("res://Items/Inventory/flashlight.tres")
}

var objects = {
	"flashlight" : preload("res://Items/Hand/flashlight.tscn")
}

func get_item(item_name):
	return items[item_name]

func get_obj(obj_name):
	return objects[obj_name]
