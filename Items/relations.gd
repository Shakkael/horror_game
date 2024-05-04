extends Node

var items = {
	"flashlight" : preload("res://Items/Inventory/flashlight.tres")
}

var objects = {
	"flashlight" : preload("res://Items/Hand/flashlight.tscn")
}

func get_item(name):
	return items[name]

func get_obj(name):
	return objects[name]
