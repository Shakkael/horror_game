@tool
extends EditorPlugin

const MyPlugin = preload("res://addons/interactives/gizmo.gd")
var gizmo_plugin = MyPlugin.new()

func _enter_tree():
	add_node_3d_gizmo_plugin(gizmo_plugin)
func _exit_tree():
	remove_node_3d_gizmo_plugin(gizmo_plugin)
